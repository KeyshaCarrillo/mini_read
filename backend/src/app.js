// backend/src/app.js
const cors = require('cors');
const express = require('express');

const { admin, db } = require('./firebase');
const { optionalAuth, requireAdmin, requireAuth } = require('./middleware');
const {
  asyncHandler,
  collectionToJson,
  dateOnly,
  docToJson,
  getProfileRef,
  pick,
  requireAllowedCollection,
  sameDay
} = require('./utils');

const app = express();

app.use(cors({ origin: true }));
app.use(express.json({ limit: '1mb' }));

app.get('/api/health', (_req, res) => {
  res.json({ ok: true, service: 'mini-read-api' });
});

app.get(
  '/api/books',
  optionalAuth,
  asyncHandler(async (_req, res) => {
    const snapshot = await db.collection('books').orderBy('title').get();
    res.json({ books: collectionToJson(snapshot) });
  })
);

app.get(
  '/api/books/:bookId',
  optionalAuth,
  asyncHandler(async (req, res) => {
    const snapshot = await db.collection('books').doc(req.params.bookId).get();
    const book = docToJson(snapshot);
    if (!book) return res.status(404).json({ error: 'Libro no encontrado.' });
    return res.json(book);
  })
);

app.post(
  '/api/books',
  requireAuth,
  requireAdmin,
  asyncHandler(async (req, res) => {
    const book = normalizeBook(req.body);
    const ref = book.id ? db.collection('books').doc(book.id) : db.collection('books').doc();
    await ref.set({
      ...book,
      id: ref.id,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    const snapshot = await ref.get();
    return res.status(201).json(docToJson(snapshot));
  })
);

app.patch(
  '/api/books/:bookId',
  requireAuth,
  requireAdmin,
  asyncHandler(async (req, res) => {
    const ref = db.collection('books').doc(req.params.bookId);
    await ref.set(
      {
        ...normalizeBook(req.body, { partial: true }),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      },
      { merge: true }
    );
    const snapshot = await ref.get();
    return res.json(docToJson(snapshot));
  })
);

app.delete(
  '/api/books/:bookId',
  requireAuth,
  requireAdmin,
  asyncHandler(async (req, res) => {
    await db.collection('books').doc(req.params.bookId).delete();
    res.status(204).send();
  })
);

app.get(
  '/api/me',
  requireAuth,
  asyncHandler(async (req, res) => {
    const snapshot = await db.collection('users').doc(req.user.uid).get();
    res.json(docToJson(snapshot));
  })
);

app.patch(
  '/api/me',
  requireAuth,
  asyncHandler(async (req, res) => {
    const allowed = ['name', 'preferences'];
    await db.collection('users').doc(req.user.uid).set(
      {
        ...pick(req.body, allowed),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      },
      { merge: true }
    );
    const snapshot = await db.collection('users').doc(req.user.uid).get();
    res.json(docToJson(snapshot));
  })
);

app.get(
  '/api/profiles',
  requireAuth,
  asyncHandler(async (req, res) => {
    const snapshot = await db.collection('users').doc(req.user.uid).collection('perfiles').get();
    res.json({ profiles: collectionToJson(snapshot) });
  })
);

app.post(
  '/api/profiles',
  requireAuth,
  asyncHandler(async (req, res) => {
    const profilesRef = db.collection('users').doc(req.user.uid).collection('perfiles');
    const snapshot = await profilesRef.get();
    if (snapshot.size >= 4) {
      return res.status(409).json({ error: 'La cuenta ya tiene 4 perfiles.' });
    }

    const profile = normalizeProfile(req.body);
    const ref = profilesRef.doc();
    await ref.set({
      ...profile,
      id: ref.id,
      tokens: profile.tokens ?? 0,
      dailyStreak: profile.dailyStreak ?? 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    const created = await ref.get();
    return res.status(201).json(docToJson(created));
  })
);

app.get(
  '/api/profiles/:profileId',
  requireAuth,
  asyncHandler(async (req, res) => {
    const snapshot = await getProfileRef(db, req.user.uid, req.params.profileId).get();
    const profile = docToJson(snapshot);
    if (!profile) return res.status(404).json({ error: 'Perfil no encontrado.' });
    return res.json(profile);
  })
);

app.patch(
  '/api/profiles/:profileId',
  requireAuth,
  asyncHandler(async (req, res) => {
    const ref = getProfileRef(db, req.user.uid, req.params.profileId);
    await ref.set(
      {
        ...normalizeProfile(req.body, { partial: true }),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      },
      { merge: true }
    );
    const snapshot = await ref.get();
    res.json(docToJson(snapshot));
  })
);

app.delete(
  '/api/profiles/:profileId',
  requireAuth,
  asyncHandler(async (req, res) => {
    await getProfileRef(db, req.user.uid, req.params.profileId).delete();
    res.status(204).send();
  })
);

app.post(
  '/api/profiles/:profileId/check-in',
  requireAuth,
  asyncHandler(async (req, res) => {
    const result = await checkInProfile(req.user.uid, req.params.profileId);
    res.json(result);
  })
);

app.post(
  '/api/profiles/:profileId/reward-ad',
  requireAuth,
  asyncHandler(async (req, res) => {
    const amount = Number(req.body.amount || 30);
    const tokens = await rewardTokens({
      uid: req.user.uid,
      profileId: req.params.profileId,
      amount,
      type: 'rewarded_video'
    });
    res.json({ profileId: req.params.profileId, tokens, amount });
  })
);

app.post(
  '/api/ai/validate',
  requireAuth,
  asyncHandler(async (req, res) => {
    const type = req.body.type === 'general' ? 'general' : 'page';
    const cost = type === 'page' ? 5 : 10;
    const result = await spendAiTokens({
      uid: req.user.uid,
      profileId: req.body.profileId,
      bookId: req.body.bookId,
      pageNumber: req.body.pageNumber,
      type,
      cost
    });
    res.json(result);
  })
);

app.get(
  '/api/history-reading',
  requireAuth,
  asyncHandler(async (req, res) => {
    let query = db.collection('history_reading').where('uid', '==', req.user.uid);
    if (req.query.profileId) query = query.where('profileId', '==', req.query.profileId);
    if (req.query.bookId) query = query.where('bookId', '==', req.query.bookId);
    const snapshot = await query.limit(100).get();
    res.json({ history: collectionToJson(snapshot) });
  })
);

app.put(
  '/api/history-reading/:profileId/:bookId',
  requireAuth,
  asyncHandler(async (req, res) => {
    const { profileId, bookId } = req.params;
    await assertProfileOwner(req.user.uid, profileId);
    const ref = db.collection('history_reading').doc(`${profileId}-${bookId}`);
    await ref.set(
      {
        uid: req.user.uid,
        profileId,
        bookId,
        lastPageRead: Number(req.body.lastPageRead || 1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      },
      { merge: true }
    );
    const snapshot = await ref.get();
    res.json(docToJson(snapshot));
  })
);

app.get(
  '/api/ia-chats',
  requireAuth,
  asyncHandler(async (req, res) => {
    let query = db.collection('ia_chats').where('uid', '==', req.user.uid);
    if (req.query.profileId) query = query.where('profileId', '==', req.query.profileId);
    if (req.query.bookId) query = query.where('bookId', '==', req.query.bookId);
    const snapshot = await query.limit(100).get();
    res.json({ chats: collectionToJson(snapshot) });
  })
);

app.post(
  '/api/ia-chats',
  requireAuth,
  asyncHandler(async (req, res) => {
    await assertProfileOwner(req.user.uid, req.body.profileId);
    const ref = await db.collection('ia_chats').add({
      uid: req.user.uid,
      profileId: req.body.profileId,
      bookId: req.body.bookId,
      pageNumber: req.body.pageNumber ?? null,
      type: req.body.type || 'page',
      question: req.body.question || '',
      answer: req.body.answer || '',
      pageContext: req.body.pageContext || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    const snapshot = await ref.get();
    res.status(201).json(docToJson(snapshot));
  })
);

app.get(
  '/api/token-transactions',
  requireAuth,
  asyncHandler(async (req, res) => {
    let query = db.collection('token_transactions').where('uid', '==', req.user.uid);
    if (req.query.profileId) query = query.where('profileId', '==', req.query.profileId);
    const snapshot = await query.limit(100).get();
    res.json({ transactions: collectionToJson(snapshot) });
  })
);

app.get(
  '/api/admin/:collection',
  requireAuth,
  requireAdmin,
  asyncHandler(async (req, res) => {
    requireAllowedCollection(req.params.collection);
    const snapshot = await db.collection(req.params.collection).limit(100).get();
    res.json({ items: collectionToJson(snapshot) });
  })
);

app.post(
  '/api/admin/:collection',
  requireAuth,
  requireAdmin,
  asyncHandler(async (req, res) => {
    requireAllowedCollection(req.params.collection);
    const ref = req.body.id
      ? db.collection(req.params.collection).doc(req.body.id)
      : db.collection(req.params.collection).doc();
    await ref.set({
      ...req.body,
      id: ref.id,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    const snapshot = await ref.get();
    res.status(201).json(docToJson(snapshot));
  })
);

app.patch(
  '/api/admin/:collection/:docId',
  requireAuth,
  requireAdmin,
  asyncHandler(async (req, res) => {
    requireAllowedCollection(req.params.collection);
    const ref = db.collection(req.params.collection).doc(req.params.docId);
    await ref.set(
      {
        ...req.body,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      },
      { merge: true }
    );
    const snapshot = await ref.get();
    res.json(docToJson(snapshot));
  })
);

app.delete(
  '/api/admin/:collection/:docId',
  requireAuth,
  requireAdmin,
  asyncHandler(async (req, res) => {
    requireAllowedCollection(req.params.collection);
    await db.collection(req.params.collection).doc(req.params.docId).delete();
    res.status(204).send();
  })
);

app.use((req, res) => {
  res.status(404).json({ error: `Ruta no encontrada: ${req.method} ${req.path}` });
});

app.use((error, _req, res, _next) => {
  const status = error.statusCode || 500;
  res.status(status).json({
    error: error.message || 'Error interno del servidor.'
  });
});

async function assertProfileOwner(uid, profileId) {
  if (!profileId) {
    const error = new Error('profileId es requerido.');
    error.statusCode = 400;
    throw error;
  }

  const snapshot = await getProfileRef(db, uid, profileId).get();
  if (!snapshot.exists) {
    const error = new Error('Perfil no encontrado.');
    error.statusCode = 404;
    throw error;
  }
}

async function checkInProfile(uid, profileId) {
  const ref = getProfileRef(db, uid, profileId);
  return db.runTransaction(async transaction => {
    const snapshot = await transaction.get(ref);
    if (!snapshot.exists) {
      const error = new Error('Perfil no encontrado.');
      error.statusCode = 404;
      throw error;
    }

    const data = snapshot.data();
    const today = dateOnly();
    const lastLogin = data.lastLoginDate?.toDate
      ? dateOnly(data.lastLoginDate.toDate())
      : null;

    if (lastLogin && sameDay(lastLogin, today)) {
      return {
        profileId,
        tokens: data.tokens || 0,
        dailyStreak: data.dailyStreak || 0,
        reward: 0
      };
    }

    const wasYesterday =
      lastLogin &&
      sameDay(lastLogin, new Date(today.getFullYear(), today.getMonth(), today.getDate() - 1));
    const reward = 20;
    const tokens = Number(data.tokens || 0) + reward;
    const dailyStreak = wasYesterday ? Number(data.dailyStreak || 0) + 1 : 1;

    transaction.update(ref, {
      tokens,
      dailyStreak,
      lastLoginDate: admin.firestore.Timestamp.fromDate(today),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    transaction.set(db.collection('token_transactions').doc(), {
      uid,
      profileId,
      amount: reward,
      type: 'daily_streak',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return { profileId, tokens, dailyStreak, reward };
  });
}

async function rewardTokens({ uid, profileId, amount, type }) {
  const ref = getProfileRef(db, uid, profileId);
  return db.runTransaction(async transaction => {
    const snapshot = await transaction.get(ref);
    if (!snapshot.exists) {
      const error = new Error('Perfil no encontrado.');
      error.statusCode = 404;
      throw error;
    }

    const tokens = Number(snapshot.data().tokens || 0) + amount;
    transaction.update(ref, {
      tokens,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    transaction.set(db.collection('token_transactions').doc(), {
      uid,
      profileId,
      amount,
      type,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    return tokens;
  });
}

async function spendAiTokens({ uid, profileId, bookId, pageNumber, type, cost }) {
  const userRef = db.collection('users').doc(uid);
  const profileRef = getProfileRef(db, uid, profileId);

  return db.runTransaction(async transaction => {
    const userSnapshot = await transaction.get(userRef);
    const profileSnapshot = await transaction.get(profileRef);

    if (!profileSnapshot.exists) {
      const error = new Error('Perfil no encontrado.');
      error.statusCode = 404;
      throw error;
    }

    const isPremium = userSnapshot.data()?.isPremium === true;
    const currentTokens = Number(profileSnapshot.data().tokens || 0);

    if (isPremium) {
      return { granted: true, premium: true, currentTokens, cost: 0 };
    }

    if (currentTokens < cost) {
      return { granted: false, premium: false, currentTokens, cost };
    }

    const nextTokens = currentTokens - cost;
    transaction.update(profileRef, {
      tokens: nextTokens,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    transaction.set(db.collection('token_transactions').doc(), {
      uid,
      profileId,
      bookId,
      pageNumber: pageNumber ?? null,
      amount: -cost,
      type: `ai_${type}`,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return { granted: true, premium: false, currentTokens: nextTokens, cost };
  });
}

function normalizeBook(body, options = {}) {
  const allowed = [
    'id',
    'title',
    'author',
    'category',
    'audience',
    'description',
    'sourceName',
    'sourceUrl',
    'accentColor',
    'estimatedMinutes',
    'hasImmersiveImages',
    'pages'
  ];
  const book = pick(body, allowed);
  if (!options.partial && !book.title) {
    const error = new Error('title es requerido.');
    error.statusCode = 400;
    throw error;
  }
  if (Array.isArray(book.pages)) {
    book.pages = book.pages.map((page, index) => ({
      pageNumber: Number(page.pageNumber || index + 1),
      title: page.title || `Pagina ${index + 1}`,
      text: page.text || page.body || '',
      imageUrl: page.imageUrl || null,
      illustration: page.illustration || null
    }));
  }
  return book;
}

function normalizeProfile(body, options = {}) {
  const allowed = [
    'name',
    'avatarUrl',
    'role',
    'tokens',
    'dailyStreak',
    'lastLoginDate',
    'ageGroup',
    'readingMood',
    'favoriteCategories',
    'accentColor'
  ];
  const profile = pick(body, allowed);
  if (!options.partial && !profile.name) {
    const error = new Error('name es requerido.');
    error.statusCode = 400;
    throw error;
  }
  if (profile.role && !['adult', 'child'].includes(profile.role)) {
    profile.role = 'adult';
  }
  if (profile.favoriteCategories && !Array.isArray(profile.favoriteCategories)) {
    profile.favoriteCategories = [];
  }
  if (typeof profile.lastLoginDate === 'string') {
    profile.lastLoginDate = admin.firestore.Timestamp.fromDate(new Date(profile.lastLoginDate));
  }
  return profile;
}

module.exports = app;
