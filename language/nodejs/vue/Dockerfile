FROM node:18.14.0
RUN npm config set registry https://registry.npm.taobao.org
WORKDIR /home/www/express
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:1.21.1
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone
COPY --from=0 /home/www/express/dist/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf

HEALTHCHECK --interval=30s --timeout=10s --retries=6 \
  CMD curl -fs http://localhost/ || exit 1
