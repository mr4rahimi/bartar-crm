import type { Config } from 'tailwindcss';

const config: Config = {
  darkMode: 'class',
  content: [
    './app/**/*.{ts,tsx}',
    './features/**/*.{ts,tsx}',
    './shared/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        'muted-foreground': 'hsl(var(--muted-foreground))',
        // Status colors — per 09-ui-guidelines.md
        status: {
          created: '#6b7280', // Gray
          waiting: '#f97316', // Orange
          approved: '#3b82f6', // Blue
          purchasing: '#a855f7', // Purple
          purchased: '#22c55e', // Green
          returned: '#ef4444', // Red
          closed: '#374151', // Dark Gray
        },
      },
      borderRadius: {
        lg: '0.75rem',
      },
    },
  },
  plugins: [],
};

export default config;
