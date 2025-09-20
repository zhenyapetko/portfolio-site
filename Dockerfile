# Stage 1: Build Hugo site
FROM alpine:latest AS builder

RUN apk add --no-cache git ca-certificates wget

# Скачать latest Hugo extended с GitHub
RUN wget -O hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v0.150.0/hugo_extended_0.150.0_linux-amd64.tar.gz

# Распаковать и установить
RUN tar -xzf hugo.tar.gz \
    && chmod +x hugo \
    && mv hugo /usr/local/bin/ \
    && rm hugo.tar.gz


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