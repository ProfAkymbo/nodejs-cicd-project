const request = require('supertest');
const app = require('../app');

describe('API Tests', () => {

  test('GET / should return 200 and message', async () => {
    const res = await request(app).get('/');

    expect(res.statusCode).toBe(200);
    expect(res.text).toContain('CI/CD Pipeline');
  });

  test('GET /api/health should return status ok', async () => {
    const res = await request(app).get('/api/health');

    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });

});