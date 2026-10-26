import { makeStyles, tokens } from "@fluentui/react-components"

export const useStyles = makeStyles({
  root: {
    minHeight: "100dvh",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    gap: tokens.spacingVerticalXL,
    padding: tokens.spacingHorizontalXXL,
    textAlign: "center",
  },
  muted: {
    color: tokens.colorNeutralForeground3,
  },
})
