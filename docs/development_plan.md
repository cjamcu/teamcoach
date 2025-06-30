# TeamCoach Development Plan

## 📋 Project Overview

TeamCoach is a mobile application for softball team management that allows roster registration, play tracking, and statistics generation. The app works offline and syncs automatically when internet is available.

## 🏗️ Technology Stack

- **Framework**: Flutter (iOS + Android)
- **Backend/Database**: Appwrite (local + remote sync)
- **State Management**: Signals (pub.dev/packages/signals)
- **UI Library**: flutter-shadcn-ui

## 🗄️ Database Design (Appwrite Collections)

### 1. **teams** Collection
```json
{
  "id": "string",
  "name": "string",
  "created_at": "datetime",
  "updated_at": "datetime",
  "logo_url": "string (optional)",
  "primary_color": "string",
  "secondary_color": "string"
}
```

### 2. **players** Collection
```json
{
  "id": "string",
  "team_id": "string (reference)",
  "name": "string",
  "number": "integer",
  "positions": ["string"], // ["P", "C", "1B", "2B", "3B", "SS", "LF", "CF", "RF", "DH"]
  "is_active": "boolean",
  "created_at": "datetime",
  "updated_at": "datetime",
  "avatar_url": "string (optional)",
  "batting_side": "string", // "right", "left", "switch"
  "throwing_side": "string" // "right", "left"
}
```

### 3. **games** Collection
```json
{
  "id": "string",
  "team_id": "string (reference)",
  "opponent": "string",
  "location": "string",
  "game_date": "datetime",
  "is_home": "boolean",
  "status": "string", // "scheduled", "in_progress", "completed"
  "innings": "integer",
  "final_score_team": "integer",
  "final_score_opponent": "integer",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### 4. **game_lineups** Collection
```json
{
  "id": "string",
  "game_id": "string (reference)",
  "player_id": "string (reference)",
  "batting_order": "integer",
  "starting_position": "string",
  "is_starter": "boolean",
  "positions_played": ["string"], // Track all positions during the game
  "substituted_at_inning": "integer (nullable)",
  "substituted_by": "string (nullable)"
}
```

### 5. **plays** Collection
```json
{
  "id": "string",
  "game_id": "string (reference)",
  "player_id": "string (reference)",
  "inning": "integer",
  "at_bat_number": "integer",
  "play_type": "string", // "hit", "out", "walk", "strikeout", "error", "sacrifice"
  "result": "string", // "single", "double", "triple", "home_run", "fly_out", "ground_out", etc.
  "rbi": "integer",
  "runs_scored": "integer",
  "timestamp": "datetime",
  "notes": "string (optional)"
}
```

### 6. **team_settings** Collection
```json
{
  "id": "string",
  "team_id": "string (reference)",
  "innings_per_game": "integer",
  "roster_size_limit": "integer",
  "default_positions": ["string"],
  "sync_enabled": "boolean",
  "last_sync": "datetime"
}
```

## 📱 App Architecture

### Project Structure
```
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── services/
│       ├── appwrite_service.dart
│       ├── offline_service.dart
│       └── sync_service.dart
├── features/
│   ├── auth/
│   ├── roster/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── controllers/
│   ├── games/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── controllers/
│   ├── plays/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── controllers/
│   └── stats/
│       ├── models/
│       ├── screens/
│       ├── widgets/
│       └── controllers/
└── shared/
    ├── widgets/
    └── models/
```

## 🚀 Development Phases

### Phase 1: Initial Setup & Core Infrastructure (Week 1-2)

#### Tasks:
1. **Project Setup**
   - Initialize Flutter project with proper package structure
   - Configure Appwrite SDK
   - Set up flutter-shadcn-ui theme
   - Implement signals for state management
   - Create base models and interfaces

2. **Core Services**
   - Set up dependency injection
   - For sync offline mode use https://appwrite.io/docs/products/databases/offline

3. **Base UI Components**
   - Configure shadcn-ui theme and components
   - Create reusable widgets (buttons, cards, inputs)
   - Implement navigation structure
   - Design app color scheme and typography

#### Deliverables:
- Working Flutter project with all dependencies
- Basic navigation between empty screens
- Configured Appwrite connection
- Base UI theme and components

### Phase 2: Roster Management (Week 3-4)

#### Features:
1. **Player CRUD Operations**
   - Add new player screen with form validation
   - Player list with search and filter
   - Edit player details
   - Delete player with confirmation
   - Bulk actions (activate/deactivate multiple players)

2. **UI/UX Design**
   - Player cards with avatar, number, and positions
   - Swipe actions for quick edit/delete
   - Position badges with colors
   - Empty state illustrations

3. **Technical Implementation**
   - Player model with offline support
   - Signals for reactive player list
   - Image picker for player avatars
   - Position multi-select component

#### Screens:
- `RosterScreen` - Main player list
- `AddPlayerScreen` - Form to add new player
- `EditPlayerScreen` - Form to edit existing player
- `PlayerDetailScreen` - View player stats and history

### Phase 3: Game Creation & Control (Week 5-6)

#### Features:
1. **Game Management**
   - Create new game with opponent details
   - Game list with filters (upcoming, in progress, completed)
   - Pre-game lineup selection
   - Batting order arrangement (drag & drop)
   - Defensive position assignment

2. **UI/UX Design**
   - Game cards with status indicators
   - Visual lineup builder with drag handles
   - Position field diagram for defense
   - Starter/reserve toggle switches

3. **Technical Implementation**
   - Game and lineup models
   - Drag & drop functionality using Flutter's Draggable
   - Position validation logic
   - Game state management with signals

#### Screens:
- `GamesListScreen` - All games with filters
- `CreateGameScreen` - New game form
- `LineupBuilderScreen` - Set batting order and positions
- `GameDetailScreen` - View/edit game info

### Phase 4: Play Tracking (Week 7-8)

#### Features:
1. **In-Game Management**
   - Active game scoreboard
   - Play-by-play recording
   - Quick play buttons (Hit, Out, Walk, etc.)
   - Player substitutions
   - Position changes during game

2. **UI/UX Design**
   - Large, touch-friendly play buttons
   - Current batter highlight
   - Inning tracker
   - Live score display
   - Substitution modal

3. **Technical Implementation**
   - Play recording with timestamps
   - Game state updates
   - Batting order rotation logic
   - Substitution history tracking

#### Screens:
- `ActiveGameScreen` - Main game tracking interface
- `PlayRecorderScreen` - Detailed play input
- `SubstitutionScreen` - Player substitution interface
- `GameSummaryScreen` - Post-game summary

### Phase 5: Statistics & Analytics (Week 9-10)

#### Features:
1. **Statistics Generation**
   - Player stats (AVG, H, AB, R, RBI, etc.)
   - Team stats aggregation
   - Game-by-game breakdown
   - Season totals
   - Sortable stat tables

2. **UI/UX Design**
   - Stats cards with key metrics
   - Charts and graphs (batting average trends)
   - Comparative views
   - Export functionality

3. **Technical Implementation**
   - Stats calculation engine
   - Data aggregation queries
   - Chart integration (fl_chart)
   - PDF/CSV export

#### Screens:
- `TeamStatsScreen` - Overall team statistics
- `PlayerStatsScreen` - Individual player stats
- `GameStatsScreen` - Single game statistics
- `SeasonStatsScreen` - Season overview

### Phase 6: Offline & Sync (Week 11-12)

#### Features:
1. **Offline Functionality**
   - Queue system for offline actions
   - Conflict resolution
   - Sync status indicators
   - Manual sync trigger
   - Data integrity checks

2. **UI/UX Design**
   - Sync status bar
   - Offline mode indicator
   - Sync progress animation
   - Error notifications

3. **Technical Implementation**
   - Local database with sqflite
   - Sync queue management
   - Network state monitoring
   - Batch sync operations
   - Conflict resolution strategies

### Phase 7: Polish & Testing (Week 13-14)

#### Tasks:
1. **UI/UX Refinement**
   - Animation improvements
   - Loading states
   - Error handling
   - Empty states
   - Onboarding flow

2. **Performance Optimization**
   - List virtualization
   - Image caching
   - Query optimization
   - Memory management

3. **Testing**
   - Unit tests for business logic
   - Widget tests for UI components
   - Integration tests for workflows
   - Manual testing on various devices

4. **Documentation**
   - User manual
   - Code documentation
   - Deployment guide

## 🎨 UI/UX Design Principles

### Design System
1. **Color Palette**
   - Primary: Team customizable
   - Secondary: Team customizable
   - Success: Green (#10B981)
   - Warning: Orange (#F59E0B)
   - Error: Red (#EF4444)
   - Background: Light/Dark mode support

2. **Typography**
   - Headers: Bold, clear hierarchy
   - Body: Readable, 16px minimum
   - Numbers: Monospace for statistics

3. **Components**
   - Consistent border radius (8px)
   - Subtle shadows for depth
   - Clear touch targets (48px minimum)
   - Smooth transitions (300ms)

### User Experience
1. **Simplicity First**
   - Maximum 3 taps to any feature
   - Clear visual hierarchy
   - Intuitive icons with labels
   - Progressive disclosure

2. **Feedback**
   - Immediate visual feedback
   - Success/error messages
   - Loading indicators
   - Haptic feedback for actions

3. **Accessibility**
   - High contrast mode
   - Large touch targets
   - Screen reader support
   - Landscape orientation support

## 🔧 Technical Considerations

### Offline-First Architecture
1. **Data Flow**
   ```
   User Action → Local DB → UI Update → Sync Queue → Appwrite
   ```

2. **Sync Strategy**
   - Immediate sync when online
   - Batch sync for efficiency
   - Retry mechanism with exponential backoff
   - Conflict resolution (last-write-wins)

### State Management Pattern
```dart
// Using signals for reactive state
final playersSignal = listSignal<Player>([]);
final selectedGameSignal = signal<Game?>(null);
final statsSignal = computedSignal(() => calculateStats(playersSignal.value));
```

### Performance Guidelines
1. **Lists**: Use ListView.builder for large datasets
2. **Images**: Implement lazy loading and caching
3. **Queries**: Index frequently searched fields
4. **Memory**: Dispose controllers and streams properly

## 📊 Success Metrics

1. **Performance**
   - App launch time < 2 seconds
   - Screen transitions < 300ms
   - Sync completion < 5 seconds

2. **Usability**
   - Task completion rate > 95%
   - Error rate < 2%
   - User satisfaction > 4.5/5

3. **Technical**
   - Code coverage > 80%
   - Crash rate < 0.1%
   - Offline functionality 100%

## 🚦 Risk Mitigation

1. **Technical Risks**
   - Appwrite sync conflicts → Implement robust conflict resolution
   - Large data sets → Pagination and lazy loading
   - Battery drain → Optimize background sync

2. **User Experience Risks**
   - Complex statistics → Progressive disclosure
   - Learning curve → Interactive onboarding
   - Data loss → Regular auto-save and backups

## 📅 Timeline Summary

- **Weeks 1-2**: Setup and infrastructure
- **Weeks 3-4**: Roster management
- **Weeks 5-6**: Game creation
- **Weeks 7-8**: Play tracking
- **Weeks 9-10**: Statistics
- **Weeks 11-12**: Offline sync
- **Weeks 13-14**: Polish and testing

**Total Duration**: 14 weeks (3.5 months)

## 🎯 MVP Definition

The MVP includes:
1. Complete roster management
2. Game creation and lineup
3. Basic play tracking
4. Essential statistics
5. Full offline functionality
6. Automatic sync

Post-MVP features:
- Advanced statistics
- Team comparison
- Season management
- Export reports
- Multi-team support 