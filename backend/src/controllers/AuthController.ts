import { Request, Response } from 'express';
import AuthService from '../services/AuthService';
import { IUser } from '../models/User';

type SafeUser = Omit<IUser, 'password'>;

const sanitizeUser = (user: IUser): SafeUser => {
  const userObject = user.toObject();
  delete userObject.password;
  return userObject as SafeUser;
};

export const register = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { email, password, nombreVisible } = req.body as {
      email?: string;
      password?: string;
      nombreVisible?: string;
    };

    if (!email || !password || !nombreVisible) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const user = await AuthService.registerUser(email, password, nombreVisible);
    const safeUser = sanitizeUser(user);

    return res.json({ data: safeUser });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unable to register user';
    return res.status(400).json({ error: message });
  }
};

export const login = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { email, password } = req.body as {
      email?: string;
      password?: string;
    };

    if (!email || !password) {
      return res.status(400).json({ error: 'Missing credentials' });
    }

    const { user, token } = await AuthService.loginUser(email, password);
    const safeUser = sanitizeUser(user);

    return res.json({ data: { user: safeUser, token } });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unable to login';
    return res.status(400).json({ error: message });
  }
};
