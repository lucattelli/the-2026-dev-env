# Minimal sandbox for running Claude Code without permission prompts.
# Only the project directory is mounted; no SSH keys, no ~/.gitconfig,
# no access to the rest of $HOME.
FROM debian:trixie-slim

ARG UID=1000
ARG GID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git build-essential pkg-config libssl-dev \
      ripgrep fd-find jq unzip \
    && rm -rf /var/lib/apt/lists/*

# Same UID/GID as the host user, so files created in the project are yours.
RUN groupadd -g "$GID" dev && useradd -m -u "$UID" -g "$GID" -s /bin/bash dev

USER dev
ENV PATH=/home/dev/.local/share/mise/shims:/home/dev/.local/bin:$PATH \
    CLAUDE_CONFIG_DIR=/home/dev/.claude \
    MISE_TRUSTED_CONFIG_PATHS=/workspace

RUN curl -fsSL https://claude.ai/install.sh | bash \
 && curl -fsSL https://mise.run | sh \
 && curl -LsSf https://astral.sh/uv/install.sh | sh \
 && mkdir -p /home/dev/.claude

WORKDIR /workspace
