using Azure.Core;
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
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    //Implement method which retrieves all time slots for a facility based on the working hours and duration
    public class FacilityService : BaseCRUDService<FacilityResponse,Facility,FacilitySearchObject,FacilityInsertRequest,FacilityUpdateRequest>, IFacilityService
    {

        public FacilityService(TerminBaContext context,IMapper mapper):base(context,mapper)
        {
        }

        public override async Task<FacilityResponse> CreateAsync(FacilityInsertRequest request)
        {

            Facility entity = new Facility();

            entity = MapInsertToEntity(entity, request);

            if (request.AvailableSportsIds != null && request.AvailableSportsIds.Any())
            {
                var sports = await _context.Sports
                    .Where(s => request.AvailableSportsIds.Contains(s.Id))
                    .ToListAsync();

                entity.AvailableSports = sports;
            }

            await BeforeInsert(entity, request);

            await _context.Facilities.AddAsync(entity);

            await _context.SaveChangesAsync();

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(Facility entity, FacilityInsertRequest request)
        {
            await ValidateFacilityRequest(request.SportCenterId, request.Name, request.AvailableSportsIds, request.TurfTypeId);
        }

        protected override async Task BeforeUpdate(Facility entity, FacilityUpdateRequest request)
        {
            await ValidateFacilityRequest(request.SportCenterId, request.Name, request.AvailableSportsIds, request.TurfTypeId);
        }

        private async Task ValidateFacilityRequest(int sportCenterId, string name, List<int> availableSportsIds, int turfTypeId)
        {
            var sportCenter = await _context.SportCenters
                .Select(sc => new { sc.Id, AvailableSportIds = sc.AvailableSports.Select(s => s.Id).ToList() })
                .FirstOrDefaultAsync(sc => sc.Id == sportCenterId);

            if (sportCenter == null)
                throw new UserException($"Sport center was not found.");

            bool nameExists = await _context.Facilities.AnyAsync(f =>
                f.SportCenterId == sportCenterId &&
                f.Name.ToLower() == name.ToLower());

            if (nameExists)
                throw new UserException($"Facility with name: {name} already exits for entered sport center.");

            bool allSportsPresent = availableSportsIds.All(x => sportCenter.AvailableSportIds.Contains(x));

            if (!allSportsPresent)
                throw new UserException($"Sport center does not support all given sports.");

            if (!await _context.TurfTypes.AnyAsync(x => x.Id == turfTypeId))
                throw new UserException($"Turf type was not found.");
        }
    }
}
