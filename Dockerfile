# Stage 1: Build Hugo site
FROM debian:stable-slim AS builder

# Устанавливаем необходимые пакеты для Debian
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    tar \
    ca-certificates \
    build-essential \
    file \
    && rm -rf /var/lib/apt/lists/*

# --- Блок установки Hugo ---
ARG HUGO_VERSION="0.150.0"
ARG HUGO_PKG="hugo_extended_${HUGO_VERSION}_linux-amd64"
ARG HUGO_TARBALL="${HUGO_PKG}.tar.gz"
ARG HUGO_DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_TARBALL}"

WORKDIR /tmp
RUN wget -O "${HUGO_TARBALL}" "${HUGO_DOWNLOAD_URL}"
RUN ls -la "${HUGO_TARBALL}" || (echo "ERROR: Hugo tarball not found!" && exit 1)
RUN tar -xzf "${HUGO_TARBALL}"
RUN ls -la hugo || (echo "ERROR: Hugo executable not found after extraction!" && exit 1)
RUN file hugo
RUN mv hugo /usr/local/bin/hugo
RUN chmod +x /usr/local/bin/hugo
RUN rm "${HUGO_TARBALL}"
WORKDIR /
RUN ls -la /usr/local/bin/hugo || (echo "ERROR: Hugo not in /usr/local/bin after mv!" && exit 1)
# ----------------------------------------

ENV PATH="/usr/local/bin:${PATH}"

# Проверяем, что Hugo запускается (это уже успешно!)
RUN hugo version || (echo "ERROR: hugo version command failed (Hugo still not found or executable failed)!" && exit 1)

# Копируем исходный код из хост-машины в /src в контейнере
# Убедитесь, что вы запускаете docker build из корневой папки вашего репозитория!
COPY . /src
WORKDIR /src

# Добавим ls для отладки конфигурации
RUN ls -la # Проверим, что config.toml и .git скопированы

# Инициализируем и обновляем подмодули Git.
# Если .git не скопирован, этот шаг выдаст ошибку.
RUN git submodule init && git submodule update --init --recursive

# Сборка сайта Hugo.
# PATH здесь не нужен, так как ENV PATH уже установлен.
RUN hugo --gc --minify --logLevel debug

# Stage 2: Fast and light Nginx for static site
FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html
COPY nginx/nginx.conf /etc/nginx/nginx.conf # Убедитесь, что nginx/nginx.conf существует в вашем проекте!
EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]