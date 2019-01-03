FROM alpine:3.8
MAINTAINER iamfat@gmail.com

ADD setup.sh /setup.sh

RUN apk add --no-cache bash curl xmlstarlet fastjar && rm -rf /var/cache/apk/*

WORKDIR /container
CMD ["/setup.sh"]
