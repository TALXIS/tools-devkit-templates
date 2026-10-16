import { useNavigate } from "react-router-dom"
import { Body1, Button, LargeTitle } from "@fluentui/react-components"
import { useStyles } from "./not-found.styles"

export default function NotFoundPage() {
  const styles = useStyles()
  const navigate = useNavigate()

  return (
    <div className={styles.root}>
      <LargeTitle as="h1">404 – Not found</LargeTitle>
      <Body1 className={styles.muted}>This isn't the page you're looking for.</Body1>
      <Button appearance="outline" onClick={() => navigate("/")}>Go home</Button>
    </div>
  )
}
