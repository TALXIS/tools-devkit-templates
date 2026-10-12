import { useState } from "react"
import {
  Body1,
  Button,
  Card,
  Caption1,
  LargeTitle,
  makeStyles,
  mergeClasses,
  tokens,
} from "@fluentui/react-components"
import powerAppsLogo from "/power-apps.svg"
import reactLogo from "@/assets/react.svg"
import { ModeToggle } from "@/components/mode-toggle"
import { useToast } from "@/hooks/use-toast"

const useStyles = makeStyles({
  root: {
    flex: 1,
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    gap: tokens.spacingVerticalXXL,
    padding: tokens.spacingHorizontalXXL,
    textAlign: "center",
  },
  logos: {
    display: "flex",
    alignItems: "center",
    gap: "32px",
  },
  logo: {
    width: "96px",
    height: "96px",
    transitionProperty: "transform",
    transitionDuration: tokens.durationNormal,
    ":hover": { transform: "scale(1.05)" },
  },
  spin: {
    "@media (prefers-reduced-motion: no-preference)": {
      animationName: { from: { transform: "rotate(0deg)" }, to: { transform: "rotate(360deg)" } },
      animationDuration: "20s",
      animationIterationCount: "infinite",
      animationTimingFunction: "linear",
    },
  },
  card: {
    alignItems: "center",
    padding: tokens.spacingHorizontalXXL,
  },
  muted: {
    color: tokens.colorNeutralForeground3,
  },
  actions: {
    display: "flex",
    gap: tokens.spacingHorizontalL,
  },
})

export default function HomePage() {
  const styles = useStyles()
  const toast = useToast()
  const [count, setCount] = useState(0)

  return (
    <div className={styles.root}>
      <div className={styles.logos}>
        <a href="https://github.com/microsoft/PowerAppsCodeApps" target="_blank" rel="noreferrer noopener">
          <img src={powerAppsLogo} className={styles.logo} alt="Power Apps logo" />
        </a>
        <a href="https://react.dev" target="_blank" rel="noreferrer noopener">
          <img src={reactLogo} className={mergeClasses(styles.logo, styles.spin)} alt="React logo" />
        </a>
      </div>

      <LargeTitle as="h1">Power + Code</LargeTitle>

      <Card className={styles.card}>
        <Button appearance="outline" onClick={() => setCount((c) => c + 1)}>
          count is {count}
        </Button>
        <Body1 className={styles.muted}>
          Edit <code>src/App.tsx</code> and save to test HMR
        </Body1>
      </Card>

      <div className={styles.actions}>
        <Button appearance="outline" onClick={() => toast.info("Hello from Power Apps!")}>
          !
        </Button>
        <ModeToggle />
      </div>

      <Caption1 className={styles.muted}>
        Click on the Power Apps and React logos to learn more
      </Caption1>
    </div>
  )
}
