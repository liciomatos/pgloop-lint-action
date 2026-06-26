-- Triggers P9 (WARN only): no lock_timeout or statement_timeout
-- Safe: uses CONCURRENTLY, so no CRITICAL issues
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
