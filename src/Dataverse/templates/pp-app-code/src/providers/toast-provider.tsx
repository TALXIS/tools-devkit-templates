import * as React from "react"
import { Toaster } from "@fluentui/react-components"
import { TOASTER_ID } from "@/hooks/use-toast"

type ToastProviderProps = { children: React.ReactNode }

// Hosts the app-wide Fluent Toaster; show toasts from any component with useToast().
export function ToastProvider({ children }: ToastProviderProps) {
  return (
    <>
      {children}
      <Toaster toasterId={TOASTER_ID} position="top" limit={3} />
    </>
  )
}
