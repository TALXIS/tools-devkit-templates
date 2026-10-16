import { useState } from "react"
import {
  Body1,
  Button,
  Card,
  Caption1,
  LargeTitle,
  mergeClasses,
} from "@fluentui/react-components"
import powerAppsLogo from "/power-apps.svg"
import reactLogo from "@/assets/react.svg"
import { Decimal, usePcfContext } from "@talxis/base-controls"
import { ModeToggle } from "@/components/mode-toggle"
import { useToast } from "@/hooks/use-toast"
import { useStyles } from "./home.styles"

export default function HomePage() {
  const styles = useStyles()
  const toast = useToast()
  const context = usePcfContext()
  const [count, setCount] = useState<number | null>(0)

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
        {/* A TALXIS base control: a Dataverse-style whole number field, formatted from user settings */}
        <div className={styles.counter}>
          <Decimal
            context={context}
            parameters={{ value: { raw: count, type: "Whole.None" } }}
            onNotifyOutputChanged={(outputs) => {
              // A parsed value arrives as a number (undefined when cleared); input the control can't
              // parse arrives as the raw text, so it's skipped here rather than stored as the count
              if (typeof outputs.value !== "string") setCount(outputs.value ?? null)
            }}
          />
          <Button appearance="outline" onClick={() => setCount((c) => (c ?? 0) + 1)}>
            +1
          </Button>
        </div>
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
