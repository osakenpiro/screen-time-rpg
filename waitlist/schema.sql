-- 画面録 待ち登録 D1 スキーマ
CREATE TABLE IF NOT EXISTS waitlist (
  email TEXT NOT NULL,
  tool  TEXT NOT NULL DEFAULT 'gamenroku',
  ts    INTEGER NOT NULL,
  ua    TEXT,
  UNIQUE(email, tool)
);
CREATE INDEX IF NOT EXISTS idx_waitlist_ts ON waitlist (ts);
