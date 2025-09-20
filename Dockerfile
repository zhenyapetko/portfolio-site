# Stage 1: Build Hugo site
FROM alpine:latest AS builder

RUN apk add --no-cache git wget tar libstdc++ libgcc
RUN wget -O hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v0.150.0/hugo_extended_0.150.0_linux-amd64.tar.gz && \
    tar -xzf hugo.tar.gz && \
    mv hugo /usr/local/bin/hugo && \
    chmod +x /usr/local/bin/hugo && \
    rm hugo.tar.gz

    
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