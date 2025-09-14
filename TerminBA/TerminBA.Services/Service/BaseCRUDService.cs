using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public abstract class BaseCRUDService<T, TEntity, TSearch, TInsert, TUpdate> : BaseService<T, TEntity, TSearch> where T : class where TEntity : class,new() where TSearch : BaseSearchObject
    {
        private readonly TerminBaContext _context;

        public  BaseCRUDService(TerminBaContext context) : base(context)
        {
            this._context = context;
        }

        public virtual async Task<T> CreateAsync(TInsert request)
        {
            TEntity entity = new TEntity();

            entity = MapInsertToEntity(request);

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

            entity = MapUpdateToEntity(request);

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

        protected virtual TEntity MapInsertToEntity(TInsert request)
        {
            throw new NotImplementedException();
        }

        protected virtual TEntity MapUpdateToEntity (TUpdate request)
        {
            throw new NotImplementedException();
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
