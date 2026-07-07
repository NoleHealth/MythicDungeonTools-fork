# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃ Claude Code DevContainer Base Image  ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
FROM node:20

# ───────────────────────────────────────
# Install essential CLI + system tools
# ───────────────────────────────────────
RUN apt-get update && apt-get install -y \
  git zsh fzf jq dnsutils sudo iptables ipset curl \
  && rm -rf /var/lib/apt/lists/*

# Install npm packages and update browserslist
RUN npm install -g npm@latest \
  && npm install -g @anthropic-ai/claude-code@latest

# Setup directories and permissions
RUN mkdir -p /home/node/.claude /home/node/.vscode-server /commandhistory \
  && chown -R node:node /home/node/.claude /home/node/.vscode-server /commandhistory

# ───────────────────────────────────────
# Set execution environment for VS Code
# ───────────────────────────────────────
USER node

RUN git config --global user.name "NoleHealth" \
  && git config --global user.email "nolemercy@outlook.com" \
  && echo "# Default Zsh config" > /home/node/.zshrc


ENV CLAUDE_CONFIG_DIR=/home/node/.claude \
  NODE_OPTIONS=--max-old-space-size=4096 \
  POWERLEVEL9K_DISABLE_GITSTATUS=true

WORKDIR /workspace
