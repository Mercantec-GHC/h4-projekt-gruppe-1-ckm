using API.Models;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class QrCodesController : ControllerBase
    {
        private readonly AppDBContext _context;

        public QrCodesController(AppDBContext context)
        {
            _context = context;
        }

        // GET: api/QrCodes
        [HttpGet]
        public async Task<ActionResult<IEnumerable<QrCode>>> GetQrCodes()
        {
            return await _context.QrCodes.ToListAsync();
        }

        // GET: api/QrCodes/5
        [HttpGet("{id}")]
        public async Task<ActionResult<QrCode>> GetQrCode(int id)
        {
            var qrCode = await _context.QrCodes.FindAsync(id);

            if (qrCode == null)
            {
                return NotFound();
            }

            return qrCode;
        }

        // PUT: api/QrCodes/5
        [Authorize]
        [HttpPut("{id}")]
        public async Task<IActionResult> PutQrCode(int id, EditQrCode qrCodeEdit)
        {
            Regex validateTitle = new(@"^[a-zA-Z0-9]{1,30}$");  // Only letters and numbers (1-30 chars)
            Regex validateText = new(@"(?:.*?\s)?(https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,10}(?:[-a-zA-Z0-9()@:%_+.~#?&//=]*)?)?(?:\s.*)?$"); // Standard link format

            var errors = new Dictionary<string, string>();

            if (!validateTitle.IsMatch(qrCodeEdit.Title))
            {
                errors["Title"] = "Title must be 1-30 characters long and contain only letters and numbers.";
            }

            if (!validateText.IsMatch(qrCodeEdit.Title))
            {
                errors["Text"] = "QR text field wrong";
            }

            if (errors.Count > 0)
            {
                BadRequest(new { Errors = errors });
            }

            // Fetch the existing QR code from the database
            var qrCode = await _context.QrCodes.FindAsync(id);

            if (qrCode == null)
            {
                return NotFound();
            }

            // Update fields
            qrCode.Text = qrCodeEdit.Text;
            qrCode.Title = qrCodeEdit.Title;
            qrCode.UpdatedAt = DateTime.UtcNow;

            _context.Entry(qrCode).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!QrCodeExists(id))
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

        // PUT: used to increment the scan count of a QR code
        [HttpPut]
        public async Task<IActionResult> IncrementQrCode(int id)
        {
            var qrCode = await _context.QrCodes.FindAsync(id);
            if (qrCode == null)
            {
                return NotFound("QR Code not found");
            }

            // Increment scan count
            qrCode.Scannings++;
            await _context.SaveChangesAsync();

            // Return the updated scan count and QR code ID
            return Ok(new { qrCode.Id, qrCode.Scannings });
        }

        // POST: api/QrCodes
        [Authorize]
        [HttpPost]
        public async Task<ActionResult<QrCode>> PostQrCode(QrCodeDTO qrCodePost)
        {
            // Get user ID from token
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim))
            {
                return Unauthorized(new { Message = "User not authenticated." });
            }

            if (!int.TryParse(userIdClaim, out int userId))
            {
                return BadRequest(new { Message = "Invalid user ID format." });
            }

            // Validation
            Regex validateTitle = new(@"^[a-zA-Z0-9]{1,30}$");
            Regex validateText = new(@"(?:.*?\s)?(https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,10}(?:[-a-zA-Z0-9()@:%_+.~#?&//=]*)?)?(?:\s.*)?$");

            var errors = new Dictionary<string, string>();

            if (!validateTitle.IsMatch(qrCodePost.Title))
            {
                errors["Title"] = "Title must be 1-30 characters long and contain only letters and numbers.";
            }

            if (!validateText.IsMatch(qrCodePost.Text))
            {
                errors["Text"] = "QR text field is incorrect.";
            }

            if (errors.Count > 0)
            {
                return BadRequest(new { Errors = errors });
            }

            // Create QR Code entity
            QrCode qrCode = new()
            {
                Text = qrCodePost.Text,
                Title = qrCodePost.Title,
                Scannings = 0,
                UpdatedAt = DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow
            };

            _context.QrCodes.Add(qrCode);
            await _context.SaveChangesAsync();

            // Create User-QR association
            User_QrCode joinQrAndUser = new()
            {
                User_id = userId,
                Qr_id = qrCode.Id,
                UpdatedAt = DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow
            };

            _context.UserQrCodes.Add(joinQrAndUser);
            await _context.SaveChangesAsync();


            return Ok(new { Message = "QR registered successfully." });
        }


        // DELETE: api/QrCodes/5
        [Authorize]
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteQrCode(int id)
        {
            var qrCode = await _context.QrCodes.FindAsync(id);
            if (qrCode == null)
            {
                return NotFound();
            }

            _context.QrCodes.Remove(qrCode);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool QrCodeExists(int id)
        {
            return _context.QrCodes.Any(e => e.Id == id);
        }
    }
}
