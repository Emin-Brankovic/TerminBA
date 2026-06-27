using Microsoft.Extensions.Logging;
using System;
using System.Globalization;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class NominatimGeocodingService : IGeocodingService
    {
        private readonly HttpClient _httpClient;

        private static readonly JsonSerializerOptions _jsonOptions = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };

        public NominatimGeocodingService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<(decimal Latitude, decimal Longitude)?> GeocodeAddressAsync(string address)
        {
            if (string.IsNullOrWhiteSpace(address))
                return null;

            try
            {
                var encoded = Uri.EscapeDataString(address);
                var url = $"https://nominatim.openstreetmap.org/search?q={encoded}&format=json&limit=1&addressdetails=0";

                var response = await _httpClient.GetAsync(url);

                if (!response.IsSuccessStatusCode)
                {
                    return null;
                }

                var content = await response.Content.ReadAsStringAsync();
                var results = JsonSerializer.Deserialize<NominatimResult[]>(content, _jsonOptions);

                if (results == null || results.Length == 0)
                {
                    return null;
                }

                var first = results[0];

                if (!decimal.TryParse(first.Lat, NumberStyles.Float, CultureInfo.InvariantCulture, out var lat)
                    || !decimal.TryParse(first.Lon, NumberStyles.Float, CultureInfo.InvariantCulture, out var lon))
                {
                    return null;
                }

                return (lat, lon);
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        private class NominatimResult
        {
            public string? Lat { get; set; }
            public string? Lon { get; set; }
        }
    }
}
