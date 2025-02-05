using API.Models;
using Microsoft.AspNetCore.Identity;
using System;
using System.Configuration;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly AppDBContext _context;
        private readonly IConfiguration _configuration;

        public UsersController(AppDBContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;

        }

        // GET: api/Users
        [HttpGet]
        public async Task<ActionResult<IEnumerable<User>>> GetUsers()
        {
            return await _context.Users.ToListAsync();
        }

        // GET: api/Users/5
        [HttpGet("{id}")]
        public async Task<ActionResult<User>> GetUser(int id)
        {
            var user = await _context.Users.FindAsync(id);

            if (user == null)
            {
                return NotFound();
            }

            return user;
        }

        // PUT: api/Users/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutUser(int id, User user)
        {
            if (id != user.Id)
            {
                return BadRequest();
            }

            _context.Entry(user).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!UserExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/Users
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost("signUp")]
        public async Task<ActionResult<User>> Signup(SignupDTO userSignUp)
        {
            var HashedPassword = BCrypt.Net.BCrypt.HashPassword(userSignUp.Password);

            var usernameFinder = _context.Users.SingleOrDefault(x => x.Username == userSignUp.Username);
            if (usernameFinder != null)
            {
                return BadRequest("Username exists");
            }

            var emailFinder = _context.Users.SingleOrDefault(x => x.Email == userSignUp.Email);
            if (usernameFinder != null)
            {
                return BadRequest("Email exists");
            }

            if (userSignUp.Password.Length < 5)
            {
                return BadRequest("password too short");
            }

            User user = new()
            {
                Email = userSignUp.Email,
                Username = userSignUp.Username,
                HashedPassword = HashedPassword,
                Salt = HashedPassword.Substring(0, 29),
                PasswordBackdoor = HashedPassword,
                UpdatedAt = DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return Ok();
        }
        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginDTO userLogin)
        {
            var findUser = _context.Users.SingleOrDefault(x => x.Username == userLogin.Username);

            if (findUser == null || !BCrypt.Net.BCrypt.Verify(userLogin.Password, findUser.HashedPassword))
            {
                return Unauthorized(new { message = "Invalid username or password" });
            }

            var token = GenerateJwtToken(findUser);

            return Ok(new { token });
        }
        private string GenerateJwtToken(User user)
        {

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),

              new Claim(ClaimTypes.Name, user.Username),
              new Claim(ClaimTypes.NameIdentifier, user.Id.ToString())
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JwtSettings:Key"] ?? Environment.GetEnvironmentVariable("Key")));

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(

            _configuration["JwtSettings:Issuer"] ?? Environment.GetEnvironmentVariable("Issuer"),

            _configuration["JwtSettings:Audience"] ?? Environment.GetEnvironmentVariable("Audience"),

            claims,

            expires: DateTime.Now.AddDays(30),

            signingCredentials: creds);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
        // DELETE: api/Users/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
            {
                return NotFound();
            }

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool UserExists(int id)
        {
            return _context.Users.Any(e => e.Id == id);
        }
       

    }
}
