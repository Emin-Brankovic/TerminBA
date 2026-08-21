using System;
using System.Runtime.InteropServices;

namespace TerminBA.Services.Helpers
{
    public static class TimeHelper
    {
        // Central European Standard Time is valid on Windows. On Linux, it's Europe/Sarajevo or Europe/Berlin.
        // We handle both just in case it runs in a Docker container (Linux) later.
        private static readonly string TimeZoneId = RuntimeInformation.IsOSPlatform(OSPlatform.Windows) 
            ? "Central European Standard Time" 
            : "Europe/Sarajevo";

        public static TimeZoneInfo GetFacilityTimeZone()
        {
            return TimeZoneInfo.FindSystemTimeZoneById(TimeZoneId);
        }

        public static DateTime GetFacilityNow()
        {
            return TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, GetFacilityTimeZone());
        }

        public static DateTime ConvertToUtc(DateTime facilityLocalTime)
        {
            // First, make sure the kind is Unspecified before conversion to avoid double conversions
            var unspecifiedTime = DateTime.SpecifyKind(facilityLocalTime, DateTimeKind.Unspecified);
            return TimeZoneInfo.ConvertTimeToUtc(unspecifiedTime, GetFacilityTimeZone());
        }
    }
}
