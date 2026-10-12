import {
  Button,
  Menu,
  MenuItemRadio,
  MenuList,
  MenuPopover,
  MenuTrigger,
} from "@fluentui/react-components"
import { WeatherMoonRegular, WeatherSunnyRegular } from "@fluentui/react-icons"
import { useTheme } from "@/hooks/use-theme"
import type { Theme } from "@/providers/theme-context"

export function ModeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <Menu
      checkedValues={{ theme: [theme] }}
      onCheckedValueChange={(_, data) => setTheme(data.checkedItems[0] as Theme)}
    >
      <MenuTrigger disableButtonEnhancement>
        <Button
          appearance="outline"
          icon={theme === "dark" ? <WeatherMoonRegular /> : <WeatherSunnyRegular />}
          aria-label="Toggle theme"
        />
      </MenuTrigger>
      <MenuPopover>
        <MenuList>
          <MenuItemRadio name="theme" value="light">Light</MenuItemRadio>
          <MenuItemRadio name="theme" value="dark">Dark</MenuItemRadio>
          <MenuItemRadio name="theme" value="system">System</MenuItemRadio>
        </MenuList>
      </MenuPopover>
    </Menu>
  )
}
