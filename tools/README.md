# MDT Route String Decoder Tools

This folder contains multiple implementations to decode Mythic Dungeon Tools route strings into JSON format for analysis and understanding.

## Quick Start

Test all decoders with the provided example routes:

```bash
cd tools
node test_decoder.js
```

## Available Decoders

### 1. Python Decoder (`mdt_decoder.py`)
**Requirements:** Python 3.6+
```bash
python mdt_decoder.py ../example_routes/rt1.txt
python mdt_decoder.py "!fBvtpUjmq0FrbH)aS9X..."
```

### 2. Node.js Decoder (`mdt_decoder.js`)
**Requirements:** Node.js 14+
```bash
node mdt_decoder.js ../example_routes/rt1.txt
node mdt_decoder.js "!fBvtpUjmq0FrbH)aS9X..."
```

### 3. C# Decoder (`MDTDecoder.cs`)
**Requirements:** .NET 6.0+
```bash
dotnet run -- ../example_routes/rt1.txt
dotnet run -- "!fBvtpUjmq0FrbH)aS9X..."
```

### 4. Lua Decoder (`mdt_decoder.lua`)
**Requirements:** Lua 5.1 + lua-zlib
```bash
luarocks install lua-zlib
lua mdt_decoder.lua ../example_routes/rt1.txt
lua mdt_decoder.lua "!fBvtpUjmq0FrbH)aS9X..."
```

## Understanding the Route Format

MDT route strings use a 3-layer encoding:

1. **Serialization**: Custom AceSerializer format (Lua table serialization)
2. **Compression**: Deflate compression (zlib/LibDeflate)
3. **Encoding**: Custom Base64 encoding with alphabet `a-zA-Z0-9()`

### Route String Structure

```
!<base64_encoded_compressed_serialized_data>
```

The `!` prefix indicates the newer deflate compression format (vs legacy compression).

### Decoded JSON Structure

```json
{
  "metadata": {
    "original_length": 1234,
    "compressed_length": 567,
    "decompressed_length": 890,
    "compression_ratio": 0.64
  },
  "route_data": {
    "format": "AceSerializer",
    "contains_week_info": true,
    "contains_objects": true,
    "contains_pulls": true,
    "raw_data": "hex_encoded_raw_data..."
  }
}
```

## Route Data Contents

Based on the MDT source code, routes contain:

- **Dungeon Information**: `dungeonIdx`, dungeon name
- **Week/Affix Data**: Current Mythic+ week and affixes
- **Pull Data**: Enemy groups and pull assignments
- **Drawing Objects**: Lines, circles, and notes drawn on the map
- **Settings**: Various route preferences and configurations

## Example Output

```json
{
  "metadata": {
    "original_length": 1456,
    "compressed_length": 782,
    "decompressed_length": 1023,
    "compression_ratio": 0.76
  },
  "route_data": {
    "format": "AceSerializer",
    "contains_week_info": true,
    "contains_objects": true,
    "contains_pulls": true,
    "dungeon_id": "12",
    "week": "1"
  }
}
```

## Limitations

These decoders provide **partial parsing** of the route data. For full route reconstruction, you would need:

1. Complete AceSerializer implementation
2. MDT's specific data structure definitions
3. Dungeon/enemy mapping tables

The current implementation:
- ✅ Decodes the compression and encoding layers
- ✅ Extracts basic metadata
- ✅ Identifies data patterns
- ❌ Does not fully parse the Lua table structure
- ❌ Does not reconstruct the complete route object

## Advanced Usage

### Custom Base64 Alphabet

MDT uses a custom Base64 alphabet for better readability in chat:
```
abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()
```

### Compression Details

- Uses LibDeflate (RFC 1951 deflate compression)
- Compression levels 1-9 supported
- Typical compression ratio: 60-80%

### Integration with Other Tools

You can use these decoders as libraries in your own projects:

```javascript
// Node.js
const { decodeMDTRouteString } = require('./mdt_decoder.js');
const result = decodeMDTRouteString(routeString);
```

```python
# Python
from mdt_decoder import decode_mdt_route_string
result = decode_mdt_route_string(route_string)
```

```csharp
// C#
var decoder = new MDTDecoder();
string json = decoder.DecodeRouteString(routeString);
```

## Troubleshooting

### Common Issues

1. **"Decompression failed"**: Route string might be corrupted or use legacy format
2. **"Invalid Base64"**: Check for copy/paste errors in the route string
3. **"File not found"**: Ensure the path to the route file is correct

### Getting Help

1. Check that your route string starts with `!`
2. Verify the route string is complete (no truncation)
3. Try with the provided example routes first
4. Compare outputs between different decoder implementations

## Contributing

To improve the decoders:

1. **Full AceSerializer Implementation**: Implement complete Lua table parsing
2. **Route Object Reconstruction**: Build complete route data structures
3. **Validation**: Add route validation and error checking
4. **Performance**: Optimize for large route strings

See the main `DEVELOPMENT.md` for more details on contributing to the MDT project.
