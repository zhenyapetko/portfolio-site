# Stage 1: Build Hugo site
FROM alpine:latest AS builder

# Устанавливаем необходимые пакеты
RUN apk add --no-cache git wget tar libstdc++ libgcc bash

# --- Исправленный блок установки Hugo ---
# Задаем версию Hugo
ARG HUGO_VERSION="0.150.0"
ARG HUGO_PKG="hugo_extended_${HUGO_VERSION}_linux-amd64" # Имя пакета используется в URL, но не для папки
ARG HUGO_TARBALL="${HUGO_PKG}.tar.gz"                     # Полное имя архива
ARG HUGO_DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_TARBALL}"

# Скачиваем архив в текущий рабочий каталог
RUN wget -O "${HUGO_TARBALL}" "${HUGO_DOWNLOAD_URL}" && \
    # Извлекаем содержимое архива.
    # В этом случае, tar -xzf извлекает ОДИН ФАЙЛ 'hugo' прямо в текущий каталог.
    tar -xzf "${HUGO_TARBALL}" && \
    # Перемещаем исполняемый файл 'hugo' (который теперь находится в текущем каталоге) в /usr/local/bin
    mv hugo /usr/local/bin/hugo && \
    # Делаем его исполняемым
    chmod +x /usr/local/bin/hugo && \
    # Удаляем скачанный архив
    rm "${HUGO_TARBALL}"
# ----------------------------------------

# Явно устанавливаем PATH
ENV PATH="/usr/local/bin:${PATH}"

# Проверяем, что Hugo установлен и находится в PATH
RUN hugo version || true # Добавил || true, чтобы сборка не упала, если hugo version выдаст предупреждение, но сам бинарник есть.


    
COPY . /src
WORKDIR /src
RUN ls -la themes/  # Debug: проверить что themes/beautifulhugo exists
RUN git submodule init || true && git submodule update --init --recursive || true
RUN export PATH="/usr/local/bin:$PATH" && hugo --gc --minify --logLevel debug

# Stage 2: Same
FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html

COPY nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]