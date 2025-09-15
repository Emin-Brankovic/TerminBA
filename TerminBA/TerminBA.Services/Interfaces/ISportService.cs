using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;

namespace TerminBA.Services.Interfaces
{
    public interface ISportService : IBaseCRUDService<SportResponse,SportSearchObject,SportInserRequest,SportUpdateRequest>
    {

    }
}
