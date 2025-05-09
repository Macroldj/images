ARG NGINX_VER

FROM nginx:${NGINX_VER}

# setting timezone shanghai
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone