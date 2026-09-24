using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TerminBA.Models.Request;

namespace TerminBA.Services.Interfaces
{
    public interface IPeriodValidatorService
    {
        Task ValidateWorkingHoursInsertAsync(int sportCenterId, WorkingHoursInsertRequest request);
        Task ValidateWorkingHoursUpdateAsync(int recordId, WorkingHoursUpdateRequest request);
        Task ValidateWorkingHoursListAsync(List<WorkingHoursInsertRequest>? workingHours);

        Task ValidateDynamicPriceInsertAsync(int sportCenterId, FacilityDynamicPriceInsertRequest request);
        Task ValidateDynamicPriceUpdateAsync(int recordId, int sportCenterId, FacilityDynamicPriceUpdateRequest request);
        Task ValidateDynamicPricesListInsertAsync(bool isDynamicPricing, int sportCenterId, List<FacilityDynamicPriceInsertRequest>? dynamicPrices);
        Task ValidateDynamicPricesListUpdateAsync(bool isDynamicPricing, int sportCenterId, List<FacilityDynamicPriceUpdateRequest>? dynamicPrices);
    }
}
