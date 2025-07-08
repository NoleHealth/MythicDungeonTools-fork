#!/usr/bin/env node
/**
 * MDT Route String Decoder (Node.js)
 * ==================================
 *
 * This script decodes Mythic Dungeon Tools route strings and converts them to JSON.
 *
 * Usage:
 * node mdt_decoder.js route_string.txt
 * node mdt_decoder.js "!fBvtpUjmq0FrbH)aS9X..."
 */

const fs = require('fs');
const zlib = require('zlib');
const path = require('path');

// Custom Base64 alphabet used by MDT
const B64_ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()";

/**
 * Create lookup table for Base64 decoding
 */
function createB64DecodeTable() {
    const table = {};
    for (let i = 0; i < B64_ALPHABET.length; i++) {
        table[B64_ALPHABET[i]] = i;
    }
    return table;
}

/**
 * Decode custom Base64 string to Buffer (following MDT's algorithm)
 */
function decodeCustomB64(encodedStr) {
    const decodeTable = createB64DecodeTable();

    const decoded = [];
    let decodedSize = 0;
    let bitfield = 0;
    let bitfieldLen = 0;

    for (let i = 0; i < encodedStr.length; i++) {
        // Process bitfield if we have enough bits
        while (bitfieldLen >= 8) {
            decoded[decodedSize] = bitfield & 255;
            decodedSize++;
            bitfield = bitfield >> 8;
            bitfieldLen -= 8;
        }

        // Add new character to bitfield
        const ch = decodeTable[encodedStr[i]];
        if (ch !== undefined) {
            bitfield = bitfield + (ch << bitfieldLen);
            bitfieldLen += 6;
        }
    }

    // Process remaining bits
    while (bitfieldLen >= 8) {
        decoded[decodedSize] = bitfield & 255;
        decodedSize++;
        bitfield = bitfield >> 8;
        bitfieldLen -= 8;
    }

    return Buffer.from(decoded.slice(0, decodedSize));
}

/**
 * Decompress deflate-compressed data
 */
function decompressData(compressedData) {
    try {
        return zlib.inflateSync(compressedData);
    } catch (error) {
        throw new Error(`Decompression failed: ${error.message}`);
    }
}

/**
 * Parse AceSerializer format data (simplified)
 */
function parseAceSerializedData(data) {
    try {
        // Remove the AceSerializer header/version info
        let processedData = data;
        if (data.length >= 2 && data[0] === 0x01 && data[1] === 0x00) {
            processedData = data.slice(2);
        }

        const dataStr = processedData.toString('binary');

        const result = {
            format: "AceSerializer",
            raw_data: Buffer.from(dataStr, 'binary').toString('hex'),
            parsed_data: "Partial parsing - full AceSerializer implementation needed"
        };

        // Try to extract some basic information
        if (dataStr.includes('week')) {
            result.contains_week_info = true;
        }
        if (dataStr.includes('objects')) {
            result.contains_objects = true;
        }
        if (dataStr.includes('pulls')) {
            result.contains_pulls = true;
        }

        // Try to find patterns that might indicate route data
        const patterns = {
            dungeon_id: /dungeonIdx.*?(\d+)/,
            week: /week.*?(\d+)/,
            difficulty: /difficulty.*?(\d+)/
        };

        for (const [key, pattern] of Object.entries(patterns)) {
            const match = dataStr.match(pattern);
            if (match) {
                result[key] = match[1];
            }
        }

        return result;

    } catch (error) {
        return {
            error: `Failed to parse serialized data: ${error.message}`,
            raw_data: data.toString('hex')
        };
    }
}

/**
 * Decode an MDT route string to JSON-compatible format
 */
function decodeMDTRouteString(routeString) {
    try {
        // Step 1: Remove the leading "!" marker
        let encodedData = routeString;
        if (routeString.startsWith('!')) {
            encodedData = routeString.slice(1);
        }

        // Step 2: Decode custom Base64
        console.log("Decoding Base64...");
        const compressedData = decodeCustomB64(encodedData);
        console.log(`Decoded ${compressedData.length} bytes`);

        // Step 3: Decompress deflate data
        console.log("Decompressing data...");
        const decompressedData = decompressData(compressedData);
        console.log(`Decompressed to ${decompressedData.length} bytes`);

        // Step 4: Parse serialized data
        console.log("Parsing serialized data...");
        const parsedData = parseAceSerializedData(decompressedData);

        // Step 5: Create result structure
        const result = {
            metadata: {
                original_length: routeString.length,
                compressed_length: compressedData.length,
                decompressed_length: decompressedData.length,
                compression_ratio: Math.round((compressedData.length / decompressedData.length) * 100) / 100
            },
            route_data: parsedData
        };

        return result;

    } catch (error) {
        return {
            error: `Failed to decode route string: ${error.message}`,
            original_string: routeString.length > 100 ? routeString.slice(0, 100) + "..." : routeString
        };
    }
}

/**
 * Main function
 */
function main() {
    const args = process.argv.slice(2);

    if (args.length !== 1) {
        console.log("Usage: node mdt_decoder.js <route_string_or_file>");
        console.log("Example: node mdt_decoder.js rt1.txt");
        console.log("Example: node mdt_decoder.js '!fBvtpUjmq0FrbH)aS9X...'");
        return;
    }

    const inputArg = args[0];
    let routeString;

    // Check if it's a file or direct string
    if (inputArg.endsWith('.txt') || inputArg.includes('/') || inputArg.includes('\\')) {
        // It's a file path
        try {
            routeString = fs.readFileSync(inputArg, 'utf-8').trim();
        } catch (error) {
            console.error(`Error reading file: ${error.message}`);
            return;
        }
    } else {
        // It's a direct string
        routeString = inputArg;
    }

    // Decode the route string
    const result = decodeMDTRouteString(routeString);

    // Output as JSON
    console.log(JSON.stringify(result, null, 2));
}

// Run main function if this file is executed directly
if (require.main === module) {
    main();
}

module.exports = {
    decodeMDTRouteString,
    decodeCustomB64,
    decompressData,
    parseAceSerializedData
};
