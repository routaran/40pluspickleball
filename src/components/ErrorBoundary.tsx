import { Component } from 'react'
import type { ErrorInfo, ReactNode } from 'react'
import { QueryErrorResetBoundary } from '@tanstack/react-query'

interface Props {
  children: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

// Error boundary component for catching and displaying React errors
class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false
  }

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error boundary caught an error:', error, errorInfo)
  }

  public render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
          <div className="max-w-md w-full bg-white rounded-lg shadow-sm p-8 text-center">
            <div className="text-red-600 text-6xl mb-4">⚠️</div>
            <h1 className="text-2xl font-bold text-gray-900 mb-4">
              Something went wrong
            </h1>
            <p className="text-gray-600 mb-6">
              We encountered an unexpected error. Please refresh the page to continue.
            </p>
            
            <div className="space-y-3">
              <button
                onClick={() => window.location.reload()}
                className="w-full btn btn-primary"
              >
                Refresh Page
              </button>
              
              <button
                onClick={() => this.setState({ hasError: false, error: undefined })}
                className="w-full btn btn-secondary"
              >
                Try Again
              </button>
            </div>
            
            {process.env.NODE_ENV === 'development' && this.state.error && (
              <details className="mt-6 text-left">
                <summary className="text-sm text-gray-500 cursor-pointer mb-2">
                  Error Details (Development)
                </summary>
                <pre className="text-xs text-red-600 bg-red-50 p-3 rounded overflow-auto max-h-32">
                  {this.state.error.stack}
                </pre>
              </details>
            )}
          </div>
        </div>
      )
    }

    return this.props.children
  }
}

// Query error boundary for handling TanStack Query errors
export function QueryErrorBoundary({ children }: { children: ReactNode }) {
  return (
    <QueryErrorResetBoundary>
      {({ reset }) => (
        <ErrorBoundaryContent reset={reset}>
          {children}
        </ErrorBoundaryContent>
      )}
    </QueryErrorResetBoundary>
  )
}

interface ErrorBoundaryContentProps {
  children: ReactNode
  reset: () => void
}

class ErrorBoundaryContent extends Component<ErrorBoundaryContentProps, State> {
  public state: State = {
    hasError: false
  }

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Query error boundary caught an error:', error, errorInfo)
  }

  public render() {
    if (this.state.hasError) {
      return (
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 m-4">
          <div className="flex items-start">
            <div className="text-red-600 text-2xl mr-3">⚠️</div>
            <div className="flex-1">
              <h3 className="text-lg font-semibold text-red-800 mb-2">
                Data Loading Error
              </h3>
              <p className="text-red-700 mb-4">
                Unable to load the requested data. This could be due to a network issue or server problem.
              </p>
              
              <div className="space-x-3">
                <button
                  onClick={() => {
                    this.props.reset()
                    this.setState({ hasError: false, error: undefined })
                  }}
                  className="btn btn-secondary btn-sm"
                >
                  Retry
                </button>
                
                <button
                  onClick={() => window.location.reload()}
                  className="btn btn-secondary btn-sm"
                >
                  Refresh Page
                </button>
              </div>
              
              {process.env.NODE_ENV === 'development' && this.state.error && (
                <details className="mt-4">
                  <summary className="text-sm text-red-600 cursor-pointer mb-2">
                    Technical Details
                  </summary>
                  <pre className="text-xs text-red-600 bg-white p-2 rounded border overflow-auto max-h-24">
                    {this.state.error.message}
                  </pre>
                </details>
              )}
            </div>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}

export default ErrorBoundary