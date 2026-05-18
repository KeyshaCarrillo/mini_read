// backend/src/utils.js
const { admin } = require('./firebase');

const allowedAdminCollections = new Set([
  'books',
  'users',
  'history_reading',
  'ia_chats',
  'token_transactions'
]);

function asyncHandler(handler) {
  return (req, res, next) => {
    Promise.resolve(handler(req, res, next)).catch(next);
  };
}

function serializeFirestore(value) {
  if (value == null) return value;
  if (value instanceof admin.firestore.Timestamp) {
    return value.toDate().toISOString();
  }
  if (Array.isArray(value)) {
    return value.map(serializeFirestore);
  }
  if (typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value).map(([key, entry]) => [
        key,
        serializeFirestore(entry)
      ])
    );
  }
  return value;
}

function docToJson(snapshot) {
  if (!snapshot.exists) return null;
  return {
    id: snapshot.id,
    ...serializeFirestore(snapshot.data())
  };
}

function collectionToJson(snapshot) {
  return snapshot.docs.map(docToJson);
}

function pick(source, allowedFields) {
  return Object.fromEntries(
    Object.entries(source || {}).filter(([key]) => allowedFields.includes(key))
  );
}

function requireAllowedCollection(name) {
  if (!allowedAdminCollections.has(name)) {
    const error = new Error(`Coleccion no permitida: ${name}`);
    error.statusCode = 400;
    throw error;
  }
}

function getProfileRef(db, uid, profileId) {
  return db.collection('users').doc(uid).collection('perfiles').doc(profileId);
}

function dateOnly(date = new Date()) {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

function sameDay(a, b) {
  return (
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate()
  );
}

module.exports = {
  asyncHandler,
  collectionToJson,
  dateOnly,
  docToJson,
  getProfileRef,
  pick,
  requireAllowedCollection,
  sameDay,
  serializeFirestore
};
