FROM jeffersonlmartins/github-cli:base-1.0

LABEL maintainer="Jefferson L. Martins"
LABEL version="1.0"
LABEL description="Image Docker to GitHub CLI (gh)"

WORKDIR /

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
