
import { useParams, Link } from 'react-router-dom'

export default function EventDetail() {
  const { id } = useParams<{ id: string }>()

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <Link
            to="/events"
            className="inline-flex items-center text-sm text-gray-500 hover:text-gray-700 mb-2"
          >
            <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
            Back to Events
          </Link>
          <h1 className="text-3xl font-bold text-gray-900">Event Details</h1>
          <p className="text-gray-600">Event ID: {id}</p>
        </div>
      </div>

      {/* Coming Soon Message */}
      <div className="card text-center py-12">
        <div className="text-blue-600 text-6xl mb-4">📅</div>
        <h2 className="text-2xl font-bold text-gray-900 mb-4">
          Event Detail Page Coming Soon
        </h2>
        <p className="text-lg text-gray-600 mb-6">
          This page will display comprehensive event information including:
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8 text-left max-w-2xl mx-auto">
          <div>
            <h3 className="font-semibold text-gray-900 mb-2">Event Information</h3>
            <ul className="text-gray-600 space-y-1 text-sm">
              <li>• Event name and date</li>
              <li>• Court configuration</li>
              <li>• Scoring format</li>
              <li>• Player roster</li>
            </ul>
          </div>
          <div>
            <h3 className="font-semibold text-gray-900 mb-2">Live Features</h3>
            <ul className="text-gray-600 space-y-1 text-sm">
              <li>• Round-by-round schedules</li>
              <li>• Real-time standings</li>
              <li>• Match results</li>
              <li>• Print-friendly layouts</li>
            </ul>
          </div>
        </div>
        
        <div className="space-y-4">
          <Link
            to="/events"
            className="btn btn-primary inline-flex items-center"
          >
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            View All Events
          </Link>
        </div>
      </div>

      {/* Preview tabs */}
      <div className="bg-white rounded-lg shadow-sm">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8 px-6" aria-label="Tabs">
            <div className="border-blue-500 text-blue-600 py-4 px-1 border-b-2 font-medium text-sm">
              Schedule
            </div>
            <div className="border-transparent text-gray-500 py-4 px-1 border-b-2 font-medium text-sm">
              Standings
            </div>
            <div className="border-transparent text-gray-500 py-4 px-1 border-b-2 font-medium text-sm">
              Results
            </div>
          </nav>
        </div>
        <div className="p-6 text-center">
          <p className="text-gray-500">Tab content will be available in Week 2 implementation.</p>
        </div>
      </div>
    </div>
  )
}