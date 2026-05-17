using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Interfaces
{
    public interface IPhotoService
    {
        Task<ImageUploadResult> UploadFacilityPhotoAsync(IFormFile file);
        Task DeleteFacilityPhotoAsync(string publicId);
        Task<ImageUploadResult> UploadSportCenterPhotoAsync(IFormFile file);
        Task DeleteSportCenterPhotoAsync(string publicId);
    }
}
