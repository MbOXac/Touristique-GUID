const admin = require('firebase-admin');

function extractTokenFromHeader(authHeader) {
  if (!authHeader) return null;
  if (!authHeader.startsWith('Bearer ')) return null;
  return authHeader.substring(7);
}

async function verifyIdToken(token) {
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    return {
      uid: decodedToken.uid,
      email: decodedToken.email || null,
      customClaims: decodedToken.custom_claims || null,
    };
  } catch (error) {
    throw new Error(`Token verification failed: ${error.message}`);
  }
}

module.exports = {
  extractTokenFromHeader,
  verifyIdToken,
};
