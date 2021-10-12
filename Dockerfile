FROM postgres:alpine

RUN apk --no-cache add bash fd
COPY backup.sh /backup.sh

ENTRYPOINT ["/backup.sh"]