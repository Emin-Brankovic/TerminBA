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
    public class FacilityDynamicPriceService : BaseCRUDService<FacilityDynamicPriceResponse, FacilityDynamicPrice, FacilityDynamicPriceSearchObject, FacilityDynamicPriceInsertRequest, FacilityDynamicPriceUpdateRequest>, IFacilityDynamicPriceService
    {
        public FacilityDynamicPriceService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<FacilityDynamicPrice> ApplyFilter(IQueryable<FacilityDynamicPrice> query, FacilityDynamicPriceSearchObject search)
        {

            if (search.FacilityId.HasValue)
            {
                query = query.Where(fdp => fdp.FacilityId == search.FacilityId.Value);
            }

            if (search.StartDay.HasValue)
            {
                query = query.Where(fdp => fdp.StartDay == search.StartDay.Value);
            }

            if (search.EndDay.HasValue)
            {
                query = query.Where(fdp => fdp.EndDay == search.EndDay.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(fdp => fdp.IsActive == search.IsActive.Value);
            }

            if (search.ValidFrom.HasValue)
            {
                query = query.Where(fdp => fdp.ValidFrom <= search.ValidFrom.Value);
            }

            if (search.ValidTo.HasValue)
            {
                query = query.Where(fdp => fdp.ValidTo == null || fdp.ValidTo >= search.ValidTo.Value);
            }

            return query;
        }

        protected override FacilityDynamicPriceResponse MapToResponse(FacilityDynamicPrice entity)
        {
            return new FacilityDynamicPriceResponse
            {
                Id = entity.Id,
                FacilityId = entity.FacilityId,
                FacilityName = entity.Facility?.Name, // null if not included

                StartDay = entity.StartDay,
                EndDay = entity.EndDay,

                StartTime = entity.StartTime,
                EndTime = entity.EndTime,

                PricePerHour = entity.PricePerHour,

                IsActive = entity.IsActive, // C# computed property

                ValidFrom = entity.ValidFrom,
                ValidTo = entity.ValidTo
            };
        }

        protected override async Task BeforeInsert(FacilityDynamicPrice entity, FacilityDynamicPriceInsertRequest request)
        {
            ValidateFacilityDynamicPriceRequest(request.StartTime, request.EndTime, request.ValidFrom, request.ValidTo);
        }

        protected override async Task BeforeUpdate(FacilityDynamicPrice entity, FacilityDynamicPriceUpdateRequest request)
        {
            ValidateFacilityDynamicPriceRequest(request.StartTime, request.EndTime, request.ValidFrom, request.ValidTo);
        }

        public override IQueryable<FacilityDynamicPrice> ApplyIncludes(IQueryable<FacilityDynamicPrice> query)
        {
            query=query.Include(f => f.Facility);
            return query;
        }

        private void ValidateFacilityDynamicPriceRequest(TimeOnly startTime, TimeOnly endTime, DateOnly validFrom, DateOnly? validTo)
        {

            if (startTime >= endTime)
            {
                throw new UserException("Start time must be before end time.");
            }

            if (validTo.HasValue && validFrom > validTo.Value)
            {
                throw new UserException("ValidFrom date must be before or equal to ValidTo date.");
            }
        }
    }
}

