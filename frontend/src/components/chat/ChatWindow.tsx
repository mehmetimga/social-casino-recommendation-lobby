import { useRef, useEffect } from 'react';
import { Bot, Sparkles } from 'lucide-react';
import { useChat } from '../../context/ChatContext';
import MessageBubble from './MessageBubble';
import ChatInput from './ChatInput';

export default function ChatWindow() {
  const { messages, isLoading } = useChat();
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom on new messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  return (
    <div className="fixed bottom-24 right-6 z-50 w-96 h-[500px] bg-casino-bg-secondary rounded-2xl shadow-2xl border border-white/10 flex flex-col overflow-hidden">
      {/* Header */}
      <div className="flex items-center gap-3 p-4 border-b border-white/10 bg-gradient-to-r from-casino-purple/20 to-transparent">
        <div className="w-10 h-10 rounded-full bg-casino-purple flex items-center justify-center">
          <Bot className="w-5 h-5 text-white" />
        </div>
        <div>
          <h3 className="text-white font-semibold">Casino Assistant</h3>
          <p className="text-xs text-gray-400 flex items-center gap-1">
            <Sparkles className="w-3 h-3" />
            Powered by AI
          </p>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.length === 0 ? (
          <div className="h-full flex flex-col items-center justify-center text-center">
            <div className="w-16 h-16 rounded-full bg-casino-purple/20 flex items-center justify-center mb-4">
              <Bot className="w-8 h-8 text-casino-purple" />
            </div>
            <h4 className="text-white font-medium mb-2">How can I help you?</h4>
            <p className="text-gray-400 text-sm max-w-[250px]">
              Ask me about games, promotions, rules, or anything else about our casino!
            </p>
            {/* Suggested Questions */}
            <div className="mt-4 space-y-2 w-full">
              {[
                'What are the best slot games?',
                'How do I claim bonuses?',
                'What is RTP?',
              ].map((question) => (
                <SuggestedQuestion key={question} question={question} />
              ))}
            </div>
          </div>
        ) : (
          <>
            {messages.map((message) => (
              <MessageBubble key={message.id} message={message} />
            ))}
            {isLoading && (
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-full bg-casino-purple flex items-center justify-center flex-shrink-0">
                  <Bot className="w-4 h-4 text-white" />
                </div>
                <div className="bg-white/5 rounded-2xl rounded-tl-none px-4 py-3">
                  <div className="flex gap-1">
                    <div className="w-2 h-2 rounded-full bg-gray-400 animate-bounce" style={{ animationDelay: '0ms' }} />
                    <div className="w-2 h-2 rounded-full bg-gray-400 animate-bounce" style={{ animationDelay: '150ms' }} />
                    <div className="w-2 h-2 rounded-full bg-gray-400 animate-bounce" style={{ animationDelay: '300ms' }} />
                  </div>
                </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </>
        )}
      </div>

      {/* Input */}
      <ChatInput />
    </div>
  );
}

function SuggestedQuestion({ question }: { question: string }) {
  const { sendMessage } = useChat();

  return (
    <button
      onClick={() => sendMessage(question)}
      className="w-full text-left px-4 py-2 bg-white/5 hover:bg-white/10 rounded-lg text-sm text-gray-300 transition-colors"
    >
      {question}
    </button>
  );
}
