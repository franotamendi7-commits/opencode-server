FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl ca-certificates git \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g opencode-ai

RUN printf '#!/bin/sh\nexit 0\n' > /usr/bin/xdg-open && chmod +x /usr/bin/xdg-open

RUN useradd -m -s /bin/bash opencode && mkdir -p /data/projects && chown -R opencode:opencode /data

USER opencode
WORKDIR /data

ENV HOME=/data
ENV OPENCODE_SERVER_PASSWORD=171171
ENV OPENCODE_MODEL=opencode/laguna-s-2.1-free

EXPOSE 8080

CMD ["sh", "-c", "\
  cd /data/projects && \
  mkdir -p my-project && \
  cd my-project && \
  git init && \
  echo '# My Project' > README.md && \
  git add -A && \
  git config user.email 'opencode@railway.app' && \
  git config user.name 'OpenCode' && \
  git commit -m 'init' 2>/dev/null; \
  cd /data/projects && \
  opencode web --port ${PORT:-8080} --hostname 0.0.0.0"]
