using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eSalon.Services.Recommender
{
    public interface IRecommenderService
    {
        Task<List<Model.Usluga>> GetRecommendedServices(int uslugaId);
        void TrainData();
    }
}
