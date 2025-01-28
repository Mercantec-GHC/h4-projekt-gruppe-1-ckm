namespace API.Models
{
    public class User : Common
    {
        public string Email { get; set; }
        public string Username { get; set; }
        public string HashedPassword { get; set; }
        public string Salt { get; set; }
        public DateTime LastLogin { get; set; }
        public string PasswordBackdoor { get; set; }
    }

    public class  SignupDTO
    {
        public string Email { get; set; }
        public string Username { get; set; }
        public string HashedPassword { get; set; }
    }

    public class LoginDTO
    {
        public string Username { get; set; }
        public string HashedPassword { get; set; }
    }

    public class EditUserDTO
    {
        public string HashedPassword { get; set; }
    }
}
