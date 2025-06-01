using eSalon.API.Filters;
using eSalon.Services;
using eSalon.Services.Auth;
using eSalon.Services.Database;
using eSalon.Services.Helpers;
using eSalon.Services.Validator.Implementation;
using eSalon.Services.Validator.Interfaces;
using Mapster;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddTransient<IUlogaService, UlogaService>();
builder.Services.AddTransient<IVrstaUslugeService, VrstaUslugeService>();
builder.Services.AddTransient<INacinPlacanjaService, NacinPlacanjaService>();
builder.Services.AddTransient<IUslugaService, UslugaService>();
builder.Services.AddTransient<IKorisnikService, KorisnikService>();
builder.Services.AddTransient<IPromocijaService, PromocijaService>();
builder.Services.AddTransient<IFavoritService, FavoritService>();
builder.Services.AddTransient<IAktiviranaPromocijaService, AktiviranaPromocijaService>();
builder.Services.AddTransient<IArhivaService, ArhivaService>();
builder.Services.AddTransient<IObavijestService, ObavijestService>();


builder.Services.AddTransient<IUlogaValidator, UlogaValidator>();
builder.Services.AddTransient<IVrstaUslugeValidator, VrstaUslugeValidator>();
builder.Services.AddTransient<IUslugaValidator, UslugaValidator>();
builder.Services.AddTransient<IKorisnikValidator, KorisnikValidator>();
builder.Services.AddTransient<IPromocijaValidator, PromocijaValidator>();


builder.Services.AddTransient<IPasswordService, PasswordService>();
builder.Services.AddTransient<ICodeGenerator, CodeGenerator>();



builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
});

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();


var connectionString = builder.Configuration.GetConnectionString("eSalonConnection");
builder.Services.AddDbContext<ESalonContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddMapster();


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
