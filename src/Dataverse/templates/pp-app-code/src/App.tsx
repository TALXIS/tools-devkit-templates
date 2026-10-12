import { ThemeProvider } from "@/providers/theme-provider"
import { ToastProvider } from "@/providers/toast-provider"
import { QueryProvider } from "./providers/query-provider"
import { RouterProvider } from "react-router-dom"
import { router } from "@/router"

export default function App() {
  return (
    <ThemeProvider>
      <ToastProvider>
        <QueryProvider>
          <RouterProvider router={router} />
        </QueryProvider>
      </ToastProvider>
    </ThemeProvider>
  )
}
