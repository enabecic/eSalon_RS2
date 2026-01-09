using eSalon.API.Authentication;
using eSalon.API.Filters;
using eSalon.Services;
using eSalon.Services.Auth;
using eSalon.Services.Database;
using eSalon.Services.Helpers;
using eSalon.Services.Recommender;
using eSalon.Services.RezervacijaStateMachine;
using eSalon.Services.Validator.Implementation;
using eSalon.Services.Validator.Interfaces;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using QuestPDF.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
QuestPDF.Settings.License = LicenseType.Community;

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
builder.Services.AddTransient<IRecenzijaService, RecenzijaService>();
builder.Services.AddTransient<IRecenzijaOdgovorService, RecenzijaOdgovorService>();
builder.Services.AddTransient<IOcjenaService, OcjenaService>();
builder.Services.AddTransient<IRezervacijaService, RezervacijaService>();
builder.Services.AddTransient<IStavkeRezervacijeService, StavkeRezervacijeService>();

builder.Services.AddTransient<BaseRezervacijaState>();
builder.Services.AddTransient<InitialRezervacijaState>();
builder.Services.AddTransient<KreiranaRezervacijaState>();
builder.Services.AddTransient<PonistenaRezervacijaState>();
builder.Services.AddTransient<OdobrenaRezervacijaState>();
builder.Services.AddTransient<ZavrsenaRezervacijaState>();



builder.Services.AddTransient<IUlogaValidator, UlogaValidator>();
builder.Services.AddTransient<IVrstaUslugeValidator, VrstaUslugeValidator>();
builder.Services.AddTransient<IUslugaValidator, UslugaValidator>();
builder.Services.AddTransient<IKorisnikValidator, KorisnikValidator>();
builder.Services.AddTransient<IPromocijaValidator, PromocijaValidator>();
builder.Services.AddTransient<IRecenzijaValidator, RecenzijaValidator>();
builder.Services.AddTransient<IRezervacijaValidator, RezervacijaValidator>();


builder.Services.AddTransient<IPasswordService, PasswordService>();
builder.Services.AddTransient<ICodeGenerator, CodeGenerator>();
builder.Services.AddTransient<IActiveUserServiceAsync, ActiveUserServiceAsync>();
builder.Services.AddScoped<IRecommenderService, RecommenderService>();

builder.Services.AddScoped<IReportService, ReportService>();

builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
});

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();




builder.Services.AddSwaggerGen(c => 
{
    c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "basicAuth"}
            },
            new string[]{}
    } });

});


var connectionString = builder.Configuration.GetConnectionString("eSalonConnection");
builder.Services.AddDbContext<ESalonContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddMapster();


builder.Services.AddAuthentication("BasicAuthentication") 
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);
builder.Services.AddHttpContextAccessor();


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
