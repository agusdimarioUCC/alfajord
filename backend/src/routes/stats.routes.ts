import { Router } from 'express';
import { getTopRated, getMostReviewed, getMyStats } from '../controllers/StatsController';
import authMiddleware from '../middlewares/authMiddleware';

const router = Router();

router.get('/top-rated', getTopRated);
router.get('/most-reviewed', getMostReviewed);
router.get('/me', authMiddleware, getMyStats);

export default router;
