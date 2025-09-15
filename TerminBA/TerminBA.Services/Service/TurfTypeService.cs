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
    public class TurfTypeService : BaseCRUDService<TurfTypeResponse, TurfType, TurfTypeSearchObject, TurfTypeInsertRequest, TurfTypeUpdateRequest>, ITurfTypeService
    {
        public TurfTypeService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<TurfType> ApplyFilter(IQueryable<TurfType> query, TurfTypeSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(t => t.Name.ToLower().Contains(search.Name.ToLower()));
            }

            return query;
        }
    }
}


