# TeamCoach UX/UI Specifications

## 🎯 Design Philosophy

TeamCoach follows a **"thumb-friendly"** design approach, optimizing for one-handed use during games. All critical actions are within easy reach of the thumb when holding a phone.

## 🎨 Visual Design System

### Color Scheme

#### Base Colors
```scss
// Core Palette
$primary: #team-custom;      // Customizable per team
$secondary: #team-custom;    // Customizable per team
$background: #F8FAFC;        // Light mode
$background-dark: #0F172A;   // Dark mode
$surface: #FFFFFF;           // Light mode
$surface-dark: #1E293B;      // Dark mode

// Semantic Colors
$success: #10B981;
$warning: #F59E0B;
$error: #EF4444;
$info: #3B82F6;

// Neutral Scale
$gray-50: #F9FAFB;
$gray-100: #F3F4F6;
$gray-200: #E5E7EB;
$gray-300: #D1D5DB;
$gray-400: #9CA3AF;
$gray-500: #6B7280;
$gray-600: #4B5563;
$gray-700: #374151;
$gray-800: #1F2937;
$gray-900: #111827;
```

### Typography Scale

```scss
// Font Family
$font-primary: 'Inter', system-ui, sans-serif;
$font-mono: 'JetBrains Mono', monospace; // For statistics

// Size Scale
$text-xs: 12px;    // Captions
$text-sm: 14px;    // Secondary text
$text-base: 16px;  // Body text
$text-lg: 18px;    // Subheadings
$text-xl: 20px;    // Section headers
$text-2xl: 24px;   // Page titles
$text-3xl: 30px;   // Large numbers
$text-4xl: 36px;   // Hero text

// Weight Scale
$font-normal: 400;
$font-medium: 500;
$font-semibold: 600;
$font-bold: 700;
```

### Spacing System

```scss
// Base unit: 4px
$space-1: 4px;
$space-2: 8px;
$space-3: 12px;
$space-4: 16px;
$space-5: 20px;
$space-6: 24px;
$space-8: 32px;
$space-10: 40px;
$space-12: 48px;
$space-16: 64px;
```

## 📱 Screen Specifications

### 1. Splash Screen

**Purpose**: Brand introduction and loading
**Duration**: 2 seconds max

```
┌─────────────────────────┐
│                         │
│                         │
│      [Team Logo]        │
│                         │
│      TeamCoach          │
│                         │
│    [Loading Bar]        │
│                         │
│                         │
└─────────────────────────┘
```

### 2. Home Dashboard

**Purpose**: Quick access to all main features
**Key Elements**:
- Active game card (if any)
- Quick stats summary
- Feature navigation

```
┌─────────────────────────┐
│ TeamCoach    [Settings] │
├─────────────────────────┤
│                         │
│ [Active Game Card]      │
│ vs Opponent - 3rd Inn   │
│ Score: 5-3              │
│ > Continue Game         │
│                         │
├─────────────────────────┤
│ Quick Actions           │
│                         │
│ [📋 Roster] [🎮 Games]  │
│ [📊 Stats]  [➕ New]    │
│                         │
├─────────────────────────┤
│ Recent Activity         │
│ • Game vs Tigers - W    │
│ • Added John Doe        │
│ • Game vs Bears - L     │
└─────────────────────────┘
```

### 3. Roster Management

#### 3.1 Roster List Screen

```
┌─────────────────────────┐
│ ← Roster      [+ Add]   │
├─────────────────────────┤
│ [Search bar]            │
│ [All] [Active] [Bench]  │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ [Avatar] #23        │ │
│ │ John Smith          │ │
│ │ P, 1B, OF          │ │
│ │ AVG: .325          │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │
│ │ [Avatar] #7         │ │
│ │ Maria Garcia        │ │
│ │ C, 3B              │ │
│ │ AVG: .298          │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

**Interactions**:
- Swipe right → Edit player
- Swipe left → Quick actions (bench/activate)
- Long press → Multi-select mode

#### 3.2 Add/Edit Player Screen

```
┌─────────────────────────┐
│ ← Add Player    [Save]  │
├─────────────────────────┤
│                         │
│     [Avatar Upload]     │
│      Tap to add photo   │
│                         │
│ Name *                  │
│ [___________________]   │
│                         │
│ Number *                │
│ [___________________]   │
│                         │
│ Positions               │
│ [P] [C] [1B] [2B] [3B] │
│ [SS] [LF] [CF] [RF]    │
│ [DH]                    │
│                         │
│ Batting                 │
│ (•) Right ( ) Left      │
│ ( ) Switch              │
│                         │
│ Throwing                │
│ (•) Right ( ) Left      │
│                         │
└─────────────────────────┘
```

### 4. Game Management

#### 4.1 Games List Screen

```
┌─────────────────────────┐
│ ← Games        [+ New]  │
├─────────────────────────┤
│ [All] [Active] [Done]   │
├─────────────────────────┤
│ Today                   │
│ ┌─────────────────────┐ │
│ │ vs Tigers    2:00PM │ │
│ │ Central Park        │ │
│ │ [Start Game]        │ │
│ └─────────────────────┘ │
│                         │
│ Yesterday               │
│ ┌─────────────────────┐ │
│ │ vs Bears      ✓ W   │ │
│ │ Final: 8-5          │ │
│ │ [View Details]      │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

#### 4.2 Create Game Screen

```
┌─────────────────────────┐
│ ← New Game     [Next]   │
├─────────────────────────┤
│                         │
│ Opponent *              │
│ [___________________]   │
│                         │
│ Date & Time             │
│ [📅 Select Date/Time]   │
│                         │
│ Location                │
│ [___________________]   │
│                         │
│ Home/Away               │
│ (•) Home ( ) Away       │
│                         │
│ Number of Innings       │
│ ( ) 7  (•) 9  ( ) Other │
│                         │
└─────────────────────────┘
```

#### 4.3 Lineup Builder Screen

```
┌─────────────────────────┐
│ ← Lineup      [Start]   │
├─────────────────────────┤
│ Batting Order           │
│                         │
│ 1. [≡] Maria Garcia    │
│ 2. [≡] John Smith      │
│ 3. [≡] Alex Johnson    │
│ 4. [≡] Sarah Davis     │
│ 5. [≡] Mike Wilson     │
│ 6. [≡] Lisa Brown      │
│ 7. [≡] Tom Anderson    │
│ 8. [≡] Emma Martinez   │
│ 9. [≡] Chris Lee       │
│                         │
├─────────────────────────┤
│ Bench                   │
│ • James Taylor         │
│ • Nancy White          │
│ [+ Add from Roster]     │
└─────────────────────────┘
```

**Drag & Drop Interaction**:
- Long press activates drag mode
- Visual feedback with elevation
- Drop zones highlighted
- Haptic feedback on drop

### 5. In-Game Experience

#### 5.1 Active Game Screen

```
┌─────────────────────────┐
│ vs Tigers    Inn 3 ▲   │
│ Home 5 - 3 Away    ⏱    │
├─────────────────────────┤
│ Now Batting:            │
│ #23 John Smith (2-2)    │
│                         │
│ ┌─────┬─────┬─────┐    │
│ │ HIT │ OUT │WALK │    │
│ └─────┴─────┴─────┘    │
│ ┌─────┬─────┬─────┐    │
│ │  K  │ SAC │ERROR│    │
│ └─────┴─────┴─────┘    │
│                         │
│ [🔄 Substitute]         │
│                         │
├─────────────────────────┤
│ On Deck: Maria Garcia   │
│ In Hole: Alex Johnson   │
└─────────────────────────┘
```

**Play Recording Flow**:
1. Tap play type (HIT)
2. Select result (Single, Double, etc.)
3. Mark RBIs if applicable
4. Auto-advance to next batter

#### 5.2 Hit Detail Screen (Modal)

```
┌─────────────────────────┐
│     Hit by John Smith   │
├─────────────────────────┤
│                         │
│ Result:                 │
│ [Single] [Double]       │
│ [Triple] [Home Run]     │
│                         │
│ RBI: [−] 0 [+]         │
│                         │
│ Runs Scored:            │
│ □ #7 Maria (3rd base)   │
│ □ #14 Alex (2nd base)   │
│                         │
│ [Cancel]    [Record]    │
└─────────────────────────┘
```

### 6. Statistics Views

#### 6.1 Team Stats Screen

```
┌─────────────────────────┐
│ ← Team Stats   [Export] │
├─────────────────────────┤
│ [Season] [Last 10] [All]│
├─────────────────────────┤
│ Team Summary            │
│ Record: 15-8            │
│ Avg: .287  Runs: 142    │
│                         │
│ Top Performers          │
│ ┌─────────────────────┐ │
│ │ Batting Average     │ │
│ │ 1. Smith    .342    │ │
│ │ 2. Garcia   .325    │ │
│ │ 3. Johnson  .310    │ │
│ └─────────────────────┘ │
│                         │
│ [View All Players →]    │
└─────────────────────────┘
```

## 🎮 Interaction Patterns

### Touch Targets
- Minimum size: 48x48px
- Spacing between targets: 8px minimum
- Primary actions: Bottom 1/3 of screen

### Gestures
- **Tap**: Primary selection
- **Long Press**: Context menu / Drag mode
- **Swipe**: Quick actions / Navigation
- **Pinch**: Zoom (statistics charts)
- **Pull to Refresh**: Update data

### Feedback Mechanisms
1. **Visual**
   - Touch ripples on all tappable elements
   - Color state changes
   - Loading spinners
   - Progress bars

2. **Haptic** (iOS/supported Android)
   - Light: Selection
   - Medium: Action confirmation
   - Heavy: Error or important action

3. **Audio** (Optional)
   - Success chime
   - Error buzz
   - Play recorded bell

### Loading States

```
// Skeleton screens for lists
┌─────────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░░░  │
│ ░░░░░░░░░░░░░░░░       │
│ ░░░░░░░░░░░            │
└─────────────────────────┘

// Inline loaders for actions
[Recording...] (with spinner)

// Full screen for initial loads
Center spinner with logo
```

### Empty States

```
┌─────────────────────────┐
│                         │
│        [Icon]           │
│                         │
│   No players yet        │
│                         │
│ Add your first player   │
│ to get started          │
│                         │
│   [Add Player]          │
│                         │
└─────────────────────────┘
```

## 🔄 Navigation Flow

### Bottom Navigation Bar
```
┌─────────────────────────┐
│                         │
│     Main Content        │
│                         │
├─────────────────────────┤
│  Home  Roster  Games    │
│  Stats   More           │
└─────────────────────────┘
```

### Navigation Hierarchy
```
Home
├── Active Game → Game Screen
├── Quick Stats → Stats Screen
└── Recent Activity → Detail Views

Roster
├── Player List
├── Add Player
└── Player Detail → Stats/History

Games
├── Games List
├── Create Game → Lineup → Active Game
└── Game Detail → Box Score

Stats
├── Team Overview
├── Player Rankings
└── Season Summary
```

## 📊 Component Library

### Buttons

```dart
// Primary Button
ShadButton.filled(
  onPressed: () {},
  child: Text('Start Game'),
  size: ShadButtonSize.lg,
)

// Secondary Button
ShadButton.outline(
  onPressed: () {},
  child: Text('Cancel'),
)

// Icon Button
ShadButton.ghost(
  onPressed: () {},
  icon: Icon(Icons.add),
  size: ShadButtonSize.sm,
)
```

### Cards

```dart
// Player Card
ShadCard(
  padding: EdgeInsets.all(16),
  child: Row(
    children: [
      Avatar(),
      PlayerInfo(),
      StatsPreview(),
    ],
  ),
)

// Game Card
ShadCard(
  variant: ShadCardVariant.filled,
  child: GameSummary(),
)
```

### Form Elements

```dart
// Text Input
ShadInput(
  placeholder: 'Player name',
  prefix: Icon(Icons.person),
)

// Select
ShadSelect<String>(
  placeholder: 'Select position',
  options: positions,
  onChanged: (value) {},
)

// Toggle
ShadSwitch(
  value: isActive,
  onChanged: (value) {},
)
```

## 🌐 Responsive Design

### Breakpoints
- Mobile: < 600px (primary target)
- Tablet: 600px - 1024px
- Desktop: > 1024px (future consideration)

### Orientation Handling
- **Portrait**: Default layouts
- **Landscape**: Side-by-side panels where appropriate
- Game screen: Larger play buttons
- Stats: More columns in tables

## ♿ Accessibility

### Requirements
1. **Font Scaling**: Support up to 200%
2. **Color Contrast**: WCAG AA minimum
3. **Screen Readers**: Full semantic markup
4. **Focus Indicators**: Visible keyboard navigation
5. **Touch Targets**: 48x48px minimum

### Accessibility Features
```dart
Semantics(
  label: 'Add new player',
  button: true,
  child: IconButton(...),
)
```

## 🔔 Notification Design

### In-App Notifications

```
┌─────────────────────────┐
│ ✅ Player added         │
│    John Smith (#23)     │
└─────────────────────────┘

┌─────────────────────────┐
│ ⚠️  No internet         │
│ Changes saved locally   │
└─────────────────────────┘
```

### Sync Status Bar

```
┌─────────────────────────┐
│ 🔄 Syncing... (3 items) │
└─────────────────────────┘
```

## 📐 Animation Specifications

### Timing Functions
```scss
$ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
$ease-out: cubic-bezier(0.0, 0, 0.2, 1);
$ease-in: cubic-bezier(0.4, 0, 1, 1);
```

### Duration Scale
```scss
$duration-fast: 150ms;     // Micro interactions
$duration-normal: 300ms;   // Most transitions
$duration-slow: 500ms;     // Page transitions
$duration-slower: 800ms;   // Complex animations
```

### Common Animations
1. **Page Transitions**: Slide + Fade (300ms)
2. **List Items**: Stagger fade-in (50ms delay)
3. **Buttons**: Scale on press (150ms)
4. **Cards**: Elevation change (300ms)
5. **Loading**: Rotation (1000ms infinite)

## 🎯 Performance Guidelines

### Image Handling
- Player avatars: 150x150px max, WebP format
- Team logos: 300x300px max, PNG with transparency
- Lazy loading for lists
- Memory cache: 50 images max

### List Optimization
- Virtual scrolling for > 50 items
- Pagination for statistics
- Debounced search (300ms)
- Optimistic UI updates

### Offline Performance
- Service worker for web
- SQLite for mobile
- Queue sync operations
- Batch API calls

## 🔐 Security & Privacy

### Data Protection
- Local encryption for sensitive data
- No passwords stored in plain text
- Secure API communication (HTTPS)
- Token refresh mechanism

### Privacy Features
- Optional player photos
- Export data ownership
- Clear data option
- GDPR compliance ready

## 📱 Platform-Specific Considerations

### iOS
- Safe area handling
- iOS-style back swipes
- Haptic feedback API
- SF Symbols where appropriate

### Android
- Material ripple effects
- Back button handling
- Status bar theming
- Edge-to-edge design

### Tablet Optimizations
- Master-detail layouts
- Floating action buttons
- Multi-column grids
- Keyboard shortcuts

## 🚀 Future Enhancements

### Phase 2 Features
1. **Advanced Stats**
   - Spray charts
   - Hot zones
   - Trend analysis

2. **Social Features**
   - Team chat
   - Share highlights
   - Public team pages

3. **Coaching Tools**
   - Practice planning
   - Drill library
   - Video analysis

4. **League Integration**
   - Schedule import
   - Standings
   - Tournament brackets 