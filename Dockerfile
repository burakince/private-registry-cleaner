FROM alpine:3.18.0

RUN apk -Uuv add curl ca-certificates coreutils jq bash

COPY run.sh /bin/

ENTRYPOINT /bin/run.sh
