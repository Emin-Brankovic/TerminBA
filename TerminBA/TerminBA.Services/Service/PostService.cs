using Azure.Core;
using MapsterMapper;
using Microsoft.AspNetCore.Http.Metadata;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
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
using TerminBA.Services.PostStateMachine;

namespace TerminBA.Services.Service
{
    public class PostService : BaseCRUDService<PostResponse, Post, PostSearchObject, PostInsertRequest, PostUpdateRequest>, IPostService
    {
        protected readonly BasePostState _basePostState;

        public PostService(TerminBaContext context, IMapper mapper, BasePostState basePostState) : base(context, mapper)
        {
            this._basePostState = basePostState;
        }

        public async override Task<PagedResult<PostResponse>> GetAsync(PostSearchObject search)
        {
            var query = _context.Posts.AsQueryable();

            query = ApplyFilter(query, search);

            query = ApplyIncludes(query);

            int totalCount = await query.CountAsync();

            if (search.Page.HasValue && search.PageSize.HasValue)
            {
                query = query
                    .Skip((search.Page.Value - 1) * search.PageSize.Value)
                    .Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();
            
            foreach (var p in list)
            {
                if (p.Reservation != null)
                {
                    var today = DateOnly.FromDateTime(DateTime.Now);
                    var now = TimeOnly.FromDateTime(DateTime.Now);

                    bool isPastReservation =
                        p.Reservation.ReservationDate < today ||
                        (p.Reservation.ReservationDate == today &&
                         p.Reservation.StartTime <= now);

                    if (isPastReservation)
                        p.PostState = nameof(ClosedPostState);
                }
            }

            await _context.SaveChangesAsync();

            return new PagedResult<PostResponse>()
            {
                Items = list.Select(MapToResponse).ToList(),
                Count = totalCount
            };
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

        public async override Task<PostResponse> CreateAsync(PostInsertRequest request)
        {
            var baseState=_basePostState.GetPostState(nameof(DraftPostState));
            
            var result = await baseState.CreateAsync(request);

            return result;
        }

        public override async Task<PostResponse?> UpdateAsync(int id, PostUpdateRequest request)
        {
           var entity=await _context.Posts.FindAsync(id);

           var baseState = _basePostState.GetPostState(entity.PostState);

           return await baseState.UpdateAsync(id,request);
        }

        public async override Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Posts.FindAsync(id);

            var baseState = _basePostState.GetPostState(entity.PostState);

            return await baseState.DeleteAsync(id);
        }

        public async Task<PostResponse> ClosePost(int id)
        {
            var entity = await _context.Posts.FindAsync(id);

            var baseState = _basePostState.GetPostState(entity!.PostState);

            return await baseState.ClosePost(entity);
        }
    }
}