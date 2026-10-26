import { createContext } from "react"

export type Theme = "dark" | "light" | "system"

type ThemeProviderState = {
  theme: Theme
  setTheme: (theme: Theme) => void
}

const initialState: ThemeProviderState = {
  theme: "system",
  setTheme: () => null,
}

// Kept apart from theme-provider.tsx so that file only exports components (React Fast Refresh).
export const ThemeProviderContext = createContext<ThemeProviderState>(initialState);
