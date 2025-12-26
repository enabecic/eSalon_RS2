using eSalon.Services.Database;
using eSalon.Services.Recommender;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;


namespace eSalon.Services.Recommender
{
    public class RecommenderService : IRecommenderService
    {
        private readonly IMapper _mapper;
        private readonly ESalonContext _context;
        private static MLContext? mlContext;
        private static ITransformer? model;
        private static readonly object isLocked = new();
        private static Task? trainingTask;


        private const string ModelFilePath = "services-recommender-model.zip";

        public RecommenderService(ESalonContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<List<Model.Usluga>> GetRecommendedServices(int uslugaId)
        {
            var exists = await _context.StavkeRezervacijes
                .AnyAsync(x => x.UslugaId == uslugaId && !x.IsDeleted);

            if (!exists)
                return new List<Model.Usluga>();

            if (mlContext == null)
            {
                bool needsTraining = false;

                lock (isLocked)
                {
                    if (mlContext == null)
                    {
                        mlContext = new MLContext();

                        if (File.Exists(ModelFilePath))
                        {
                            using var stream = new FileStream(ModelFilePath, FileMode.Open, FileAccess.Read, FileShare.Read);
                            model = mlContext.Model.Load(stream, out _);
                        }
                        else
                        {
                            needsTraining = true;
                        }
                    }
                }

                if (needsTraining)
                {
                    lock (isLocked)
                    {
                        trainingTask ??= TrainData();
                    }

                    await trainingTask;
                }

            }


            if (model == null)
                return new List<Model.Usluga>();

            var services = await _context.Uslugas
                .Where(x => x.UslugaId != uslugaId && !x.IsDeleted)
                .ToListAsync();

            using var predictionEngine = mlContext.Model.CreatePredictionEngine<ServiceEntry, CopurchasePrediction>(model);

            var predictions = new List<(Usluga, float)>();

            foreach (var service in services)
            {
                var prediction = predictionEngine.Predict(new ServiceEntry
                {
                    ServiceID = (uint)uslugaId,
                    CoPurchaseServiceID = (uint)service.UslugaId
                });

                predictions.Add((service, prediction.Score));
            }

            var topServices = predictions
                .OrderByDescending(x => x.Item2)
                .Take(3)
                .Select(x => x.Item1)
                .ToList();

            return _mapper.Map<List<Model.Usluga>>(topServices);
        }

        public async Task TrainData()
        {
            if (mlContext == null)
                mlContext = new MLContext();

            var reservations = await _context.Rezervacijas
                .Include(o => o.StavkeRezervacijes)
                .Where(o => !o.IsDeleted)
                .ToListAsync();

            var data = new List<ServiceEntry>();

            foreach (var reservation in reservations)
            {
                var itemIds = reservation.StavkeRezervacijes
                    .Where(s => !s.IsDeleted)
                    .Select(s => s.UslugaId)
                    .Distinct()
                    .ToList();

                for (int i = 0; i < itemIds.Count; i++)
                    for (int j = 0; j < itemIds.Count; j++)
                    {
                        if (i == j) continue;

                        data.Add(new ServiceEntry
                        {
                            ServiceID = (uint)itemIds[i],
                            CoPurchaseServiceID = (uint)itemIds[j],
                            Label = 1f
                        });
                    }
            }

            if (!data.Any())
                return;

            var trainData = mlContext.Data.LoadFromEnumerable(data);

            var options = new MatrixFactorizationTrainer.Options
            {
                MatrixColumnIndexColumnName = nameof(ServiceEntry.ServiceID),
                MatrixRowIndexColumnName = nameof(ServiceEntry.CoPurchaseServiceID),
                LabelColumnName = nameof(ServiceEntry.Label),
                LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                Alpha = 0.01,
                Lambda = 0.005,
                NumberOfIterations = 100,
                C = 0.00001
            };

            var est = mlContext.Recommendation().Trainers.MatrixFactorization(options);
            model = est.Fit(trainData);

            using var stream = new FileStream(ModelFilePath, FileMode.Create, FileAccess.Write, FileShare.Write);
            mlContext.Model.Save(model, trainData.Schema, stream);
        }
    }

    public class ServiceEntry
    {
        [KeyType(count: 10000)]
        public uint ServiceID { get; set; }

        [KeyType(count: 10000)]
        public uint CoPurchaseServiceID { get; set; }

        public float Label { get; set; }
    }

    public class CopurchasePrediction
    {
        public float Score { get; set; }
    }
}
