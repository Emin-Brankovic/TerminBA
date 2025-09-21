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
    public class PostService : BaseCRUDService<PostResponse, Post, PostSearchObject, PostInsertRequest, PostUpdateRequest>, IPostService
    {
        public PostService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Post> ApplyFilter(IQueryable<Post> query, PostSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.SkillLevel))
                query = query.Where(p => p.SkillLevel.ToLower().Contains(search.SkillLevel.ToLower()));

            if (search.ReservationId.HasValue)
                query = query.Where(p => p.ReservationId == search.ReservationId.Value);

            return query;
        }
    }
}
