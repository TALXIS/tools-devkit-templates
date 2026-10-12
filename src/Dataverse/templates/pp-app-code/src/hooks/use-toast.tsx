import { useMemo } from "react"
import { Toast, ToastTitle, useToastController, type ToastIntent } from "@fluentui/react-components"

export const TOASTER_ID = "app-toaster"

// Fluent dispatches toasts through a hook rather than a global function, so each component
// grabs one stable { info, success, warning, error } set and calls it like toast.success(...).
export function useToast() {
  const { dispatchToast } = useToastController(TOASTER_ID)

  return useMemo(() => {
    const show = (intent: ToastIntent) => (message: string) =>
      dispatchToast(
        <Toast>
          <ToastTitle>{message}</ToastTitle>
        </Toast>,
        { intent, timeout: 3000 }
      )
    return {
      info: show("info"),
      success: show("success"),
      warning: show("warning"),
      error: show("error"),
    }
  }, [dispatchToast])
}
