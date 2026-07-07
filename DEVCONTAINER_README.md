# MDT Multi-Language Development Environment

Welcome to the **Mythic Dungeon Tools** multi-language development environment! This setup provides a comprehensive, containerized development experience supporting **Node.js**, **Python (with uv/pyproject.toml)**, **C# (.NET)**, and **Lua** development.

## 🚀 Quick Start

### Prerequisites
- **Docker** installed and running
- **VS Code** with the Dev Containers extension

### Getting Started

1. **Open in Dev Container**
   ```bash
   # Open VS Code in the project directory
   code .

   # VS Code will prompt to "Reopen in Container" - click Yes
   # Or use Command Palette: "Dev Containers: Reopen in Container"
   ```

2. **Run Setup Script**
   ```bash
   # After container starts, run the setup script
   ./setup.sh
   ```

3. **Start Developing!**
   The environment is now ready with all languages and tools configured.

## 🛠️ Supported Languages & Tools

### Node.js (v20)
- **Runtime**: Node.js 20 with npm
- **Global Tools**: TypeScript, ts-node, nodemon, eslint, prettier
- **Package Manager**: npm
- **Config**: `package.json`, `.eslintrc`, `.prettierrc`

### Python (3.11+)
- **Runtime**: Python 3.11+
- **Package Manager**: `uv` (fast Python package installer)
- **Project Config**: `pyproject.toml` (modern Python project standard)
- **Fallback**: `requirements.txt` for pip compatibility
- **Tools**: black, ruff, mypy, pytest

### C# (.NET 9.0)
- **Runtime**: .NET 9.0 SDK (Linux compatible)
- **Project**: `tools/MDTDecoder.csproj`
- **IDE Support**: Full IntelliSense and debugging
- **CLI Tools**: dotnet CLI fully configured

### Lua (5.1)
- **Runtime**: Lua 5.1 (WoW compatible)
- **Package Manager**: LuaRocks
- **Libraries**: lua-zlib, dkjson, luafilesystem, serpent
- **WoW API**: Globals and API definitions included

## 📁 Project Structure

```
MythicDungeonTools/
├── .devcontainer/              # Dev container configuration
│   ├── devcontainer.json       # VS Code dev container settings
│   └── Dockerfile              # Multi-language container definition
├── tools/                      # MDT route decoders and utilities
│   ├── mdt_decoder.py          # Python decoder
│   ├── mdt_decoder.js          # Node.js decoder
│   ├── MDTDecoder.cs           # C# decoder
│   ├── mdt_decoder.lua         # Lua decoder
│   ├── test_decoder.js         # Test script
│   └── README.md               # Tools documentation
├── example_routes/             # Sample MDT route strings
├── pyproject.toml              # Python project configuration
├── requirements.txt            # Python dependencies (pip fallback)
├── package.json                # Node.js project configuration
├── setup.sh                    # Environment setup script
└── README.md                   # This file
```

## 🎮 MDT Route Decoders

This environment includes route decoders for **Mythic Dungeon Tools** route strings in all supported languages:

### Quick Test Commands

```bash
# Test all decoders with sample route
./setup.sh

# Individual decoder testing
mdt-decode-py "!WA:2!S33ZUTn4cNl8TKu3cUKcJPAhCKDjGfnQcKPczKq(uOGZU9H6N0E6Kkk5LXzY2eG4TwdU2f2YaGh9VKY2z!4"
mdt-decode-js "!WA:2!S33ZUTn4cNl8TKu3cUKcJPAhCKDjGfnQcKPczKq(uOGZU9H6N0E6Kkk5LXzY2eG4TwdU2f2YaGh9VKY2z!4"
mdt-decode-cs "!WA:2!S33ZUTn4cNl8TKu3cUKcJPAhCKDjGfnQcKPczKq(uOGZU9H6N0E6Kkk5LXzY2eG4TwdU2f2YaGh9VKY2z!4"
mdt-decode-lua "!WA:2!S33ZUTn4cNl8TKu3cUKcJPAhCKDjGfnQcKPczKq(uOGZU9H6N0E6Kkk5LXzY2eG4TwdU2f2YaGh9VKY2z!4"
```

### npm Scripts

```bash
# Run decoders through npm
npm run decode:js "route_string"
npm run decode:py "route_string"
npm run decode:cs "route_string"
npm run decode:lua "route_string"

# Development
npm run dev          # Watch mode for Node.js
npm run test         # Run tests
npm run lint         # Lint JavaScript files
npm run format       # Format code
npm run build        # Build and test all
```

## 🐍 Python Development with uv

This project uses **uv** for fast Python package management and **pyproject.toml** for modern Python project configuration.

### uv Commands

```bash
# Create virtual environment
uv venv

# Install dependencies
uv pip install -r requirements.txt

# Install development dependencies
uv pip install -e ".[dev]"

# Run Python scripts
uv run python tools/mdt_decoder.py

# Add new dependencies
uv add package_name

# Add development dependencies
uv add --dev package_name
```

### Traditional pip (fallback)

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt
```

## 🔧 C# .NET Development

The C# decoder is a console application built with .NET 9.0.

### .NET Commands

```bash
# Navigate to tools directory
cd tools

# Restore packages
dotnet restore

# Build project
dotnet build

# Run project
dotnet run

# Run with arguments
dotnet run -- "route_string_here"

# Create new project (if needed)
dotnet new console -n MDTDecoder
```

## 🌙 Lua Development

Lua 5.1 is installed for World of Warcraft addon compatibility.

### Lua Commands

```bash
# Run Lua script
lua tools/mdt_decoder.lua

# Install Lua packages
luarocks install package_name

# List installed packages
luarocks list

# Lua REPL
lua
```

## 🔄 VS Code Integration

The dev container includes comprehensive VS Code extensions and configuration:

### Installed Extensions

**Core Development:**
- GitHub Copilot & Copilot Chat
- GitLens, Git integration
- Code Runner
- TODO Tree, Path IntelliSense

**JavaScript/TypeScript:**
- ESLint, Prettier
- TypeScript support
- Auto rename tags

**Python:**
- Python extension pack
- Pylance (IntelliSense)
- Ruff (linting)
- Black (formatting)

**C# .NET:**
- C# extension
- .NET runtime support
- IntelliCode

**Lua:**
- Lua Language Server
- Lua Debug
- WoW API support

### Language-Specific Settings

The devcontainer includes pre-configured settings for:
- **Formatters**: Prettier (JS/TS), Black (Python), built-in (.NET)
- **Linters**: ESLint (JS/TS), Ruff (Python), built-in (.NET)
- **IntelliSense**: Full support for all languages
- **Debugging**: Configured for all languages
- **File associations**: `.toc`, `.lua`, `.xml` etc.

## 🐳 Container Details

### Base Image
- **Node.js 20** (Debian-based)
- All tools installed on top of Node base

### Installed Tools
- **System**: git, zsh, curl, wget, build-essential
- **Node.js**: npm, TypeScript, nodemon, global tools
- **Python**: Python 3.11+, uv, pip, development headers
- **C#**: .NET 9.0 SDK, runtime
- **Lua**: Lua 5.1, LuaRocks, essential packages

### Volumes & Persistence
- **Workspace**: Mounted from host
- **Node modules**: Volume for faster installs
- **VS Code server**: Persistent VS Code setup
- **Cache directories**: uv, npm, dotnet caches

## 🔧 Troubleshooting

### Container Issues

```bash
# Rebuild container
# Command Palette: "Dev Containers: Rebuild Container"

# View container logs
docker logs <container_id>

# Enter container manually
docker exec -it <container_id> /bin/zsh
```

### Language-Specific Issues

**Python:**
```bash
# Reset uv environment
rm -rf .venv
uv venv
uv pip install -r requirements.txt
```

**Node.js:**
```bash
# Clear npm cache and reinstall
npm run clean
```

**C#:**
```bash
# Clean and rebuild
cd tools
dotnet clean
dotnet restore
dotnet build
```

**Lua:**
```bash
# Reinstall packages
luarocks remove package_name
luarocks install package_name
```

### Path Issues

If commands aren't found, check your PATH:
```bash
echo $PATH
source ~/.zshrc
```

## 📚 Additional Resources

- **MDT Route Format**: See `tools/README.md` for route string specification
- **WoW API**: [WoW API Documentation](https://wow.gamepedia.com/World_of_Warcraft_API)
- **uv Documentation**: [uv GitHub](https://github.com/astral-sh/uv)
- **Dev Containers**: [VS Code Dev Containers](https://code.visualstudio.com/docs/remote/containers)

## 🚀 Getting Started Checklist

- [ ] Ensure Docker is running
- [ ] Open project in VS Code
- [ ] Reopen in Dev Container when prompted
- [ ] Run `./setup.sh` to verify all tools
- [ ] Test MDT decoders with sample route
- [ ] Start developing!

Happy coding! 🎮✨
