using System;

namespace TerminBA.Models.SearchObjects
{
    public class SportCenterAvailabilitySearchObject : BaseSearchObject
    {
        public string? Username { get; set; }
        public int? CityId { get; set; }
        public string? CityName { get; set; }
        public int? SportId { get; set; }
        public DateOnly? Date { get; set; }
    }
}
