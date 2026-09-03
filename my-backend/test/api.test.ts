import { test, describe } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import app from '../api/index';

describe('RE:TRACE API Suite', () => {
  test('GET /health returns 200 and status ok', async () => {
    const res = await request(app).get('/health');
    assert.equal(res.status, 200);
    assert.equal(res.body.status, 'ok');
    assert.ok(res.body.timestamp);
  });

  test('GET /api/v1/check-ins returns mock items list', async () => {
    const res = await request(app).get('/api/v1/check-ins');
    assert.equal(res.status, 200);
    assert.ok(Array.isArray(res.body.items));
    assert.ok(res.body.items.length > 0);
  });

  test('POST /api/v1/check-ins creates check-in with secure UUID', async () => {
    const res = await request(app)
      .post('/api/v1/check-ins')
      .send({ energy: 7, fatigue: 3 });
    assert.equal(res.status, 201);
    assert.equal(res.body.status, 'submitted');
    assert.match(res.body.check_in_id, /^checkin_[0-9a-fA-F-]{36}$/);
  });

  test('POST /api/v1/trace/chat rejects requests without client authentication', async () => {
    const res = await request(app)
      .post('/api/v1/trace/chat')
      .send({ message: 'Why am I tired?' });
    assert.equal(res.status, 401);
    assert.match(res.body.error, /Unauthorized/);
  });

  test('POST /api/v1/trace/chat rejects empty message payload', async () => {
    const res = await request(app)
      .post('/api/v1/trace/chat')
      .set('X-Client-Secret', 're-trace-hackathon-2026')
      .send({ message: '   ' });
    assert.equal(res.status, 400);
    assert.equal(res.body.error, 'Message is required');
  });

  test('POST /api/v1/trace/chat rejects oversized messages (> 1000 chars)', async () => {
    const hugeMessage = 'a'.repeat(1001);
    const res = await request(app)
      .post('/api/v1/trace/chat')
      .set('X-Client-Secret', 're-trace-hackathon-2026')
      .send({ message: hugeMessage });
    assert.equal(res.status, 400);
    assert.match(res.body.error, /too long/);
  });

  test('POST /api/v1/trace/chat safely handles offline mode without input reflection', async () => {
    // Delete GEMINI_API_KEY temporarily if set
    const savedKey = process.env.GEMINI_API_KEY;
    delete process.env.GEMINI_API_KEY;

    try {
      const res = await request(app)
        .post('/api/v1/trace/chat')
        .set('X-Client-Secret', 're-trace-hackathon-2026')
        .send({ message: 'Sensitive private info' });

      assert.equal(res.status, 200);
      assert.ok(res.body.response);
      assert.equal(res.body.response.includes('Sensitive private info'), false);
    } finally {
      if (savedKey) process.env.GEMINI_API_KEY = savedKey;
    }
  });
});
