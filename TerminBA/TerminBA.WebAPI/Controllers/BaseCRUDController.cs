using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Interfaces;

namespace TerminBA.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BaseCRUDController<T, TSearch, TInsert, TUpdate> : BaseController<T,TSearch> where T : class where TSearch : BaseSearchObject,new() where TInsert : class where TUpdate : class
    {
        protected readonly IBaseCRUDService<T, TSearch, TInsert, TUpdate> _crudService;

        public BaseCRUDController(IBaseCRUDService<T,TSearch,TInsert,TUpdate> crudService):base(crudService)
        {
            this._crudService = crudService;
        }

        [HttpPost]
        public async Task<T> Create(TInsert request)
        {
            return await _crudService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        public async Task<T?> Update(int id, TUpdate request)
        {
            return await _crudService.UpdateAsync(id,request);
        }

        [HttpDelete("{id}")]
        public async Task<bool> Delete(int id)
        {
            return await _crudService.DeleteAsync(id);  
        }

    }
}
