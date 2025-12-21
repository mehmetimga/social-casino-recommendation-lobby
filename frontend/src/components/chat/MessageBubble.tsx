import { Bot, User } from 'lucide-react';
import { ChatMessage } from '../../types/chat';
import { cn } from '../../utils/cn';
import Citation from './Citation';

interface MessageBubbleProps {
  message: ChatMessage;
  isMaximized?: boolean;
}

// Helper function to render text with markdown bold (**text**)
function renderFormattedText(text: string): React.ReactNode {
  // Split by **text** pattern
  const parts = text.split(/(\*\*[^*]+\*\*)/g);

  return parts.map((part, index) => {
    // Check if this part is bold (wrapped in **)
    if (part.startsWith('**') && part.endsWith('**')) {
      const boldText = part.slice(2, -2);
      return <strong key={index} className="font-semibold">{boldText}</strong>;
    }
    return part;
  });
}

export default function MessageBubble({ message, isMaximized = false }: MessageBubbleProps) {
  const isUser = message.role === 'user';

  return (
    <div
      className={cn(
        'flex items-start gap-3',
        isUser && 'flex-row-reverse',
        isMaximized && 'gap-4'
      )}
    >
      {/* Avatar */}
      <div
        className={cn(
          'rounded-full flex items-center justify-center flex-shrink-0',
          isMaximized ? 'w-10 h-10' : 'w-8 h-8',
          isUser ? 'bg-casino-gold' : 'bg-casino-purple'
        )}
      >
        {isUser ? (
          <User className={cn('text-black', isMaximized ? 'w-5 h-5' : 'w-4 h-4')} />
        ) : (
          <Bot className={cn('text-white', isMaximized ? 'w-5 h-5' : 'w-4 h-4')} />
        )}
      </div>

      {/* Message Content */}
      <div
        className={cn(
          'max-w-[80%] rounded-2xl',
          isMaximized ? 'px-6 py-4' : 'px-4 py-3',
          isUser
            ? 'bg-casino-purple text-white rounded-tr-none'
            : 'bg-white/5 text-gray-100 rounded-tl-none'
        )}
      >
        {/* Message Text */}
        <p className={cn('whitespace-pre-wrap', isMaximized ? 'text-base leading-relaxed' : 'text-sm')}>
          {renderFormattedText(message.content)}
        </p>

        {/* Citations */}
        {message.citations && message.citations.length > 0 && (
          <div className="mt-3 pt-3 border-t border-white/10">
            <p className={cn('text-gray-400 mb-2', isMaximized ? 'text-sm' : 'text-xs')}>
              Sources:
            </p>
            <div className="space-y-2">
              {message.citations.map((citation, index) => (
                <Citation key={index} citation={citation} isMaximized={isMaximized} />
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
