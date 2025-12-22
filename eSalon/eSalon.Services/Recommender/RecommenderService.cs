using eSalon.Services.Database;
using MapsterMapper;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Recommender
{
    public class RecommenderService : IRecommenderService
    {
        private readonly IMapper mapper;
        private readonly ESalonContext eSalonContext;
        private static MLContext mlContext = null;
        private static object isLocked = new object();
        private static ITransformer model = null;

        private const string ModelFilePath = "reservation-model.zip";

        public RecommenderService(ESalonContext eSalonContext, IMapper mapper)
        {
            this.eSalonContext = eSalonContext;
            this.mapper = mapper;
        }
        public async Task<List<Model.Usluga>> GetRecommendedServices(int uslugaId)
        {
            //bool uslugaExistsInReservations = eSalonContext.StavkeRezervacijes.Any(x => x.UslugaId == uslugaId);

            bool uslugaExistsInReservations = eSalonContext.StavkeRezervacijes.Any(x => x.UslugaId == uslugaId && !x.Usluga.IsDeleted);

            if (!uslugaExistsInReservations)
            {
                return null;
            }

            if (mlContext == null)
            {
                lock (isLocked)
                {
                    mlContext = new MLContext();

                    if (File.Exists(ModelFilePath))
                    {
                        using (var stream = new FileStream(ModelFilePath, FileMode.Open, FileAccess.Read, FileShare.Read))
                        {
                            model = mlContext.Model.Load(stream, out var modelInputSchema);
                        }
                    }
                    else
                    {
                        TrainData();
                    }
                }
            }

            //var services = eSalonContext.Uslugas.Where(x => x.UslugaId != uslugaId);
            var services = eSalonContext.Uslugas.Where(x => x.UslugaId != uslugaId && !x.IsDeleted);

            var predictionResult = new List<(Database.Usluga, float)>();

            foreach (var service in services)
            {
                var predictionengine = mlContext.Model.CreatePredictionEngine<UslugaEntry, Copurchase_prediction>(model);
                var prediction = predictionengine.Predict(
                                         new UslugaEntry()
                                         {
                                             UslugaId = (uint)uslugaId,
                                             CoPurchaseUslugaId = (uint)service.UslugaId
                                         });

                predictionResult.Add(new(service, prediction.Score));
            }

            var finalResult = predictionResult.OrderByDescending(x => x.Item2).Select(x => x.Item1).Take(3).ToList();

            return mapper.Map<List<Model.Usluga>>(finalResult);
        }

        public void TrainData()
        {
            if (mlContext == null)
                mlContext = new MLContext();


            var rezervacije = eSalonContext.StavkeRezervacijes
                .Where(x => !x.Usluga.IsDeleted)
                .GroupBy(x => x.RezervacijaId)
                .ToList();

            var data = new List<UslugaEntry>();

            foreach (var rezervacija in rezervacije)
            {
                var usluge = rezervacija
                    .Select(x => x.UslugaId)
                    .Distinct()
                    .ToList();

                for (int i = 0; i < usluge.Count; i++)
                {
                    for (int j = 0; j < usluge.Count; j++)
                    {
                        if (i == j) continue;

                        data.Add(new UslugaEntry
                        {
                            UslugaId = (uint)usluge[i],
                            CoPurchaseUslugaId = (uint)usluge[j],
                            Label = 1
                        });
                    }
                }
            }


            var traindata = mlContext.Data.LoadFromEnumerable(data);

            MatrixFactorizationTrainer.Options options = new MatrixFactorizationTrainer.Options
            {
                MatrixColumnIndexColumnName = nameof(UslugaEntry.UslugaId),
                MatrixRowIndexColumnName = nameof(UslugaEntry.CoPurchaseUslugaId),
                LabelColumnName = "Label",
                LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                Alpha = 0.01,
                Lambda = 0.005,
                NumberOfIterations = 100,
                C = 0.00001,
            };

            var estimator = mlContext.Recommendation().Trainers.MatrixFactorization(options);
            model = estimator.Fit(traindata);

            using (var stream = new FileStream(ModelFilePath, FileMode.Create, FileAccess.Write, FileShare.Write))
            {
                mlContext.Model.Save(model, traindata.Schema, stream);
            }
        }

    }
    public class Copurchase_prediction
    {
        public float Score { get; set; }
    }

    public class UslugaEntry
    {
        [KeyType(count: 262111)]
        public uint UslugaId { get; set; }

        [KeyType(count: 262111)]
        public uint CoPurchaseUslugaId { get; set; }

        public float Label { get; set; }
    }
}
