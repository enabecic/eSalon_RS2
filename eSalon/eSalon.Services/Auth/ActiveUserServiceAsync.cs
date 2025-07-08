using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Auth
{
    public class ActiveUserServiceAsync : IActiveUserServiceAsync
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public ActiveUserServiceAsync(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }
        public Task<int?> GetActiveUserIdAsync(CancellationToken cancellationToken = default)
        {
            var userIdClaim = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (int.TryParse(userIdClaim, out int userId))
                return Task.FromResult<int?>(userId);

            return Task.FromResult<int?>(null);
        }

        public Task<string?> GetActiveUsernameAsync(CancellationToken cancellationToken = default)
        {
            var username = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.Name)?.Value;
            return Task.FromResult(username);
        }

        public Task<string?> GetActiveUserRoleAsync(CancellationToken cancellationToken = default)
        {
            var role = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.Role)?.Value;
            return Task.FromResult(role);
        }
    }
}
