-- Clean migration: timeouts set, safe index creation
SET lock_timeout = '3s';
SET statement_timeout = '30s';
CREATE INDEX CONCURRENTLY idx_products_sku ON products(sku);
