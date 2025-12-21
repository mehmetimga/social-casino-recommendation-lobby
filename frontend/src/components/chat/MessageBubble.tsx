import { Bot, User } from 'lucide-react';
import { ChatMessage } from '../../types/chat';
import { cn } from '../../utils/cn';
import Citation from './Citation';

interface MessageBubbleProps {
  message: ChatMessage;
}

export default function MessageBubble({ message }: MessageBubbleProps) {
  const isUser = message.role === 'user';

  return (
    <div
      className={cn(
        'flex items-start gap-3',
        isUser && 'flex-row-reverse'
      )}
    >
      {/* Avatar */}
      <div
        className={cn(
          'w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0',
          isUser ? 'bg-casino-gold' : 'bg-casino-purple'
        )}
      >
        {isUser ? (
          <User className="w-4 h-4 text-black" />
        ) : (
          <Bot className="w-4 h-4 text-white" />
        )}
      </div>

      {/* Message Content */}
      <div
        className={cn(
          'max-w-[80%] rounded-2xl px-4 py-3',
          isUser
            ? 'bg-casino-purple text-white rounded-tr-none'
            : 'bg-white/5 text-gray-100 rounded-tl-none'
        )}
      >
        {/* Message Text */}
        <p className="text-sm whitespace-pre-wrap">{message.content}</p>

        {/* Citations */}
        {message.citations && message.citations.length > 0 && (
          <div className="mt-3 pt-3 border-t border-white/10">
            <p className="text-xs text-gray-400 mb-2">Sources:</p>
            <div className="space-y-2">
              {message.citations.map((citation, index) => (
                <Citation key={index} citation={citation} />
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
