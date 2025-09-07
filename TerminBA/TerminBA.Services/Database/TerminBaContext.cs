using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TerminBA.Services.Database
{
    public class TerminBaContext : DbContext
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



        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<SportCenter>()
                .HasMany(sc => sc.AvailableAmenities)
                .WithMany(a => a.SportCentars)
                .UsingEntity(j => j.ToTable("SportCenterAmenities"));

            modelBuilder.Entity<SportCenter>()
                .HasMany(sc => sc.AvailableSports)
                .WithMany(a => a.SportCentars)
                .UsingEntity(j => j.ToTable("SportCenterSports"));

            modelBuilder.Entity<Facility>()
                .HasMany(sc => sc.AvailableSports)
                .WithMany(a => a.Facilities)
                .UsingEntity(j => j.ToTable("FacilitySports"));

            modelBuilder.Entity<UserReview>(entity =>
            {
                entity.HasOne(r => r.Reviewer)
                      .WithMany(u => u.UserReviewsGiven)
                      .HasForeignKey(r => r.ReviewerId)
                      .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne(r => r.Reviewed)
                      .WithMany(u => u.ReviewsReceived)
                      .HasForeignKey(r => r.ReviewedId)
                      .OnDelete(DeleteBehavior.ClientCascade);

                entity.HasIndex(ur => new { ur.ReviewerId, ur.ReviewedId })
                      .IsUnique();
                       
            });

            modelBuilder.Entity<FacilityReview>()
                        .HasIndex(fr => new { fr.UserId, fr.FacilityId })
                        .IsUnique();

            modelBuilder.Entity<FacilityReview>()
                .HasOne(fr => fr.User)
                .WithMany(u => u.FacilityReviewsGiven)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<FacilityReview>()
                .HasOne(fr => fr.Facility)
                .WithMany(f => f.ReviewsReceived)
                .OnDelete(DeleteBehavior.ClientCascade);

            modelBuilder.Entity<Post>()
                .HasIndex(p => p.SkillLevel);
                
            modelBuilder.Entity<SportCenter>()
                .HasMany(sc => sc.WorkingHours)
                .WithOne(wh => wh.SportCentar)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Reservation>()
                .HasIndex(r => new { r.FacilityId, r.ReservationDate, r.StartTime })
                .IsUnique();


            modelBuilder.Entity<Reservation>()
                .HasMany(r=>r.Posts)
                .WithOne(p=>p.Reservation)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Reservation>()
                .HasIndex(r => r.ReservationDate);

            modelBuilder.Entity<Facility>()
                .HasOne(f => f.SportCenter)
                .WithMany(sc => sc.Facilities)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Facility>()
                .HasIndex(f => f.Name);

            modelBuilder.Entity<City>()
                .HasMany(c => c.Users)
                .WithOne(u => u.City)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<City>()
                .HasMany(c => c.SportCenters)
                .WithOne(u => u.City)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<TurfType>()
                .HasIndex(tt => tt.Name);

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email);
        }
    }
}
