using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace API.Migrations
{
    /// <inheritdoc />
    public partial class datetime : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("ALTER TABLE \"Users\" ALTER COLUMN \"UpdatedAt\" TYPE TIMESTAMP WITH TIME ZONE USING \"UpdatedAt\"::TIMESTAMP WITH TIME ZONE;");
            migrationBuilder.Sql("ALTER TABLE \"Users\" ALTER COLUMN \"CreatedAt\" TYPE TIMESTAMP WITH TIME ZONE USING \"CreatedAt\"::TIMESTAMP WITH TIME ZONE;");

            migrationBuilder.Sql("ALTER TABLE \"QrCodes\" ALTER COLUMN \"UpdatedAt\" TYPE TIMESTAMP WITH TIME ZONE USING \"UpdatedAt\"::TIMESTAMP WITH TIME ZONE;");
            migrationBuilder.Sql("ALTER TABLE \"QrCodes\" ALTER COLUMN \"CreatedAt\" TYPE TIMESTAMP WITH TIME ZONE USING \"CreatedAt\"::TIMESTAMP WITH TIME ZONE;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("ALTER TABLE \"Users\" ALTER COLUMN \"UpdatedAt\" TYPE TEXT USING \"UpdatedAt\"::TEXT;");
            migrationBuilder.Sql("ALTER TABLE \"Users\" ALTER COLUMN \"CreatedAt\" TYPE TEXT USING \"CreatedAt\"::TEXT;");

            migrationBuilder.Sql("ALTER TABLE \"QrCodes\" ALTER COLUMN \"UpdatedAt\" TYPE TEXT USING \"UpdatedAt\"::TEXT;");
            migrationBuilder.Sql("ALTER TABLE \"QrCodes\" ALTER COLUMN \"CreatedAt\" TYPE TEXT USING \"CreatedAt\"::TEXT;");
        }
    }
}
