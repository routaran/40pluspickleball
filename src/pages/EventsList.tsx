
import { Link } from 'react-router-dom'

export default function EventsList() {
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold text-gray-900">All Events</h1>
      </div>

      {/* Coming Soon Message */}
      <div className="card text-center py-12">
        <div className="text-blue-600 text-6xl mb-4">🏓</div>
        <h2 className="text-2xl font-bold text-gray-900 mb-4">
          Events List Coming Soon
        </h2>
        <p className="text-lg text-gray-600 mb-6">
          This page will display all upcoming and current pickleball tournaments.
        </p>
        <p className="text-gray-500 mb-8">
          Features will include event filtering, search, and quick access to schedules and standings.
        </p>
        
        <div className="space-y-4">
          <Link
            to="/"
            className="btn btn-primary inline-flex items-center"
          >
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
            </svg>
            Back to Home
          </Link>
        </div>
      </div>

      {/* Preview of what's coming */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div className="card opacity-75">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-gray-600">Today's Events</h3>
            <span className="text-xs text-gray-500">Coming in Week 2</span>
          </div>
          <p className="text-sm text-gray-500">
            Highlighted events happening today with quick access to live standings.
          </p>
        </div>

        <div className="card opacity-75">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-gray-600">Upcoming Events</h3>
            <span className="text-xs text-gray-500">Coming in Week 2</span>
          </div>
          <p className="text-sm text-gray-500">
            Future tournaments with registration and event details.
          </p>
        </div>

        <div className="card opacity-75">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-gray-600">Past Events</h3>
            <span className="text-xs text-gray-500">Coming in Week 2</span>
          </div>
          <p className="text-sm text-gray-500">
            Historical tournaments with final results and statistics.
          </p>
        </div>
      </div>
    </div>
  )
}