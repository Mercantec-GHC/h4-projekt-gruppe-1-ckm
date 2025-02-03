using System.ComponentModel.DataAnnotations.Schema;

namespace API.Models
{
    public class User_QrCode : Common
    {
        [ForeignKey("UserId")]
        public User User { get; set; }
        public int User_id {  get; set; }
        [ForeignKey("QrId")]
        public QrCode QrCode { get; set; }
        public int Qr_id { get; set; }
    }
}
