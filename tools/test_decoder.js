#!/usr/bin/env node
/**
 * Test script for MDT decoders
 */

const fs = require('fs');
const path = require('path');
const { decodeMDTRouteString } = require('./mdt_decoder.js');

// Test route strings
const testRoutes = [
    '../example_routes/rt1.txt',
    '../example_routes/rt2.txt'
];

console.log('Testing MDT Route Decoders');
console.log('==========================\n');

testRoutes.forEach((routeFile, index) => {
    console.log(`\n--- Test ${index + 1}: ${routeFile} ---`);

    try {
        // Read the route string
        const routeString = fs.readFileSync(routeFile, 'utf-8').trim();
        console.log(`Route string length: ${routeString.length} characters`);
        console.log(`First 50 chars: ${routeString.substring(0, 50)}...`);

        // Decode it
        const result = decodeMDTRouteString(routeString);

        if (result.error) {
            console.log('❌ Error:', result.error);
        } else {
            console.log('✅ Successfully decoded!');
            console.log(`Compression ratio: ${result.metadata.compression_ratio}:1`);
            console.log(`Original: ${result.metadata.original_length} bytes`);
            console.log(`Compressed: ${result.metadata.compressed_length} bytes`);
            console.log(`Decompressed: ${result.metadata.decompressed_length} bytes`);

            if (result.route_data.contains_week_info) {
                console.log('📅 Contains week information');
            }
            if (result.route_data.contains_objects) {
                console.log('🎯 Contains objects');
            }
            if (result.route_data.contains_pulls) {
                console.log('⚔️ Contains pulls');
            }
        }

    } catch (error) {
        console.log('❌ Test failed:', error.message);
    }
});

console.log('\n=== Test Complete ===');
console.log('\nTo run individual decoders:');
console.log('node mdt_decoder.js ../example_routes/rt1.txt');
console.log('python mdt_decoder.py ../example_routes/rt1.txt');
console.log('lua mdt_decoder.lua ../example_routes/rt1.txt');
console.log('dotnet run -- ../example_routes/rt1.txt');
