-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Optimize PostgreSQL for n8n
ALTER SYSTEM SET max_connections = '200';
ALTER SYSTEM SET shared_buffers = '1GB';
ALTER SYSTEM SET effective_cache_size = '3GB';
ALTER SYSTEM SET maintenance_work_mem = '256MB';
ALTER SYSTEM SET checkpoint_completion_target = '0.9';
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = '100';
ALTER SYSTEM SET random_page_cost = '1.1';
ALTER SYSTEM SET effective_io_concurrency = '200';
ALTER SYSTEM SET work_mem = '5242kB';
ALTER SYSTEM SET min_wal_size = '1GB';
ALTER SYSTEM SET max_wal_size = '4GB';
ALTER SYSTEM SET max_worker_processes = '8';
ALTER SYSTEM SET max_parallel_workers_per_gather = '4';
ALTER SYSTEM SET max_parallel_workers = '8';
ALTER SYSTEM SET max_parallel_maintenance_workers = '4';

-- Create a read-only user for monitoring
CREATE USER n8n_monitor WITH PASSWORD 'monitor_password';
GRANT CONNECT ON DATABASE n8n TO n8n_monitor;
GRANT USAGE ON SCHEMA public TO n8n_monitor;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO n8n_monitor;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO n8n_monitor;
