import { expect } from 'chai';
import axios from 'axios';
import { API_URL } from '../helpers/driver.js';

const client = axios.create({
  baseURL: API_URL,
  validateStatus: () => true,
});

const TEST_USER = {
  email: `test_${Date.now()}@strengthlabs.test`,
  password: 'test1234',
};

describe('API — /auth', function () {
  describe('POST /auth/register', function () {
    it('returns 201 with access_token on valid registration', async function () {
      const res = await client.post('/auth/register', TEST_USER);
      expect(res.status).to.equal(201);
      expect(res.data).to.have.property('access_token');
    });

    it('returns 409 when the email is already registered', async function () {
      await client.post('/auth/register', TEST_USER);
      const res = await client.post('/auth/register', TEST_USER);
      expect(res.status).to.equal(409);
    });

    it('returns 422 when the email is missing', async function () {
      const res = await client.post('/auth/register', { password: 'test1234' });
      expect(res.status).to.equal(422);
    });

    it('returns 422 when the password is missing', async function () {
      const res = await client.post('/auth/register', { email: 'x@example.com' });
      expect(res.status).to.equal(422);
    });
  });

  describe('POST /auth/login', function () {
    before(async function () {
      await client.post('/auth/register', TEST_USER);
    });

    it('returns 200 with access_token and refresh_token on valid credentials', async function () {
      const res = await client.post('/auth/login', TEST_USER);
      expect(res.status).to.equal(200);
      expect(res.data).to.have.property('access_token');
      expect(res.data).to.have.property('refresh_token');
    });

    it('returns 401 on wrong password', async function () {
      const res = await client.post('/auth/login', {
        email: TEST_USER.email,
        password: 'wrongpassword',
      });
      expect(res.status).to.equal(401);
    });

    it('returns 401 for a non-existent email', async function () {
      const res = await client.post('/auth/login', {
        email: 'nobody@strengthlabs.test',
        password: 'test1234',
      });
      expect(res.status).to.equal(401);
    });
  });

  describe('GET /auth/me', function () {
    let token;

    before(async function () {
      await client.post('/auth/register', TEST_USER);
      const res = await client.post('/auth/login', TEST_USER);
      token = res.data?.access_token;
      if (!token) this.skip();
    });

    it('returns 200 with the authenticated user profile', async function () {
      const res = await client.get('/auth/me', {
        headers: { Authorization: `Bearer ${token}` },
      });
      expect(res.status).to.equal(200);
      expect(res.data).to.have.property('email', TEST_USER.email);
    });

    it('returns 401 without a token', async function () {
      const res = await client.get('/auth/me');
      expect(res.status).to.equal(401);
    });

    it('returns 401 with a malformed token', async function () {
      const res = await client.get('/auth/me', {
        headers: { Authorization: 'Bearer not.a.valid.token' },
      });
      expect(res.status).to.equal(401);
    });
  });
});
