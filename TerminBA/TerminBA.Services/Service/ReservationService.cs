using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using TerminBA.Models.Execptions;
using TerminBA.Models.Model;
using TerminBA.Models.Request;
using TerminBA.Models.SearchObjects;
using TerminBA.Services.Database;
using TerminBA.Services.Helpers;
using TerminBA.Services.Interfaces;

namespace TerminBA.Services.Service
{
    public class ReservationService : BaseCRUDService<ReservationResponse, Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>, IReservationService
    {
        protected readonly EmailService _emailService;

        public ReservationService(TerminBaContext context, IMapper mapper,EmailService emailService) : base(context, mapper)
        {
            this._emailService = emailService;
        }

        public override IQueryable<Reservation> ApplyFilter(IQueryable<Reservation> query, ReservationSearchObject search)
        {
            if (search.UserId.HasValue)
                query = query.Where(r => r.UserId == search.UserId.Value);

            if (search.FacilityId.HasValue)
                query = query.Where(r => r.FacilityId == search.FacilityId.Value);

            if (!string.IsNullOrEmpty(search.Status))
                query = query.Where(r => r.Status!.ToLower().Contains(search.Status.ToLower()));

            if (search.ChosenSportId.HasValue)
                query = query.Where(r => r.ChosenSportId == search.ChosenSportId.Value);

            if (search.ReservationDate.HasValue)
                query = query.Where(r => r.ReservationDate == search.ReservationDate.Value);

            return query;
        }

        protected override async Task BeforeInsert(Reservation entity, ReservationInsertRequest request)
        {
            var timeSlots=await TimeSlotHelper.GenerateTimeSlots(request.FacilityId ,request.ReservationDate,_context);

            var exists=timeSlots.Any(t=>t.Start==request.StartTime.ToTimeSpan() && t.End==request.EndTime.ToTimeSpan());

            if(!exists)
                throw new UserException("Can't pick a non existing time slot");

           await SendEmailAsync(request);
        }

        protected async override Task BeforeUpdate(Reservation entity, ReservationUpdateRequest request)
        {
            var allSlots = await TimeSlotHelper.GenerateTimeSlots(entity.FacilityId, request.ReservationDate, _context);

            var bookedSlots = await _context.Reservations
                .Where(r => r.FacilityId == entity.FacilityId
                            && r.ReservationDate == request.ReservationDate
                            && r.Id != entity.Id) // ignore this reservation
                .Select(r => r.StartTime)
                .ToListAsync();

            var occupiedStarts = new HashSet<TimeSpan>(bookedSlots.Select(ts => ts.ToTimeSpan()));

            var slot = allSlots.FirstOrDefault(t =>
                t.Start == request.StartTime.ToTimeSpan() &&
                t.End == request.EndTime.ToTimeSpan());

            if (slot == default)
                throw new UserException("Can't pick a non existing time slot.");

            if (occupiedStarts.Contains(slot.Start))
                throw new UserException("Can't pick a booked time slot.");

            var facility = await _context.Facilities
                .Include(f=>f.DynamicPrices)
                .FirstOrDefaultAsync(f => f.Id == entity.FacilityId);

            if (facility!.IsDynamicPricing)
            {
                if (isPriceChanged(entity,request,facility))
                {
                    //implement stripe invoice logic
                }
            }
        }

        private bool isPriceChanged(Reservation entity, ReservationUpdateRequest request,Facility facility)
        {
            var price = facility.DynamicPrices.Where(dp =>
                             TimeSlotHelper.IsInDayRange(request.ReservationDate.DayOfWeek, dp.StartDay, dp.EndDay)
                             && TimeSlotHelper.IsWithinValidityPeriod(request.ReservationDate, dp.ValidFrom, dp.ValidTo)
                             && dp.StartTime <= request.StartTime
                             && dp.EndTime >= request.EndTime).FirstOrDefault()
                             ?? throw new UserException("No price is found for selected time and date");

            bool priceChanged = false;

            if (price.PricePerHour != entity.Price)
            {
                priceChanged = true;
                request.Price = price.PricePerHour;
            }

            return priceChanged;
        }


        private async Task SendEmailAsync(ReservationInsertRequest reservation)
        {

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == reservation.UserId);

            if(user == null) 
            {
                throw new UserException("User not found");
            }

            var message = "Your reservation has been successfully created. Thank you";
            var recepient = user.Email ?? "";

            await _emailService.SendEmailAsync(recepient, message);
        }
    }
}







