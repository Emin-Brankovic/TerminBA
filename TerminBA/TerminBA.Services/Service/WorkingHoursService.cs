using MapsterMapper;
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
    public class WorkingHoursService : BaseCRUDService<WorkingHoursResponse, WorkingHours, WorkingHoursSearchObject, WorkingHoursInsertRequest, WorkingHoursUpdateRequest>, IWorkingHoursService
    {
        public WorkingHoursService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<WorkingHours> ApplyFilter(IQueryable<WorkingHours> query, WorkingHoursSearchObject search)
        {
            if (search.SportCenterId.HasValue)
                query = query.Where(wh => wh.SportCenterId == search.SportCenterId.Value);

            return query;
        }
    }
}




