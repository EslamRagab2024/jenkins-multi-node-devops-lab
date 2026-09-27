FROM jenkins/ssh-agent:alpine

RUN apk add --no-cache docker-cli shadow \
    && groupadd -g 999 docker || true \
    && usermod -aG docker jenkins