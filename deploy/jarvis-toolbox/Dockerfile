FROM node:22-bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates curl jq python3 \
 && rm -rf /var/lib/apt/lists/*

RUN npm install -g \
    n8n-doctor@0.1.0 \
    n8nac@2.7.0

WORKDIR /workspace
ENTRYPOINT ["/bin/bash", "-lc"]
