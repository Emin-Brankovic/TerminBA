using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;

namespace TerminBA.Services.Interfaces
{
    public interface IFacilityDynamicPriceService : IBaseCRUDService<FacilityDynamicPriceResponse, FacilityDynamicPriceSearchObject, FacilityDynamicPriceInsertRequest, FacilityDynamicPriceUpdateRequest>
    {
        public Task<decimal> DynamicPriceForDateAsync(DynamicPriceForDateRequest request);
    }
}

