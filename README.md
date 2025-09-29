# 🚀 Portfolio Site - DevOps Project

> **Персональный сайт-портфолио с полным DevOps стеком**

[![Live Demo](https://img.shields.io/badge/Live%20Demo-e--petko.dev-blue?style=for-the-badge&logo=web)](https://e-petko.dev)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)

## 📋 О проекте

Это учебный DevOps проект, демонстрирующий полный цикл разработки и деплоя веб-приложения. От статического сайта до продакшн-среды с мониторингом и автоматизацией.

### 🎯 Что делает проект

- **Статический сайт** на Hugo
- **Автоматический деплой** в облако AWS
- **Мониторинг** всех сервисов в реальном времени
- **Логирование** и сбор метрик
- **SSL сертификаты** и безопасность

## 🛠️ Технологический стек

### Frontend
- **Hugo** - генератор статических сайтов
- **BeautifulHugo** - тема для Hugo

### Контейнеризация
- **Docker** - контейнеризация приложения
- **Docker Compose** - оркестрация сервисов

### Инфраструктура
- **Terraform** - создание облачной инфраструктуры
- **Ansible** - развертывание программного обеспечения
- **AWS EC2** - облачный сервер

### Мониторинг
- **Prometheus** - сбор метрик
- **Grafana** - визуализация данных
- **Loki** - сбор логов
- **Promtail** - агент сбора логов

### Прокси и безопасность
- **Nginx** - reverse proxy
- **Let's Encrypt** - SSL сертификаты

## 🏗️ Архитектура

Схема

```mermaid
flowchart TD
    A[Terraform] -->B
    C[Ansible] -->B(AWS EC2)
    L[Developer] -->M(GitHub) -->N(GitHub Action)-->B
    N -->I
    B --> E{NGINX}
    B -->Q[Loki: logs from Promtail]
    Q --> H
    E -->F[Website]
    E -->G[PROMETHEUS
    metrics from Node-exporter
    Blackbox-exporter]
    G --> H
    E -->H[Grafana]

    
    H -->I{Alert in Telegram}
    S{S3: Logs and Backup Grafana Volume}
```



После деплоя доступны:

- **Сайт:** https://e-petko.dev
- **Grafana:** https://grafana.e-petko.dev
- **Prometheus:** https://prometheus.e-petko.dev


## 📝 Что применяется

- **Контейнеризация** - Docker и Docker Compose
- **Infrastructure as Code** - Terraform
- **Configuration as Code** - Ansible
- **Мониторинг** - Prometheus, Grafana, Loki
- **Облачные технологии** - AWS EC2, S3
- **CI/CD** - GitHub Actions
- **Безопасность** - SSL, Security Groups

## 👨‍💻 Автор

**Петько Евгений** - Junior DevOps Engineer

- 📧 Email: zhen.petko@gmail.com
- 💼 LinkedIn: [zhenyapetko](https://linkedin.com/in/zhenyapetko)
- 🐙 GitHub: [zhenyapetko](https://github.com/zhenyapetko)

---
