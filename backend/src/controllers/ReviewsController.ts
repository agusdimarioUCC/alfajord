import { Request, Response } from 'express';
import ReviewsService from '../services/ReviewsService';
import { AuthRequest } from '../middlewares/authMiddleware';

const parseNumber = (value?: string | string[]): number | undefined => {
  if (typeof value !== 'string') {
    return undefined;
  }

  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : undefined;
};

const parseDate = (value?: string | Date): Date | undefined => {
  if (!value) {
    return undefined;
  }

  const date = value instanceof Date ? value : new Date(value);
  return Number.isNaN(date.getTime()) ? undefined : date;
};

export const createReview = async (req: AuthRequest, res: Response): Promise<Response> => {
  try {
    if (!req.userId) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const { alfajorId, puntuacion, texto, fechaConsumo } = req.body as {
      alfajorId?: string;
      puntuacion?: number;
      texto?: string;
      fechaConsumo?: string | Date;
    };

    if (!alfajorId || typeof puntuacion !== 'number') {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const fechaConsumoDate = parseDate(fechaConsumo);

    const review = await ReviewsService.createReview(req.userId, {
      alfajorId,
      puntuacion,
      texto,
      fechaConsumo: fechaConsumoDate,
    });

    return res.status(201).json({ data: review });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unable to create review';
    return res.status(400).json({ error: message });
  }
};

export const updateReview = async (req: AuthRequest, res: Response): Promise<Response> => {
  try {
    if (!req.userId) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const { id } = req.params;
    const { puntuacion, texto, fechaConsumo } = req.body as {
      puntuacion?: number;
      texto?: string;
      fechaConsumo?: string | Date;
    };

    const fechaConsumoDate = parseDate(fechaConsumo);

    const review = await ReviewsService.updateReview(id, req.userId, {
      puntuacion,
      texto,
      fechaConsumo: fechaConsumoDate,
    });

    return res.json({ data: review });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unable to update review';
    return res.status(400).json({ error: message });
  }
};

export const deleteReview = async (req: AuthRequest, res: Response): Promise<Response> => {
  try {
    if (!req.userId) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const { id } = req.params;
    await ReviewsService.deleteReview(id, req.userId);
    return res.json({ message: 'Reseña eliminada' });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unable to delete review';
    return res.status(400).json({ error: message });
  }
};

export const getReviewsByAlfajor = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { alfajorId } = req.params;
    const page = parseNumber(req.query.page as string | undefined);
    const limit = parseNumber(req.query.limit as string | undefined);

    if (!alfajorId) {
      return res.status(400).json({ error: 'Alfajor ID is required' });
    }

    const result = await ReviewsService.getReviewsByAlfajor(
      alfajorId,
      page,
      limit
    );

    return res.json({
      data: result.data,
      meta: { total: result.total, page: result.page, limit: result.limit },
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unable to fetch reviews';
    return res.status(400).json({ error: message });
  }
};
