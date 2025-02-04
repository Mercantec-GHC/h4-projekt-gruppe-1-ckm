using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace API.Migrations
{
    /// <inheritdoc />
    public partial class idIdid : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Remove the incorrect columns
            migrationBuilder.DropColumn(
                name: "User_idId",
                table: "UserQrCodes");

            migrationBuilder.DropColumn(
                name: "Qr_idId",
                table: "UserQrCodes");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "User_idId",
                table: "UserQrCodes",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Qr_idId",
                table: "UserQrCodes",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }
    }
}
