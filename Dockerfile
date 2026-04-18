# syntax=docker/dockerfile:1.7

ARG HUGO_VERSION=0.151.0
ARG HUGO_BASEURL=https://klykken.com

FROM hugomods/hugo:exts-${HUGO_VERSION} AS builder
WORKDIR /src
COPY . .
ARG HUGO_ENV=production
RUN hugo --gc --minify \
      --baseURL "https://__BASE_URL__/" \
      --environment "${HUGO_ENV}"

FROM nginx:1.27-alpine AS runtime
RUN apk add --no-cache tini
RUN rm -rf /usr/share/nginx/html/* \
 && printf 'server {\n  listen 8080 default_server;\n  server_name _;\n  root /usr/share/nginx/html;\n  index index.html;\n  location / { try_files $uri $uri/ $uri/index.html =404; }\n  error_page 404 /404.html;\n}\n' > /etc/nginx/conf.d/default.conf
COPY --from=builder /src/public /var/www/site.template
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENV BASE_URL=http://localhost:8080
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1:8080/ >/dev/null || exit 1
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
