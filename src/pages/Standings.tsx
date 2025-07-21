
import { useParams, Link } from 'react-router-dom'

export default function Standings() {
  const { eventId } = useParams<{ eventId: string }>()

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
          <h1 className="text-3xl font-bold text-gray-900">Standings</h1>
          <p className="text-gray-600">Event ID: {eventId}</p>
        </div>
      </div>

      <div className="card text-center py-12">
        <div className="text-blue-600 text-6xl mb-4">🏆</div>
        <h2 className="text-2xl font-bold text-gray-900 mb-4">
          Standings Coming Soon
        </h2>
        <p className="text-lg text-gray-600 mb-6">
          Live standings and rankings will be available in Week 2 implementation.
        </p>
        
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
  )
}