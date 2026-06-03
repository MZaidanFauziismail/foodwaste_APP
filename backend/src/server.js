const app = require('./app');
const config = require('./config');
const { pool } = require('./db');

const server = app.listen(config.port, '0.0.0.0', () => {
  console.log(`EcoShare backend running on ${config.publicBaseUrl || `http://localhost:${config.port}`}`);
});

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

async function shutdown() {
  console.log('Shutting down EcoShare backend...');
  server.close(async () => {
    await pool.end();
    process.exit(0);
  });
}
