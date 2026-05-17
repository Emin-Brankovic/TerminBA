using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Services.Helpers;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class PhotoService : IPhotoService
    {
        private readonly Cloudinary _cloudinary;

        public PhotoService()
        {
            var cloudinaryCloudName = Environment.GetEnvironmentVariable("CloudinaryCloudName");
            var cloudinaryAPIKey = Environment.GetEnvironmentVariable("CloudinaryAPIKey");
            var cloudinaryAPISecret = Environment.GetEnvironmentVariable("CloudinaryAPISecret");

            var acc = new Account(cloudinaryCloudName, cloudinaryAPIKey, cloudinaryAPISecret);
            _cloudinary = new Cloudinary(acc);
        }

        public async Task<ImageUploadResult> UploadFacilityPhotoAsync(IFormFile file)
        {
            FileValidator.ValidateImage(file);
            var uploadResult = new ImageUploadResult();

            using var stream = file.OpenReadStream();
            var uploadParams = new ImageUploadParams
            {
                File = new FileDescription(file.FileName, stream),
                Transformation = new Transformation()
                    .Width(1200).Height(800).Crop("fill").Gravity("auto").Quality("auto:good").FetchFormat("auto"),
                Folder = "terminba/facility_photos"
            };

            uploadResult = await _cloudinary.UploadAsync(uploadParams);
            return uploadResult;
        }

        public async Task DeleteFacilityPhotoAsync(string publicId)
        {
            if (string.IsNullOrWhiteSpace(publicId))
            {
                return;
            }

            var deletionParams = new DeletionParams(publicId)
            {
                ResourceType = ResourceType.Image
            };

            await _cloudinary.DestroyAsync(deletionParams);
        }

        public async Task<ImageUploadResult> UploadSportCenterPhotoAsync(IFormFile file)
        {
            FileValidator.ValidateImage(file);
            var uploadResult = new ImageUploadResult();

            using var stream = file.OpenReadStream();
            var uploadParams = new ImageUploadParams
            {
                File = new FileDescription(file.FileName, stream),
                Transformation = new Transformation()
                    .Width(1200).Height(800).Crop("fill").Gravity("auto").Quality("auto:good").FetchFormat("auto"),
                Folder = "terminba/sport_center_photos"
            };

            uploadResult = await _cloudinary.UploadAsync(uploadParams);
            return uploadResult;
        }

        public async Task DeleteSportCenterPhotoAsync(string publicId)
        {
            if (string.IsNullOrWhiteSpace(publicId))
            {
                return;
            }

            var deletionParams = new DeletionParams(publicId)
            {
                ResourceType = ResourceType.Image
            };

            await _cloudinary.DestroyAsync(deletionParams);
        }
    }
}
