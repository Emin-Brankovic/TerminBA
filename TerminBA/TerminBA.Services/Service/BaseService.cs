using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public abstract class BaseService<T, TEntity, TSearch> : IBaseService<T, TSearch> where T : class where TSearch : BaseSearchObject where TEntity : class
    {
        private readonly TerminBaContext _context;
        protected readonly IMapper _mapper;

        public BaseService(TerminBaContext context,IMapper mapper)
        {
            this._context = context;
            this._mapper = mapper;
        }

        public virtual async Task<PagedResult<T>> GetAsync(TSearch search)
        {
            var query = _context.Set<TEntity>().AsQueryable();

            query = ApplyFilter(query,search);

            int totalCount = await query.CountAsync();

            if (search.Page.HasValue && search.PageSize.HasValue)
            {
                query = query
                    .Skip((search.Page.Value - 1) * search.PageSize.Value)
                    .Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            return new PagedResult<T>()
            {
                Items = list.Select(MapToResponse).ToList(),
                Count = totalCount
            };
        }

        public async Task<T?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);

            if (entity == null)
                return null;

            return MapToResponse(entity);

        }

        public virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TSearch search)
        {
            return query;
        }

        protected virtual T MapToResponse(TEntity entity)
        {
            return _mapper.Map<T>(entity);
        }
    }
}
