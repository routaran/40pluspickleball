import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

// Add simple error logging for debugging
window.addEventListener('error', (e) => {
  console.error('App Error:', e.error)
})

const rootElement = document.getElementById('root')
if (!rootElement) {
  console.error('Root element not found')
} else {
  createRoot(rootElement).render(
    <StrictMode>
      <App />
    </StrictMode>,
  )
}
