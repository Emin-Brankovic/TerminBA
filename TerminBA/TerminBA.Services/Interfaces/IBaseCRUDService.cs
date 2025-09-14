using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.SearchObjects;

namespace TerminBA.Services.Interfaces
{
    public interface IBaseCRUDService <T,TSearch,TInsert,TUpdate> : IBaseService<T,TSearch> where T : class where TSearch : BaseSearchObject where TInsert : class where TUpdate : class 
    {
        public Task<T> CreateAsync(TInsert request);
        public Task<T?> UpdateAsync(int id, TUpdate request);
        public Task<bool> DeleteAsync(int id);
    }
}
