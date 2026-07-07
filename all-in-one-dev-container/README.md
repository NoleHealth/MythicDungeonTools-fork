# MDT Multi-Language Development Container

This development container provides a complete environment for working with Mythic Dungeon Tools, supporting all the languages used in the project.

## Features

### 🛠️ **Supported Languages & Tools**
- **Node.js 20** - For JavaScript/TypeScript development and MDT decoder
- **Python 3.11** - With uv package manager for fast dependency management
- **C# .NET 9.0** - For cross-platform .NET development
- **Lua 5.1** - Same version as World of Warcraft uses
- **Git & GitHub CLI** - For version control and GitHub integration

### 📦 **Pre-installed Tools**
- **Claude Code** - AI-powered development assistance
- **ESLint & Prettier** - Code formatting and linting
- **Python Black & Ruff** - Python formatting and linting
- **TypeScript** - For enhanced JavaScript development
- **Code Runner** - Execute code directly in VS Code

### 🎮 **MDT-Specific Setup**
- All route decoders ready to use (Python, Node.js, C#, Lua)
- Pre-configured VS Code settings for WoW addon development
- Helpful aliases for common tasks
- Example route strings for testing

## Quick Start

### 1. **Build the Container**
```bash
# Build the custom image
docker build -t mdt-multi-lang-dev ./all-in-one-dev-container/

# Or use the devcontainer directly in VS Code
```

### 2. **Open in VS Code**
1. Install the "Dev Containers" extension
2. Open the project folder
3. Press `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"
4. Wait for the container to build and start

### 3. **Verify Setup**
```bash
# Check all tools are installed
node --version    # Should show v20.x.x
python3 --version # Should show Python 3.11.x
dotnet --version  # Should show 9.0.x
lua -v           # Should show Lua 5.1.x

# Test the MDT decoders
cd tools
node test_decoder.js
```

## Available Commands

### 🎯 **Quick Decoder Aliases**
```bash
mdt-decode-py route_file.txt    # Decode with Python
mdt-decode-js route_file.txt    # Decode with Node.js
mdt-decode-cs route_file.txt    # Decode with C#
mdt-decode-lua route_file.txt   # Decode with Lua
```

### 🔧 **Development Commands**
```bash
# Python with uv
uv pip install package_name
uv run python script.py

# Node.js
npm install
node script.js

# C#
dotnet build
dotnet run

# Lua
lua script.lua
luarocks install package_name
```

## Development Workflow

### 1. **For WoW Addon Development**
```bash
# Edit Lua files with VS Code
# Use the dev-helper.ps1 script to copy to WoW
# Test in-game with /reload
```

### 2. **For Route Analysis**
```bash
# Add route strings to example_routes/
# Use any decoder to analyze:
cd tools
python mdt_decoder.py ../example_routes/new_route.txt
```

### 3. **For Tool Development**
```bash
# Modify decoders in tools/ folder
# Test with existing routes
# Add new features across all languages
```

## VS Code Configuration

The container includes optimized settings for:

- **Lua Development**: WoW API globals, proper formatting
- **Python Development**: Black formatting, Ruff linting, uv integration
- **C# Development**: .NET 9.0 support, OmniSharp integration
- **Node.js Development**: TypeScript support, ESLint, Prettier

## Environment Variables

- `DOTNET_CLI_TELEMETRY_OPTOUT=1` - Disable .NET telemetry
- `UV_CACHE_DIR=/home/node/.cache/uv` - Python uv cache location
- `PYTHONPATH=/workspace` - Python module path
- `NODE_OPTIONS=--max-old-space-size=4096` - Increase Node.js memory

## Troubleshooting

### Container Won't Start
1. Check Docker is running
2. Ensure you have enough disk space
3. Try rebuilding: `docker build --no-cache -t mdt-multi-lang-dev ./all-in-one-dev-container/`

### Tool Not Found
1. Restart the container
2. Run the setup script: `./all-in-one-dev-container/setup.sh`
3. Check the tool is in PATH: `which python3`

### Decoder Errors
1. Verify route string format (should start with `!`)
2. Check file paths are correct
3. Test with provided example routes first

## Customization

### Add New Languages
1. Modify `Dockerfile` to install the language
2. Update `devcontainer.json` with VS Code extensions
3. Add language-specific settings

### Add New Tools
1. Install in `Dockerfile` or use VS Code extensions
2. Update aliases in the setup script
3. Document in this README

## Performance Tips

- **Use uv for Python** - Much faster than pip
- **Enable VS Code settings sync** - Keep configs across containers
- **Mount Docker volumes** - Persist package caches between rebuilds
- **Use multi-stage builds** - If container gets too large

## Contributing

When modifying the dev container:
1. Test all language tools work
2. Update documentation
3. Verify VS Code extensions load correctly
4. Test with actual MDT development workflow

---

This development container provides everything needed for full-stack MDT development across multiple languages! 🚀
