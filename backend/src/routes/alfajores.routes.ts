import { Router } from 'express';
import { getAlfajores, getAlfajor, createAlfajor } from '../controllers/AlfajoresController';
import authMiddleware from '../middlewares/authMiddleware';

const router = Router();

router.get('/', getAlfajores);
router.get('/:id', getAlfajor);
router.post('/', authMiddleware, createAlfajor);

export default router;
