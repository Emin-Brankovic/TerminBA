using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public abstract class BaseCRUDService<T, TEntity, TSearch, TInsert, TUpdate> : BaseService<T, TEntity, TSearch>, IBaseCRUDService<T, TSearch, TInsert, TUpdate> where T : class where TEntity : class,new() where TSearch : BaseSearchObject where TInsert : class where TUpdate : class
    {
        protected readonly TerminBaContext _context;

        public  BaseCRUDService(TerminBaContext context,IMapper mapper) : base(context,mapper)
        {
            this._context = context;
        }

        public virtual async Task<T> CreateAsync(TInsert request)
        {
            TEntity entity = new TEntity();

            entity = MapInsertToEntity(entity, request);

            await BeforeInsert(entity, request);

            await _context.Set<TEntity>().AddAsync(entity);

            await _context.SaveChangesAsync();

            return MapToResponse(entity);

        }

        public virtual async Task<T?> UpdateAsync(int id, TUpdate request)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);

            if (entity == null)
                return null;

            await BeforeUpdate(entity,request);

            entity = MapUpdateToEntity(entity,request);

            await _context.SaveChangesAsync();

            return MapToResponse(entity);

        }


        public virtual async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);

            if (entity == null)
                return false;

            await BeforeDelete(entity);

            _context.Set<TEntity>().Remove(entity);

            await _context.SaveChangesAsync();

            return true;

        }

        protected virtual TEntity MapInsertToEntity(TEntity entity,TInsert request)
        {
            return _mapper.Map(request, entity);
        }

        protected virtual TEntity MapUpdateToEntity (TEntity entity,TUpdate request)
        {
            return _mapper.Map(request, entity);
        }


        protected virtual async Task BeforeInsert(TEntity entity, TInsert request)
        {

        }

        protected virtual async Task BeforeUpdate(TEntity entity, TUpdate request)
        {

        }

        protected virtual async Task BeforeDelete(TEntity entity)
        {

        }

    }
}
