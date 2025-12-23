import { createContext, useContext, useState, ReactNode, useCallback } from 'react';
import { chatApi } from '../api/chat';
import { ChatMessage, ChatSession, VipLevel } from '../types/chat';
import { useUser } from './UserContext';

interface ChatContextType {
  currentPage?: string;
  currentGame?: string;
  vipLevel?: VipLevel;
}

interface ChatContextValue {
  session: ChatSession | null;
  messages: ChatMessage[];
  isLoading: boolean;
  isOpen: boolean;
  isMaximized: boolean;
  context: ChatContextType;
  openChat: () => void;
  closeChat: () => void;
  toggleChat: () => void;
  toggleMaximize: () => void;
  sendMessage: (content: string) => Promise<void>;
  setContext: (context: ChatContextType) => void;
  openWithGame: (gameSlug: string, gameTitle: string) => void;
}

const ChatContext = createContext<ChatContextValue | null>(null);

export function ChatProvider({ children }: { children: ReactNode }) {
  const { userId, vipLevel } = useUser();
  const [session, setSession] = useState<ChatSession | null>(null);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [isMaximized, setIsMaximized] = useState(false);
  const [chatContext, setChatContext] = useState<ChatContextType>({});

  const createSession = useCallback(async (contextOverride?: ChatContextType) => {
    try {
      const contextToUse = {
        ...(contextOverride ?? chatContext),
        vipLevel, // Always include user's VIP level
      };
      const newSession = await chatApi.createSession({
        userId: userId || undefined,
        context: contextToUse,
      });
      setSession(newSession);
      return newSession;
    } catch (error) {
      console.error('Failed to create chat session:', error);
      return null;
    }
  }, [userId, chatContext, vipLevel]);

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

  const toggleMaximize = useCallback(() => {
    setIsMaximized((prev) => !prev);
  }, []);

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

  const setContext = useCallback((context: ChatContextType) => {
    setChatContext(context);
  }, []);

  // Open chat with a specific game context - updates context without clearing history
  const openWithGame = useCallback(async (gameSlug: string, gameTitle: string) => {
    const newContext: ChatContextType = {
      currentPage: 'game',
      currentGame: gameTitle,
      vipLevel, // Include user's VIP level
    };

    // Update local context state
    setChatContext(newContext);

    // If session exists, update the context on the server
    if (session) {
      try {
        await chatApi.updateContext(session.id, { context: newContext });
      } catch (error) {
        console.error('Failed to update chat context:', error);
      }
    }

    setIsOpen(true);
  }, [session, vipLevel]);

  return (
    <ChatContext.Provider
      value={{
        session,
        messages,
        isLoading,
        isOpen,
        isMaximized,
        context: chatContext,
        openChat,
        closeChat,
        toggleChat,
        toggleMaximize,
        sendMessage,
        setContext,
        openWithGame,
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
