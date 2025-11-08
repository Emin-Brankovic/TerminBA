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

        public SportCenterService(TerminBaContext context, IMapper mapper,IWorkingHoursService workingHoursService) : base(context, mapper)
        {
            _workingHoursService = workingHoursService;
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

            entity.PasswordSalt = HashingHelper.GenerateSalt();
            entity.PasswordHash = HashingHelper.GenerateHash(entity.PasswordSalt, "password"); // temporary solution

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

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(SportCenter entity, SportCenterInsertRequest request)
        {
            var sameNameCenter=await _context.SportCenters.AnyAsync(sc=>sc.Username!.ToLower() == request.Username!.ToLower());

            if (sameNameCenter)
                throw new UserException($"Sport center with name:{request.Username} already exits.");
        }

        protected override async Task BeforeUpdate(SportCenter entity, SportCenterUpdateRequest request)
        {
            var sameNameCenter = await _context.SportCenters.AnyAsync(sc => sc.Username!.ToLower() == request.Username!.ToLower());

            if (sameNameCenter)
                throw new UserException($"Sport center with name:{request.Username} already exits.");
        }
    }
}





