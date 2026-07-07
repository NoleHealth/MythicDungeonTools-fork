# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃ MDT Multi-Language Development Container                              ┃
# ┃ Node.js + Python (uv/pyproject.toml) + C# (.NET) + Lua               ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

# Use Node.js 20 as base for modern JavaScript development
FROM node:20

# ───────────────────────────────────────
# Install essential system tools and dependencies
# ───────────────────────────────────────
RUN apt-get update && apt-get install -y \
  # Core system tools
  git zsh fzf jq curl wget unzip zip \
  dnsutils sudo iptables ipset \
  # Build tools and compilers
  build-essential software-properties-common \
  apt-transport-https ca-certificates \
  # Python development dependencies
  python3 python3-pip python3-venv python3-dev \
  # Lua development dependencies
  lua5.1 lua5.1-dev luarocks \
  # Compression and crypto libraries
  zlib1g-dev libssl-dev liblz4-dev \
  # Text editors for emergency fixes
  nano vim \
  && rm -rf /var/lib/apt/lists/*

# ───────────────────────────────────────
# Install Microsoft .NET 9 SDK and Runtime (Linux compatible)
# ───────────────────────────────────────
RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
  && dpkg -i packages-microsoft-prod.deb \
  && rm packages-microsoft-prod.deb \
  && apt-get update \
  && apt-get install -y dotnet-sdk-9.0 aspnetcore-runtime-9.0 \
  && rm -rf /var/lib/apt/lists/*

# ───────────────────────────────────────
# Install uv (fast Python package manager)
# ───────────────────────────────────────
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# ───────────────────────────────────────
# Install Lua packages for MDT development
# ───────────────────────────────────────
RUN luarocks install lua-zlib \
  && luarocks install dkjson \
  && luarocks install luafilesystem \
  && luarocks install luaposix \
  && luarocks install serpent

# ───────────────────────────────────────
# Install global Node.js tools
# ───────────────────────────────────────
RUN npm install -g npm@latest \
  && npm install -g typescript ts-node nodemon \
  && npm install -g @types/node \
  && npm install -g eslint prettier \
  && npm install -g pako buffer

# ───────────────────────────────────────
# Create user directories and set permissions
# ───────────────────────────────────────
RUN mkdir -p /home/node/.vscode-server /home/node/.cache /commandhistory \
  && chown -R node:node /home/node/.vscode-server /home/node/.cache /commandhistory

# ───────────────────────────────────────
# Switch to node user and setup user environment
# ───────────────────────────────────────
USER node

# Install uv for the node user
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/home/node/.local/bin:$PATH"

# Setup shell and aliases for MDT development
RUN echo "# MDT Multi-Language Development Environment" > /home/node/.zshrc \
  && echo "export PATH=\"/home/node/.local/bin:\$PATH\"" >> /home/node/.zshrc \
  && echo "export DOTNET_ROOT=/usr/share/dotnet" >> /home/node/.zshrc \
  && echo "export DOTNET_CLI_TELEMETRY_OPTOUT=1" >> /home/node/.zshrc \
  && echo "export UV_CACHE_DIR=/home/node/.cache/uv" >> /home/node/.zshrc \
  && echo "export PYTHONPATH=/workspace" >> /home/node/.zshrc \
  && echo "" >> /home/node/.zshrc \
  && echo "# Aliases for quick access" >> /home/node/.zshrc \
  && echo "alias ll='ls -la'" >> /home/node/.zshrc \
  && echo "alias la='ls -la'" >> /home/node/.zshrc \
  && echo "alias cls='clear'" >> /home/node/.zshrc \
  && echo "" >> /home/node/.zshrc \
  && echo "# MDT Route Decoder aliases" >> /home/node/.zshrc \
  && echo "alias mdt-decode-py='python /workspace/tools/mdt_decoder.py'" >> /home/node/.zshrc \
  && echo "alias mdt-decode-js='node /workspace/tools/mdt_decoder.js'" >> /home/node/.zshrc \
  && echo "alias mdt-decode-cs='cd /workspace/tools && dotnet run'" >> /home/node/.zshrc \
  && echo "alias mdt-decode-lua='lua /workspace/tools/mdt_decoder.lua'" >> /home/node/.zshrc \
  && echo "" >> /home/node/.zshrc \
  && echo "# Project shortcuts" >> /home/node/.zshrc \
  && echo "alias mdt-test='cd /workspace && npm test'" >> /home/node/.zshrc \
  && echo "alias mdt-build='cd /workspace && npm run build'" >> /home/node/.zshrc \
  && echo "alias mdt-setup='cd /workspace && ./setup.sh'" >> /home/node/.zshrc \
  && echo "" >> /home/node/.zshrc \
  && echo "# Welcome message" >> /home/node/.zshrc \
  && echo "echo '🎮 MDT Development Environment Ready!'" >> /home/node/.zshrc \
  && echo "echo 'Available languages: Node.js, Python (uv), C# (.NET), Lua'" >> /home/node/.zshrc \
  && echo "echo 'Type mdt-decode-* to test route decoders'" >> /home/node/.zshrc

# Setup git configuration
RUN git config --global user.name "MDT Developer" \
  && git config --global user.email "developer@mdt.dev" \
  && git config --global init.defaultBranch main

# ───────────────────────────────────────
# Set environment variables for all tools
# ───────────────────────────────────────
ENV NODE_OPTIONS=--max-old-space-size=4096 \
  DOTNET_ROOT=/usr/share/dotnet \
  DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  PYTHONPATH=/workspace \
  UV_CACHE_DIR=/home/node/.cache/uv \
  LUA_PATH="/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;;" \
  LUA_CPATH="/usr/local/lib/lua/5.1/?.so;;"

WORKDIR /workspace

# Default command
CMD ["zsh"]
