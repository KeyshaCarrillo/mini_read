// backend/src/app.js
const cors = require('cors');
const express = require('express');

const fs = require('fs');
const path = require('path');

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

app.delete(
  '/api/account',
  requireAuth,
  asyncHandler(async (req, res) => {
    const uid = req.user.uid;
    const userRef = db.collection('users').doc(uid);
    const profilesSnapshot = await userRef.collection('perfiles').get();
    const profilesV2Snapshot = await db.collection('profiles').where('userId', '==', uid).get();
    const profileIds = [
      ...new Set([
        ...profilesSnapshot.docs.map((doc) => doc.id),
        ...profilesV2Snapshot.docs.map((doc) => doc.id)
      ])
    ];

    const associatedCollections = [
      'history_reading',
      'favorites',
      'reading_progress',
      'reviews',
      'memberships',
      'ia_chats',
      'token_transactions',
      'notifications',
      'achievements',
      'profiles'
    ];
    for (const collection of associatedCollections) {
      await deleteDocumentsForUser(collection, uid);
    }
    await db.collection('memberships').doc(uid).delete();
    await deleteDocumentsForProfiles('achievements', profileIds);
    await db.recursiveDelete(userRef);
    try {
      await deleteCloudinaryAccountAssets(uid, profileIds);
    } catch (error) {
      console.warn(`No se pudieron limpiar todos los avatares de ${uid}: ${error.message}`);
    }
    await admin.auth().deleteUser(uid);

    res.status(204).send();
  })
);

// â—„â€” Reemplaza por completo tu app.get('/api/books') con esto:
app.get(
  '/api/books',
  optionalAuth,
  asyncHandler(async (_req, res) => {
    try {
      // Definimos los libros directamente en memoria (RÃ¡pido, seguro y sin fallas de archivos)
      const mockBooks = [
        {
          "id": "libro-ninos-1",
          "title": "El Viaje de la Estrellita",
          "author": "Elena Espacio",
          "category": "FantastÃ­a",
          "audience": "Ninos",
          "description": "Una pequeÃ±a estrella cae a la Tierra y busca la ayuda de los animales del bosque para volver al cielo nocturno.",
          "sourceName": "API de libros",
          "sourceUrl": "",
          "accentColor": "#FF8FB3",
          "estimatedMinutes": 5,
          "hasImmersiveImages": true,
          "pages": [
            {
              "pageNumber": 1,
              "title": "Un Destello en la Noche",
              "text": "HabÃ­a una vez una pequeÃ±a estrella llamada Centella que vivÃ­a en lo mÃ¡s alto del cielo.",
              "illustration": "estrellita_cayendo",
              "imageUrl": "https://images.unsplash.com/photo-1506318137071-a8e063b4bec0"
            },
            {
              "pageNumber": 2,
              "title": "Nuevos Amigos",
              "text": "Al caer en un suave colchÃ³n de musgo, el sabio bÃºho la saludÃ³ con un parpadeo.",
              "illustration": "buho_sabio",
              "imageUrl": "https://images.unsplash.com/photo-1543466835-00a7907e9de1"
            }
          ]
        },
        {
          "id": "libro-ninos-2",
          "title": "El DragÃ³n que no podÃ­a Escupir Fuego",
          "author": "Lucas Relatos",
          "category": "Aventura",
          "audience": "Ninos",
          "description": "Dante es un dragÃ³n muy especial: en lugar de fuego, Â¡escurre burbujas mÃ¡gicas de colores!",
          "sourceName": "API de libros",
          "sourceUrl": "",
          "accentColor": "#7ED7C1",
          "estimatedMinutes": 6,
          "hasImmersiveImages": true,
          "pages": [
            {
              "pageNumber": 1,
              "title": "La Gran Fogata",
              "text": "Todos los dragones se preparaban para el concurso anual de llamaradas, excepto Dante.",
              "illustration": "dragon_triste",
              "imageUrl": ""
            }
          ]
        },
        {
          "id": "libro-ninos-3",
          "title": "Las Botas Saltarinas de Mateo",
          "author": "Sonia Sonrisas",
          "category": "DiversiÃ³n",
          "audience": "Ninos",
          "description": "Mateo encuentra unas botas amarillas en su jardÃ­n que lo hacen saltar tan alto como las nubes.",
          "sourceName": "API de libros",
          "sourceUrl": "",
          "accentColor": "#FFFFC8",
          "estimatedMinutes": 4,
          "hasImmersiveImages": false,
          "pages": [
            {
              "pageNumber": 1,
              "title": "El Descubrimiento",
              "text": "Escondidas detrÃ¡s del arbusto de rosas, las botas brillaban intensamente bajo el sol.",
              "illustration": "botas_amarillas",
              "imageUrl": ""
            }
          ]
        },
        {
          "id": "libro-adultos-1",
          "title": "El Susurro de la Niebla",
          "author": "Carlos Somoza",
          "category": "Suspenso",
          "audience": "Adultos",
          "description": "Un inspector retirado viaja a un pequeÃ±o pueblo costero solo para descubrir que nadie recuerda el aÃ±o en que Ã©l naciÃ³.",
          "sourceName": "API de libros",
          "sourceUrl": "",
          "accentColor": "#1B263B",
          "estimatedMinutes": 15,
          "hasImmersiveImages": false,
          "pages": [
            {
              "pageNumber": 1,
              "title": "CapÃ­tulo I: El Faro Olvidado",
              "text": "El tren se detuvo con un quejido metÃ¡lico. La niebla lo borraba todo, devorando los contornos de la vieja estaciÃ³n ferroviaria.",
              "illustration": "",
              "imageUrl": ""
            }
          ]
        },
        {
          "id": "libro-adultos-2",
          "title": "Ecos del MaÃ±ana",
          "author": "V. K. Gibson",
          "category": "Ciencia FicciÃ³n",
          "audience": "General",
          "description": "En una sociedad donde los recuerdos se pueden almacenar en discos duros, un programador encuentra un archivo encriptado con su propia voz.",
          "sourceName": "API de libros",
          "sourceUrl": "",
          "accentColor": "#637A8B",
          "estimatedMinutes": 12,
          "hasImmersiveImages": false,
          "pages": [
            {
              "pageNumber": 1,
              "title": "Bloque de Memoria 0x7F",
              "text": "Las lÃ­neas de cÃ³digo parpadeaban en el monitor hologrÃ¡fico. No era una intrusiÃ³n externa; el algoritmo llevaba mi firma digital.",
              "illustration": "",
              "imageUrl": ""
            }
          ]
        },
        {
          "id": "libro-adultos-3",
          "title": "Cartas desde el Olvido",
          "author": "Mariana DÃ¡vila",
          "category": "Romance",
          "audience": "Adultos",
          "description": "Una recopilaciÃ³n de correspondencia encontrada en un baÃºl antiguo que narra un amor clandestino durante la Ã©poca de la posguerra.",
          "sourceName": "API de libros",
          "sourceUrl": "",
          "accentColor": "#76608A",
          "estimatedMinutes": 10,
          "hasImmersiveImages": false,
          "pages": [
            {
              "pageNumber": 1,
              "title": "Octubre, 1946",
              "text": "Querida mÃ­a, te escribo estas lÃ­neas con la certeza de que el tiempo sabrÃ¡ perdonar nuestra impaciencia...",
              "illustration": "",
              "imageUrl": ""
            }
          ]
        }
      ];

      // Respondemos envolviÃ©ndolo exactamente en la propiedad "books" que Flutter espera
      res.json({ books: mockBooks });
    } catch (error) {
      console.error('Error en el endpoint de libros:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
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

app.post(
  '/api/seed/infantil-books',
  optionalAuth,
  asyncHandler(async (_req, res) => {
    const result = await seedInfantilBooks();
    res.status(201).json(result);
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
    'coverUrl',
    'pdfUrl',
    'active',
    'featured',
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

async function seedInfantilBooks() {
  const books = infantilSeedBooks();
  const created = [];
  const updated = [];

  await deleteLegacyBookDocuments();

  for (const book of books) {
    const ref = db.collection('books').doc(book.id);
    const snapshot = await ref.get();
    await ref.set(
      {
        ...book,
        createdAt: snapshot.exists
          ? snapshot.data().createdAt || admin.firestore.FieldValue.serverTimestamp()
          : admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      },
      { merge: true }
    );
    (snapshot.exists ? updated : created).push(book.id);
  }

  return {
    ok: true,
    collection: 'books',
    category: 'Infantil',
    created,
    updated,
    total: books.length
  };
}

async function deleteLegacyBookDocuments() {
  const legacyIds = ['7', 'el-principito', 'caperucita-roja', 'antologia-2012'];
  await Promise.all(
    legacyIds.map(id => db.collection('books').doc(id).delete().catch(() => null))
  );
}

function infantilSeedBooks() {
  return [
    {
      id: 'el_principito',
      title: 'El Principito',
      author: 'Antoine de Saint-Exupery',
      description:
        'Un clÃ¡sico de imaginaciÃ³n, amistad y aprendizaje para lectores de todas las edades.',
      featured: true
    },
    {
      id: 'heidi',
      title: 'Heidi',
      author: 'Johanna Spyri',
      description:
        'La historia de una niÃ±a que descubre la belleza de la montaÃ±a, la amistad y la familia.',
      featured: true
    },
    {
      id: 'caperucita_roja',
      title: 'Caperucita Roja',
      author: 'Charles Perrault',
      description:
        'Un cuento tradicional sobre atenciÃ³n, valentÃ­a y aventura en el bosque.',
      featured: false
    },
    {
      id: 'antologia_2012',
      title: 'AntologÃ­a 2012',
      author: 'Mini Read',
      description:
        'SelecciÃ³n de lecturas infantiles para descubrir cuentos, valores y creatividad.',
      featured: false
    }
  ].map(book => ({
    ...book,
    category: 'Infantil',
    audience: 'kids',
    active: true,
    coverUrl: coverUrlFor(book.id),
    pdfUrl: pdfUrlFor(book.id),
    sourceName: 'Firebase Storage',
    sourceUrl: pdfUrlFor(book.id),
    accentColor: 0xFFD4AF37,
    estimatedMinutes: 12,
    hasImmersiveImages: false,
    pages: []
  }));
}

function pdfUrlFor(id) {
  const envKey = `PDF_${id.toUpperCase().replace(/-/g, '_')}_URL`;
  if (process.env[envKey]) return process.env[envKey];
  const bucket = process.env.FIREBASE_STORAGE_BUCKET || 'readlevelproject-6e5d3.firebasestorage.app';
  const fileNameById = {
    el_principito: 'El principito.pdf',
    heidi: 'Heidi.pdf',
    caperucita_roja: 'Caperucita Roja.pdf',
    antologia_2012: 'Antologia-2012.pdf'
  };
  const objectPath = encodeURIComponent(`books/infantil/${fileNameById[id] || `${id}.pdf`}`);
  return `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${objectPath}?alt=media`;
}

function coverUrlFor(id) {
  const envKey = `COVER_${id.toUpperCase().replace(/-/g, '_')}_URL`;
  if (process.env[envKey]) return process.env[envKey];
  const cloudName = process.env.CLOUDINARY_CLOUD_NAME || 'deussxkkg';
  return `https://res.cloudinary.com/${cloudName}/image/upload/mini_read/covers/${id}.jpg`;
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
    'favoriteGenres',
    'isKids',
    'pinEnabled',
    'pinCode',
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

async function deleteDocumentsForUser(collectionName, uid) {
  const refs = new Map();
  for (const field of ['uid', 'userId']) {
    const snapshot = await db.collection(collectionName).where(field, '==', uid).get();
    for (const doc of snapshot.docs) refs.set(doc.ref.path, doc.ref);
  }
  await deleteReferences([...refs.values()]);
}

async function deleteDocumentsForProfiles(collectionName, profileIds) {
  for (let index = 0; index < profileIds.length; index += 10) {
    const chunk = profileIds.slice(index, index + 10);
    if (chunk.length === 0) continue;
    const snapshot = await db.collection(collectionName).where('profileId', 'in', chunk).get();
    await deleteReferences(snapshot.docs.map((doc) => doc.ref));
  }
}

async function deleteReferences(references) {
  for (const ref of references) await db.recursiveDelete(ref);
}

async function deleteCloudinaryAccountAssets(uid, profileIds) {
  const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
  const apiKey = process.env.CLOUDINARY_API_KEY;
  const apiSecret = process.env.CLOUDINARY_API_SECRET;
  if (!cloudName || !apiKey || !apiSecret) return;

  const prefixes = [
    `mini_read/avatars/users/${uid}`,
    ...profileIds.map((profileId) => `mini_read/avatars/profiles/${profileId}`)
  ];
  const authorization = Buffer.from(`${apiKey}:${apiSecret}`).toString('base64');
  for (const prefix of prefixes) {
    const url = new URL(`https://api.cloudinary.com/v1_1/${cloudName}/resources/image/upload`);
    url.searchParams.set('prefix', prefix);
    await fetch(url, {
      method: 'DELETE',
      headers: { Authorization: `Basic ${authorization}` }
    });
  }
}

module.exports = app;

