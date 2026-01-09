using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services
{
    public interface IReportService
    {
        Task<byte[]> FrizerStatistikaPdf(string? stateMachineFilter = null);
        Task<byte[]> AdminStatistikaPdf(string? stateMachineFilter = null);
        Task<byte[]> FrizerKreiranPdf(int frizerId, string plainPassword);
    }
}
