import { MessageCircle, X } from 'lucide-react';
import { useChat } from '../../context/ChatContext';
import ChatWindow from './ChatWindow';
import { cn } from '../../utils/cn';

export default function ChatWidget() {
  const { isOpen, toggleChat } = useChat();

  return (
    <>
      {/* Chat Window */}
      {isOpen && <ChatWindow />}

      {/* Toggle Button */}
      <button
        onClick={toggleChat}
        className={cn(
          'fixed bottom-6 right-6 z-[60] w-14 h-14 rounded-full shadow-lg flex items-center justify-center transition-all',
          isOpen
            ? 'bg-gray-700 hover:bg-gray-600'
            : 'bg-casino-purple hover:bg-casino-purple-dark shadow-casino'
        )}
      >
        {isOpen ? (
          <X className="w-6 h-6 text-white" />
        ) : (
          <MessageCircle className="w-6 h-6 text-white" />
        )}
      </button>
    </>
  );
}
