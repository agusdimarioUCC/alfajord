import { Request, Response } from 'express';
import StatsService from '../services/StatsService';
import { AuthRequest } from '../middlewares/authMiddleware';

const parseNumber = (value?: string | string[]): number | undefined => {
  if (typeof value !== 'string') {
    return undefined;
  }

  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : undefined;
};

export const getTopRated = async (req: Request, res: Response): Promise<Response> => {
  try {
    const minReviews = parseNumber(req.query.minReviews as string | undefined);
    const limit = parseNumber(req.query.limit as string | undefined);

    const data = await StatsService.getTopRated(
      minReviews ?? 5,
      limit ?? 10
    );

    return res.json({ data });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unable to fetch top rated alfajores';
    return res.status(400).json({ error: message });
  }
};

export const getMostReviewed = async (req: Request, res: Response): Promise<Response> => {
  try {
    const limit = parseNumber(req.query.limit as string | undefined);
    const data = await StatsService.getMostReviewed(limit ?? 10);
    return res.json({ data });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unable to fetch most reviewed alfajores';
    return res.status(400).json({ error: message });
  }
};

export const getMyStats = async (req: AuthRequest, res: Response): Promise<Response> => {
  try {
    if (!req.userId) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const data = await StatsService.getUserStats(req.userId);
    return res.json({ data });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unable to fetch user stats';
    return res.status(400).json({ error: message });
  }
};
