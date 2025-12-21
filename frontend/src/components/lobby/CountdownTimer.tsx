import { useState, useEffect } from 'react';

interface CountdownTimerProps {
  endTime: string | Date;
  label?: string;
}

interface TimeLeft {
  days: number;
  hours: number;
  minutes: number;
  seconds: number;
}

export default function CountdownTimer({ endTime, label = 'Ends in' }: CountdownTimerProps) {
  const [timeLeft, setTimeLeft] = useState<TimeLeft>({ days: 0, hours: 0, minutes: 0, seconds: 0 });
  const [isExpired, setIsExpired] = useState(false);

  useEffect(() => {
    const calculateTimeLeft = () => {
      const end = new Date(endTime).getTime();
      const now = Date.now();
      const diff = end - now;

      if (diff <= 0) {
        setIsExpired(true);
        return { days: 0, hours: 0, minutes: 0, seconds: 0 };
      }

      return {
        days: Math.floor(diff / (1000 * 60 * 60 * 24)),
        hours: Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)),
        minutes: Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60)),
        seconds: Math.floor((diff % (1000 * 60)) / 1000),
      };
    };

    setTimeLeft(calculateTimeLeft());

    const timer = setInterval(() => {
      setTimeLeft(calculateTimeLeft());
    }, 1000);

    return () => clearInterval(timer);
  }, [endTime]);

  if (isExpired) {
    return (
      <div className="inline-flex items-center gap-2 bg-red-500/20 text-red-400 px-4 py-2 rounded-lg">
        <span className="text-sm font-medium">Offer Expired</span>
      </div>
    );
  }

  const timeUnits = [
    { value: timeLeft.days, label: 'DAYS' },
    { value: timeLeft.hours, label: 'HOURS' },
    { value: timeLeft.minutes, label: 'MINS' },
    { value: timeLeft.seconds, label: 'SECS' },
  ];

  return (
    <div className="inline-flex items-center gap-4 bg-black/60 backdrop-blur-sm px-6 py-3 rounded-lg">
      {label && (
        <span className="text-gray-400 text-sm font-medium hidden sm:block">{label}</span>
      )}
      <div className="flex items-center gap-3">
        {timeUnits.map((unit, index) => (
          <div key={unit.label} className="flex items-center gap-3">
            <div className="text-center">
              <div className="text-2xl md:text-3xl font-bold text-white tabular-nums">
                {String(unit.value).padStart(2, '0')}
              </div>
              <div className="text-xs text-gray-400">{unit.label}</div>
            </div>
            {index < timeUnits.length - 1 && (
              <span className="text-2xl text-gray-500">:</span>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
