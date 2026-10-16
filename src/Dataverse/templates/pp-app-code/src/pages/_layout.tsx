import { Outlet, NavLink } from "react-router-dom"
import { mergeClasses } from "@fluentui/react-components"
import { useStyles } from "./_layout.styles"

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
