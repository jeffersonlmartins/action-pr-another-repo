FROM alpine/git:latest

LABEL maintainer="Jefferson L. Martins"
LABEL version="1.0"
LABEL description="Image Docker to Github CLI (gh)"

ADD entrypoint.sh /entrypoint.sh

WORKDIR /

ENTRYPOINT [ "/entrypoint.sh" ]
