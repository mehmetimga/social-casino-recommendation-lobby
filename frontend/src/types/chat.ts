export interface ChatSession {
  id: string;
  userId?: string;
  context?: {
    currentPage?: string;
    currentGame?: string;
  };
  createdAt: string;
  updatedAt: string;
}

export interface Citation {
  documentId: string;
  source: string;
  excerpt: string;
}

export interface ChatMessage {
  id: string;
  sessionId: string;
  role: 'user' | 'assistant';
  content: string;
  citations?: Citation[];
  createdAt: string;
}

export interface ChatResponse {
  messageId: string;
  content: string;
  citations?: Citation[];
}
