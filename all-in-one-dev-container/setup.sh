#!/bin/bash
# MDT Development Environment Setup Script

echo "🎮 Setting up MDT Development Environment..."

# Check all tools are available
echo "📋 Checking installed tools:"
echo "Node.js: $(node --version)"
echo "Python: $(python3 --version)"
echo ".NET: $(dotnet --version)"
echo "Lua: $(lua -v)"

# Setup Python environment with uv
echo "🐍 Setting up Python environment..."
cd /workspace
if [ -f "all-in-one-dev-container/pyproject.toml" ]; then
    uv pip install -e "all-in-one-dev-container[dev]"
fi

# Install Node.js dependencies for tools
echo "📦 Setting up Node.js dependencies..."
cd /workspace/tools
if [ -f "package.json" ]; then
    npm install
fi

# Build C# project
echo "🔧 Building C# decoder..."
cd /workspace/tools
if [ -f "MDTDecoder.csproj" ]; then
    dotnet build
fi

# Install Lua dependencies
echo "🌙 Setting up Lua environment..."
luarocks list

# Test all decoders
echo "🧪 Testing decoders..."
cd /workspace/tools

echo "Testing Node.js decoder..."
if [ -f "../example_routes/rt1.txt" ]; then
    timeout 10s node mdt_decoder.js ../example_routes/rt1.txt > /dev/null 2>&1 && echo "✅ Node.js decoder works" || echo "❌ Node.js decoder failed"
fi

echo "Testing Python decoder..."
if [ -f "../example_routes/rt1.txt" ]; then
    timeout 10s python3 mdt_decoder.py ../example_routes/rt1.txt > /dev/null 2>&1 && echo "✅ Python decoder works" || echo "❌ Python decoder failed"
fi

echo "Testing C# decoder..."
if [ -f "../example_routes/rt1.txt" ]; then
    timeout 10s dotnet run -- ../example_routes/rt1.txt > /dev/null 2>&1 && echo "✅ C# decoder works" || echo "❌ C# decoder failed"
fi

echo "Testing Lua decoder..."
if [ -f "../example_routes/rt1.txt" ]; then
    timeout 10s lua mdt_decoder.lua ../example_routes/rt1.txt > /dev/null 2>&1 && echo "✅ Lua decoder works" || echo "❌ Lua decoder failed"
fi

echo ""
echo "🎉 MDT Development Environment Setup Complete!"
echo ""
echo "Available commands:"
echo "  mdt-decode-py <route_file>   - Decode with Python"
echo "  mdt-decode-js <route_file>   - Decode with Node.js"
echo "  mdt-decode-cs <route_file>   - Decode with C#"
echo "  mdt-decode-lua <route_file>  - Decode with Lua"
echo ""
echo "To get started:"
echo "  cd tools"
echo "  node test_decoder.js"
