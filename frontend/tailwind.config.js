/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Dark casino theme
        casino: {
          bg: '#0a0a0a',
          'bg-secondary': '#1a1a2e',
          'bg-card': '#16162a',
          purple: {
            DEFAULT: '#7c3aed',
            dark: '#5b21b6',
            light: '#a78bfa',
          },
          gold: {
            DEFAULT: '#fbbf24',
            dark: '#d97706',
            light: '#fcd34d',
          },
          accent: '#e11d48',
        },
      },
      backgroundImage: {
        'gradient-casino': 'linear-gradient(180deg, #0a0a0a 0%, #1a0a2e 100%)',
        'gradient-card': 'linear-gradient(135deg, #1a1a2e 0%, #16162a 100%)',
        'gradient-gold': 'linear-gradient(135deg, #fbbf24 0%, #d97706 100%)',
        'gradient-purple': 'linear-gradient(135deg, #7c3aed 0%, #5b21b6 100%)',
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'shimmer': 'shimmer 2s linear infinite',
        'float': 'float 3s ease-in-out infinite',
      },
      keyframes: {
        shimmer: {
          '0%': { transform: 'translateX(-100%)' },
          '100%': { transform: 'translateX(100%)' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-10px)' },
        },
      },
      boxShadow: {
        'casino': '0 4px 20px rgba(124, 58, 237, 0.3)',
        'casino-lg': '0 8px 40px rgba(124, 58, 237, 0.4)',
        'gold': '0 4px 20px rgba(251, 191, 36, 0.3)',
      },
    },
  },
  plugins: [],
};
