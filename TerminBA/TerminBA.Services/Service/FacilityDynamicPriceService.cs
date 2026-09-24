using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Exceptions;
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
        private readonly IAuthService<AccountBase> _authService;
        private readonly Dictionary<string, string> _currentUser;
        private readonly IPeriodValidatorService _periodValidator;

        public FacilityDynamicPriceService(TerminBaContext context, IMapper mapper, IAuthService<AccountBase> authService, IPeriodValidatorService periodValidator) : base(context, mapper)
        {
            _authService = authService;
            _currentUser = _authService.GetCurrentUser();
            _periodValidator = periodValidator;
        }

        public async Task<decimal> DynamicPriceForDateAsync(DynamicPriceForDateRequest request)
        {
            var facility = await _context.Facilities
                    .Include(f => f.DynamicPrices)
                    .FirstOrDefaultAsync(f => f.Id == request.FacilityId);

            if (facility == null)
                throw new UserException("Facility not found.");

            var price = DynamicPriceHelper.GetExpectedPrice(
                facility,
                request.ReservationDate,
                request.StartTime,
                request.EndTime);

            return price;
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
                FacilityName = entity.Facility?.Name,

                StartDay = entity.StartDay,
                EndDay = entity.EndDay,

                StartTime = entity.StartTime,
                EndTime = entity.EndTime,

                Price = entity.Price,

                IsActive = entity.IsActive,

                ValidFrom = entity.ValidFrom,
                ValidTo = entity.ValidTo
            };
        }

        protected override async Task BeforeInsert(FacilityDynamicPrice entity, FacilityDynamicPriceInsertRequest request)
        {
            var facility = await _context.Facilities.FirstOrDefaultAsync(f => f.Id == request.FacilityId);
            if (facility == null)
            {
                throw new UserException("Facility not found.");
            }

            if (_currentUser["userRole"] == "Sport center")
            {
                if (facility.SportCenterId != int.Parse(_authService.GetUserId()))
                {
                    throw new UserException("You can only create dynamic prices for your own facilities.");
                }
            }

            await _periodValidator.ValidateDynamicPriceInsertAsync(facility.SportCenterId, request);
        }

        protected override async Task BeforeUpdate(FacilityDynamicPrice entity, FacilityDynamicPriceUpdateRequest request)
        {
            var facility = await _context.Facilities.FirstOrDefaultAsync(f => f.Id == entity.FacilityId);
            if (facility == null)
            {
                throw new UserException("Facility not found.");
            }

            if (_currentUser["userRole"] == "Sport center")
            {
                if (facility.SportCenterId != int.Parse(_authService.GetUserId()))
                {
                    throw new UserException("You can only modify dynamic prices for your own facilities.");
                }
            }
            else
            {
                // Ensure request-supplied IDs cannot bypass validation for admins too
                request.FacilityId = entity.FacilityId;
            }

            if (request.FacilityId != entity.FacilityId)
            {
                throw new UserException("Changing FacilityId is not allowed.");
            }

            await _periodValidator.ValidateDynamicPriceUpdateAsync(entity.Id, facility.SportCenterId, request);
        }

        protected override async Task BeforeDelete(FacilityDynamicPrice entity)
        {
            if (_currentUser["userRole"] == "Sport center")
            {
                var facility = await _context.Facilities.FirstOrDefaultAsync(f => f.Id == entity.FacilityId);
                if (facility == null || facility.SportCenterId != int.Parse(_authService.GetUserId()))
                {
                    throw new UserException("You can only delete dynamic prices for your own facilities.");
                }
            }
        }

        public override IQueryable<FacilityDynamicPrice> ApplyIncludes(IQueryable<FacilityDynamicPrice> query)
        {
            query=query.Include(f => f.Facility);
            return query;
        }

        // Removed validation methods

    }
}

