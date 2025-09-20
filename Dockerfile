# Stage 1: Build Hugo site
FROM alpine:latest AS builder

# Устанавливаем необходимые пакеты
RUN apk add --no-cache git wget tar libstdc++ libgcc bash file

# --- Блок установки Hugo с отладкой ---
ARG HUGO_VERSION="0.150.0"
ARG HUGO_PKG="hugo_extended_${HUGO_VERSION}_linux-amd64"
ARG HUGO_TARBALL="${HUGO_PKG}.tar.gz"
ARG HUGO_DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_TARBALL}"

# 1. Скачиваем архив
RUN wget -O "${HUGO_TARBALL}" "${HUGO_DOWNLOAD_URL}"

# 2. Проверяем, что архив скачался
RUN ls -la "${HUGO_TARBALL}" || (echo "ERROR: Hugo tarball not found!" && exit 1)

# 3. Извлекаем. Здесь мы узнаем, как именно распаковывается архив.
# Мы извлечем его и посмотрим, что внутри.
# Затем предполагаем, что исполняемый файл "hugo" находится прямо в корне архива.
RUN tar -xzf "${HUGO_TARBALL}"

# 4. Проверяем, что исполняемый файл 'hugo' появился в текущем каталоге
RUN ls -la hugo || (echo "ERROR: Hugo executable not found after extraction!" && exit 1)
RUN file hugo # Этот шаг поможет понять, что это за файл (для отладки)

# 5. Перемещаем исполняемый файл 'hugo' в /usr/local/bin
RUN mv hugo /usr/local/bin/hugo

# 6. Делаем его исполняемым
RUN chmod +x /usr/local/bin/hugo

# 7. Убеждаемся, что bin удален (архив)
RUN rm "${HUGO_TARBALL}"

# 8. Проверяем, что Hugo теперь находится в /usr/local/bin
RUN ls -la /usr/local/bin/hugo || (echo "ERROR: Hugo not in /usr/local/bin after mv!" && exit 1)
# ----------------------------------------

# Явно устанавливаем PATH. Эта форма универсальнее и безопаснее.
ENV PATH="/usr/local/bin:${PATH}"

# Проверяем, что Hugo установлен и находится в PATH
RUN hugo version || (echo "ERROR: hugo version command failed (hugo not found in PATH or executable failed)!" && exit 1)



    
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