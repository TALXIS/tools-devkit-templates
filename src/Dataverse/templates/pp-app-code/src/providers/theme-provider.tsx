import { useState, useSyncExternalStore } from "react"
import { FluentProvider, webDarkTheme, webLightTheme } from "@fluentui/react-components"
import { ThemeProviderContext, type Theme } from "@/providers/theme-context"

type ThemeProviderProps = {
  children: React.ReactNode
  defaultTheme?: Theme
  storageKey?: string
}

const darkQuery = window.matchMedia("(prefers-color-scheme: dark)")

// Tracks the OS color scheme live, so "system" follows it without a reload.
function usePrefersDark() {
  return useSyncExternalStore(
    (onChange) => {
      darkQuery.addEventListener("change", onChange)
      return () => darkQuery.removeEventListener("change", onChange)
    },
    () => darkQuery.matches
  )
}

export function ThemeProvider({
  children,
  defaultTheme = "system",
  storageKey = "app-theme",
}: ThemeProviderProps) {
  const [theme, setTheme] = useState<Theme>(
    () => (localStorage.getItem(storageKey) as Theme) || defaultTheme
  )
  const prefersDark = usePrefersDark()
  const isDark = theme === "dark" || (theme === "system" && prefersDark)

  const value = {
    theme,
    setTheme: (theme: Theme) => {
      localStorage.setItem(storageKey, theme)
      setTheme(theme)
    },
  }

  return (
    <ThemeProviderContext.Provider value={value}>
      <FluentProvider theme={isDark ? webDarkTheme : webLightTheme} style={{ minHeight: "100dvh" }}>
        {children}
      </FluentProvider>
    </ThemeProviderContext.Provider>
  )
}
