using DotNetEnv;
using eSalon.Subscriber.MailSenderService;
using eSalon.Subscriber;
using Newtonsoft.Json;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;

Env.Load();

Console.WriteLine("Sleeping to wait for RabbitMQ...");
Task.Delay(10000).Wait();

var hostname = Environment.GetEnvironmentVariable("_rabbitMqHost") ?? "localhost";
var username = Environment.GetEnvironmentVariable("_rabbitMqUser") ?? "guest";
var password = Environment.GetEnvironmentVariable("_rabbitMqPassword") ?? "guest";
var port = int.Parse(Environment.GetEnvironmentVariable("_rabbitMqPort") ?? "5672");

var emailService = new MailSenderService();

Console.WriteLine($"Connecting to RabbitMQ at {hostname}:{port}");

var factory = new ConnectionFactory()
{
    HostName = hostname,
    Port = port,
    UserName = username,
    Password = password
};

using var connection = factory.CreateConnection();
using var channel = connection.CreateModel();

channel.QueueDeclare(
    queue: "mail_sending",
    durable: false,
    exclusive: false,
    autoDelete: false,
    arguments: null);

Console.WriteLine("Waiting for messages...");

var consumer = new EventingBasicConsumer(channel);
consumer.Received += async (model, ea) =>
{
    var body = ea.Body.ToArray();
    var message = Encoding.UTF8.GetString(body);
    Console.WriteLine($"Message received: {message}");
    var dto = JsonConvert.DeserializeObject<Email>(message);
    if (dto != null)
        await emailService.SendEmail(dto);
};

channel.BasicConsume(
    queue: "mail_sending",
    autoAck: true,
    consumer: consumer);

Thread.Sleep(Timeout.Infinite);