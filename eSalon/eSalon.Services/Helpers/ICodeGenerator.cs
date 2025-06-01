using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Helpers
{
    public interface ICodeGenerator
    {
        string GenerateCode(int length = 6);
        Task<string> GenerateUniqueCodeAsync(Func<string, Task<bool>> existsFunc, int length = 6);
    }
}
