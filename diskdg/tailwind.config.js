  const { blackA, green, mauve, slate } = require('@radix-ui/colors')

  /** @type {import('tailwindcss').Config} */
  module.exports = {
    content: [
      './src/**/*.{vue,js,ts,jsx,tsx}',
      '!./node_modules',
    ],
    theme: {
      extend: {
        boxShadow: {
          'custom': '0 8px white',
        },
        ringWidth: {
          5: '5px',
        },
        ringColor: {
          'red-outline': 'rgba(255, 90, 120, 0.5)',
          'blue-outline': 'rgba(90, 120, 255, 0.6)',
        },
        inset: {
          'button-custom-top': 'calc(50% - 48px - 7vh)',
          'button-custom-left': 'calc(50% - 48px - 7.7vh)',
        },
        height: {
          'sidebar': 'calc(100vh - 2rem)',
        },
        width: {
          'screendiv': 'calc(100vw - 14rem)',
        },
        backgroundImage: {
          'red-gradient': 'linear-gradient(0deg, rgba(255, 90, 120, .6) 20%, rgba(255, 90, 120) 50%)',
          'blue-gradient': 'linear-gradient(0deg, rgba(90, 120, 255, .6) 20%, rgba(90, 120, 255) 50%)',
        },
        colors: {
          ...blackA,
          ...green,
          ...mauve,
          ...slate,
        },
        keyframes: {
          hide: {
            from: { opacity: 1 },
            to: { opacity: 0 },
          },
          slideIn: {
            from: { transform: 'translateX(calc(100% + var(--viewport-padding)))' },
            to: { transform: 'translateX(0)' },
          },
          swipeOut: {
            from: { transform: 'translateX(var(--radix-toast-swipe-end-x))' },
            to: { transform: 'translateX(calc(100% + var(--viewport-padding)))' },
          },
        },
        animation: {
          hide: 'hide 100ms ease-in',
          slideIn: 'slideIn 150ms cubic-bezier(0.16, 1, 0.3, 1)',
          swipeOut: 'swipeOut 100ms ease-out',
        },
      },
    },
    plugins: [],
  }
