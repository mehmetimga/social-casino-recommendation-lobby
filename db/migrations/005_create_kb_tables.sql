-- Knowledge base sources
CREATE TABLE IF NOT EXISTS kb_sources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    source_type VARCHAR(50) NOT NULL CHECK (source_type IN ('file', 'confluence', 'url')),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Knowledge base documents
CREATE TABLE IF NOT EXISTS kb_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id UUID REFERENCES kb_sources(id) ON DELETE CASCADE,
    title VARCHAR(500),
    content_hash VARCHAR(64) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_kb_documents_source_id ON kb_documents(source_id);

-- Knowledge base chunks
CREATE TABLE IF NOT EXISTS kb_chunks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES kb_documents(id) ON DELETE CASCADE,
    chunk_index INTEGER NOT NULL,
    content TEXT NOT NULL,
    token_count INTEGER,
    vector_id VARCHAR(255),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_kb_chunks_document_id ON kb_chunks(document_id);
CREATE INDEX idx_kb_chunks_vector_id ON kb_chunks(vector_id);

-- Knowledge base ingestion jobs
CREATE TABLE IF NOT EXISTS kb_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id UUID REFERENCES kb_sources(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    progress INTEGER DEFAULT 0,
    error_message TEXT,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_kb_jobs_source_id ON kb_jobs(source_id);
CREATE INDEX idx_kb_jobs_status ON kb_jobs(status);
