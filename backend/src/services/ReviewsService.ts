import { Types } from 'mongoose';
import ReviewModel, { IReview } from '../models/Review';
import AlfajorModel from '../models/Alfajor';
import calculateAverage from '../utils/calculateAverage';

const ensureObjectId = (id: string): Types.ObjectId => new Types.ObjectId(id);

export const recalculateAlfajorStats = async (alfajorId: string): Promise<void> => {
  const query = { alfajorId: ensureObjectId(alfajorId) };
  const reviews = await ReviewModel.find(query).select('puntuacion').lean();
  const puntuaciones = reviews.map((review) => review.puntuacion);
  const promedioPuntuacion = calculateAverage(puntuaciones);
  const totalReseñas = puntuaciones.length;

  await AlfajorModel.findByIdAndUpdate(alfajorId, {
    promedioPuntuacion,
    totalReseñas,
  });
};

interface CreateReviewInput {
  alfajorId: string;
  puntuacion: number;
  texto?: string;
  fechaConsumo?: Date;
}

const createReview = async (
  userId: string,
  data: CreateReviewInput
): Promise<IReview> => {
  const { alfajorId, puntuacion, texto, fechaConsumo } = data;

  if (!alfajorId || typeof puntuacion !== 'number') {
    throw new Error('Missing required review fields');
  }

  if (puntuacion < 1 || puntuacion > 5) {
    throw new Error('Score must be between 1 and 5');
  }

  const alfajorExists = await AlfajorModel.exists({ _id: alfajorId });

  if (!alfajorExists) {
    throw new Error('Alfajor not found');
  }

  const existingReview = await ReviewModel.findOne({
    userId: ensureObjectId(userId),
    alfajorId: ensureObjectId(alfajorId),
  });

  if (existingReview) {
    throw new Error('You have already reviewed this alfajor');
  }

  const review = await ReviewModel.create({
    userId,
    alfajorId,
    puntuacion,
    texto,
    fechaConsumo,
    fechaPublicacion: new Date(),
  });

  await recalculateAlfajorStats(alfajorId);
  return review;
};

const updateReview = async (
  reviewId: string,
  userId: string,
  data: Partial<IReview>
): Promise<IReview> => {
  const review = await ReviewModel.findOne({
    _id: ensureObjectId(reviewId),
    userId: ensureObjectId(userId),
  });

  if (!review) {
    throw new Error('Review not found or unauthorized');
  }

  if (typeof data.puntuacion === 'number') {
    if (data.puntuacion < 1 || data.puntuacion > 5) {
      throw new Error('Score must be between 1 and 5');
    }
    review.puntuacion = data.puntuacion;
  }

  if (typeof data.texto === 'string') {
    review.texto = data.texto;
  }

  if (data.fechaConsumo) {
    review.fechaConsumo = data.fechaConsumo;
  }

  await review.save();
  await recalculateAlfajorStats(review.alfajorId.toString());

  return review;
};

const deleteReview = async (reviewId: string, userId: string): Promise<void> => {
  const review = await ReviewModel.findOneAndDelete({
    _id: ensureObjectId(reviewId),
    userId: ensureObjectId(userId),
  });

  if (!review) {
    throw new Error('Review not found or unauthorized');
  }

  await recalculateAlfajorStats(review.alfajorId.toString());
};

const getReviewsByAlfajor = async (
  alfajorId: string,
  page = 1,
  limit = 10
): Promise<{ data: IReview[]; total: number; page: number; limit: number }> => {
  const safePage = Number.isFinite(page) && page > 0 ? Math.floor(page) : 1;
  const safeLimit = Number.isFinite(limit) && limit > 0 ? Math.floor(limit) : 10;
  const skip = (safePage - 1) * safeLimit;

  const query = { alfajorId: ensureObjectId(alfajorId) };

  const [data, total] = await Promise.all([
    ReviewModel.find(query)
      .populate('userId', 'nombreVisible avatarUrl')
      .sort({ fechaPublicacion: -1 })
      .skip(skip)
      .limit(safeLimit)
      .exec(),
    ReviewModel.countDocuments(query),
  ]);

  return { data, total, page: safePage, limit: safeLimit };
};

const ReviewsService = {
  createReview,
  updateReview,
  deleteReview,
  getReviewsByAlfajor,
  recalculateAlfajorStats,
};

export default ReviewsService;
