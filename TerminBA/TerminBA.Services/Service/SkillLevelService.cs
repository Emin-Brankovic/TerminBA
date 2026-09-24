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
    public class SkillLevelService : BaseCRUDService<SkillLevelResponse, SkillLevel, SkillLevelSearchObject, SkillLevelInsertRequest, SkillLevelUpdateRequest>, ISkillLevelService
    {
        public SkillLevelService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<SkillLevel> ApplyFilter(IQueryable<SkillLevel> query, SkillLevelSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name!.ToLower().Contains(search.Name.ToLower()));
            }

            return base.ApplyFilter(query, search);
        }
    }
}
