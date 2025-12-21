import { apiClient } from './client';
import { ChatSession, ChatResponse } from '../types/chat';

interface CreateSessionInput {
  userId?: string;
  context?: {
    currentPage?: string;
    currentGame?: string;
  };
}

interface SendMessageInput {
  content: string;
}

export const chatApi = {
  async createSession(input: CreateSessionInput = {}): Promise<ChatSession> {
    return apiClient.chat.post<ChatSession>('/v1/chat/sessions', input);
  },

  async sendMessage(sessionId: string, input: SendMessageInput): Promise<ChatResponse> {
    return apiClient.chat.post<ChatResponse>(`/v1/chat/sessions/${sessionId}/messages`, input);
  },
};
