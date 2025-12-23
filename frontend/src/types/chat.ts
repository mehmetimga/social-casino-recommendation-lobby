export type VipLevel = 'bronze' | 'silver' | 'gold' | 'platinum';

export interface SessionContext {
  currentPage?: string;
  currentGame?: string;
  vipLevel?: VipLevel;
}

export interface ChatSession {
  id: string;
  userId?: string;
  context?: SessionContext;
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
