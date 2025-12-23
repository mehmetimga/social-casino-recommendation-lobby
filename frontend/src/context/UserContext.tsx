import { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { v4 as uuidv4 } from 'uuid';
import { recommendationApi } from '../api/recommendation';
import { EventType } from '../types/recommendation';
import { VipLevel } from '../types/chat';

interface UserContextValue {
  userId: string;
  isLoggedIn: boolean;
  vipLevel: VipLevel;
  setVipLevel: (level: VipLevel) => void;
  trackEvent: (gameSlug: string, eventType: EventType, durationSeconds?: number) => void;
  trackRating: (gameSlug: string, rating: number) => void;
}

const UserContext = createContext<UserContextValue | null>(null);

const USER_ID_KEY = 'casino_user_id';
const VIP_LEVEL_KEY = 'casino_vip_level';

export function UserProvider({ children }: { children: ReactNode }) {
  const [userId, setUserId] = useState<string>('');
  const [vipLevel, setVipLevelState] = useState<VipLevel>('bronze');

  useEffect(() => {
    // Get or create user ID from localStorage
    let storedUserId = localStorage.getItem(USER_ID_KEY);
    if (!storedUserId) {
      storedUserId = uuidv4();
      localStorage.setItem(USER_ID_KEY, storedUserId);
    }
    setUserId(storedUserId);

    // Get VIP level from localStorage (default to bronze)
    const storedVipLevel = localStorage.getItem(VIP_LEVEL_KEY) as VipLevel | null;
    if (storedVipLevel && ['bronze', 'silver', 'gold', 'platinum'].includes(storedVipLevel)) {
      setVipLevelState(storedVipLevel);
    }
  }, []);

  const setVipLevel = (level: VipLevel) => {
    setVipLevelState(level);
    localStorage.setItem(VIP_LEVEL_KEY, level);
  };

  const trackEvent = async (gameSlug: string, eventType: EventType, durationSeconds?: number) => {
    if (!userId) return;

    try {
      await recommendationApi.trackEvent({
        userId,
        gameSlug,
        eventType,
        durationSeconds,
      });
    } catch (error) {
      // Silently fail - don't interrupt user experience
      console.error('Failed to track event:', error);
    }
  };

  const trackRating = async (gameSlug: string, rating: number) => {
    if (!userId) return;

    try {
      await recommendationApi.submitRating({
        userId,
        gameSlug,
        rating,
      });
    } catch (error) {
      console.error('Failed to track rating:', error);
    }
  };

  return (
    <UserContext.Provider
      value={{
        userId,
        isLoggedIn: false, // PoC: always guest
        vipLevel,
        setVipLevel,
        trackEvent,
        trackRating,
      }}
    >
      {children}
    </UserContext.Provider>
  );
}

export function useUser() {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error('useUser must be used within a UserProvider');
  }
  return context;
}
