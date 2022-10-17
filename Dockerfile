FROM alpine:3.14

RUN apk update \
    && apk add --no-cache openssl curl yq bash \
    && mkdir -p /usr/local/bin/ \
    && cd /usr/local/bin/ \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x /usr/local/bin/kubectl

ADD --chown=root:root ./entrypoint.sh ./entrypoint.sh

RUN chmod +x ./entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh"]

CMD [ "echo", "$1" ]