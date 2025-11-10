import { Schema, model, Document, Types } from 'mongoose';

export interface IReview extends Document {
  userId: Types.ObjectId;
  alfajorId: Types.ObjectId;
  puntuacion: number;
  texto?: string;
  fechaConsumo?: Date;
  fechaPublicacion: Date;
  createdAt: Date;
  updatedAt: Date;
}

const reviewSchema = new Schema<IReview>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    alfajorId: {
      type: Schema.Types.ObjectId,
      ref: 'Alfajor',
      required: true,
      index: true,
    },
    puntuacion: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    texto: {
      type: String,
      trim: true,
    },
    fechaConsumo: {
      type: Date,
    },
    fechaPublicacion: {
      type: Date,
      default: Date.now,
      immutable: true,
    },
  },
  {
    timestamps: true,
    versionKey: false,
  }
);

const ReviewModel = model<IReview>('Review', reviewSchema);

export default ReviewModel;
