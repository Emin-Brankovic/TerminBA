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
    public class AmenityService : BaseCRUDService<AmenityResponse, Amenity, AmenitySearchObject, AmenityInsertRequest, AmenityUpdateRequest>, IAmenityService
    {
        public AmenityService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Amenity> ApplyFilter(IQueryable<Amenity> query, AmenitySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(a => a.Name.ToLower().Contains(search.Name.ToLower()));
            }

            return query;
        }
    }
}


