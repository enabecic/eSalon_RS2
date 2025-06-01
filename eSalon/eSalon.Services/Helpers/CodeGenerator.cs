using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Helpers
{
    public class CodeGenerator : ICodeGenerator
    {
        private readonly Random _random = new();

        private const string Chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; 

        public string GenerateCode(int length = 6)
        {
            return new string(Enumerable.Repeat(Chars, length)
                .Select(s => s[_random.Next(s.Length)]).ToArray());
        }

        public async Task<string> GenerateUniqueCodeAsync(Func<string, Task<bool>> existsFunc, int length = 6)
        {
            string code;
            do
            {
                code = GenerateCode(length);
            } while (await existsFunc(code));

            return code;
        }
    }
}
