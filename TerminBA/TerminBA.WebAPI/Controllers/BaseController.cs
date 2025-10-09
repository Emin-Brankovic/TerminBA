using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Metadata.Conventions;
using TerminBA.Models.Model;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Interfaces;

namespace TerminBA.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BaseController <T,TSearch> : ControllerBase where TSearch : BaseSearchObject,new() where T : class
    {
        protected readonly IBaseService<T, TSearch> _service;

        public BaseController(IBaseService<T,TSearch> service)
        {
            this._service = service;
        }

       [HttpGet("")]
       public virtual async Task<PagedResult<T>> Get([FromQuery] TSearch? search=null) 
       {
            return await _service.GetAsync(search ?? new TSearch());
       }

        [HttpGet("{id}")]
        public async Task<T?> GetById(int id)
        {
            return await _service.GetByIdAsync(id);
        }
    }
}
