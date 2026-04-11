/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./App.{js,jsx,ts,tsx}", "./src/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        ink: {
          950: "#151515",
          900: "#1B1B1E",
          800: "#232328",
          700: "#35353C",
          500: "#767681",
          300: "#BFC0C6",
          200: "#D9DAE0",
          100: "#ECECF1",
          50: "#F7F7F9",
        },
        sage: {
          500: "#70806E",
          300: "#A5B3A2",
          100: "#E7ECE6",
        },
        amber: {
          500: "#A97A4B",
          100: "#F3E9DF",
        },
      },
    },
  },
  plugins: [],
};
