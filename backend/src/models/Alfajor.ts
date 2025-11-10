import { Schema, model, Document } from 'mongoose';

export interface IAlfajor extends Document {
  nombre: string;
  marca: string;
  pais: string;
  tipo: string;
  cobertura: string;
  descripcion?: string;
  imagen?: string;
  promedioPuntuacion: number;
  totalReseñas: number;
  createdAt: Date;
  updatedAt: Date;
}

const alfajorSchema = new Schema<IAlfajor>(
  {
    nombre: { type: String, required: true, trim: true },
    marca: { type: String, required: true, trim: true },
    pais: { type: String, required: true, trim: true },
    tipo: { type: String, required: true, trim: true },
    cobertura: { type: String, required: true, trim: true },
    descripcion: { type: String, trim: true },
    imagen: { type: String, trim: true },
    promedioPuntuacion: { type: Number, default: 0, min: 0, max: 5 },
    totalReseñas: { type: Number, default: 0, min: 0 },
  },
  {
    timestamps: true,
    versionKey: false,
  }
);

const AlfajorModel = model<IAlfajor>('Alfajor', alfajorSchema);

export default AlfajorModel;
