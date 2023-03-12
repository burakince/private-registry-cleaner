FROM alpine:3.17.2

RUN apk -Uuv add curl ca-certificates coreutils jq bash

COPY run.sh /bin/

ENTRYPOINT /bin/run.sh
