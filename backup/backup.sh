#!/bin/bash
# Этот скрипт бэкапит только Grafana volume с дашбордами и настройками

# Настройка переменных окружения для cron
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
export HOME=/home/ubuntu

# === КОНФИГУРАЦИЯ ===
BUCKET="portfolio-site-logs-from-loki"    # S3 bucket для бэкапов
DATE=$(date +%Y%m%d-%H%M%S)               # Текущая дата и время
VOLUME_NAME="portfolio-site_grafana_data" # Имя volume Grafana (проверь точное имя!)
LOG_FILE="/var/log/backup-grafana.log"    # Файл логов

echo "$(date) - 🔍 Starting Grafana volume backup check..." >> $LOG_FILE

# 1. Проверяем что AWS CLI доступен
if ! command -v aws &> /dev/null; then
    echo "$(date) - ❌ AWS CLI not found" >> $LOG_FILE
    exit 1
fi

# 2. Проверяем доступ к S3
if ! aws s3 ls s3://$BUCKET/ > /dev/null 2>&1; then
    echo "$(date) - ❌ Cannot access S3 bucket" >> $LOG_FILE
    exit 1
fi

# 3. Проверяем что volume существует
if ! docker volume inspect $VOLUME_NAME > /dev/null 2>&1; then
    echo "$(date) - ❌ Volume $VOLUME_NAME not found" >> $LOG_FILE
    # Покажем какие volumes есть
    echo "$(date) - Available volumes:" >> $LOG_FILE
    docker volume ls >> $LOG_FILE
    exit 1
fi

# 4. Проверяем последний бэкап Grafana
LAST_BACKUP_DATE=$(aws s3 ls s3://$BUCKET/backups/grafana-volume/ 2>/dev/null | 
                   grep .tar.gz | 
                   awk '{print $1}' | 
                   sort | 
                   tail -1)

TODAY=$(date +%Y-%m-%d)

# 5. Если сегодня уже есть бэкап - выходим
if [ "$LAST_BACKUP_DATE" == "$TODAY" ]; then
    echo "$(date) - ✅ Grafana backup already exists for today: $TODAY" >> $LOG_FILE
    exit 0
fi

echo "$(date) - 🚀 Starting new Grafana volume backup..." >> $LOG_FILE

# === СОЗДАНИЕ БЭКАПА VOLUME ===

# 6. Создаем бэкап volume с помощью Docker
# Запускаем временный контейнер который архивирует volume
docker run --rm \
  -v $VOLUME_NAME:/source:ro \          # Монтируем volume только для чтения
  -v /tmp:/backup \                     # Монтируем папку для бэкапа
  alpine \                              # Используем легкий Alpine Linux
  tar czf /backup/grafana-volume-$DATE.tar.gz -C /source .  # Архивируем всё из volume
# --rm = удалить контейнер после выполнения
# :ro = read-only (только чтение) чтобы не повредить данные

# 7. Проверяем что архив создался
if [ ! -f "/tmp/grafana-volume-$DATE.tar.gz" ]; then
    echo "$(date) - ❌ Failed to create Grafana volume archive" >> $LOG_FILE
    exit 1
fi

# 8. Проверяем размер архива
ARCHIVE_SIZE=$(ls -lh /tmp/grafana-volume-$DATE.tar.gz | awk '{print $5}')
echo "$(date) - 📦 Archive created: $ARCHIVE_SIZE" >> $LOG_FILE

# === ЗАГРУЗКА В S3 ===

# 9. Загружаем архив в S3
if aws s3 cp /tmp/grafana-volume-$DATE.tar.gz s3://$BUCKET/backups/grafana-volume/ > /dev/null 2>&1; then
    echo "$(date) - ✅ Grafana volume uploaded to S3: grafana-volume-$DATE.tar.gz" >> $LOG_FILE
    
    # 10. Проверяем что файл в S3
    if aws s3 ls s3://$BUCKET/backups/grafana-volume/grafana-volume-$DATE.tar.gz > /dev/null 2>&1; then
        echo "$(date) - ✅ Grafana backup verified in S3" >> $LOG_FILE
    else
        echo "$(date) - ❌ Grafana backup not found in S3 after upload" >> $LOG_FILE
    fi
else
    echo "$(date) - ❌ Failed to upload Grafana volume to S3" >> $LOG_FILE
    exit 1
fi

# === ОЧИСТКА ===

# 11.Удаляем временный архив
rm -f /tmp/grafana-volume-$DATE.tar.gz

echo "$(date) - 🎉 GRAFANA VOLUME BACKUP COMPLETED SUCCESSFULLY" >> $LOG_FILE
echo "$(date) - 💾 S3 Path: s3://$BUCKET/backups/grafana-volume/grafana-volume-$DATE.tar.gz" >> $LOG_FILE