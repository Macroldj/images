FROM 100.64.10.37/security/jj-code-web:v3.0.1

RUN mkdir /etc/nginx/cert
COPY bj.tkoffice.cn.key /etc/nginx/cert/
COPY bj.tkoffice.cn.pem /etc/nginx/cert/
COPY nginx.conf /etc/nginx/nginx.conf

HEALTHCHECK --interval=30s --timeout=10s --retries=6 \
  CMD curl -fs http://localhost/ || exit 1