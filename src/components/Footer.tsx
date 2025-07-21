
export default function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="bg-white border-t border-gray-200 mt-auto">
      <div className="container mx-auto px-4 py-6">
        <div className="flex flex-col sm:flex-row justify-between items-center space-y-2 sm:space-y-0">
          {/* Logo and Copyright */}
          <div className="flex items-center space-x-2 text-gray-600">
            <span className="text-blue-600 text-lg">🏓</span>
            <span className="text-sm">
              © {currentYear} 40+ Pickleball Platform
            </span>
          </div>

          {/* Simple links */}
          <div className="flex items-center space-x-6 text-sm">
            <span className="text-gray-500">
              Professional tournament management
            </span>
          </div>
        </div>
      </div>
    </footer>
  )
}