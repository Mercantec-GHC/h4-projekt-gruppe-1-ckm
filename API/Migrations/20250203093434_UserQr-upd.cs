using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace API.Migrations
{
    /// <inheritdoc />
    public partial class UserQrupd : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
          

            migrationBuilder.RenameColumn(
                name: "UserId",
                table: "UserQrCodes",
                newName: "User_id");

            migrationBuilder.RenameColumn(
                name: "QrId",
                table: "UserQrCodes",
                newName: "Qr_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "User_id",
                table: "UserQrCodes",
                newName: "User_idId");

            migrationBuilder.RenameColumn(
                name: "Qr_id",
                table: "UserQrCodes",
                newName: "Qr_idId");

            migrationBuilder.CreateIndex(
                name: "IX_UserQrCodes_Qr_idId",
                table: "UserQrCodes",
                column: "Qr_idId");

            migrationBuilder.CreateIndex(
                name: "IX_UserQrCodes_User_idId",
                table: "UserQrCodes",
                column: "User_idId");

            migrationBuilder.AddForeignKey(
                name: "FK_UserQrCodes_QrCodes_Qr_idId",
                table: "UserQrCodes",
                column: "Qr_idId",
                principalTable: "QrCodes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserQrCodes_Users_User_idId",
                table: "UserQrCodes",
                column: "User_idId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
