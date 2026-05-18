// backend/api/index.js
// 1. Cargamos las variables locales de inmediato si estamos en desarrollo
if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config({ path: '.env.local' });
}

// 2. Cargamos la aplicación (que a su vez inicializará Firebase)
const app = require('../src/app');

module.exports = app;

// 3. Levantar el servidor localmente
if (require.main === module) {
  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`Mini Read API listening on http://localhost:${port}`);
    console.log(`🔑 Firebase cargado con el proyecto: ${process.env.FIREBASE_PROJECT_ID}`);
  });
}