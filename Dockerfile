# Stage 1: Build Hugo site
FROM alpine:latest AS builder

# Устанавливаем Hugo extended версию
RUN apk add --no-cache git wget tar
RUN wget -O hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v0.150.0/hugo_extended_0.150.0_linux-amd64.tar.gz
RUN tar -xzf hugo.tar.gz
RUN ls -la  # Посмотрим что распаковалось
RUN find . -name "hugo" -type f  # Найдем файл hugo
RUN mv hugo /usr/local/bin/hugo || find . -name "hugo" -type f -exec mv {} /usr/local/bin/hugo \;
RUN chmod +x /usr/local/bin/hugo
RUN rm -rf hugo.tar.gz *LICENSE* *README*
RUN /usr/local/bin/hugo version

COPY . /src
WORKDIR /src
RUN ls -la themes/  # Debug: проверить что themes/beautifulhugo exists
RUN git submodule init || true && git submodule update --init --recursive || true
RUN hugo --gc --minify --logLevel debug

# Stage 2: Same
FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html

COPY nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]