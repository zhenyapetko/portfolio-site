# Stage 1: Build Hugo site
FROM debian:stable-slim AS builder

# Устанавливаем необходимые пакеты для Debian
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git wget tar ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



# --- Блок установки Hugo ---
ARG HUGO_VERSION="0.150.0"
ARG HUGO_PKG="hugo_extended_${HUGO_VERSION}_linux-amd64"
ARG HUGO_TARBALL="${HUGO_PKG}.tar.gz"
ARG HUGO_DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_TARBALL}"

WORKDIR /tmp
RUN wget -O "${HUGO_TARBALL}" "${HUGO_DOWNLOAD_URL}"
RUN tar -xzf "${HUGO_TARBALL}"
RUN mv hugo /usr/local/bin/hugo
RUN chmod +x /usr/local/bin/hugo
RUN rm "${HUGO_TARBALL}"

ENV PATH="/usr/local/bin:${PATH}"
# Копируем исходный код из хост-машины в /src в контейнере
COPY ./ /src
WORKDIR /src
# Инициализируем и обновляем подмодули Git.
RUN git submodule init && git submodule update --init --recursive

# Сборка сайта Hugo.
RUN hugo --gc --minify

# Stage 2: Простой HTTP-сервер на Python
FROM python:alpine

# Копируем собранный сайт
COPY --from=builder /src/public /app

WORKDIR /app

# Простой HTTP-сервер на порту 8000
EXPOSE 8000
CMD ["python", "-m", "http.server", "8000"]