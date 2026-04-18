# syntax=docker/dockerfile:1.7

ARG HUGO_VERSION=0.151.0
ARG HUGO_BASEURL=https://klykken.com
ARG HUGO_ENV=production

FROM hugomods/hugo:exts-${HUGO_VERSION} AS builder
ARG HUGO_BASEURL
ARG HUGO_ENV
WORKDIR /src
COPY . .
RUN hugo --gc --minify --baseURL "${HUGO_BASEURL}" --environment "${HUGO_ENV}"

FROM nginx:1.27-alpine AS runtime
RUN rm -rf /usr/share/nginx/html/* \
 && printf 'server {\n  listen 8080 default_server;\n  server_name _;\n  root /usr/share/nginx/html;\n  index index.html;\n  location / { try_files $uri $uri/ $uri/index.html =404; }\n  error_page 404 /404.html;\n}\n' > /etc/nginx/conf.d/default.conf
COPY --from=builder /src/public /usr/share/nginx/html
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1:8080/ >/dev/null || exit 1
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
