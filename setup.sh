#!/bin/bash

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃ MDT Multi-Language Development Environment Setup Script             ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

set -e  # Exit on any error

echo "🎮 MDT Development Environment Setup"
echo "======================================"
echo ""

# ───────────────────────────────────────
# Verify all language installations
# ───────────────────────────────────────

echo "📋 Verifying installed tools..."
echo ""

echo "Node.js:"
node --version
npm --version
echo ""

echo "Python:"
python3 --version
if command -v uv &> /dev/null; then
    uv --version
else
    echo "⚠️  uv not found, installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    uv --version
fi
echo ""

echo ".NET:"
dotnet --version
echo ""

echo "Lua:"
lua -v
luarocks --version
echo ""

echo "Git:"
git --version
echo ""

# ───────────────────────────────────────
# Setup Python environment with uv
# ───────────────────────────────────────

echo "🐍 Setting up Python environment with uv..."
if [ -f "pyproject.toml" ]; then
    echo "Found pyproject.toml, creating virtual environment..."
    uv venv
    echo "Installing dependencies..."
    uv pip install -r requirements.txt 2>/dev/null || echo "No requirements.txt found"
    echo "✅ Python environment ready"
else
    echo "No pyproject.toml found, skipping Python project setup"
fi
echo ""

# ───────────────────────────────────────
# Setup Node.js dependencies
# ───────────────────────────────────────

echo "📦 Setting up Node.js dependencies..."
if [ -f "package.json" ]; then
    echo "Found package.json, installing dependencies..."
    npm install
    echo "✅ Node.js dependencies installed"
elif [ -f "tools/package.json" ]; then
    echo "Found tools/package.json, installing dependencies..."
    cd tools
    npm install
    cd ..
    echo "✅ Node.js dependencies installed"
else
    echo "No package.json found, skipping Node.js setup"
fi
echo ""

# ───────────────────────────────────────
# Setup .NET project
# ───────────────────────────────────────

echo "🔧 Setting up .NET project..."
if [ -f "tools/MDTDecoder.csproj" ]; then
    echo "Found .NET project, restoring packages..."
    cd tools
    dotnet restore
    dotnet build
    cd ..
    echo "✅ .NET project ready"
else
    echo "No .NET project found, skipping .NET setup"
fi
echo ""

# ───────────────────────────────────────
# Test MDT decoders with sample data
# ───────────────────────────────────────

echo "🧪 Testing MDT Route Decoders..."
echo ""

# Create test route string if it doesn't exist
if [ ! -f "example_routes/rt1.txt" ]; then
    mkdir -p example_routes
    echo "!WA:2!S33ZUTn4cNl8TKu3cUKcJPAhCKDjGfnQcKPczKq(uOGZU9H6N0E6Kkk5LXzY2eG4TwdU2f2YaGh9VKY2z!4" > example_routes/rt1.txt
    echo "Created sample route string for testing"
fi

TEST_ROUTE=$(cat example_routes/rt1.txt 2>/dev/null || echo "!WA:2!S33ZUTn4cNl8TKu3cUKcJPAhCKDjGfnQcKPczKq(uOGZU9H6N0E6Kkk5LXzY2eG4TwdU2f2YaGh9VKY2z!4")

echo "Using test route: $TEST_ROUTE"
echo ""

# Test Python decoder
echo "Testing Python decoder..."
if [ -f "tools/mdt_decoder.py" ]; then
    python3 tools/mdt_decoder.py "$TEST_ROUTE" && echo "✅ Python decoder works" || echo "❌ Python decoder failed"
else
    echo "❌ Python decoder not found"
fi
echo ""

# Test Node.js decoder
echo "Testing Node.js decoder..."
if [ -f "tools/mdt_decoder.js" ]; then
    node tools/mdt_decoder.js "$TEST_ROUTE" && echo "✅ Node.js decoder works" || echo "❌ Node.js decoder failed"
else
    echo "❌ Node.js decoder not found"
fi
echo ""

# Test C# decoder
echo "Testing C# decoder..."
if [ -f "tools/MDTDecoder.cs" ]; then
    cd tools
    dotnet run -- "$TEST_ROUTE" && echo "✅ C# decoder works" || echo "❌ C# decoder failed"
    cd ..
else
    echo "❌ C# decoder not found"
fi
echo ""

# Test Lua decoder
echo "Testing Lua decoder..."
if [ -f "tools/mdt_decoder.lua" ]; then
    lua tools/mdt_decoder.lua "$TEST_ROUTE" && echo "✅ Lua decoder works" || echo "❌ Lua decoder failed"
else
    echo "❌ Lua decoder not found"
fi
echo ""

# ───────────────────────────────────────
# Final summary
# ───────────────────────────────────────

echo "🎉 Setup Complete!"
echo ""
echo "Available commands:"
echo "  mdt-decode-py <route>    - Decode route with Python"
echo "  mdt-decode-js <route>    - Decode route with Node.js"
echo "  mdt-decode-cs <route>    - Decode route with C#"
echo "  mdt-decode-lua <route>   - Decode route with Lua"
echo ""
echo "Development tools:"
echo "  npm run dev              - Start Node.js development"
echo "  uv run <script>          - Run Python with uv"
echo "  dotnet run               - Run .NET application"
echo "  lua <script>             - Run Lua script"
echo ""
echo "Happy coding! 🚀"
