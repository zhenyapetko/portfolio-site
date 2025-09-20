# Stage 1: Build Hugo site
FROM alpine:latest AS builder

RUN apk add --no-cache git wget tar libstdc++ libgcc bash # Добавил bash для удобства отладки

# --- Исправленный блок установки Hugo ---
# Задаем версию Hugo
ARG HUGO_VERSION="0.150.0"
ARG HUGO_PKG="hugo_extended_${HUGO_VERSION}_linux-amd64" # Имя пакета, которое будет в архиве
ARG HUGO_TARBALL="${HUGO_PKG}.tar.gz"                     # Полное имя архива
ARG HUGO_DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_TARBALL}"

# Скачиваем архив в текущий рабочий каталог
RUN wget -O ${HUGO_TARBALL} "${HUGO_DOWNLOAD_URL}" && \
    # Извлекаем содержимое архива. В результате появится каталог с именем HUGO_PKG
    tar -xzf ${HUGO_TARBALL} && \
    # Перемещаем исполняемый файл 'hugo' ИЗ извлеченного каталога в /usr/local/bin
    mv ${HUGO_PKG}/hugo /usr/local/bin/hugo && \
    # Делаем его исполняемым
    chmod +x /usr/local/bin/hugo && \
    # Удаляем скачанный архив и извлеченный каталог
    rm -r ${HUGO_TARBALL} ${HUGO_PKG}
# ----------------------------------------

# Явно устанавливаем PATH, так как alpine:latest может не включать /usr/local/bin по умолчанию
# Или чтобы быть уверенным в последовательности PATH
ENV PATH="/usr/local/bin:${PATH}"

# Проверяем, что Hugo установлен и находится в PATH
RUN hugo version

    
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