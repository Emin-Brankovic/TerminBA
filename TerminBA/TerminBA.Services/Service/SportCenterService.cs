using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;
using TerminBA.Services.Interfaces;
using TerminBA.Services.ReservationStateMachine;

namespace TerminBA.Services.Service
{
    public class SportCenterService : BaseCRUDService<SportCenterResponse, SportCenter, SportCenterSearchObject, SportCenterInsertRequest, SportCenterUpdateRequest>, ISportCenterService
    {
        private readonly IWorkingHoursService _workingHoursService;
        private readonly IReportService _reportService;
        private readonly IAuthService<SportCenter> _authService;
        private readonly IPhotoService _photoService;
        private readonly IGeocodingService _geocodingService;

        public SportCenterService(TerminBaContext context, IMapper mapper, IWorkingHoursService workingHoursService, IReportService reportService, IAuthService<SportCenter> authService, IPhotoService photoService, IGeocodingService geocodingService) : base(context, mapper)
        {
            _workingHoursService = workingHoursService;
            _reportService = reportService;
            _authService = authService;
            _photoService = photoService;
            _geocodingService = geocodingService;
        }

        public async Task<AuthResponse?> Login(SportCenterLoginRequest request)
        {
            var response = await _authService.Login(request);

            return response;
        }

        public override IQueryable<SportCenter> ApplyFilter(IQueryable<SportCenter> query, SportCenterSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(sc => sc.Username!.ToLower().Contains(search.Name.ToLower()));

            if (search.CityId.HasValue)
                query = query.Where(sc => sc.CityId == search.CityId.Value);

            if (search.IsEquipmentProvided.HasValue)
                query = query.Where(sc => sc.IsEquipmentProvided == search.IsEquipmentProvided.Value);

            return query;
        }

        public override async Task<SportCenterResponse> CreateAsync(SportCenterInsertRequest request)
        {
            SportCenter entity = new SportCenter();

            var sportcenter = MapInsertToEntity(entity, request);

            if (request.SportIds != null && request.SportIds.Any())
            {
                var sports = await _context.Sports
                    .Where(s => request.SportIds.Contains(s.Id))
                    .ToListAsync();

                entity.AvailableSports = sports;
            }

            if (request.AmenityIds != null && request.AmenityIds.Any())
            {
                var amenities = await _context.Amenity
                    .Where(s => request.AmenityIds.Contains(s.Id))
                    .ToListAsync();

                entity.AvailableAmenities = amenities;
            }

            string randomPassword = StringHelper.GenerateRandomString();

            entity.PasswordSalt = HashingHelper.GenerateSalt();
            entity.PasswordHash = HashingHelper.GenerateHash(entity.PasswordSalt, randomPassword); // temporary solution

            await BeforeInsert(entity,request);

            _context.Add(entity);

            await _context.SaveChangesAsync();

            var workingHoursEntities = request.WorkingHours
                    !.Select(wh => new WorkingHours
                    {
                        SportCenterId = sportcenter.Id,
                        StartDay = wh.StartDay,
                        EndDay = wh.EndDay,
                        OpeningHours = wh.OpeningHours,
                        CloseingHours = wh.CloseingHours,
                        ValidFrom = wh.ValidFrom,
                        ValidTo = wh.ValidTo
                    }).ToList();

            await _context.AddRangeAsync(workingHoursEntities);

            byte[] pdfBytes = _reportService.SportCenterCredentialsReport(entity.Username!, randomPassword);

            var response = MapToResponse(entity);

            response.CredentialsReport = pdfBytes;

            return response;
        }

        public async Task<SportCenterResponse> GetCurrentSportCenter()
        {
            var id = int.Parse(_authService.GetUserId());

            var query = _context.SportCenters.AsQueryable();

            query = ApplyIncludes(query);

            var entity = await query.FirstOrDefaultAsync(sc=>sc.Id==id);

            if (entity == null)
                throw new UserException("Sport center not found");


            return MapToResponse(entity);
        }

        public async Task<SportCenterResponse> UpdateCurrentGallery(SportCenterGalleryUpdateRequest request)
        {
            var id = int.Parse(_authService.GetUserId());

            var query = _context.SportCenters.AsQueryable();
            query = ApplyIncludes(query);

            var entity = await query.FirstOrDefaultAsync(sc => sc.Id == id);

            if (entity == null)
                throw new UserException("Sport center not found");

            await UpdateGalleryAsync(entity, request.RemovedPhotoIds, request.PhotosBase64);

            return MapToResponse(entity);
        }

        public async Task<PagedResult<SportCenterResponse>> SearchAvailableAsync(
            SportCenterAvailabilitySearchObject search)
        {
            if (!search.Date.HasValue)
                throw new UserException("Date is required for availability search.");

            //if (!search.SportId.HasValue)
            //    throw new UserException("Sport is required for availability search.");

            if (!search.CityId.HasValue && string.IsNullOrWhiteSpace(search.CityName))
                throw new UserException("City is required for availability search.");

            var date = search.Date.Value;
            var sportId = search.SportId;

            var facilitiesQuery = _context.Facilities.AsQueryable();
            if(sportId != null)
                facilitiesQuery = facilitiesQuery.Where(f =>
                    f.AvailableSports.Any(s => s.Id == sportId));

            if (search.CityId.HasValue)
            {
                facilitiesQuery = facilitiesQuery.Where(
                    f => f.SportCenter != null && f.SportCenter.CityId == search.CityId);
            }
            else if (!string.IsNullOrWhiteSpace(search.CityName))
            {
                var cityName = search.CityName.Trim().ToLower();
                facilitiesQuery = facilitiesQuery.Where(
                    f =>
                        f.SportCenter!.City!.Name!.ToLower().Contains(cityName));
            }

            var facilities = await facilitiesQuery
                .Select(f => new { f.Id, f.SportCenterId })
                .ToListAsync();

            if (!facilities.Any())
            {
                return new PagedResult<SportCenterResponse>
                {
                    Items = new List<SportCenterResponse>(),
                    Count = 0
                };
            }

            var availableSportCenterIds = new HashSet<int>();

            foreach (var facility in facilities)
            {
                if (await FacilityHasFreeSlotAsync(facility.Id, date))
                {
                    availableSportCenterIds.Add(facility.SportCenterId);
                }
            }

            if (availableSportCenterIds.Count == 0)
            {
                return new PagedResult<SportCenterResponse>
                {
                    Items = new List<SportCenterResponse>(),
                    Count = 0
                };
            }

            var query = _context.SportCenters.AsQueryable();
            query = ApplyIncludes(query);
            query = query.Where(sc => availableSportCenterIds.Contains(sc.Id));

            var totalCount = await query.CountAsync();

            if (search.Page.HasValue && search.PageSize.HasValue)
            {
                query = query
                    .Skip((search.Page.Value - 1) * search.PageSize.Value)
                    .Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            return new PagedResult<SportCenterResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                Count = totalCount
            };
        }

        public override IQueryable<SportCenter> ApplyIncludes(IQueryable<SportCenter> query)
        {
            return query
                 .Include(sc => sc.City)
                 .Include(sc => sc.Role)
                 .Include(sc => sc.AvailableAmenities)
                 .Include(sc => sc.AvailableSports)
                 .Include(sc => sc.WorkingHours)
                 .Include(sc => sc.Photos);
        }

        private async Task<bool> FacilityHasFreeSlotAsync(int facilityId, DateOnly pickedDate)
        {
            var allSlots = await TimeSlotHelper.GenerateTimeSlots(
                facilityId,
                pickedDate,
                _context
            );

            var bookedReservations = await _context.Reservations
                .Where(r => r.FacilityId == facilityId
                    && r.ReservationDate == pickedDate
                    && (r.Status == nameof(ActiveReservationState)
                        || r.Status == nameof(CompletedReservationState)))
                .Select(r => r.StartTime)
                .ToListAsync();

            var occupiedStartTimes = new HashSet<TimeSpan>(
                bookedReservations.Select(ts => ts.ToTimeSpan())
            );

            var today = DateOnly.FromDateTime(DateTime.Now);

            return allSlots.Any(t =>
                !occupiedStartTimes.Contains(t.Start)
                && pickedDate >= today
            );
        }


        protected override async Task BeforeInsert(SportCenter entity, SportCenterInsertRequest request)
        {
            var sameNameCenter = await _context.SportCenters.AnyAsync(sc => sc.Username!.ToLower() == request.Username!.ToLower());

            if (sameNameCenter)
                throw new UserException($"Sport center with name: {request.Username} already exits.");

            await TryGeocodeAsync(entity, request.Address, request.CityId);
        }

        private async Task TryGeocodeAsync(SportCenter entity, string address, int cityId)
        {
            var cityName = await _context.Cities
                .Where(c => c.Id == cityId)
                .Select(c => c.Name)
                .FirstOrDefaultAsync();

            var fullAddress = string.IsNullOrWhiteSpace(cityName)
                ? address
                : $"{address}, {cityName}, Bosnia and Herzegovina";


            var coords = await _geocodingService.GeocodeAddressAsync(fullAddress);

            if (coords.HasValue)
            {
                entity.Latitude = coords.Value.Latitude;
                entity.Longitude = coords.Value.Longitude;
            }
        }

        protected override async Task BeforeUpdate(SportCenter entity, SportCenterUpdateRequest request)
        {
            if (entity.Username!.ToLower() != request.Username!.ToLower())
            {
                var sameNameCenter = await _context.SportCenters.AnyAsync(sc => sc.Username!.ToLower() == request.Username!.ToLower());

                if (sameNameCenter)
                    throw new UserException($"Sport center with name: {request.Username} already exits.");
            }

            _context.Entry(entity).Collection(sc => sc.AvailableSports).Load();
            _context.Entry(entity).Collection(sc => sc.AvailableAmenities).Load();
            _context.Entry(entity).Collection(sc => sc.WorkingHours).Load();

            var existingSports = await _context.Sports
                .Where(s => request.SportIds!.Contains(s.Id))
                .ToListAsync();

            var existingAmenities = await _context.Amenity
                .Where(s => request.AmenityIds!.Contains(s.Id))
                .ToListAsync();

            var existingWorkingHours = await _context.WorkingHours
                .Where(wh => wh.SportCenterId == entity.Id)
                .ToListAsync();

            entity.WorkingHours = existingWorkingHours;
            entity.AvailableSports = existingSports;
            entity.AvailableAmenities = existingAmenities;


            bool addressChanged = !string.Equals(entity.Address, request.Address, StringComparison.OrdinalIgnoreCase);
            bool cityChanged = entity.CityId != request.CityId;
            bool hasExplicitCoords = request.Latitude.HasValue && request.Longitude.HasValue;

            if (hasExplicitCoords)
            {
                entity.Latitude = request.Latitude;
                entity.Longitude = request.Longitude;
            }
            else if (addressChanged || cityChanged)
            {
                await TryGeocodeAsync(entity, request.Address, request.CityId);
            }

           // await UpdateGalleryAsync(entity, request.RemovedPhotoIds, request.PhotosBase64);
        }

        private async Task UpdateGalleryAsync(SportCenter entity, List<int>? removedPhotoIds, List<string>? photosBase64)
        {
            if (removedPhotoIds != null && removedPhotoIds.Any())
            {
                _context.Entry(entity).Collection(sc => sc.Photos).Load();

                var photosToRemove = entity.Photos
                    .Where(p => removedPhotoIds.Contains(p.Id))
                    .ToList();

                if (photosToRemove.Any())
                {
                    foreach (var photo in photosToRemove)
                    {
                        if (!string.IsNullOrWhiteSpace(photo.PublicId))
                        {
                            await _photoService.DeleteSportCenterPhotoAsync(photo.PublicId);
                        }
                    }

                    _context.SportCenterPhotos.RemoveRange(photosToRemove);
                    await _context.SaveChangesAsync();
                }
            }

            if (photosBase64 == null || !photosBase64.Any())
            {
                return;
            }

            var photos = new List<SportCenterPhoto>();
            foreach (var base64Photo in photosBase64)
            {
                if (string.IsNullOrWhiteSpace(base64Photo))
                {
                    continue;
                }

                var photoBytes = DecodeBase64Photo(base64Photo);
                using var stream = new MemoryStream(photoBytes);
                var fileName = $"sportcenter_{Guid.NewGuid():N}.jpg";
                var formFile = new FormFile(stream, 0, photoBytes.Length, "photos", fileName)
                {
                    Headers = new HeaderDictionary(),
                    ContentType = "image/jpeg"
                };

                var result = await _photoService.UploadSportCenterPhotoAsync(formFile);
                photos.Add(new SportCenterPhoto
                {
                    Url = result.SecureUrl.AbsoluteUri,
                    PublicId = result.PublicId,
                    SportCenter = entity
                });
            }

            if (photos.Any())
            {
                foreach (var photo in photos)
                {
                    photo.SportCenterId = entity.Id;
                }

                entity.Photos = photos;
                await _context.SportCenterPhotos.AddRangeAsync(photos);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<double> GetAverageRatingAsync(int sportCenterId)
        {
            var avg = await _context.FacilityReviews
                .Include(r=>r.Facility)
                .Where(r => r.Facility!.SportCenterId == sportCenterId)
                .Select(r => (double?)r.RatingNumber)
                .AverageAsync() ?? 0.0;

            return Math.Round(avg, 1);
        }


        private static byte[] DecodeBase64Photo(string base64Photo)
        {
            var trimmed = base64Photo.Trim();
            var commaIndex = trimmed.IndexOf(",", StringComparison.Ordinal);
            if (commaIndex >= 0 && trimmed.Substring(0, commaIndex).Contains("base64", StringComparison.OrdinalIgnoreCase))
            {
                trimmed = trimmed[(commaIndex + 1)..];
            }

            return Convert.FromBase64String(trimmed);
        }
    }
}






