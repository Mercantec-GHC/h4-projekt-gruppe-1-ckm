namespace API.Data
{
    public class AppDBContext : DbContext
    {
        public AppDBContext(DbContextOptions<AppDBContext> options) 
        : base(options)
        {
        
        }

        public DbSet<User> Users { get; set; }
        public DbSet<QrCode> QrCodes { get; set; }
        public DbSet<User_QrCode> UserQrCodes { get; set;}

    }
}
