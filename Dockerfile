FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl ca-certificates git \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g opencode-ai@1.18.3

RUN printf '#!/bin/sh\nexit 0\n' > /usr/bin/xdg-open && chmod +x /usr/bin/xdg-open && \
    printf '#!/bin/sh\nexit 0\n' > /usr/bin/open && chmod +x /usr/bin/open

RUN useradd -m -s /bin/bash opencode
USER opencode
WORKDIR /home/opencode/project

RUN mkdir -p /home/opencode/project && \
    git init && \
    git config user.email "opencode@railway.app" && \
    git config user.name "OpenCode" && \
    echo "# My Project" > README.md && \
    git add -A && \
    git commit -m "initial" 2>/dev/null || true

ENV HOME=/home/opencode
ENV OPENCODE_SERVER_PASSWORD=171171
ENV OPENCODE_MODEL=opencode/laguna-s-2.1-free

EXPOSE 8080

CMD ["sh", "-c", "\
  opencode web --port ${PORT:-8080} --hostname 0.0.0.0 --print-logs 2>&1 \
"]
