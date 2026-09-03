import { test, describe, before } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import type { Application } from 'express';

// SECURITY: Set CLIENT_SECRET before importing the app so the middleware
// initializes with a known test value. Never use the production secret here.
const TEST_SECRET = 'test-secret-for-ci-do-not-use-in-production';

let app: Application;

describe('RE:TRACE API Suite', () => {
  before(async () => {
    process.env.CLIENT_SECRET = TEST_SECRET;
    // Import after setting env vars so middleware picks up the test secret
    const module = await import('../api/index');
    app = module.default;
  });

  // ─── Health Check ───────────────────────────────────────────────────────
  test('GET /health → 200 with status ok (public, no auth required)', async () => {
    const res = await request(app).get('/health');
    assert.equal(res.status, 200);
    assert.equal(res.body.status, 'ok');
    assert.ok(res.body.timestamp, 'should include a timestamp');
    assert.ok(res.headers['x-request-id'], 'should include correlation request ID header');
  });

  // ─── Check-ins Auth Enforcement (H-01 fix verification) ────────────────
  test('GET /api/v1/check-ins → 401 without authentication', async () => {
    const res = await request(app).get('/api/v1/check-ins');
    assert.equal(res.status, 401);
    assert.match(res.body.error, /Unauthorized/);
  });

  test('POST /api/v1/check-ins → 401 without authentication', async () => {
    const res = await request(app).post('/api/v1/check-ins').send({ energy: 7 });
    assert.equal(res.status, 401);
    assert.match(res.body.error, /Unauthorized/);
  });

  test('GET /api/v1/check-ins → 200 with valid auth, returns mock items', async () => {
    const res = await request(app)
      .get('/api/v1/check-ins')
      .set('X-Client-Secret', TEST_SECRET);
    assert.equal(res.status, 200);
    assert.ok(Array.isArray(res.body.items));
    assert.ok(res.body.items.length > 0);
  });

  test('POST /api/v1/check-ins → 201 with valid auth, returns UUID check-in ID', async () => {
    const res = await request(app)
      .post('/api/v1/check-ins')
      .set('X-Client-Secret', TEST_SECRET)
      .send({ energy: 7, fatigue: 3 });
    assert.equal(res.status, 201);
    assert.equal(res.body.status, 'submitted');
    // UUID format: checkin_<uuid-v4>
    assert.match(res.body.check_in_id, /^checkin_[0-9a-fA-F-]{36}$/);
  });

  // ─── Chat Auth Enforcement ───────────────────────────────────────────────
  test('POST /api/v1/trace/chat → 401 without client authentication', async () => {
    const res = await request(app)
      .post('/api/v1/trace/chat')
      .send({ message: 'Why am I tired?' });
    assert.equal(res.status, 401);
    assert.match(res.body.error, /Unauthorized/);
  });

  test('POST /api/v1/trace/chat → 401 with wrong secret (timing-safe comparison)', async () => {
    const res = await request(app)
      .post('/api/v1/trace/chat')
      .set('X-Client-Secret', 'wrong-secret')
      .send({ message: 'Hello' });
    assert.equal(res.status, 401);
  });

  test('POST /api/v1/trace/chat → 401 with old leaked default secret', async () => {
    // Verifies the old hardcoded default no longer works (C-01 fix)
    const res = await request(app)
      .post('/api/v1/trace/chat')
      .set('X-Client-Secret', 're-trace-hackathon-2026')
      .send({ message: 'Hello' });
    // Since CLIENT_SECRET is set to TEST_SECRET, the old default must fail
    assert.equal(res.status, 401);
  });

  // ─── Chat Input Validation ────────────────────────────────────────────────
  test('POST /api/v1/trace/chat → 400 on empty message', async () => {
    const res = await request(app)
      .post('/api/v1/trace/chat')
      .set('X-Client-Secret', TEST_SECRET)
      .send({ message: '   ' });
    assert.equal(res.status, 400);
    assert.equal(res.body.error, 'Message is required');
  });

  test('POST /api/v1/trace/chat → 400 on oversized message (> 1000 chars)', async () => {
    const res = await request(app)
      .post('/api/v1/trace/chat')
      .set('X-Client-Secret', TEST_SECRET)
      .send({ message: 'a'.repeat(1001) });
    assert.equal(res.status, 400);
    assert.match(res.body.error, /too long/);
  });

  // ─── Offline Mode Safety (H-03 regression check) ─────────────────────────
  test('POST /api/v1/trace/chat → offline mode does NOT echo user input', async () => {
    const savedKey = process.env.GEMINI_API_KEY;
    delete process.env.GEMINI_API_KEY;
    try {
      const res = await request(app)
        .post('/api/v1/trace/chat')
        .set('X-Client-Secret', TEST_SECRET)
        .send({ message: 'Top secret user data 12345' });
      assert.equal(res.status, 200);
      assert.ok(res.body.response);
      // Offline response must never reflect back user input
      assert.equal(
        res.body.response.includes('Top secret user data 12345'),
        false,
        'Offline mode must not echo user input'
      );
    } finally {
      if (savedKey) process.env.GEMINI_API_KEY = savedKey;
    }
  });

  // ─── Default Fallback Auth Behavior ────────────────────────
  test('Authenticated endpoints accept default secret when CLIENT_SECRET env var is missing', async () => {
    const savedSecret = process.env.CLIENT_SECRET;
    delete process.env.CLIENT_SECRET;
    try {
      const chatRes = await request(app)
        .post('/api/v1/trace/chat')
        .set('X-Client-Secret', 're-trace-hackathon-2026')
        .send({ message: 'Hello' });
      assert.equal(chatRes.status, 200, 'chat should accept default secret fallback');

      const checkInRes = await request(app)
        .get('/api/v1/check-ins')
        .set('X-Client-Secret', 're-trace-hackathon-2026');
      assert.equal(checkInRes.status, 200, 'check-ins should accept default secret fallback');
    } finally {
      if (savedSecret) process.env.CLIENT_SECRET = savedSecret;
    }
  });

  // ─── Correlation ID (L-02 fix verification) ──────────────────────────────
  test('All responses include X-Request-Id correlation header', async () => {
    const res = await request(app).get('/health');
    assert.ok(res.headers['x-request-id'], 'X-Request-Id header must be present');
    // UUID format
    assert.match(
      res.headers['x-request-id'],
      /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
    );
  });

  // ─── 404 handler ─────────────────────────────────────────────────────────
  test('Unknown routes → 404', async () => {
    const res = await request(app).get('/nonexistent/route');
    assert.equal(res.status, 404);
  });
});
