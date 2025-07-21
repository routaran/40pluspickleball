import React from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { AuthProvider, useAuth } from '@/contexts/AuthContext'
import { queryClient } from '@/services/queryClient'

// Layout and error components
import Layout from '@/components/Layout'
import ErrorBoundary, { QueryErrorBoundary } from '@/components/ErrorBoundary'
import { FullPageLoading } from '@/components/LoadingSpinner'

// Public pages
import Home from '@/pages/Home'
import EventsList from '@/pages/EventsList'
import EventDetail from '@/pages/EventDetail'
import Standings from '@/pages/Standings'
import Login from '@/pages/Login'
import SetupPassword from '@/pages/SetupPassword'
import NotFound from '@/pages/NotFound'

// Protected admin pages
import AdminLayout from '@/components/AdminLayout'
import Dashboard from '@/pages/admin/Dashboard'

// Route guard component for protected routes
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user, loading, initialized } = useAuth()

  // Show loading while checking auth status
  if (!initialized || loading) {
    return <FullPageLoading label="Checking authentication..." />
  }

  // Redirect to login if not authenticated
  if (!user) {
    return <Navigate to="/login" replace />
  }

  // If user hasn't set password, redirect to setup
  if (!user.password_set) {
    return <Navigate to="/setup-password" replace />
  }

  return <>{children}</>
}

// Component to redirect authenticated users away from login
function PublicRoute({ children }: { children: React.ReactNode }) {
  const { user, loading, initialized } = useAuth()

  // Show loading while checking auth status
  if (!initialized || loading) {
    return <FullPageLoading label="Loading..." />
  }

  // Redirect authenticated users to dashboard
  if (user && user.password_set) {
    return <Navigate to="/admin/dashboard" replace />
  }

  // If user exists but password not set, allow access to setup password
  return <>{children}</>
}

function AppRoutes() {
  return (
    <Routes>
      {/* Public routes */}
      <Route path="/" element={<Layout />}>
        <Route index element={<Home />} />
        <Route path="events" element={<EventsList />} />
        <Route path="event/:id" element={<EventDetail />} />
        <Route path="standings/:eventId" element={<Standings />} />
      </Route>

      {/* Authentication routes */}
      <Route path="/login" element={
        <PublicRoute>
          <Login />
        </PublicRoute>
      } />
      
      <Route path="/setup-password" element={
        <PublicRoute>
          <SetupPassword />
        </PublicRoute>
      } />

      {/* Protected admin routes */}
      <Route path="/admin" element={
        <ProtectedRoute>
          <AdminLayout />
        </ProtectedRoute>
      }>
        <Route index element={<Navigate to="/admin/dashboard" replace />} />
        <Route path="dashboard" element={<Dashboard />} />
        {/* Additional admin routes will be added in later weeks */}
      </Route>

      {/* Catch all route - 404 */}
      <Route path="*" element={<NotFound />} />
    </Routes>
  )
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ErrorBoundary>
        <Router>
          <AuthProvider>
            <QueryErrorBoundary>
              <div className="min-h-screen bg-gray-50">
                <AppRoutes />
              </div>
            </QueryErrorBoundary>
          </AuthProvider>
        </Router>
      </ErrorBoundary>
      
      {/* React Query DevTools - only in development */}
      {process.env.NODE_ENV === 'development' && (
        <ReactQueryDevtools initialIsOpen={false} />
      )}
    </QueryClientProvider>
  )
}

export default App
