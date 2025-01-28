namespace API.Models
{
    public class QrCode : Common
    {
        public string Title { get; set; }
        public string Text { get; set; }
        public string Scannings { get; set; }
    }

    public class QrCodeDTO
    {
        public string Title { get; set; }
        public string Text { get; set; }
    }

    public class EditQrCode
    {
        public string Title { get; set; }
        public string Text { get; set; }
    }
}
