using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace API.Migrations
{
    /// <inheritdoc />
    public partial class FixUserQrCodeForeignKeys : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_UserQrCodes_QrCodes_QrCodeId",
                table: "UserQrCodes");

            migrationBuilder.RenameColumn(
                name: "QrCodeId",
                table: "UserQrCodes",
                newName: "QrId");

            migrationBuilder.RenameIndex(
                name: "IX_UserQrCodes_QrCodeId",
                table: "UserQrCodes",
                newName: "IX_UserQrCodes_QrId");

            migrationBuilder.AddForeignKey(
                name: "FK_UserQrCodes_QrCodes_QrId",
                table: "UserQrCodes",
                column: "QrId",
                principalTable: "QrCodes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_UserQrCodes_QrCodes_QrId",
                table: "UserQrCodes");

            migrationBuilder.RenameColumn(
                name: "QrId",
                table: "UserQrCodes",
                newName: "QrCodeId");

            migrationBuilder.RenameIndex(
                name: "IX_UserQrCodes_QrId",
                table: "UserQrCodes",
                newName: "IX_UserQrCodes_QrCodeId");

            migrationBuilder.AddForeignKey(
                name: "FK_UserQrCodes_QrCodes_QrCodeId",
                table: "UserQrCodes",
                column: "QrCodeId",
                principalTable: "QrCodes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
