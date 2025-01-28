namespace API.Models
{
    public class Common
    {
        [Key]
        public int Id { get; set; }
        public string CreatedAt { get; set; }
        public string UpdatedAt { get; set; }
    }
}
