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
    public interface IFacilityService : IBaseCRUDService<FacilityResponse, FacilitySearchObject, FacilityInsertRequest, FacilityUpdateRequest>
    {
        public Task<List<FacilityTimeSlot>> GetFacilityTimeSlotAsync(int facilityId,DateOnly pickedDate);
    }
}

