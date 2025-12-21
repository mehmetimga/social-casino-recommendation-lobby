import { useRef, useEffect, useState } from 'react';
import { Bot, Sparkles, Maximize2, Minimize2 } from 'lucide-react';
import { useChat } from '../../context/ChatContext';
import MessageBubble from './MessageBubble';
import ChatInput from './ChatInput';
import { cn } from '../../utils/cn';

export default function ChatWindow() {
  const { messages, isLoading, isMaximized, toggleMaximize } = useChat();
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const [size, setSize] = useState({ width: 384, height: 500 }); // Default: w-96 = 384px
  const [isResizing, setIsResizing] = useState(false);
  const resizeRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom on new messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // Handle resize functionality
  useEffect(() => {
    if (!resizeRef.current || isMaximized) return;

    const handleMouseMove = (e: MouseEvent) => {
      if (!isResizing) return;

      const newWidth = window.innerWidth - e.clientX - 24; // 24px for right padding
      const newHeight = window.innerHeight - e.clientY - 96; // 96px for bottom button

      setSize({
        width: Math.max(320, Math.min(800, newWidth)),
        height: Math.max(400, Math.min(window.innerHeight - 150, newHeight)),
      });
    };

    const handleMouseUp = () => {
      setIsResizing(false);
    };

    if (isResizing) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
    }

    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };
  }, [isResizing, isMaximized]);

  return (
    <div
      ref={resizeRef}
      className={cn(
        'fixed z-[60] bg-casino-bg-secondary rounded-2xl shadow-2xl border border-white/10 flex flex-col overflow-hidden transition-all',
        isMaximized
          ? 'inset-4 md:inset-8' // Maximized: full screen with padding
          : 'bottom-24 right-6' // Normal: bottom right corner
      )}
      style={
        !isMaximized
          ? {
              width: `${size.width}px`,
              height: `${size.height}px`,
            }
          : undefined
      }
    >
      {/* Resize handle (only visible when not maximized) */}
      {!isMaximized && (
        <div
          className="absolute top-0 left-0 w-4 h-4 cursor-nwse-resize hover:bg-casino-purple/20 rounded-br-lg"
          onMouseDown={() => setIsResizing(true)}
        >
          <div className="absolute top-1 left-1 w-2 h-2 border-l-2 border-t-2 border-white/30" />
        </div>
      )}

      {/* Header */}
      <div className="flex items-center gap-3 p-4 border-b border-white/10 bg-gradient-to-r from-casino-purple/20 to-transparent">
        <div className="w-10 h-10 rounded-full bg-casino-purple flex items-center justify-center">
          <Bot className="w-5 h-5 text-white" />
        </div>
        <div className="flex-1">
          <h3 className="text-white font-semibold">Casino Assistant</h3>
          <p className="text-xs text-gray-400 flex items-center gap-1">
            <Sparkles className="w-3 h-3" />
            Powered by AI
          </p>
        </div>
        {/* Maximize/Minimize button */}
        <button
          onClick={toggleMaximize}
          className="p-2 hover:bg-white/10 rounded-lg transition-colors"
          title={isMaximized ? 'Restore' : 'Maximize'}
        >
          {isMaximized ? (
            <Minimize2 className="w-4 h-4 text-gray-400" />
          ) : (
            <Maximize2 className="w-4 h-4 text-gray-400" />
          )}
        </button>
      </div>

      {/* Messages */}
      <div className={cn('flex-1 overflow-y-auto p-4', isMaximized && 'p-8')}>
        <div className={cn('space-y-4', isMaximized && 'max-w-4xl mx-auto space-y-6')}>
          {messages.length === 0 ? (
            <div className="h-full flex flex-col items-center justify-center text-center">
              <div className={cn(
                'rounded-full bg-casino-purple/20 flex items-center justify-center mb-4',
                isMaximized ? 'w-24 h-24' : 'w-16 h-16'
              )}>
                <Bot className={cn('text-casino-purple', isMaximized ? 'w-12 h-12' : 'w-8 h-8')} />
              </div>
              <h4 className={cn('text-white font-medium mb-2', isMaximized && 'text-2xl')}>
                How can I help you?
              </h4>
              <p className={cn('text-gray-400 text-sm', isMaximized ? 'text-lg max-w-md' : 'max-w-[250px]')}>
                Ask me about games, promotions, rules, or anything else about our casino!
              </p>
              {/* Suggested Questions */}
              <div className={cn('mt-4 space-y-2 w-full', isMaximized && 'max-w-2xl mt-8 space-y-3')}>
                {[
                  'What are the best slot games?',
                  'How do I claim bonuses?',
                  'What is RTP?',
                ].map((question) => (
                  <SuggestedQuestion key={question} question={question} isMaximized={isMaximized} />
                ))}
              </div>
            </div>
          ) : (
            <>
              {messages.map((message) => (
                <MessageBubble key={message.id} message={message} isMaximized={isMaximized} />
              ))}
              {isLoading && (
                <div className="flex items-start gap-3">
                  <div className={cn(
                    'rounded-full bg-casino-purple flex items-center justify-center flex-shrink-0',
                    isMaximized ? 'w-10 h-10' : 'w-8 h-8'
                  )}>
                    <Bot className={cn('text-white', isMaximized ? 'w-5 h-5' : 'w-4 h-4')} />
                  </div>
                  <div className={cn('bg-white/5 rounded-2xl rounded-tl-none px-4 py-3', isMaximized && 'px-6 py-4')}>
                    <div className="flex gap-1">
                      <div className={cn('rounded-full bg-gray-400 animate-bounce', isMaximized ? 'w-3 h-3' : 'w-2 h-2')} style={{ animationDelay: '0ms' }} />
                      <div className={cn('rounded-full bg-gray-400 animate-bounce', isMaximized ? 'w-3 h-3' : 'w-2 h-2')} style={{ animationDelay: '150ms' }} />
                      <div className={cn('rounded-full bg-gray-400 animate-bounce', isMaximized ? 'w-3 h-3' : 'w-2 h-2')} style={{ animationDelay: '300ms' }} />
                    </div>
                  </div>
                </div>
              )}
              <div ref={messagesEndRef} />
            </>
          )}
        </div>
      </div>

      {/* Input */}
      <ChatInput />
    </div>
  );
}

function SuggestedQuestion({ question, isMaximized }: { question: string; isMaximized: boolean }) {
  const { sendMessage } = useChat();

  return (
    <button
      onClick={() => sendMessage(question)}
      className={cn(
        'w-full text-left px-4 py-2 bg-white/5 hover:bg-white/10 rounded-lg text-gray-300 transition-colors',
        isMaximized ? 'text-base py-3 px-6' : 'text-sm'
      )}
    >
      {question}
    </button>
  );
}
