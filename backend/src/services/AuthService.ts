import bcrypt from 'bcrypt';
import UserModel, { IUser } from '../models/User';
import { signToken } from '../lib/jwt';

const SALT_ROUNDS = 10;

const normalizeEmail = (email: string): string => email.trim().toLowerCase();

const registerUser = async (
  email: string,
  password: string,
  nombreVisible: string
): Promise<IUser> => {
  const normalizedEmail = normalizeEmail(email);
  const existingUser = await UserModel.findOne({ email: normalizedEmail });

  if (existingUser) {
    throw new Error('Email already registered');
  }

  const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);
  const user = await UserModel.create({
    email: normalizedEmail,
    password: hashedPassword,
    nombreVisible,
    fechaRegistro: new Date(),
  });

  return user;
};

const loginUser = async (
  email: string,
  password: string
): Promise<{ user: IUser; token: string }> => {
  const normalizedEmail = normalizeEmail(email);
  const user = await UserModel.findOne({ email: normalizedEmail });

  if (!user) {
    throw new Error('Invalid credentials');
  }

  const isPasswordValid = await bcrypt.compare(password, user.password);

  if (!isPasswordValid) {
    throw new Error('Invalid credentials');
  }

  const token = signToken(user._id.toString());

  return { user, token };
};

const AuthService = {
  registerUser,
  loginUser,
};

export default AuthService;
