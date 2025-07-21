import React, { useState } from 'react'
import { useAuth } from '@/contexts/AuthContext'
import { Link } from 'react-router-dom'

export default function Login() {
  const { signInWithEmail, signInWithMagicLink, loading } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [rememberMe, setRememberMe] = useState(false)
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')
  const [isSignUp, setIsSignUp] = useState(false)

  const handleEmailPasswordSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setMessage('')

    if (!email || !password) {
      setError('Email and password are required')
      return
    }

    const { error } = await signInWithEmail(email, password)

    if (error) {
      if (error.message.includes('Invalid login credentials')) {
        setError('Invalid email or password. Please check your credentials.')
      } else {
        setError(error.message)
      }
    } else {
      // Sign in successful - context will handle state updates
      setMessage('Sign in successful! Redirecting...')
    }
  }

  const handleMagicLinkSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setMessage('')

    if (!email) {
      setError('Email is required')
      return
    }

    const { error } = await signInWithMagicLink(email)

    if (error) {
      setError(error.message)
    } else {
      setMessage('Magic link sent! Please check your email and click the link to sign in.')
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="text-center">
          <h2 className="mt-6 text-center text-3xl font-bold tracking-tight text-gray-900">
            {isSignUp ? 'Create your account' : 'Sign in to your account'}
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            40+ Pickleball Tournament Management
          </p>
        </div>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="card">
          <div className="space-y-6">
            {/* Toggle between Sign In and Sign Up */}
            <div className="flex justify-center space-x-4">
              <button
                type="button"
                onClick={() => setIsSignUp(false)}
                className={`px-4 py-2 text-sm font-medium rounded-md ${
                  !isSignUp
                    ? 'bg-blue-600 text-white'
                    : 'text-blue-600 hover:text-blue-800'
                }`}
              >
                Sign In
              </button>
              <button
                type="button"
                onClick={() => setIsSignUp(true)}
                className={`px-4 py-2 text-sm font-medium rounded-md ${
                  isSignUp
                    ? 'bg-blue-600 text-white'
                    : 'text-blue-600 hover:text-blue-800'
                }`}
              >
                New Organizer
              </button>
            </div>

            {/* Error and success messages */}
            {error && (
              <div className="rounded-md bg-red-50 p-4">
                <div className="text-sm text-red-700">{error}</div>
              </div>
            )}

            {message && (
              <div className="rounded-md bg-green-50 p-4">
                <div className="text-sm text-green-700">{message}</div>
              </div>
            )}

            {!isSignUp ? (
              /* Sign In Form */
              <>
                <form className="space-y-6" onSubmit={handleEmailPasswordSubmit}>
                  <div>
                    <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                      Email address
                    </label>
                    <div className="mt-1">
                      <input
                        id="email"
                        name="email"
                        type="email"
                        autoComplete="email"
                        required
                        className="input"
                        placeholder="Enter your email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                      />
                    </div>
                  </div>

                  <div>
                    <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                      Password
                    </label>
                    <div className="mt-1">
                      <input
                        id="password"
                        name="password"
                        type="password"
                        autoComplete="current-password"
                        required
                        className="input"
                        placeholder="Enter your password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                      />
                    </div>
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="flex items-center">
                      <input
                        id="remember-me"
                        name="remember-me"
                        type="checkbox"
                        className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                        checked={rememberMe}
                        onChange={(e) => setRememberMe(e.target.checked)}
                      />
                      <label htmlFor="remember-me" className="ml-2 block text-sm text-gray-900">
                        Remember me for 30 days
                      </label>
                    </div>
                  </div>

                  <div>
                    <button
                      type="submit"
                      disabled={loading}
                      className="btn btn-primary w-full"
                    >
                      {loading ? 'Signing in...' : 'Sign in'}
                    </button>
                  </div>
                </form>

                <div className="mt-6">
                  <div className="relative">
                    <div className="absolute inset-0 flex items-center">
                      <div className="w-full border-t border-gray-300" />
                    </div>
                    <div className="relative flex justify-center text-sm">
                      <span className="px-2 bg-white text-gray-500">Or</span>
                    </div>
                  </div>

                  <div className="mt-6">
                    <form onSubmit={handleMagicLinkSubmit}>
                      <button
                        type="submit"
                        disabled={loading || !email}
                        className="btn btn-secondary w-full"
                      >
                        {loading ? 'Sending...' : 'Send Magic Link'}
                      </button>
                    </form>
                    <p className="mt-2 text-xs text-gray-500 text-center">
                      For first-time users or if you forgot your password
                    </p>
                  </div>
                </div>
              </>
            ) : (
              /* Sign Up Form */
              <div className="text-center space-y-4">
                <div className="rounded-md bg-blue-50 p-4">
                  <div className="text-sm text-blue-700">
                    <p className="font-medium">New organizers welcome!</p>
                    <p className="mt-1">
                      To get started, please contact an administrator to create your account.
                      Once your account is set up, you'll receive a magic link to set your password.
                    </p>
                  </div>
                </div>
                
                <div className="text-sm text-gray-600">
                  <p>Account creation is currently managed by administrators to ensure</p>
                  <p>security and proper access controls for tournament management.</p>
                </div>

                <div className="pt-4">
                  <Link
                    to="/contact"
                    className="btn btn-primary"
                  >
                    Contact Administrator
                  </Link>
                </div>
              </div>
            )}
          </div>
        </div>

        <div className="mt-6 text-center">
          <div className="text-sm text-gray-600">
            <p>Need help? Contact support for assistance with your account.</p>
          </div>
        </div>
      </div>
    </div>
  )
}