FROM alpine:3.21.2

RUN apk -Uuv add curl ca-certificates coreutils jq bash

COPY src/run.sh /bin/

ENTRYPOINT ["/bin/run.sh"]
