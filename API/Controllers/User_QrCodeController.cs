﻿namespace API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class User_QrCodeController : ControllerBase
    {
        private readonly AppDBContext _context;

        public User_QrCodeController(AppDBContext context)
        {
            _context = context;
        }
        [Authorize]
        // GET: api/User_QrCode
        [HttpGet]
        public async Task<ActionResult<IEnumerable<User_QrCodeDTO>>> GetQrCodes()
        {
            var qrCodes = await _context.UserQrCodes 
                .Select(q => new User_QrCodeDTO
                {
                    User_id = q.User_id,
                    Qr_id = q.Qr_id
                })
                .ToListAsync();

            return Ok(qrCodes);
        }

        [Authorize]
        // GET: api/User_QrCode/5
        [HttpGet("{id}")]
        public async Task<ActionResult<User_QrCode>> GetUser_QrCode(int id)
        {
            var user_QrCode = await _context.UserQrCodes.FindAsync(id);

            if (user_QrCode == null)
            {
                return NotFound();
            }

            return user_QrCode;
        }

        [Authorize]
        [HttpGet("Search")]
        public async Task<ActionResult<IEnumerable<User_QrCodeDTO>>> Search_QrCode(string title)
        {
            if (string.IsNullOrWhiteSpace(title))
            {
                return BadRequest("Search title cannot be empty.");
            }

            var qrCodes = await _context.UserQrCodes
                .Where(q => q.QrCode.Title.Contains(title))
                .ToListAsync();

            if (qrCodes == null || !qrCodes.Any())
            {
                return NotFound("No matching QR codes found.");
            }

            return Ok(qrCodes);
        }

        // PUT: api/User_QrCode/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutUser_QrCode(int id, User_QrCode user_QrCode)
        {
            if (id != user_QrCode.Id)
            {
                return BadRequest();
            }

            _context.Entry(user_QrCode).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!User_QrCodeExists(id))
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

        // POST: api/User_QrCode
        [Authorize]
        [HttpPost]
        public async Task<ActionResult<User_QrCode>> PostUser_QrCode(User_QrCodeDTO user_QrCode)
        {
            var user = await _context.Users.FindAsync(user_QrCode.User_id);

            if (user == null)
            {
                return BadRequest("No user id");
            }

            var qrCode = await _context.QrCodes.FindAsync(user_QrCode.Qr_id);

            if(qrCode == null)
            {
                return BadRequest("No QR id");
            }

            User_QrCode userQR = new()
            {
                User_id = user_QrCode.User_id,
                Qr_id = user_QrCode.Qr_id,
                UpdatedAt = DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow,
            };

            _context.UserQrCodes.Add(userQR);
            await _context.SaveChangesAsync();

            return Ok();
        }

        // DELETE: api/User_QrCode/5
        [Authorize]
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser_QrCode(int id)
        {
            var user_QrCode = await _context.UserQrCodes.FindAsync(id);
            if (user_QrCode == null)
            {
                return NotFound();
            }

            _context.UserQrCodes.Remove(user_QrCode);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool User_QrCodeExists(int id)
        {
            return _context.UserQrCodes.Any(e => e.Id == id);
        }
    }
}
