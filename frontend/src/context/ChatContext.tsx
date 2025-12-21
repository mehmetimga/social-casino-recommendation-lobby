import { createContext, useContext, useState, ReactNode, useCallback } from 'react';
import { chatApi } from '../api/chat';
import { ChatMessage, ChatSession } from '../types/chat';
import { useUser } from './UserContext';

interface ChatContextValue {
  session: ChatSession | null;
  messages: ChatMessage[];
  isLoading: boolean;
  isOpen: boolean;
  openChat: () => void;
  closeChat: () => void;
  toggleChat: () => void;
  sendMessage: (content: string) => Promise<void>;
  setContext: (context: { currentPage?: string; currentGame?: string }) => void;
}

const ChatContext = createContext<ChatContextValue | null>(null);

export function ChatProvider({ children }: { children: ReactNode }) {
  const { userId } = useUser();
  const [session, setSession] = useState<ChatSession | null>(null);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [chatContext, setChatContext] = useState<{ currentPage?: string; currentGame?: string }>({});

  const createSession = useCallback(async () => {
    try {
      const newSession = await chatApi.createSession({
        userId: userId || undefined,
        context: chatContext,
      });
      setSession(newSession);
      return newSession;
    } catch (error) {
      console.error('Failed to create chat session:', error);
      return null;
    }
  }, [userId, chatContext]);

  const openChat = useCallback(async () => {
    setIsOpen(true);
    if (!session) {
      await createSession();
    }
  }, [session, createSession]);

  const closeChat = useCallback(() => {
    setIsOpen(false);
  }, []);

  const toggleChat = useCallback(() => {
    if (isOpen) {
      closeChat();
    } else {
      openChat();
    }
  }, [isOpen, openChat, closeChat]);

  const sendMessage = useCallback(async (content: string) => {
    let currentSession = session;

    if (!currentSession) {
      currentSession = await createSession();
      if (!currentSession) {
        throw new Error('Failed to create session');
      }
    }

    // Add user message to UI immediately
    const userMessage: ChatMessage = {
      id: `temp-${Date.now()}`,
      sessionId: currentSession.id,
      role: 'user',
      content,
      createdAt: new Date().toISOString(),
    };
    setMessages((prev) => [...prev, userMessage]);
    setIsLoading(true);

    try {
      const response = await chatApi.sendMessage(currentSession.id, { content });

      // Add assistant response
      const assistantMessage: ChatMessage = {
        id: response.messageId,
        sessionId: currentSession.id,
        role: 'assistant',
        content: response.content,
        citations: response.citations,
        createdAt: new Date().toISOString(),
      };
      setMessages((prev) => [...prev, assistantMessage]);
    } catch (error) {
      console.error('Failed to send message:', error);
      // Add error message
      const errorMessage: ChatMessage = {
        id: `error-${Date.now()}`,
        sessionId: currentSession.id,
        role: 'assistant',
        content: 'Sorry, I encountered an error. Please try again.',
        createdAt: new Date().toISOString(),
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  }, [session, createSession]);

  const setContext = useCallback((context: { currentPage?: string; currentGame?: string }) => {
    setChatContext(context);
  }, []);

  return (
    <ChatContext.Provider
      value={{
        session,
        messages,
        isLoading,
        isOpen,
        openChat,
        closeChat,
        toggleChat,
        sendMessage,
        setContext,
      }}
    >
      {children}
    </ChatContext.Provider>
  );
}

export function useChat() {
  const context = useContext(ChatContext);
  if (!context) {
    throw new Error('useChat must be used within a ChatProvider');
  }
  return context;
}
