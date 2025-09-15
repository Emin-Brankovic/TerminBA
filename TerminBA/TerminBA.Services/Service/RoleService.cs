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
    public class RoleService : BaseCRUDService<RoleResponse, Role, RoleSearchObject, RoleInsertRequest, RoleUpdateRequest>, IRoleService
    {
        public RoleService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Role> ApplyFilter(IQueryable<Role> query, RoleSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.RoleName))
            {
                query = query.Where(r => r.RoleName.ToLower().Contains(search.RoleName.ToLower()));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(r => r.RoleName.ToLower().Contains(search.FTS.ToLower()) || r.RoleDescription.ToLower().Contains(search.FTS));
            }

            return query;
        }
    }
}


