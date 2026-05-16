using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Execptions;

namespace TerminBA.Services.Helpers
{
    public static class FileValidator
    {
        private const long MaxImageSize = 3 * 1024 * 1024; // 3 MB
        private static readonly string[] AllowedImageExtensions = { ".jpg", ".jpeg", ".png"};
        private static readonly string[] AllowedImageMimeTypes = { "image/jpeg", "image/png" };

        private static readonly string[] AllowedDocumentExtensions = { ".pdf", ".doc", ".docx", ".jpg", ".jpeg", ".png" };
        private static readonly string[] AllowedDocumentMimeTypes =
        {
            "application/pdf",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "image/jpeg",
            "image/png"
        };


        public static void ValidateImage(IFormFile file)
        {
            ValidateFile(file, MaxImageSize, AllowedImageExtensions, AllowedImageMimeTypes);

            using var stream = file.OpenReadStream();
            using var reader = new BinaryReader(stream);
            var headerBytes = reader.ReadBytes(8);

            if (!IsValidImageHeader(headerBytes))
                throw new UserException("File content does not match common image formats.");
        }


        public static void ValidateFile(IFormFile file, long maxSize, string[] allowedExtensions, string[] allowedMimeTypes)
        {
            if (file == null || file.Length == 0)
                throw new UserException("File is empty or not provided.");

            if (file.Length > maxSize)
                throw new UserException($"File size exceeds the limit of {maxSize / 1024 / 1024}MB.");

            // 1. Extension check
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (allowedExtensions != null && !allowedExtensions.Contains(extension))
                throw new UserException("Unsupported file extension.");

            // 2. MIME type check
            if (allowedMimeTypes != null && !allowedMimeTypes.Contains(file.ContentType.ToLowerInvariant()))
                throw new UserException("Unsupported MIME type.");

            // 3. Filename sanitization (Path Traversal protection)
            var fileName = Path.GetFileName(file.FileName);
            if (string.IsNullOrEmpty(fileName) || fileName.Contains("/") || fileName.Contains("\\") || fileName.Contains("..") || fileName.Any(c => Path.GetInvalidFileNameChars().Contains(c)))
                throw new UserException("Invalid filename characters detected.");
        }


        private static bool IsValidImageHeader(byte[] header)
        {
            if (header.Length < 4) return false;

            // JPEG: FF D8 FF
            if (header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF) return true;

            // PNG: 89 50 4E 47
            if (header[0] == 0x89 && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47) return true;

            return false;
        }
    }
}
