import { Router } from 'express';
import {
  createReview,
  updateReview,
  deleteReview,
  getReviewsByAlfajor,
} from '../controllers/ReviewsController';
import authMiddleware from '../middlewares/authMiddleware';

const router = Router();

router.get('/alfajor/:alfajorId', getReviewsByAlfajor);
router.post('/', authMiddleware, createReview);
router.put('/:id', authMiddleware, updateReview);
router.delete('/:id', authMiddleware, deleteReview);

export default router;
