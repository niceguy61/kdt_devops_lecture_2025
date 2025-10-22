const request = require('supertest');
const app = require('./index');

describe('API Tests', () => {
  test('GET /api/health returns healthy status', async () => {
    const response = await request(app).get('/api/health');
    expect(response.status).toBe(200);
    expect(response.body.message).toBe('Backend is healthy!');
    expect(response.body.version).toBe('1.0.0');
  });

  test('GET /api/health returns JSON', async () => {
    const response = await request(app).get('/api/health');
    expect(response.headers['content-type']).toMatch(/json/);
  });
});
