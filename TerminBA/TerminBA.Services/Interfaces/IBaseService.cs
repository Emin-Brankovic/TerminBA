using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.SearchObjects;

namespace TerminBA.Services.Interfaces
{
    public interface IBaseService <T,TSearch> where TSearch : BaseSearchObject where T : class 
    {
        public Task<PagedResult<T>> GetAsync(TSearch search);

        public Task<T?> GetByIdAsync(int id);
    }
}
