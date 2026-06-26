-- Triggers P2 (CRITICAL): CREATE INDEX without CONCURRENTLY
-- Triggers P9 (WARN): no lock_timeout or statement_timeout
CREATE INDEX idx_orders_user_id ON orders(user_id);
