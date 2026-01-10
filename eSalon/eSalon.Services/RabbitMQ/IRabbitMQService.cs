using eSalon.Model.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.RabbitMQ
{
    public interface IRabbitMQService
    {
        Task SendAnEmail(Email mail);
    }
}
