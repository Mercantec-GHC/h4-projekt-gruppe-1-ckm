namespace API.Models
{
    public class User_QrCode : Common
    {
        [ForeignKey("User_id")]
        public User User { get; set; }
        public int User_id {  get; set; }
        
        [ForeignKey("Qr_id")]
        public QrCode QrCode { get; set; }
        public int Qr_id { get; set; }
    }

    public class User_QrCodeDTO
    {
        public int User_id { get; set; }
        public int Qr_id { get; set; }
    }
}
