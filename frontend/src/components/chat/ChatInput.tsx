import { useState, useRef, useEffect } from 'react';
import { Send } from 'lucide-react';
import { useChat } from '../../context/ChatContext';
import { cn } from '../../utils/cn';

export default function ChatInput() {
  const { sendMessage, isLoading, isMaximized } = useChat();
  const [input, setInput] = useState('');
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Auto-resize textarea
  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
      textareaRef.current.style.height = `${Math.min(textareaRef.current.scrollHeight, 120)}px`;
    }
  }, [input]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const trimmedInput = input.trim();
    if (!trimmedInput || isLoading) return;

    setInput('');
    await sendMessage(trimmedInput);
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit(e);
    }
  };

  return (
    <form onSubmit={handleSubmit} className={cn('border-t border-white/10', isMaximized ? 'p-6' : 'p-4')}>
      <div className={cn('flex items-end gap-2', isMaximized && 'max-w-4xl mx-auto')}>
        <textarea
          ref={textareaRef}
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="Type your message..."
          disabled={isLoading}
          rows={1}
          className={cn(
            'flex-1 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-casino-purple resize-none max-h-[120px]',
            isMaximized ? 'px-6 py-3 text-base' : 'px-4 py-2'
          )}
        />
        <button
          type="submit"
          disabled={!input.trim() || isLoading}
          className={cn(
            'rounded-xl bg-casino-purple hover:bg-casino-purple-dark disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center transition-colors',
            isMaximized ? 'w-12 h-12' : 'w-10 h-10'
          )}
        >
          <Send className={cn('text-white', isMaximized ? 'w-5 h-5' : 'w-4 h-4')} />
        </button>
      </div>
      <p className={cn('text-gray-500 mt-2 text-center', isMaximized ? 'text-sm' : 'text-xs')}>
        Press Enter to send, Shift+Enter for new line
      </p>
    </form>
  );
}
