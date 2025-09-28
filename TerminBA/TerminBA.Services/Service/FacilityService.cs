using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
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
            var sportCenter = await _context.SportCenters
                .Include(sc=>sc.AvailableSports)
                .FirstOrDefaultAsync(sc => sc.Id == request.SportCenterId);

            if (sportCenter == null)
                throw new ArgumentException($"Sport center with ID {request.SportCenterId} not found.");

            var facilityExists = await _context.Facilities
                .AnyAsync(f => f.Name.ToLower() == request.Name.ToLower() && f.SportCenterId == request.SportCenterId);

            if(facilityExists)
                throw new ArgumentException($"Facility with name:{request.Name} already exits for entered sport center.");

            var sportCenterSportIds = sportCenter.AvailableSports.Select(s => s.Id).ToList();

            bool allPresent = request.AvailableSportsIds.All(x => sportCenterSportIds.Contains(x));

            if (!allPresent)
                throw new ArgumentException($"Sport center does not support all given sports.");
        }
    }
}
