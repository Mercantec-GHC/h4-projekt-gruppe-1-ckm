using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using API.Data;
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
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutQrCode(int id, QrCode qrCode)
        {
            if (id != qrCode.Id)
            {
                return BadRequest();
            }

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

        // POST: api/QrCodes
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<QrCode>> PostQrCode(QrCode qrCode)
        {
            _context.QrCodes.Add(qrCode);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetQrCode", new { id = qrCode.Id }, qrCode);
        }

        // DELETE: api/QrCodes/5
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
