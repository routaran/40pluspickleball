
import { useAuth } from '@/contexts/AuthContext'

export default function Dashboard() {
  const { user } = useAuth()

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600">Welcome back, {user?.display_name}</p>
      </div>

      <div className="card text-center py-12">
        <div className="text-blue-600 text-6xl mb-4">⚡</div>
        <h2 className="text-2xl font-bold text-gray-900 mb-4">
          Admin Dashboard Coming Soon
        </h2>
        <p className="text-lg text-gray-600 mb-6">
          Tournament management features will be available in Week 2 implementation.
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8 text-left max-w-2xl mx-auto">
          <div>
            <h3 className="font-semibold text-gray-900 mb-2">Coming Features</h3>
            <ul className="text-gray-600 space-y-1 text-sm">
              <li>• Create new tournaments</li>
              <li>• Manage player registration</li>
              <li>• Configure court settings</li>
              <li>• Generate schedules</li>
            </ul>
          </div>
          <div>
            <h3 className="font-semibold text-gray-900 mb-2">Live Management</h3>
            <ul className="text-gray-600 space-y-1 text-sm">
              <li>• Real-time score entry</li>
              <li>• Update standings</li>
              <li>• Print court assignments</li>
              <li>• Export results</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}