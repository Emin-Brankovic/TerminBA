using MapsterMapper;
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
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class WorkingHoursService : BaseCRUDService<WorkingHoursResponse, WorkingHours, WorkingHoursSearchObject, WorkingHoursInsertRequest, WorkingHoursUpdateRequest>, IWorkingHoursService
    {
        private readonly IAuthService<AccountBase> _authService;
        private readonly Dictionary<string, string> _currentUser;

        private readonly IPeriodValidatorService _periodValidator;

        public WorkingHoursService(TerminBaContext context, IMapper mapper, IAuthService<AccountBase> authService, IPeriodValidatorService periodValidator) : base(context, mapper)
        {
            _authService = authService;
            _currentUser = _authService.GetCurrentUser();
            _periodValidator = periodValidator;
        }

        public override IQueryable<WorkingHours> ApplyFilter(IQueryable<WorkingHours> query, WorkingHoursSearchObject search)
        {
            if (search.SportCenterId.HasValue)
                query = query.Where(wh => wh.SportCenterId == search.SportCenterId.Value);

            return query;
        }

        protected override async Task BeforeInsert(WorkingHours entity, WorkingHoursInsertRequest request)
        {
            if (_currentUser["userRole"] == "Sport center" && request.SportCenterId != int.Parse(_authService.GetUserId()))
            {
                throw new UserException("You can only create working hours for your own sport center.");
            }

            await _periodValidator.ValidateWorkingHoursInsertAsync(request.SportCenterId, request);
        }

        protected override async Task BeforeUpdate(WorkingHours entity, WorkingHoursUpdateRequest request)
        {
            if (_currentUser["userRole"] == "Sport center")
            {
                if (entity.SportCenterId != int.Parse(_authService.GetUserId()))
                {
                    throw new UserException("You can only modify working hours for your own sport center.");
                }
            }
            else
            {
                // Ensure request-supplied IDs cannot bypass validation for admins too
                request.SportCenterId = entity.SportCenterId;
            }

            if (request.SportCenterId != entity.SportCenterId)
            {
                throw new UserException("Changing SportCenterId is not allowed.");
            }

            await _periodValidator.ValidateWorkingHoursUpdateAsync(entity.Id, request);
        }

        protected override async Task BeforeDelete(WorkingHours entity)
        {
            if (_currentUser["userRole"] == "Sport center" && entity.SportCenterId != int.Parse(_authService.GetUserId()))
            {
                throw new UserException("You can only delete working hours for your own sport center.");
            }
        }
    }
}