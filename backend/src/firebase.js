// backend/src/firebase.js
const admin = require('firebase-admin');

function getPrivateKey() {
  const key = process.env.FIREBASE_PRIVATE_KEY;
  return key ? key.replace(/\\n/g, '\n') : undefined;
}

function initializeFirebase() {
  if (admin.apps.length > 0) return admin.app();

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = getPrivateKey();

  if (projectId && clientEmail && privateKey) {
    try {
      return admin.initializeApp({
        credential: admin.credential.cert({
          projectId,
          clientEmail,
          privateKey
        })
      });
    } catch (error) {
      console.error(" Error crítico al certificar credenciales de Firebase:", error.message);
    }
  }

  // Si faltan variables o falla el cert, lanzamos un error claro controlable
  throw new Error(" No se pudieron cargar las credenciales de Firebase en el entorno actual.");
}

// Inicializamos primero de forma segura
initializeFirebase();

// Exportamos los servicios invocándolos de forma segura una vez inicializado admin
module.exports = {
  admin,
  get auth() { return admin.auth(); },
  get db() { return admin.firestore(); }
};