-- Enable pgvector extension for high-performance vector similarity search
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Log extension initialization
DO $$
BEGIN
    RAISE NOTICE 'pgvector and uuid-ossp extensions initialized successfully for SchemeMate AI';
END $$;

