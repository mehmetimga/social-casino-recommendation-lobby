import { FileText, ExternalLink } from 'lucide-react';
import { Citation as CitationType } from '../../types/chat';
import { cn } from '../../utils/cn';

interface CitationProps {
  citation: CitationType;
  isMaximized?: boolean;
}

export default function Citation({ citation, isMaximized = false }: CitationProps) {
  return (
    <div className={cn('flex items-start gap-2 bg-white/5 rounded-lg', isMaximized ? 'p-3' : 'p-2')}>
      <FileText className={cn('text-casino-purple flex-shrink-0 mt-0.5', isMaximized ? 'w-5 h-5' : 'w-4 h-4')} />
      <div className="flex-1 min-w-0">
        <p className={cn('font-medium text-gray-300 truncate', isMaximized ? 'text-sm' : 'text-xs')}>
          {citation.source}
        </p>
        {citation.excerpt && (
          <p className={cn('text-gray-500 line-clamp-2 mt-1', isMaximized ? 'text-sm' : 'text-xs')}>
            "{citation.excerpt}"
          </p>
        )}
      </div>
      <button className="text-casino-purple hover:text-casino-purple-light transition-colors">
        <ExternalLink className={cn(isMaximized ? 'w-4 h-4' : 'w-3 h-3')} />
      </button>
    </div>
  );
}
