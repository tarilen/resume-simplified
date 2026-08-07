FROM nginx:1.31-alpine

COPY site/ /usr/share/nginx/html/


EXPOSE 80