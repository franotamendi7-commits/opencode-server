FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl ca-certificates git tmux \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g opencode-ai

RUN printf '#!/bin/sh\nexit 0\n' > /usr/bin/xdg-open && chmod +x /usr/bin/xdg-open && \
    printf '#!/bin/sh\nexit 0\n' > /usr/bin/open && chmod +x /usr/bin/open

RUN curl -fsSL https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd

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
ENV OPENCODE_MODEL=opencode/laguna-s-2.1-free
ENV TERM=xterm-256color

EXPOSE 8080

CMD ["sh", "-c", "\
  tmux new-session -d -s opencode 'cd /home/opencode/project && exec opencode' && \
  exec ttyd --port ${PORT:-8080} \
    --credential opencode:171171 \
    --client-option titleFixed='OpenCode' \
    tmux attach-session -t opencode \
"]
