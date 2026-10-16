import { makeStyles, tokens } from "@fluentui/react-components"

export const useStyles = makeStyles({
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
  counter: {
    display: "flex",
    alignItems: "center",
    gap: tokens.spacingHorizontalS,
    width: "240px",
  },
  muted: {
    color: tokens.colorNeutralForeground3,
  },
  actions: {
    display: "flex",
    gap: tokens.spacingHorizontalL,
  },
})
