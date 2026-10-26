import { useMemo } from "react"
import { PcfContextProvider, usePcfContext } from "@talxis/base-controls"
import { getEntityMetadata, openForm } from "@/providers/pcf-host"

type XrmWindow = Window & { Xrm?: { Utility: { getEntityMetadata: unknown } } }

// Read at import, before any provider renders: the provider only creates its fallback Xrm when
// the host page hasn't provided one
const hostProvidesXrm = !!(window as XrmWindow).Xrm

type PcfProviderProps = {
  children: React.ReactNode
  /** The current Fluent v9 theme, so controls follow light/dark mode with the rest of the app. */
  fluentDesignLanguage: Pick<ComponentFramework.FluentDesignState, "isDarkTheme" | "tokenTheme">
}

// Gives TALXIS base controls a PCF context. The outer PcfContextProvider generates one for a
// non-PCF host (formatting, user settings, dialogs, ...); the inner one reuses it with the two
// surfaces this app answers itself, entity metadata and opening a record (see pcf-host.ts).
export function PcfProvider({ children, fluentDesignLanguage }: PcfProviderProps) {
  const baseContext = useMemo(
    () => ({ fluentDesignLanguage }) as unknown as ComponentFramework.Context<unknown>,
    [fluentDesignLanguage]
  )

  return (
    <PcfContextProvider context={baseContext}>
      <HostSurfaces>{children}</HostSurfaces>
    </PcfContextProvider>
  )
}

function HostSurfaces({ children }: { children: React.ReactNode }) {
  const generated = usePcfContext()

  // The generated surfaces stay the prototypes, so everything not overridden here still works
  const context = useMemo(
    () => ({
      ...generated,
      utils: Object.assign(Object.create(generated.utils), { getEntityMetadata }),
      navigation: Object.assign(Object.create(generated.navigation), { openForm }),
    }),
    [generated]
  )

  // Lookup reads entity metadata from window.Xrm rather than the context; point the global
  // (base controls' own fallback Xrm, created by the provider above) at the same answer.
  // Set during render: the controls below read it in their own mount effects.
  // A real Xrm the host page provided is left alone.
  const xrm = (window as XrmWindow).Xrm
  if (xrm && !hostProvidesXrm) xrm.Utility.getEntityMetadata = getEntityMetadata

  return <PcfContextProvider context={context}>{children}</PcfContextProvider>
}
