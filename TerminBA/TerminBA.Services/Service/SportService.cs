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
    public class SportService : BaseCRUDService<SportResponse, Sport, SportSearchObject, SportInserRequest, SportUpdateRequest>, ISportService
    {
        public SportService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Sport> ApplyFilter(IQueryable<Sport> query, SportSearchObject search)
        {
            if(!string.IsNullOrEmpty(search.SportName))
            {
                query = query.Where(c => c.SportName!.ToLower().Contains(search.SportName.ToLower()));
            }

            return query;
        }
    }
}
