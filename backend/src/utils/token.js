const crypto = require('crypto');
const config = require('../config');

function b64url(input) {
  return Buffer.from(input).toString('base64url');
}

function signToken(payload, expiresInSeconds = 60 * 60 * 24 * 7) {
  const header = { alg: 'HS256', typ: 'JWT' };
  const now = Math.floor(Date.now() / 1000);
  const fullPayload = { ...payload, iat: now, exp: now + expiresInSeconds };
  const unsigned = `${b64url(JSON.stringify(header))}.${b64url(JSON.stringify(fullPayload))}`;
  const signature = crypto.createHmac('sha256', config.authSecret).update(unsigned).digest('base64url');
  return `${unsigned}.${signature}`;
}

function verifyToken(token) {
  if (!token || typeof token !== 'string') throw new Error('Token tidak ada.');
  const parts = token.split('.');
  if (parts.length !== 3) throw new Error('Format token tidak valid.');
  const [header, payload, signature] = parts;
  const unsigned = `${header}.${payload}`;
  const expected = crypto.createHmac('sha256', config.authSecret).update(unsigned).digest('base64url');
  if (!crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected))) {
    throw new Error('Token tidak valid.');
  }
  const decoded = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8'));
  if (decoded.exp && decoded.exp < Math.floor(Date.now() / 1000)) throw new Error('Token kedaluwarsa.');
  return decoded;
}

module.exports = { signToken, verifyToken };
