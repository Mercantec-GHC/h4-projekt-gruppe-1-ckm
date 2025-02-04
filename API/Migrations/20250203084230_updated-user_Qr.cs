using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace API.Migrations
{
    /// <inheritdoc />
    public partial class updateduser_Qr : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "QrCodeId",
                table: "UserQrCodes",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "UserId",
                table: "UserQrCodes",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_UserQrCodes_QrCodeId",
                table: "UserQrCodes",
                column: "QrCodeId");

            migrationBuilder.CreateIndex(
                name: "IX_UserQrCodes_UserId",
                table: "UserQrCodes",
                column: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_UserQrCodes_QrCodes_QrCodeId",
                table: "UserQrCodes",
                column: "QrCodeId",
                principalTable: "QrCodes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserQrCodes_Users_UserId",
                table: "UserQrCodes",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_UserQrCodes_QrCodes_QrCodeId",
                table: "UserQrCodes");

            migrationBuilder.DropForeignKey(
                name: "FK_UserQrCodes_Users_UserId",
                table: "UserQrCodes");

            migrationBuilder.DropIndex(
                name: "IX_UserQrCodes_QrCodeId",
                table: "UserQrCodes");

            migrationBuilder.DropIndex(
                name: "IX_UserQrCodes_UserId",
                table: "UserQrCodes");

            migrationBuilder.DropColumn(
                name: "QrCodeId",
                table: "UserQrCodes");

            migrationBuilder.DropColumn(
                name: "UserId",
                table: "UserQrCodes");
        }
    }
}
