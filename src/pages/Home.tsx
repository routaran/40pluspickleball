
import { Link } from 'react-router-dom'
import { useAuth } from '@/contexts/AuthContext'
import { isDemo } from '@/services/supabase'

export default function Home() {
  const { user } = useAuth()

  return (
    <div className="space-y-8">
      {/* Hero Section */}
      <div className="bg-white rounded-lg shadow-sm p-8 text-center">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">
          🏓 40+ Pickleball Platform
        </h1>
        <p className="text-xl text-gray-600 mb-8">
          Professional tournament management for the 40+ pickleball community
        </p>
        
        {isDemo && (
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
            <div className="text-blue-800">
              <p className="font-medium">🎯 Demo Mode</p>
              <p className="text-sm mt-1">
                This is a demonstration of the Week 1 foundation. Authentication and database features show demo content only.
              </p>
            </div>
          </div>
        )}
        
        {user ? (
          <div className="space-y-4">
            <p className="text-lg text-gray-700">
              Welcome back, {user.display_name}!
            </p>
            <Link
              to="/admin/dashboard"
              className="btn btn-primary inline-flex items-center"
            >
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
              Go to Dashboard
            </Link>
          </div>
        ) : (
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              to="/events"
              className="btn btn-primary inline-flex items-center"
            >
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
              View Events
            </Link>
            <Link
              to="/login"
              className="btn btn-secondary inline-flex items-center"
            >
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
              </svg>
              Organizer Login
            </Link>
          </div>
        )}
      </div>

      {/* Features Section */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="card text-center">
          <div className="text-blue-600 text-4xl mb-4">🏓</div>
          <h3 className="text-lg font-semibold text-gray-900 mb-2">
            Round-Robin Tournaments
          </h3>
          <p className="text-gray-600">
            Advanced algorithm ensures fair pairings and partner variety throughout your tournament.
          </p>
        </div>

        <div className="card text-center">
          <div className="text-blue-600 text-4xl mb-4">📱</div>
          <h3 className="text-lg font-semibold text-gray-900 mb-2">
            Mobile-Optimized
          </h3>
          <p className="text-gray-600">
            Designed for courtside use with large touch targets and one-thumb operation.
          </p>
        </div>

        <div className="card text-center">
          <div className="text-blue-600 text-4xl mb-4">🖨️</div>
          <h3 className="text-lg font-semibold text-gray-900 mb-2">
            Print-Friendly
          </h3>
          <p className="text-gray-600">
            Generate professional schedules and standings for courtside posting.
          </p>
        </div>
      </div>

      {/* Quick Links Section */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-6">Quick Access</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Link
            to="/events"
            className="flex items-center p-4 border border-gray-200 rounded-lg hover:border-blue-300 hover:bg-blue-50 transition-colors"
          >
            <svg className="w-8 h-8 text-blue-600 mr-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            <div>
              <h3 className="font-semibold text-gray-900">View All Events</h3>
              <p className="text-gray-600 text-sm">Browse upcoming and current tournaments</p>
            </div>
          </Link>

          <div className="flex items-center p-4 border border-gray-200 rounded-lg opacity-75">
            <svg className="w-8 h-8 text-gray-400 mr-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2-2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
            <div>
              <h3 className="font-semibold text-gray-600">Player Statistics</h3>
              <p className="text-gray-500 text-sm">Coming soon - track your tournament performance</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}