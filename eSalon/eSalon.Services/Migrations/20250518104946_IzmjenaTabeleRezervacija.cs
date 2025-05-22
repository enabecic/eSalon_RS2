using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eSalon.Services.Migrations
{
    /// <inheritdoc />
    public partial class IzmjenaTabeleRezervacija : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<TimeSpan>(
                name: "VrijemeKraja",
                table: "Rezervacija",
                type: "time",
                nullable: true,
                oldClrType: typeof(TimeSpan),
                oldType: "time");

            migrationBuilder.AlterColumn<int>(
                name: "UkupnoTrajanje",
                table: "Rezervacija",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddColumn<bool>(
                name: "TerminZatvoren",
                table: "Rezervacija",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TerminZatvoren",
                table: "Rezervacija");

            migrationBuilder.AlterColumn<TimeSpan>(
                name: "VrijemeKraja",
                table: "Rezervacija",
                type: "time",
                nullable: false,
                defaultValue: new TimeSpan(0, 0, 0, 0, 0),
                oldClrType: typeof(TimeSpan),
                oldType: "time",
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "UkupnoTrajanje",
                table: "Rezervacija",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);
        }
    }
}
