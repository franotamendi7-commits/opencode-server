FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl ca-certificates git \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g opencode-ai

RUN useradd -m -s /bin/bash opencode

USER opencode
WORKDIR /home/opencode

EXPOSE 4096

ENV HOME=/home/opencode
ENV OPENCODE_SERVER_PASSWORD=171171
ENV OPENCODE_MODEL=opencode/laguna-s-2.1-free

CMD ["sh", "-c", "opencode web --port 4096 --hostname 0.0.0.0"]
