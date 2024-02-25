FROM nginx:mainline-alpine
ENV TZ Asia/Tokyo

RUN apk update

COPY key/ /etc/nginx/key/
COPY templates/ /etc/nginx/templates/