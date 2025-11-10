import { Types } from 'mongoose';
import AlfajorModel from '../models/Alfajor';
import ReviewModel from '../models/Review';

export interface RankedAlfajor {
  nombre: string;
  marca: string;
  promedioPuntuacion: number;
  totalReseñas: number;
}

export interface ReviewedAlfajor {
  nombre: string;
  marca: string;
  totalReseñas: number;
  promedioPuntuacion: number;
}

export interface UserStats {
  totalReseñas: number;
  totalAlfajoresDistintos: number;
  promedioPuntuacionDada: number;
}

const sanitizePositiveInt = (value: number, fallback: number): number => {
  if (!Number.isFinite(value) || value <= 0) {
    return fallback;
  }
  return Math.floor(value);
};

const getTopRated = async (
  minReviews = 5,
  limit = 10
): Promise<RankedAlfajor[]> => {
  const safeMinReviews = sanitizePositiveInt(minReviews, 5);
  const safeLimit = sanitizePositiveInt(limit, 10);

  const results = await AlfajorModel.aggregate<RankedAlfajor>([
    { $match: { totalReseñas: { $gte: safeMinReviews } } },
    { $sort: { promedioPuntuacion: -1 } },
    { $limit: safeLimit },
    {
      $project: {
        _id: 0,
        nombre: 1,
        marca: 1,
        promedioPuntuacion: 1,
        totalReseñas: 1,
      },
    },
  ]);

  return results;
};

const getMostReviewed = async (limit = 10): Promise<ReviewedAlfajor[]> => {
  const safeLimit = sanitizePositiveInt(limit, 10);

  const results = await AlfajorModel.aggregate<ReviewedAlfajor>([
    { $sort: { totalReseñas: -1 } },
    { $limit: safeLimit },
    {
      $project: {
        _id: 0,
        nombre: 1,
        marca: 1,
        totalReseñas: 1,
        promedioPuntuacion: 1,
      },
    },
  ]);

  return results;
};

const getUserStats = async (userId: string): Promise<UserStats> => {
  const userObjectId = new Types.ObjectId(userId);
  const query = { userId: userObjectId };

  const [totalReseñas, distinctAlfajores, promedioResult] = await Promise.all([
    ReviewModel.countDocuments(query),
    ReviewModel.distinct('alfajorId', query),
    ReviewModel.aggregate<{ promedio: number }>([
      { $match: query },
      { $group: { _id: null, promedio: { $avg: '$puntuacion' } } },
    ]),
  ]);

  const promedioPuntuacionDada = promedioResult.length
    ? Number(promedioResult[0].promedio.toFixed(2))
    : 0;

  return {
    totalReseñas,
    totalAlfajoresDistintos: distinctAlfajores.length,
    promedioPuntuacionDada,
  };
};

const StatsService = {
  getTopRated,
  getMostReviewed,
  getUserStats,
};

export default StatsService;
