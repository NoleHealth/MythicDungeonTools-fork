using System;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Text.Json;
using System.Collections.Generic;

namespace MDTRouteDecoder
{
  /// <summary>
  /// MDT Route String Decoder for C#
  ///
  /// This class decodes Mythic Dungeon Tools route strings and converts them to JSON.
  ///
  /// Usage:
  /// var decoder = new MDTDecoder();
  /// string json = decoder.DecodeRouteString(routeString);
  /// </summary>
  public class MDTDecoder
  {
    // Custom Base64 alphabet used by MDT
    private const string B64_ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()";
    private static readonly Dictionary<char, int> B64DecodeTable;

    static MDTDecoder()
    {
      B64DecodeTable = new Dictionary<char, int>();
      for (int i = 0; i < B64_ALPHABET.Length; i++)
      {
        B64DecodeTable[B64_ALPHABET[i]] = i;
      }
    }

    /// <summary>
    /// Decode custom Base64 string to byte array
    /// </summary>
    public byte[] DecodeCustomB64(string encodedStr)
    {
      // Remove padding
      string paddingRemoved = encodedStr.TrimEnd('=');

      // Convert to binary string
      StringBuilder binaryStr = new StringBuilder();
      foreach (char c in paddingRemoved)
      {
        if (B64DecodeTable.ContainsKey(c))
        {
          binaryStr.Append(Convert.ToString(B64DecodeTable[c], 2).PadLeft(6, '0'));
        }
      }

      // Convert binary to bytes
      List<byte> bytes = new List<byte>();
      for (int i = 0; i < binaryStr.Length - 7; i += 8)
      {
        string byteChunk = binaryStr.ToString().Substring(i, Math.Min(8, binaryStr.Length - i));
        if (byteChunk.Length == 8)
        {
          bytes.Add(Convert.ToByte(byteChunk, 2));
        }
      }

      return bytes.ToArray();
    }

    /// <summary>
    /// Decompress deflate-compressed data
    /// </summary>
    public byte[] DecompressData(byte[] compressedData)
    {
      try
      {
        using (var memoryStream = new MemoryStream(compressedData))
        using (var deflateStream = new DeflateStream(memoryStream, CompressionMode.Decompress))
        using (var resultStream = new MemoryStream())
        {
          deflateStream.CopyTo(resultStream);
          return resultStream.ToArray();
        }
      }
      catch (Exception ex)
      {
        throw new InvalidOperationException($"Decompression failed: {ex.Message}", ex);
      }
    }

    /// <summary>
    /// Parse AceSerializer format data (simplified)
    /// </summary>
    public object ParseAceSerializedData(byte[] data)
    {
      try
      {
        // Remove the AceSerializer header/version info
        byte[] processedData = data;
        if (data.Length >= 2 && data[0] == 0x01 && data[1] == 0x00)
        {
          processedData = new byte[data.Length - 2];
          Array.Copy(data, 2, processedData, 0, processedData.Length);
        }

        string dataStr = Encoding.GetEncoding("ISO-8859-1").GetString(processedData);

        var result = new Dictionary<string, object>
        {
          ["format"] = "AceSerializer",
          ["raw_data"] = Convert.ToHexString(processedData),
          ["parsed_data"] = "Partial parsing - full AceSerializer implementation needed"
        };

        // Try to extract some basic information
        if (dataStr.Contains("week"))
          result["contains_week_info"] = true;
        if (dataStr.Contains("objects"))
          result["contains_objects"] = true;
        if (dataStr.Contains("pulls"))
          result["contains_pulls"] = true;

        // Try to find patterns that might indicate route data
        var patterns = new Dictionary<string, string>
        {
          ["dungeon_pattern"] = @"dungeonIdx.*?(\d+)",
          ["week_pattern"] = @"week.*?(\d+)",
          ["difficulty_pattern"] = @"difficulty.*?(\d+)"
        };

        foreach (var pattern in patterns)
        {
          var match = System.Text.RegularExpressions.Regex.Match(dataStr, pattern.Value);
          if (match.Success)
          {
            result[pattern.Key.Replace("_pattern", "")] = match.Groups[1].Value;
          }
        }

        return result;
      }
      catch (Exception ex)
      {
        return new Dictionary<string, object>
        {
          ["error"] = $"Failed to parse serialized data: {ex.Message}",
          ["raw_data"] = Convert.ToHexString(data)
        };
      }
    }

    /// <summary>
    /// Decode an MDT route string to JSON-compatible format
    /// </summary>
    public string DecodeRouteString(string routeString)
    {
      try
      {
        // Step 1: Remove the leading "!" marker
        string encodedData = routeString;
        if (routeString.StartsWith("!"))
        {
          encodedData = routeString.Substring(1);
        }

        // Step 2: Decode custom Base64
        Console.WriteLine("Decoding Base64...");
        byte[] compressedData = DecodeCustomB64(encodedData);
        Console.WriteLine($"Decoded {compressedData.Length} bytes");

        // Step 3: Decompress deflate data
        Console.WriteLine("Decompressing data...");
        byte[] decompressedData = DecompressData(compressedData);
        Console.WriteLine($"Decompressed to {decompressedData.Length} bytes");

        // Step 4: Parse serialized data
        Console.WriteLine("Parsing serialized data...");
        object parsedData = ParseAceSerializedData(decompressedData);

        // Step 5: Create result structure
        var result = new
        {
          metadata = new
          {
            original_length = routeString.Length,
            compressed_length = compressedData.Length,
            decompressed_length = decompressedData.Length,
            compression_ratio = Math.Round((double)compressedData.Length / decompressedData.Length, 2)
          },
          route_data = parsedData
        };

        return JsonSerializer.Serialize(result, new JsonSerializerOptions { WriteIndented = true });

      }
      catch (Exception ex)
      {
        var errorResult = new
        {
          error = $"Failed to decode route string: {ex.Message}",
          original_string = routeString.Length > 100 ? routeString.Substring(0, 100) + "..." : routeString
        };

        return JsonSerializer.Serialize(errorResult, new JsonSerializerOptions { WriteIndented = true });
      }
    }
  }

  /// <summary>
  /// Console application for testing the decoder
  /// </summary>
  class Program
  {
    static void Main(string[] args)
    {
      if (args.Length != 1)
      {
        Console.WriteLine("Usage: MDTRouteDecoder.exe <route_string_or_file>");
        Console.WriteLine("Example: MDTRouteDecoder.exe rt1.txt");
        Console.WriteLine("Example: MDTRouteDecoder.exe \"!fBvtpUjmq0FrbH)aS9X...\"");
        return;
      }

      string inputArg = args[0];
      string routeString;

      // Check if it's a file or direct string
      if (inputArg.EndsWith(".txt") || inputArg.Contains("/") || inputArg.Contains("\\"))
      {
        // It's a file path
        try
        {
          routeString = File.ReadAllText(inputArg).Trim();
        }
        catch (FileNotFoundException)
        {
          Console.WriteLine($"Error: File '{inputArg}' not found");
          return;
        }
        catch (Exception ex)
        {
          Console.WriteLine($"Error reading file: {ex.Message}");
          return;
        }
      }
      else
      {
        // It's a direct string
        routeString = inputArg;
      }

      // Decode the route string
      var decoder = new MDTDecoder();
      string result = decoder.DecodeRouteString(routeString);

      // Output as JSON
      Console.WriteLine(result);
    }
  }
}
