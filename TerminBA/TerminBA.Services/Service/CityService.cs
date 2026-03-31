using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
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
    public class CityService : BaseCRUDService<CityResponse,City,CitySearchObject,CityInsertRequest,CityUpdateRequest>, ICityService
    {

        public CityService(TerminBaContext context,IMapper mapper): base(context, mapper)
        {
        }

        public override IQueryable<City> ApplyFilter(IQueryable<City> query, CitySearchObject search)
        {
            if(!string.IsNullOrEmpty(search.CityName))
                query = query.Where(c => c.Name.ToLower().Contains(search.CityName.ToLower()));

            return query;
        }

        protected async override Task BeforeInsert(City entity, CityInsertRequest request)
        {
            bool exists = await _context.Cities.AnyAsync(c => c.Name!.ToLower() == request.Name.ToLower());

            if (exists)
                throw new UserException("City already exists");
        }

        protected async override Task BeforeUpdate(City entity, CityUpdateRequest request)
        {
            bool exists = await _context.Cities.AnyAsync(c => c.Name!.ToLower() == request.Name.ToLower());

            if (exists)
                throw new UserException("City already exists");
        }
    }
}
