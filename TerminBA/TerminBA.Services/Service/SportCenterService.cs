using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
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

namespace TerminBA.Services.Service
{
    public class SportCenterService : BaseCRUDService<SportCenterResponse, SportCenter, SportCenterSearchObject, SportCenterInsertRequest, SportCenterUpdateRequest>, ISportCenterService
    {
        private readonly IWorkingHoursService _workingHoursService;
        private readonly IReportService _reportService;

        public SportCenterService(TerminBaContext context, IMapper mapper,IWorkingHoursService workingHoursService, IReportService reportService) : base(context, mapper)
        {
            _workingHoursService = workingHoursService;
            _reportService = reportService;
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

        public override IQueryable<SportCenter> ApplyIncludes(IQueryable<SportCenter> query)
        {
            return query
                 .Include(sc => sc.City)
                 .Include(sc => sc.Role)
                 .Include(sc => sc.AvailableAmenities)
                 .Include(sc => sc.AvailableSports)
                 .Include(sc => sc.WorkingHours);
        }

        protected override async Task BeforeInsert(SportCenter entity, SportCenterInsertRequest request)
        {
            var sameNameCenter=await _context.SportCenters.AnyAsync(sc=>sc.Username!.ToLower() == request.Username!.ToLower());

            if (sameNameCenter)
                throw new UserException($"Sport center with name: {request.Username} already exits.");
        }

        protected override async Task BeforeUpdate(SportCenter entity, SportCenterUpdateRequest request)
        {
            if(entity.Username!.ToLower()!=request.Username!.ToLower())
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

        }

        //public override async Task<SportCenterResponse?> UpdateAsync(int id, SportCenterUpdateRequest request)
        //{
        //    var existingWorkingHours = await _context.WorkingHours
        //        .Where(wh => wh.SportCenterId == id)
        //        .ToListAsync();

        //    _context.WorkingHours.RemoveRange(existingWorkingHours);

        //    return await base.UpdateAsync(id, request);
        //}
    }
}






