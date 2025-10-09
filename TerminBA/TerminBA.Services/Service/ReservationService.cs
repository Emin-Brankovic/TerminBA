using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class ReservationService : BaseCRUDService<ReservationResponse, Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>, IReservationService
    {
        public ReservationService(TerminBaContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Reservation> ApplyFilter(IQueryable<Reservation> query, ReservationSearchObject search)
        {
            if (search.UserId.HasValue)
                query = query.Where(r => r.UserId == search.UserId.Value);

            if (search.FacilityId.HasValue)
                query = query.Where(r => r.FacilityId == search.FacilityId.Value);

            if (!string.IsNullOrEmpty(search.Status))
                query = query.Where(r => r.Status.ToLower().Contains(search.Status.ToLower()));

            if (search.ChosenSportId.HasValue)
                query = query.Where(r => r.ChosenSportId == search.ChosenSportId.Value);

            return query;
        }
    }
}




