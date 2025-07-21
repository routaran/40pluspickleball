# 🏓 40+ Pickleball Tournament Platform

A comprehensive web application for managing round-robin pickleball tournaments, designed specifically for the 40+ age demographic. Built with modern web technologies and optimized for mobile courtside use.

## 🌟 Features

### Core Tournament Management
- **Dynamic Event Creation**: Set up tournaments with flexible court and scoring configurations
- **Player Roster Management**: Add players, track check-ins, handle mid-event changes
- **Automated Round-Robin Generation**: Advanced Modified Berger Tables algorithm ensures fair pairings
- **Real-time Standings**: Multi-tier tiebreaker system with live updates
- **Mobile Score Entry**: One-thumb operation design for courtside use

### Advanced Algorithms
- **Partnership Optimization**: Ensures players partner with different people each round
- **Bye Round Distribution**: Fair rotation system prevents consecutive byes
- **Head-to-Head Tiebreakers**: Sophisticated ranking system handles all edge cases

### Professional Features
- **Print-Friendly Layouts**: High-quality schedules and standings for posting
- **Player Statistics**: Cross-tournament performance tracking
- **30-Day Sessions**: Long-lasting authentication for tournament organizers
- **Responsive Design**: Works perfectly on phones, tablets, and desktops

## 🚀 Live Demo

Visit the live application: **[https://routaran.github.io/40pluspickleball/](https://routaran.github.io/40pluspickleball/)**

## 🏗️ Technical Architecture

### Frontend Stack
- **React 18+** with TypeScript for type-safe development
- **Vite** for fast development and optimized builds
- **Tailwind CSS** for responsive, mobile-first design
- **TanStack Query** for intelligent server state management
- **React Router v6** for seamless navigation

### Backend & Database
- **Supabase** for authentication, database, and real-time features
- **PostgreSQL** with comprehensive Row Level Security policies
- **11 normalized tables** supporting complex tournament logic
- **Automated triggers** for data validation and integrity

### Deployment & DevOps
- **GitHub Pages** for reliable static hosting
- **GitHub Actions** for automated CI/CD pipeline
- **Environment-based configuration** for secure credential management

## 📋 Project Status

### ✅ Completed (Planning & Foundation)
- [x] **Product Requirements Document** - Complete feature specification
- [x] **Technical Architecture** - Comprehensive system design
- [x] **Database Schema** - 11 tables with security policies
- [x] **Algorithm Specifications** - Detailed tournament logic
- [x] **UI/UX Specifications** - Mobile-first design patterns
- [x] **Implementation Roadmap** - 6-week development plan
- [x] **GitHub Repository Setup** - Automated deployment pipeline

### 🔄 In Progress (Week 1: Foundation)
- [ ] React + TypeScript project initialization
- [ ] Authentication system implementation
- [ ] Base UI components and routing
- [ ] Supabase integration and type generation

### 📅 Upcoming Milestones
- **Week 2**: Event management and player roster features
- **Week 3**: Tournament algorithm implementation
- **Week 4**: Score entry and statistics system
- **Week 5**: Mobile optimization and print layouts
- **Week 6**: Testing, polish, and production deployment

## 🛠️ Development Setup

### Prerequisites
- Node.js 18+ 
- npm or yarn package manager
- Supabase account and project

### Local Development
```bash
# Clone the repository
git clone git@github.com:routaran/40pluspickleball.git
cd 40pluspickleball

# Install dependencies (when React app is created)
npm install

# Configure environment variables
cp .env.example .env.local
# Add your Supabase URL and API key

# Start development server
npm run dev
```

### Database Setup
1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Run the SQL schema from `supabase/schema.sql` in your Supabase dashboard
3. Copy your project URL and API key to `.env.local`

## 📚 Documentation

### Project Files
- **[PRD.md](./PRD.md)** - Complete Product Requirements Document
- **[TODO_IMPLEMENTATION_GUIDE.md](./TODO_IMPLEMENTATION_GUIDE.md)** - Step-by-step development guide
- **[IMPLEMENTATION_ROADMAP.md](./IMPLEMENTATION_ROADMAP.md)** - 6-week development timeline
- **[PLANNING_ANALYSIS.md](./PLANNING_ANALYSIS.md)** - Requirements alignment analysis

### Technical Specifications
- **[specifications/algorithms/](./specifications/algorithms/)** - Tournament algorithms and tiebreaker logic
- **[specifications/database/](./specifications/database/)** - Complete database schema and policies
- **[specifications/auth/](./specifications/auth/)** - Authentication flow and security
- **[specifications/ui/](./specifications/ui/)** - Mobile UI/UX patterns
- **[specifications/print/](./specifications/print/)** - Print layout templates

## 🎯 Target Users

### Primary: Tournament Organizers
- Volunteer organizers at community centers and clubs
- Need simple, reliable tools for managing 8-32 player events
- Value mobile-friendly interfaces for courtside management
- Require professional-looking printed materials

### Secondary: Players
- 40+ age demographic participating in tournaments
- Need easy access to schedules and standings
- Prefer simple, clear interfaces with large text
- Value printed backup materials

## 🏆 Success Metrics

- **Organizer Efficiency**: Reduce setup time from 30+ minutes to under 5 minutes
- **Player Satisfaction**: Clear, accessible tournament information
- **Mobile Performance**: Smooth operation on iOS Safari 14+ and Chrome Mobile 90+
- **Algorithm Performance**: <100ms generation time for 16-player tournaments
- **Session Reliability**: 30-day persistent authentication

## 🤝 Contributing

This is currently a personal project in active development. The codebase will be open for contributions once the initial implementation is complete (estimated late 2025).

## 📄 License

This project is licensed under the GNU Affero General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## 📧 Contact

**Project Maintainer**: Routaran  
**Repository**: [https://github.com/routaran/40pluspickleball](https://github.com/routaran/40pluspickleball)

---

*Built with ❤️ for the pickleball community*
