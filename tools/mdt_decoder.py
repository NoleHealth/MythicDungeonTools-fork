#!/usr/bin/env python3
"""
MDT Route String Decoder
========================

This script decodes Mythic Dungeon Tools route strings and converts them to JSON.
The route strings are encoded using:
1. Custom Base64 encoding (a-z, A-Z, 0-9, (, ))
2. Deflate compression
3. Custom serialization format

Requirements:
- pip install zlib (usually built-in)
- No external dependencies needed

Usage:
python mdt_decoder.py route_string.txt
python mdt_decoder.py "!fBvtpUjmq0FrbH)aS9X..."
"""

import sys
import zlib
import json
import re
from typing import Dict, Any, List, Union

# Custom Base64 alphabet used by MDT
B64_ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()"

def create_b64_decode_table():
    """Create lookup table for Base64 decoding"""
    return {char: idx for idx, char in enumerate(B64_ALPHABET)}

def decode_custom_b64(encoded_str: str) -> bytes:
    """Decode custom Base64 string to bytes"""
    decode_table = create_b64_decode_table()

    # Remove padding and prepare for decoding
    padding_removed = encoded_str.rstrip('=')

    # Convert to binary string
    binary_str = ''
    for char in padding_removed:
        if char in decode_table:
            binary_str += format(decode_table[char], '06b')

    # Convert binary to bytes
    byte_data = bytearray()
    for i in range(0, len(binary_str) - 7, 8):
        byte_chunk = binary_str[i:i+8]
        if len(byte_chunk) == 8:
            byte_data.append(int(byte_chunk, 2))

    return bytes(byte_data)

def decompress_data(compressed_data: bytes) -> bytes:
    """Decompress deflate-compressed data"""
    try:
        return zlib.decompress(compressed_data)
    except zlib.error as e:
        raise ValueError(f"Decompression failed: {e}")

def parse_ace_serialized_data(data: str) -> Dict[str, Any]:
    """
    Parse AceSerializer format data
    This is a simplified parser - the actual format is more complex
    """
    try:
        # Remove the AceSerializer header/version info
        # AceSerializer format typically starts with version info
        if data.startswith('\x01\x00'):
            data = data[2:]  # Remove version bytes

        # This is a simplified parser - for full compatibility,
        # you'd need to implement the full AceSerializer protocol
        # For now, we'll extract what we can

        result = {
            "format": "AceSerializer",
            "raw_data": data.encode('unicode_escape').decode('ascii'),
            "parsed_data": "Partial parsing - full AceSerializer implementation needed"
        }

        # Try to extract some basic information
        if "week" in data:
            result["contains_week_info"] = True
        if "objects" in data:
            result["contains_objects"] = True
        if "pulls" in data:
            result["contains_pulls"] = True

        return result

    except Exception as e:
        return {
            "error": f"Failed to parse serialized data: {e}",
            "raw_data": data.encode('unicode_escape').decode('ascii')
        }

def decode_mdt_route_string(route_string: str) -> Dict[str, Any]:
    """
    Decode an MDT route string to JSON-compatible format
    """
    try:
        # Step 1: Remove the leading "!" marker
        if route_string.startswith('!'):
            encoded_data = route_string[1:]
        else:
            encoded_data = route_string

        # Step 2: Decode custom Base64
        print("Decoding Base64...")
        compressed_data = decode_custom_b64(encoded_data)
        print(f"Decoded {len(compressed_data)} bytes")

        # Step 3: Decompress deflate data
        print("Decompressing data...")
        decompressed_data = decompress_data(compressed_data)
        print(f"Decompressed to {len(decompressed_data)} bytes")

        # Step 4: Parse serialized data
        print("Parsing serialized data...")
        serialized_str = decompressed_data.decode('latin-1')  # Use latin-1 for binary data
        parsed_data = parse_ace_serialized_data(serialized_str)

        # Step 5: Create result structure
        result = {
            "metadata": {
                "original_length": len(route_string),
                "compressed_length": len(compressed_data),
                "decompressed_length": len(decompressed_data),
                "compression_ratio": round(len(compressed_data) / len(decompressed_data), 2)
            },
            "route_data": parsed_data
        }

        return result

    except Exception as e:
        return {
            "error": f"Failed to decode route string: {e}",
            "original_string": route_string[:100] + "..." if len(route_string) > 100 else route_string
        }

def main():
    if len(sys.argv) != 2:
        print("Usage: python mdt_decoder.py <route_string_or_file>")
        print("Example: python mdt_decoder.py rt1.txt")
        print("Example: python mdt_decoder.py '!fBvtpUjmq0FrbH)aS9X...'")
        return

    input_arg = sys.argv[1]

    # Check if it's a file or direct string
    if input_arg.endswith('.txt') or '/' in input_arg or '\\' in input_arg:
        # It's a file path
        try:
            with open(input_arg, 'r', encoding='utf-8') as f:
                route_string = f.read().strip()
        except FileNotFoundError:
            print(f"Error: File '{input_arg}' not found")
            return
        except Exception as e:
            print(f"Error reading file: {e}")
            return
    else:
        # It's a direct string
        route_string = input_arg

    # Decode the route string
    result = decode_mdt_route_string(route_string)

    # Output as JSON
    print(json.dumps(result, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()
