using DotNetEnv;
using MimeKit;
using MailKit.Net.Smtp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Subscriber.MailSenderService
{
    public class MailSenderService : IMailSenderService
    {
        public async Task SendEmail(Email emailObj)
        {
            if (emailObj == null)
                return;

            Env.Load();

            string fromAddress = Environment.GetEnvironmentVariable("_fromAddress") ?? "esalon.rs2@gmail.com";
            string password = Environment.GetEnvironmentVariable("_password") ?? string.Empty;
            string host = Environment.GetEnvironmentVariable("_host") ?? "smtp.gmail.com";
            int port = int.Parse(Environment.GetEnvironmentVariable("_port") ?? "465");
            bool enableSSL = bool.Parse(Environment.GetEnvironmentVariable("_enableSSL") ?? "true");
            string displayName = Environment.GetEnvironmentVariable("_displayName") ?? "no-reply";

            if (string.IsNullOrWhiteSpace(password))
            {
                Console.WriteLine("Greška: Lozinka za email je prazna.");
                return;
            }

            var email = new MimeMessage();
            email.From.Add(new MailboxAddress(displayName, fromAddress));
            email.To.Add(new MailboxAddress(emailObj.ReceiverName, emailObj.EmailTo));
            email.Subject = emailObj.Subject;
            email.Body = new TextPart(MimeKit.Text.TextFormat.Html) { Text = emailObj.Message };

            try
            {
                using (var smtp = new SmtpClient())
                {
                    Console.WriteLine("Povezivanje na SMTP server...");
                    await smtp.ConnectAsync(host, port, enableSSL);
                    Console.WriteLine("Autentifikacija...");
                    await smtp.AuthenticateAsync(fromAddress, password);
                    Console.WriteLine("Slanje emaila...");
                    await smtp.SendAsync(email);
                    await smtp.DisconnectAsync(true);
                }
                Console.WriteLine("Email je uspješno poslan.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Greška prilikom slanja emaila: {ex.Message}");
                return;
            }
        }
    }
}
