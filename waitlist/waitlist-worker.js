/* 画面録 待ち登録 Worker — Cloudflare Workers + D1
 * 役割：Web版の「自動版を待つ」フォームの POST 受け口。
 *   いまは未デプロイ（既定は index.html の mailto）。需要が出たらこれを deploy して
 *   index.html の ENDPOINT に publicなWorker URLを入れる（=1行）だけで切替わる。
 *
 * デプロイ：wrangler.toml を見て `wrangler d1 create gamenroku_waitlist` →
 *   schema.sql を流し込み → `wrangler deploy`。手順は README.md。
 *
 * 設計：ゼロコスト枠内（D1 無料枠/Workers 無料枠）。個人情報は email のみ・端末データは一切受けない。
 */

const ALLOW_ORIGINS = [
  'https://osakenpiro.github.io', // GitHub Pages 本番
  'http://localhost:8000',         // ローカル検証
];
const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

function cors(origin) {
  const allow = ALLOW_ORIGINS.includes(origin) ? origin : ALLOW_ORIGINS[0];
  return {
    'Access-Control-Allow-Origin': allow,
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Max-Age': '86400',
  };
}
const json = (obj, status, origin) =>
  new Response(JSON.stringify(obj), {
    status,
    headers: { 'Content-Type': 'application/json', ...cors(origin) },
  });

export default {
  async fetch(request, env) {
    const origin = request.headers.get('Origin') || '';

    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors(origin) });
    if (request.method !== 'POST') return json({ ok: false, error: 'method' }, 405, origin);

    let body;
    try { body = await request.json(); } catch { return json({ ok: false, error: 'json' }, 400, origin); }

    const email = String(body.email || '').trim().toLowerCase();
    const tool = String(body.tool || 'gamenroku').slice(0, 40);
    if (!EMAIL_RE.test(email) || email.length > 254) return json({ ok: false, error: 'email' }, 400, origin);

    const ua = (request.headers.get('User-Agent') || '').slice(0, 200);
    try {
      // INSERT OR IGNORE で重複登録は静かに無視（UNIQUE(email,tool)）。
      await env.DB
        .prepare('INSERT OR IGNORE INTO waitlist (email, tool, ts, ua) VALUES (?, ?, ?, ?)')
        .bind(email, tool, Date.now(), ua)
        .run();
      return json({ ok: true }, 200, origin);
    } catch (e) {
      return json({ ok: false, error: 'db' }, 500, origin);
    }
  },
};
