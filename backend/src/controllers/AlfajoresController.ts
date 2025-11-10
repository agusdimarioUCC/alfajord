import { Request, Response } from 'express';
import AlfajoresService, { AlfajorFilters } from '../services/AlfajoresService';

const parseNumber = (value?: string | string[]): number | undefined => {
  if (typeof value !== 'string') {
    return undefined;
  }

  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : undefined;
};

export const getAlfajores = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { q, pais, tipo, cobertura, sort } = req.query;
    const page = parseNumber(req.query.page as string | undefined);
    const limit = parseNumber(req.query.limit as string | undefined);

    const filters: AlfajorFilters = {
      q: typeof q === 'string' ? q : undefined,
      pais: typeof pais === 'string' ? pais : undefined,
      tipo: typeof tipo === 'string' ? tipo : undefined,
      cobertura: typeof cobertura === 'string' ? cobertura : undefined,
    };

    const result = await AlfajoresService.getAllAlfajores(
      filters,
      typeof sort === 'string' ? sort : undefined,
      page,
      limit
    );

    return res.json({
      data: result.data,
      meta: { total: result.total, page: result.page, limit: result.limit },
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unable to fetch alfajores';
    return res.status(400).json({ error: message });
  }
};

export const getAlfajor = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { id } = req.params;
    const alfajor = await AlfajoresService.getAlfajorById(id);
    return res.json({ data: alfajor });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unable to fetch alfajor';
    return res.status(400).json({ error: message });
  }
};

export const createAlfajor = async (req: Request, res: Response): Promise<Response> => {
  try {
    const {
      nombre,
      marca,
      pais,
      tipo,
      cobertura,
      descripcion,
      imagen,
    } = req.body as {
      nombre?: string;
      marca?: string;
      pais?: string;
      tipo?: string;
      cobertura?: string;
      descripcion?: string;
      imagen?: string;
    };

    if (!nombre || !marca || !pais || !tipo || !cobertura) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const nuevoAlfajor = await AlfajoresService.createAlfajor({
      nombre,
      marca,
      pais,
      tipo,
      cobertura,
      descripcion,
      imagen,
    });

    return res.status(201).json({ data: nuevoAlfajor });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unable to create alfajor';
    return res.status(400).json({ error: message });
  }
};
