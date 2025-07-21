
interface LoadingSpinnerProps {
  size?: 'sm' | 'md' | 'lg' | 'xl'
  className?: string
  label?: string
  showLabel?: boolean
}

export default function LoadingSpinner({ 
  size = 'md', 
  className = '', 
  label = 'Loading...',
  showLabel = false 
}: LoadingSpinnerProps) {
  const sizeClasses = {
    sm: 'h-4 w-4',
    md: 'h-8 w-8', 
    lg: 'h-12 w-12',
    xl: 'h-16 w-16'
  }

  const spinnerElement = (
    <div
      className={`animate-spin rounded-full border-2 border-gray-300 border-t-blue-600 ${sizeClasses[size]} ${className}`}
      aria-label={label}
      role="status"
    >
      <span className="sr-only">{label}</span>
    </div>
  )

  if (showLabel) {
    return (
      <div className="flex flex-col items-center space-y-3">
        {spinnerElement}
        <span className="text-sm text-gray-600">{label}</span>
      </div>
    )
  }

  return spinnerElement
}

// Fullscreen loading component
export function FullPageLoading({ label = 'Loading...' }: { label?: string }) {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <LoadingSpinner size="lg" showLabel label={label} />
    </div>
  )
}

// Inline loading component for buttons
export function ButtonLoading({ size = 'sm' }: { size?: 'sm' | 'md' }) {
  return <LoadingSpinner size={size} className="mr-2" />
}

// Card/section loading component
export function SectionLoading({ label = 'Loading content...' }: { label?: string }) {
  return (
    <div className="flex items-center justify-center py-12">
      <LoadingSpinner size="md" showLabel label={label} />
    </div>
  )
}