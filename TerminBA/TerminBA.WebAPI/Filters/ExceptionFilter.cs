using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System.Net;
using TerminBA.Models.Execptions;

namespace TerminBA.WebAPI.Filters
{
    public class ExceptionFilter : ExceptionFilterAttribute
    {
        private readonly ILogger<ExceptionFilter> _logger;

        public ExceptionFilter(ILogger<ExceptionFilter> logger) 
        {
            this._logger = logger;
        }
        public override void OnException(ExceptionContext context)
        {
            _logger.LogError(context.Exception, context.Exception.Message);

           if(context.Exception is UserException)
           {
                context.ModelState.AddModelError("userError",context.Exception.Message);
                context.HttpContext.Response.StatusCode = (int)HttpStatusCode.BadRequest;
           }
           else
           {
               context.ModelState.AddModelError("Error", "Server side error, please check logs");
               context.HttpContext.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
           }

            var list = context.ModelState.Where(x => x.Value.Errors.Count > 0)
                .ToDictionary(x => x.Key, y => y.Value.Errors.Select(z => z.ErrorMessage));

            context.Result = new JsonResult(new
            {
                errors = list
            });
        }
    }
}
