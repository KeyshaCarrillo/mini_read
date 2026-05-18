// backend/src/middleware.js
const { auth, db } = require('./firebase');

async function requireAuth(req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const [, token] = header.match(/^Bearer (.+)$/) || [];

    if (!token) {
      return res.status(401).json({ error: 'Falta Authorization Bearer token.' });
    }

    req.user = await auth.verifyIdToken(token);
    return next();
  } catch (error) {
    return res.status(401).json({ error: 'Token invalido o expirado.' });
  }
}

async function optionalAuth(req, _res, next) {
  try {
    const header = req.headers.authorization || '';
    const [, token] = header.match(/^Bearer (.+)$/) || [];
    if (token) req.user = await auth.verifyIdToken(token);
  } catch (_) {
    req.user = null;
  }
  return next();
}

async function requireAdmin(req, res, next) {
  try {
    if (req.user?.admin === true) return next();

    const uid = req.user?.uid;
    if (!uid) return res.status(401).json({ error: 'No autenticado.' });

    const userDoc = await db.collection('users').doc(uid).get();
    const role = userDoc.data()?.role;

    if (role === 'admin' || role === 'owner') return next();

    return res.status(403).json({ error: 'Requiere rol admin.' });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  optionalAuth,
  requireAdmin,
  requireAuth
};
