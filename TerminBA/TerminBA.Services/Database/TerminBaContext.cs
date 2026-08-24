using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using Stripe.V2.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public partial class TerminBaContext : DbContext
    {

        public TerminBaContext()
        {
        }

        public TerminBaContext(DbContextOptions<TerminBaContext> options)
            : base(options)
        {
           
        }

        public DbSet<User> Users { get; set; }
        public DbSet<City> Cities { get; set; }
        public DbSet<TurfType> TurfTypes { get; set; }
        public DbSet<Sport> Sports { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<SportCenter> SportCenters { get; set; }
        public DbSet<Facility> Facilities { get; set; }
        public DbSet<WorkingHours> WorkingHours { get; set; }
        public DbSet<Post> Posts { get; set; }
        public DbSet<FacilityReview> FacilityReviews { get; set; }
        public DbSet<UserReview> UserReviews { get; set; }
        public DbSet<Reservation> Reservations { get; set; }
        public DbSet<Amenity> Amenity { get; set; }
        public DbSet<PlayRequest> PlayRequests { get; set; }
        public DbSet<FacilityDynamicPrice> FacilityDynamicPrices { get; set; }
        public DbSet<FacilityPhoto> FacilityPhotos { get; set; }
        public DbSet<SportCenterPhoto> SportCenterPhotos { get; set; }
        public DbSet<FavoriteSportCenter> FavoriteSportCenters { get; set; }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<CancelationNotification> CancelationNotifications { get; set; }
        public DbSet<RecommendationEvent> RecommendationEvents { get; set; }
        public DbSet<RevokedToken> RevokedTokens { get; set; }


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            var dateTimeConverter = new ValueConverter<DateTime, DateTime>(
                v => v.ToUniversalTime(),
                v => DateTime.SpecifyKind(v, DateTimeKind.Utc));

            foreach (var entityType in modelBuilder.Model.GetEntityTypes())
            {
                foreach (var property in entityType.GetProperties())
                {
                    if (property.ClrType == typeof(DateTime) || property.ClrType == typeof(DateTime?))
                    {
                        property.SetValueConverter(dateTimeConverter);
                    }
                }
            }

            CreateConfiguration(modelBuilder);
            //CreateSeed(modelBuilder);

        }
    }
}
