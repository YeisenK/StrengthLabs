import { expect } from 'chai';
import axios from 'axios';
import { API_URL } from '../helpers/driver.js';

const client = axios.create({
  baseURL: API_URL,
  validateStatus: () => true,
});

const SEED_USER = {
  email: `workouts_${Date.now()}@strengthlabs.test`,
  password: 'test1234',
};

async function getToken() {
  await client.post('/auth/register', SEED_USER);
  const res = await client.post('/auth/login', SEED_USER);
  return res.data?.access_token;
}

function authHeader(token) {
  return { headers: { Authorization: `Bearer ${token}` } };
}

describe('API — /workouts', function () {
  let token;
  let createdId;

  before(async function () {
    token = await getToken();
    if (!token) this.skip();
  });

  describe('GET /workouts', function () {
    it('returns 200 with an array', async function () {
      const res = await client.get('/workouts', authHeader(token));
      expect(res.status).to.equal(200);
      expect(res.data).to.satisfy(
        (d) => Array.isArray(d) || Array.isArray(d?.items),
        'Expected an array or paginated object'
      );
    });

    it('returns 401 without token', async function () {
      const res = await client.get('/workouts');
      expect(res.status).to.equal(401);
    });
  });

  describe('POST /workouts', function () {
    it('creates a workout and returns 201 with an id', async function () {
      const payload = { name: 'Morning session', notes: 'Mocha test run' };
      const res = await client.post('/workouts', payload, authHeader(token));
      expect(res.status).to.equal(201);
      expect(res.data).to.have.property('id');
      createdId = res.data.id;
    });

    it('returns 401 without token', async function () {
      const res = await client.post('/workouts', { name: 'Ghost session' });
      expect(res.status).to.equal(401);
    });
  });

  describe('GET /workouts/:id', function () {
    it('returns 200 with workout detail for a valid id', async function () {
      if (!createdId) this.skip();
      const res = await client.get(`/workouts/${createdId}`, authHeader(token));
      expect(res.status).to.equal(200);
      expect(res.data).to.have.property('id', createdId);
    });

    it('returns 404 for a non-existent workout', async function () {
      const res = await client.get('/workouts/000000', authHeader(token));
      expect(res.status).to.equal(404);
    });
  });

  describe('DELETE /workouts/:id', function () {
    it('deletes the workout and returns 200 or 204', async function () {
      if (!createdId) this.skip();
      const res = await client.delete(`/workouts/${createdId}`, authHeader(token));
      expect(res.status).to.be.oneOf([200, 204]);
    });

    it('returns 404 when deleting an already-deleted workout', async function () {
      if (!createdId) this.skip();
      const res = await client.delete(`/workouts/${createdId}`, authHeader(token));
      expect(res.status).to.equal(404);
    });
  });
});
