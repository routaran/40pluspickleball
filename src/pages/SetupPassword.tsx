import React, { useState } from 'react'
import { useAuth } from '@/contexts/AuthContext'
import { useNavigate } from 'react-router-dom'

export default function SetupPassword() {
  const { setupPassword, user, loading } = useAuth()
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [error, setError] = useState('')
  const [validationErrors, setValidationErrors] = useState<string[]>([])
  const navigate = useNavigate()

  // Password validation rules as per authentication specification
  const validatePassword = (password: string): string[] => {
    const errors: string[] = []
    
    if (password.length < 8) {
      errors.push('Password must be at least 8 characters long')
    }
    
    if (!/\d/.test(password)) {
      errors.push('Password must contain at least 1 number')
    }
    
    // Additional security recommendations for organizers
    if (!/[A-Z]/.test(password)) {
      errors.push('Password should contain at least 1 uppercase letter (recommended)')
    }
    
    if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) {
      errors.push('Password should contain at least 1 special character (recommended)')
    }

    return errors
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setValidationErrors([])

    // Validate password requirements
    const passwordErrors = validatePassword(password)
    const requiredErrors = passwordErrors.filter(error => 
      error.includes('8 characters') || error.includes('1 number')
    )
    
    if (requiredErrors.length > 0) {
      setValidationErrors(passwordErrors)
      setError('Please fix the password requirements above')
      return
    }

    // Check password confirmation
    if (password !== confirmPassword) {
      setError('Passwords do not match')
      return
    }

    // Setup password
    const { error } = await setupPassword(password)

    if (error) {
      setError(error.message)
    } else {
      // Password setup successful, redirect to dashboard
      navigate('/admin/dashboard')
    }
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
        <div className="sm:mx-auto sm:w-full sm:max-w-md">
          <div className="card text-center">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">
              Authentication Required
            </h2>
            <p className="text-gray-600 mb-6">
              Please follow the magic link in your email to access password setup.
            </p>
            <button
              onClick={() => navigate('/login')}
              className="btn btn-primary"
            >
              Return to Login
            </button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="text-center">
          <h2 className="mt-6 text-center text-3xl font-bold tracking-tight text-gray-900">
            Set Up Your Password
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Welcome, {user.display_name}! Please create a secure password for your account.
          </p>
        </div>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="card">
          <form className="space-y-6" onSubmit={handleSubmit}>
            {/* Error message */}
            {error && (
              <div className="rounded-md bg-red-50 p-4">
                <div className="text-sm text-red-700">{error}</div>
              </div>
            )}

            {/* Password validation feedback */}
            {validationErrors.length > 0 && (
              <div className="rounded-md bg-yellow-50 p-4">
                <div className="text-sm text-yellow-700">
                  <p className="font-medium mb-2">Password requirements:</p>
                  <ul className="list-disc list-inside space-y-1">
                    {validationErrors.map((error, index) => (
                      <li key={index} className={
                        error.includes('recommended') ? 'text-yellow-600' : 'text-red-600'
                      }>
                        {error}
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            )}

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                New Password
              </label>
              <div className="mt-1">
                <input
                  id="password"
                  name="password"
                  type="password"
                  autoComplete="new-password"
                  required
                  className="input"
                  placeholder="Enter your password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                />
              </div>
              <div className="mt-2 text-xs text-gray-500">
                <p>• Minimum 8 characters</p>
                <p>• At least 1 number</p>
                <p>• Uppercase letter and special character recommended</p>
              </div>
            </div>

            <div>
              <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700">
                Confirm Password
              </label>
              <div className="mt-1">
                <input
                  id="confirmPassword"
                  name="confirmPassword"
                  type="password"
                  autoComplete="new-password"
                  required
                  className="input"
                  placeholder="Confirm your password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                />
              </div>
            </div>

            <div className="rounded-md bg-blue-50 p-4">
              <div className="text-sm text-blue-700">
                <p className="font-medium">Security Information</p>
                <p className="mt-1">
                  Your password will be used to access tournament management features.
                  After setup, your session will remain active for 30 days on trusted devices.
                </p>
              </div>
            </div>

            <div>
              <button
                type="submit"
                disabled={loading || !password || !confirmPassword}
                className="btn btn-primary w-full"
              >
                {loading ? 'Setting up password...' : 'Set Password & Continue'}
              </button>
            </div>
          </form>

          <div className="mt-6 text-center">
            <div className="text-sm text-gray-600">
              <p>Having trouble? Contact your administrator for assistance.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}