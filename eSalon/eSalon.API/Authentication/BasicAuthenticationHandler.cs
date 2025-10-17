using eSalon.Model.Requests;
using eSalon.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Options;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Text.Encodings.Web;

namespace eSalon.API.Authentication
{
    public class BasicAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
    {

        private readonly IKorisnikService _korisniciService;

        public BasicAuthenticationHandler(
           IOptionsMonitor<AuthenticationSchemeOptions> options,
           ILoggerFactory logger,
           UrlEncoder encoder,
           ISystemClock clock,
           IKorisnikService korisniciService)
           : base(options, logger, encoder, clock)
        {
            _korisniciService = korisniciService;
        }

        protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            if (Context.GetEndpoint()?.Metadata.GetMetadata<IAllowAnonymous>() != null)
            {
                return AuthenticateResult.NoResult();
            }

            if (!Request.Headers.ContainsKey("Authorization"))
                return AuthenticateResult.NoResult();

            var authHeader = AuthenticationHeaderValue.Parse(Request.Headers["Authorization"]);
            var credentialsBytes = Convert.FromBase64String(authHeader.Parameter!);
            var credentials = Encoding.UTF8.GetString(credentialsBytes).Split(':');
            var username = credentials[0];
            var password = credentials[1];

            var user = await _korisniciService.LoginAsync(new KorisnikLoginRequest { KorisnickoIme = username, Lozinka = password });

            if (user == null)
                return AuthenticateResult.Fail("Neispravni korisnički podaci.");

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.KorisnikId.ToString()),
                new Claim(ClaimTypes.Name, user.KorisnickoIme),
                new Claim(ClaimTypes.GivenName, user.Ime ?? ""),
                new Claim(ClaimTypes.Surname, user.Prezime ?? ""),
                new Claim(ClaimTypes.Email, user.Email)
            };

            if (user.Uloge != null)
            {
                foreach (var role in user.Uloge)
                {
                    claims.Add(new Claim(ClaimTypes.Role, role)); 
                }
            }

            var identity = new ClaimsIdentity(claims, Scheme.Name);
            var principal = new ClaimsPrincipal(identity);
            var ticket = new AuthenticationTicket(principal, Scheme.Name);

            return AuthenticateResult.Success(ticket);
        }

    }
}
