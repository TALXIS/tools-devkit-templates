import { Outlet, NavLink } from "react-router-dom"
import { makeStyles, mergeClasses, tokens } from "@fluentui/react-components"

const useStyles = makeStyles({
  root: {
    minHeight: "100dvh",
    display: "flex",
    flexDirection: "column",
  },
  header: {
    height: "56px",
    display: "flex",
    alignItems: "center",
    borderBottom: `${tokens.strokeWidthThin} solid ${tokens.colorNeutralStroke2}`,
  },
  container: {
    boxSizing: "border-box",
    width: "100%",
    maxWidth: "1280px",
    margin: "0 auto",
    padding: `0 ${tokens.spacingHorizontalXXL}`,
  },
  nav: {
    display: "flex",
    alignItems: "center",
    gap: tokens.spacingHorizontalL,
  },
  navLink: {
    fontSize: tokens.fontSizeBase300,
    color: tokens.colorNeutralForeground3,
    textDecorationLine: "none",
    ":hover": { color: tokens.colorNeutralForeground1 },
  },
  navLinkActive: {
    color: tokens.colorNeutralForeground1,
    fontWeight: tokens.fontWeightSemibold,
  },
  main: {
    flex: 1,
    display: "flex",
    width: "100%",
    maxWidth: "1280px",
    margin: "0 auto",
  },
})

type LayoutProps = { showHeader?: boolean }

export default function Layout({ showHeader = true }: LayoutProps) {
  const styles = useStyles()

  return (
    <div className={styles.root}>
      {showHeader && (
        <header className={styles.header}>
          <div className={styles.container}>
            <nav className={styles.nav}>
              <NavLink to="/" end
                className={({ isActive }) =>
                  mergeClasses(styles.navLink, isActive && styles.navLinkActive)
                }
              >
                Home
              </NavLink>
            </nav>
          </div>
        </header>
      )}

      <main className={styles.main}>
        <Outlet />
      </main>
    </div>
  )
}
