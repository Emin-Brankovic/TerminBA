using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class CityService : BaseCRUDService<CityResponse,City,CitySearchObject,CityInsertRequest,CityUpdateRequest>, ICityService
    {
        private readonly TerminBaContext _context;

        public CityService(TerminBaContext context): base(context)
        {
            this._context = context;
        }

        protected override CityResponse MapToResponse(City entity)
        {
            return new CityResponse
            {
                Id=entity.Id,
                Name = entity.Name
            };
        }

        protected override City MapInsertToEntity(CityInsertRequest request)
        {
            return new City
            {
                Name = request.Name
            };
        }

        protected override City MapUpdateToEntity(CityUpdateRequest request)
        {
            return new City
            {
                Name = request.Name
            };
        }

        public override IQueryable<City> ApplyFilter(IQueryable<City> query, CitySearchObject search)
        {
            if(!string.IsNullOrEmpty(search.CityName))
                query = query.Where(c => c.Name.ToLower() == search.CityName.ToLower());

            return query;
        }
    }
}
