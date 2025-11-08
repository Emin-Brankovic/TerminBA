using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
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
    public class PostService : BaseCRUDService<PostResponse, Post, PostSearchObject, PostInsertRequest, PostUpdateRequest>, IPostService
    {
        public PostService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Post> ApplyFilter(IQueryable<Post> query, PostSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.SkillLevel))
                query = query.Where(p => p.SkillLevel!.ToLower().Contains(search.SkillLevel.ToLower()));

            if(search.SportId.HasValue)
                query=query
                    .Where(p=>p.Reservation!.ChosenSportId==search.SportId);

            if (search.ReservationDate.HasValue)
                query = query
                    .Where(p => p.Reservation!.ReservationDate == search.ReservationDate);

            if (search.CityId.HasValue)
                query = query
                    .Where(p => p.Reservation!.Facility!.SportCenter!.CityId==search.CityId);

            if (search.TurfTypeId.HasValue)
                query = query
                    .Where(p => p.Reservation!.Facility!.TurfTypeId == search.TurfTypeId);

            return query;
        }

        public override IQueryable<Post> ApplyIncludes(IQueryable<Post> query)
        {
            query = query
                .Include(p => p.Reservation)
                    .ThenInclude(r => r.User)        
                .Include(p => p.Reservation)
                    .ThenInclude(r => r.Facility)    
                        .ThenInclude(f => f.SportCenter)
                .Include(p => p.Reservation)
                    .ThenInclude(r => r.ChosenSport);

            return query;
        }

        protected override async Task BeforeInsert(Post entity, PostInsertRequest request)
        {
            var currentDate = DateOnly.FromDateTime(DateTime.Now); 

            var currentTime=TimeOnly.FromDateTime(DateTime.Now);

            var reservation = await _context.Reservations.FirstOrDefaultAsync(r => r.Id == entity.ReservationId);


            if(currentDate > reservation!.ReservationDate)
                throw new UserException("Can create post for already begun/finished reservation");

            else if (currentDate==reservation!.ReservationDate && currentTime > reservation!.StartTime)
                throw new UserException("Can create post for already begun/finished reservation");
        }
    }
}





