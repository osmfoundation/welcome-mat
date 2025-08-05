# ---- Build Stage ----
FROM python:3.13-bookworm AS builder

# Install dependencies
RUN apt-get update && apt-get install -y build-essential git libcairo2-dev

WORKDIR /site

COPY requirements.txt /site/

# Install MkDocs and your theme/plugins
RUN pip install -r requirements.txt  --no-cache-dir

COPY . .

# Build the MkDocs site
RUN mkdocs build --strict --site-dir /output

RUN find /output -type f -size +512c \( -name "*.html" -o -name "*.css" -o -name "*.js" -o -name "*.xml" -o -name "*.json" -o -name "*.svg" -o -name "*.ttf" -o -name "*.woff2" -o -name "*.woff" -o -name "*.eot" -o -name "*.otf" -o -name "*.pbf" \) -print0 | xargs -0 -P4 --no-run-if-empty gzip -9k --force

# ---- Final Stage: Webserver ----
FROM ghcr.io/nginxinc/nginx-unprivileged:stable-alpine AS webserver

# Copy built site from builder stage
COPY --from=builder /output /usr/share/nginx/html

RUN echo "absolute_redirect off;" >/etc/nginx/conf.d/no-absolute_redirect.conf
RUN echo "gzip_static on; gzip_proxied any;" >/etc/nginx/conf.d/gzip_static.conf

RUN nginx -t

EXPOSE 8080