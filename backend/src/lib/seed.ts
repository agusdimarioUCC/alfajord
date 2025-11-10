import 'dotenv/config';
import mongoose from 'mongoose';
import bcrypt from 'bcrypt';
import connectDB from './db';
import UserModel from '../models/User';
import AlfajorModel from '../models/Alfajor';
import ReviewModel from '../models/Review';
import { recalculateAlfajorStats } from '../services/ReviewsService';

const SALT_ROUNDS = 10;

interface SeedUser {
  email: string;
  password: string;
  nombreVisible: string;
}

interface SeedAlfajor {
  nombre: string;
  marca: string;
  pais: string;
  tipo: string;
  cobertura: string;
  descripcion?: string;
  imagen?: string;
}

const userSeeds: SeedUser[] = [
  { email: 'agus@test.com', password: '123456', nombreVisible: 'Agus' },
  { email: 'alma@test.com', password: '123456', nombreVisible: 'Alma' },
  { email: 'santi@test.com', password: '123456', nombreVisible: 'Santi' },
];

const alfajorSeeds: SeedAlfajor[] = [
  {
    nombre: 'Havanna Clásico',
    marca: 'Havanna',
    pais: 'Argentina',
    tipo: 'Dulce de leche',
    cobertura: 'Chocolate con leche',
    descripcion: 'Triple clásico con mucho dulce de leche.',
  },
  {
    nombre: 'Guaymallén Triple',
    marca: 'Guaymallén',
    pais: 'Argentina',
    tipo: 'Dulce de leche',
    cobertura: 'Chocolate amargo',
    descripcion: 'Una institución porteña accesible.',
  },
  {
    nombre: 'Capitán del Espacio',
    marca: 'Capitán del Espacio',
    pais: 'Argentina',
    tipo: 'Dulce de leche',
    cobertura: 'Chocolate con leche',
  },
  {
    nombre: 'Cachafaz Mousse',
    marca: 'Cachafaz',
    pais: 'Argentina',
    tipo: 'Mousse de dulce de leche',
    cobertura: 'Chocolate semi-amargo',
  },
  {
    nombre: 'Serenata',
    marca: 'Nestlé',
    pais: 'Uruguay',
    tipo: 'Dulce de leche',
    cobertura: 'Chocolate con leche',
  },
  {
    nombre: 'Punta Ballena Clásico',
    marca: 'Punta Ballena',
    pais: 'Uruguay',
    tipo: 'Dulce de leche',
    cobertura: 'Chocolate',
  },
  {
    nombre: 'Costa Ramita',
    marca: 'Costa',
    pais: 'Chile',
    tipo: 'Manjar',
    cobertura: 'Chocolate',
  },
  {
    nombre: 'Helena Gourmet',
    marca: 'Helena',
    pais: 'Perú',
    tipo: 'Manjar blanco',
    cobertura: 'Azúcar impalpable',
  },
  {
    nombre: 'Chomp Deluxe',
    marca: 'Whittaker',
    pais: 'Nueva Zelanda',
    tipo: 'Caramelo y dulce de leche',
    cobertura: 'Chocolate',
  },
  {
    nombre: 'Milka Oreo Alfajor',
    marca: 'Milka',
    pais: 'Argentina',
    tipo: 'Crema Oreo',
    cobertura: 'Chocolate con leche',
  },
];

const reviewTexts = [
  'Increíble textura y equilibrio.',
  'Rico pero un poco empalagoso.',
  'Ideal con café.',
  'El chocolate podría ser mejor.',
  'Sabor nostálgico.',
  'Sorprendentemente fresco.',
];

const ratingOptions = [5, 4.5, 4, 3.5, 3, 2.5];

const randomFrom = <T>(items: T[]): T => items[Math.floor(Math.random() * items.length)];

const buildFechaConsumo = (): Date => {
  const daysAgo = Math.floor(Math.random() * 120);
  const date = new Date();
  date.setDate(date.getDate() - daysAgo);
  return date;
};

const shuffle = <T>(array: T[]): T[] => {
  const shuffled = [...array];
  for (let i = shuffled.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
};

const seed = async (): Promise<void> => {
  try {
    await connectDB();
    await Promise.all([
      UserModel.deleteMany({}),
      AlfajorModel.deleteMany({}),
      ReviewModel.deleteMany({}),
    ]);

    const hashedUsers = await Promise.all(
      userSeeds.map(async ({ email, password, nombreVisible }) => ({
        email,
        password: await bcrypt.hash(password, SALT_ROUNDS),
        nombreVisible,
        fechaRegistro: new Date(),
      }))
    );

    const createdUsers = await UserModel.insertMany(hashedUsers);
    const createdAlfajores = await AlfajorModel.insertMany(alfajorSeeds);

    const combos = createdUsers.flatMap((user) =>
      createdAlfajores.map((alfajor) => ({ userId: user._id, alfajorId: alfajor._id }))
    );

    const selectedCombos = shuffle(combos).slice(0, 15);

    const reviewDocs = selectedCombos.map(({ userId, alfajorId }) => ({
      userId,
      alfajorId,
      puntuacion: randomFrom(ratingOptions),
      texto: randomFrom(reviewTexts),
      fechaConsumo: buildFechaConsumo(),
      fechaPublicacion: new Date(),
    }));

    const createdReviews = await ReviewModel.insertMany(reviewDocs);
    const uniqueAlfajores = Array.from(
      new Set(createdReviews.map((review) => review.alfajorId.toString()))
    );

    await Promise.all(uniqueAlfajores.map((alfajorId) => recalculateAlfajorStats(alfajorId)));

    console.log('Seed completado ✅');
    console.log(`Usuarios: ${createdUsers.length}`);
    console.log(`Alfajores: ${createdAlfajores.length}`);
    console.log(`Reseñas: ${createdReviews.length}`);
  } catch (error) {
    console.error('Error ejecutando seed', error);
    process.exitCode = 1;
  } finally {
    await mongoose.connection.close();
  }
};

seed();
