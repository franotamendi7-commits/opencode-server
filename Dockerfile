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

# Install Go for building gotty
RUN curl -fsSL https://go.dev/dl/go1.22.5.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"

# Build and install gotty
RUN go install github.com/sorenisanerd/gotty@latest

RUN useradd -m -s /bin/bash opencode
USER opencode
WORKDIR /home/opencode

# Create project with git init
RUN mkdir -p /home/opencode/project && \
    cd /home/opencode/project && \
    git init && \
    git config user.email "opencode@railway.app" && \
    git config user.name "OpenCode" && \
    echo "# My Project" > README.md && \
    git add -A && \
    git commit -m "initial" 2>/dev/null || true

ENV HOME=/home/opencode
ENV OPENCODE_MODEL=opencode/laguna-s-2.1-free
ENV OPENCODE_SERVER_PASSWORD=171171

EXPOSE 8080

CMD ["sh", "-c", "\
  tmux new-session -d -s opencode 'cd /home/opencode/project && opencode --model opencode/laguna-s-2.1-free' && \
  $(go env GOPATH)/bin/gotty --port ${PORT:-8080} --permit-write --reconnect tmux attach -t opencode \
"]
