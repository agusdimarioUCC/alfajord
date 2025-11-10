import jwt, { JwtPayload } from 'jsonwebtoken';

const getJwtSecret = (): string => {
  const secret = process.env.JWT_SECRET;

  if (!secret) {
    throw new Error('JWT_SECRET is not defined');
  }

  return secret;
};

interface TokenPayload extends JwtPayload {
  userId: string;
}

export const signToken = (userId: string): string =>
  jwt.sign({ userId }, getJwtSecret(), { expiresIn: '7d' });

export const verifyToken = (token: string): string | null => {
  try {
    const decoded = jwt.verify(token, getJwtSecret()) as TokenPayload;
    return typeof decoded.userId === 'string' ? decoded.userId : null;
  } catch (error) {
    return null;
  }
};
