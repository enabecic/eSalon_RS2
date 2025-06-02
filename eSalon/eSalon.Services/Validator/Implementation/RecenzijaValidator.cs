using eSalon.Services.Database;
using eSalon.Services.Validator.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Validator.Implementation
{
    public class RecenzijaValidator : BaseValidatorService<Database.Recenzija>, IRecenzijaValidator
    {
        public RecenzijaValidator(ESalonContext context) : base(context)
        {
        }
    }
}
