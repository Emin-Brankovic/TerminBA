using Microsoft.AspNetCore.Http;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace TerminBA.Models.Request
{
    public class SportCenterGalleryUpdateRequest
    {
        [MaxLength(12)]
        [JsonIgnore]
        public List<IFormFile>? PhotoFiles { get; set; }

        [MaxLength(12)]
        [JsonPropertyName("photos")]
        public List<string>? PhotosBase64 { get; set; }

        public List<int>? RemovedPhotoIds { get; set; }
    }
}
