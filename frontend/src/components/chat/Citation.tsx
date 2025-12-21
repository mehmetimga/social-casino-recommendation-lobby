import { FileText, ExternalLink } from 'lucide-react';
import { Citation as CitationType } from '../../types/chat';

interface CitationProps {
  citation: CitationType;
}

export default function Citation({ citation }: CitationProps) {
  return (
    <div className="flex items-start gap-2 p-2 bg-white/5 rounded-lg">
      <FileText className="w-4 h-4 text-casino-purple flex-shrink-0 mt-0.5" />
      <div className="flex-1 min-w-0">
        <p className="text-xs font-medium text-gray-300 truncate">
          {citation.source}
        </p>
        {citation.excerpt && (
          <p className="text-xs text-gray-500 line-clamp-2 mt-1">
            "{citation.excerpt}"
          </p>
        )}
      </div>
      <button className="text-casino-purple hover:text-casino-purple-light transition-colors">
        <ExternalLink className="w-3 h-3" />
      </button>
    </div>
  );
}
