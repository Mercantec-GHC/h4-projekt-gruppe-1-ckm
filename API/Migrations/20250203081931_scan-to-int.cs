using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace API.Migrations
{
    /// <inheritdoc />
    public partial class scantoint : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Add a temporary integer column
            migrationBuilder.AddColumn<int>(
                name: "Scannings_temp",
                table: "QrCodes",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            // Migrate data from text column to the temporary integer column
            migrationBuilder.Sql("UPDATE \"QrCodes\" SET \"Scannings_temp\" = CAST(\"Scannings\" AS INTEGER) WHERE \"Scannings\" ~ '^\\d+$'");

            // Drop the old text column
            migrationBuilder.DropColumn(name: "Scannings", table: "QrCodes");

            // Rename the temporary column to Scannings
            migrationBuilder.RenameColumn(name: "Scannings_temp", table: "QrCodes", newName: "Scannings");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Add the original text column back
            migrationBuilder.AddColumn<string>(
                name: "Scannings_temp",
                table: "QrCodes",
                type: "text",
                nullable: false,
                defaultValue: "0");

            // Convert integer values back to text
            migrationBuilder.Sql("UPDATE \"QrCodes\" SET \"Scannings_temp\" = \"Scannings\"::TEXT");

            // Drop the integer column
            migrationBuilder.DropColumn(name: "Scannings", table: "QrCodes");

            // Rename temp column back to Scannings
            migrationBuilder.RenameColumn(name: "Scannings_temp", table: "QrCodes", newName: "Scannings");
        }

    }
}
