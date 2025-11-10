import { FilterQuery, SortOrder } from 'mongoose';
import AlfajorModel, { IAlfajor } from '../models/Alfajor';

export interface AlfajorFilters {
  q?: string;
  pais?: string;
  tipo?: string;
  cobertura?: string;
}

const SORT_MAP: Record<string, Record<string, SortOrder>> = {
  rating: { promedioPuntuacion: -1 },
  popular: { totalReseñas: -1 },
  recent: { createdAt: -1 },
};

const buildQuery = (filters: AlfajorFilters): FilterQuery<IAlfajor> => {
  const query: FilterQuery<IAlfajor> = {};
  const { q, pais, tipo, cobertura } = filters;

  if (q) {
    const regex = new RegExp(q, 'i');
    query.$or = [{ nombre: regex }, { marca: regex }];
  }

  if (pais) {
    query.pais = pais;
  }

  if (tipo) {
    query.tipo = tipo;
  }

  if (cobertura) {
    query.cobertura = cobertura;
  }

  return query;
};

const getAllAlfajores = async (
  filters: AlfajorFilters,
  sort?: string,
  page = 1,
  limit = 10
): Promise<{ data: IAlfajor[]; total: number; page: number; limit: number }> => {
  const query = buildQuery(filters);
  const sortKey = sort && SORT_MAP[sort] ? sort : 'recent';
  const sortOption = SORT_MAP[sortKey] ?? SORT_MAP.recent;
  const safePage = Number.isFinite(page) && page > 0 ? Math.floor(page) : 1;
  const safeLimit = Number.isFinite(limit) && limit > 0 ? Math.floor(limit) : 10;
  const skip = (safePage - 1) * safeLimit;

  const [data, total] = await Promise.all([
    AlfajorModel.find(query)
      .sort(sortOption)
      .skip(skip)
      .limit(safeLimit)
      .exec(),
    AlfajorModel.countDocuments(query),
  ]);

  return { data, total, page: safePage, limit: safeLimit };
};

const getAlfajorById = async (id: string): Promise<IAlfajor> => {
  const alfajor = await AlfajorModel.findById(id);

  if (!alfajor) {
    throw new Error('Alfajor not found');
  }

  return alfajor;
};

const createAlfajor = async (data: Partial<IAlfajor>): Promise<IAlfajor> => {
  const alfajor = await AlfajorModel.create({
    ...data,
    promedioPuntuacion: 0,
    totalReseñas: 0,
  });

  return alfajor;
};

const AlfajoresService = {
  getAllAlfajores,
  getAlfajorById,
  createAlfajor,
};

export default AlfajoresService;
