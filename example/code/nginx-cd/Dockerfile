FROM 100.64.10.37/security/jj-code-web:v2.0.2

COPY nginx.conf /etc/nginx/nginx.conf

HEALTHCHECK --interval=30s --timeout=10s --retries=6 \
  CMD curl -fs http://localhost/ || exit 1