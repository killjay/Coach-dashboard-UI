# Coach-Client Design & Data Flow Documentation

## Table of Contents
1. [System Architecture Overview](#system-architecture-overview)
2. [Database Structure (Firestore Collections)](#database-structure-firestore-collections)
3. [Coach-Client Relationship Model](#coach-client-relationship-model)
4. [Data Flow Diagrams](#data-flow-diagrams)
5. [Key Workflows](#key-workflows)
6. [Real-time Data Synchronization](#real-time-data-synchronization)
7. [Security & Access Control](#security--access-control)

---

## System Architecture Overview

### Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Auth, Storage)
- **State Management**: Provider Pattern
- **Data Serialization**: json_annotation with build_runner

### Architecture Pattern
The application follows a **layered architecture**:
```
UI Layer (Screens/Widgets)
    ↓
State Management Layer (Providers)
    ↓
Service Layer (Business Logic)
    ↓
Data Access Layer (FirestoreService)
    ↓
Firebase Firestore Database
```

---

## Database Structure (Firestore Collections)

### Core Collections

#### 1. `users` Collection
**Purpose**: Base user authentication and profile data

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "email": "string",
  "name": "string",
  "role": "coach" | "client",
  "createdAt": "Timestamp",
  "profileImageUrl": "string (optional)"
}
```

**Access Rules**:
- Users can read/write their own document
- Document ID = Firebase Auth UID

---

#### 2. `coaches` Collection
**Purpose**: Coach-specific data and client relationships

**Document Structure**:
```json
{
  "id": "string (document ID = user.id)",
  "email": "string",
  "name": "string",
  "clientIds": ["string array"],
  "settings": {
    "leaderboardSettings": {...},
    "notificationSettings": {...}
  },
  "createdAt": "Timestamp"
}
```

**Access Rules**:
- Coaches can read/write their own document
- Used to track which clients belong to which coach

**Relationships**:
- `clientIds`: Array of client document IDs
- Links to `clients` collection via `coachId` field

---

#### 3. `clients` Collection
**Purpose**: Client-specific data, onboarding, and coach linkage

**Document Structure**:
```json
{
  "id": "string (document ID = user.id)",
  "email": "string",
  "name": "string",
  "coachId": "string (optional, links to coaches collection)",
  "onboardingCompleted": "boolean",
  "demographics": {
    "dateOfBirth": "Timestamp",
    "gender": "string",
    "height": "number (cm)",
    "weight": "number (kg)"
  },
  "healthData": {
    "conditions": ["string array"],
    "medications": "string",
    "injuries": "string"
  },
  "lifestyleGoals": {
    "activityLevel": "string",
    "fitnessGoals": ["string array"],
    "targetWeight": "number (optional)"
  },
  "createdAt": "Timestamp",
  "profileImageUrl": "string (optional)"
}
```

**Access Rules**:
- Clients can read/write their own document
- Coaches can read their clients' documents (if `coachId` matches)

**Key Fields**:
- `coachId`: Establishes coach-client relationship
- `onboardingCompleted`: Tracks onboarding progress

---

### Workout Management Collections

#### 4. `workout_templates` Collection
**Purpose**: Reusable workout templates created by coaches

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "name": "string",
  "description": "string (optional)",
  "exercises": [
    {
      "id": "string",
      "exerciseName": "string",
      "sets": "number",
      "reps": "string (e.g., '8-10')",
      "weight": "number (optional, prescribed)",
      "rpe": "number (optional, 1-10)",
      "notes": "string (optional)",
      "restSeconds": "number (optional)"
    }
  ],
  "createdBy": "string (coachId)",
  "createdAt": "Timestamp"
}
```

**Access Rules**:
- Public read (all authenticated users)
- Write: Only the coach who created it (`createdBy`)

**Data Flow**:
1. Coach creates template → Saved to `workout_templates/{templateId}`
2. Coach assigns template → Creates document in `assigned_workouts`
3. Client views assigned workout → Reads from `assigned_workouts`

---

#### 5. `assigned_workouts` Collection
**Purpose**: Links workout templates to specific clients with dates

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "templateId": "string (links to workout_templates)",
  "clientId": "string (links to clients)",
  "coachId": "string (links to coaches)",
  "startDate": "Timestamp",
  "endDate": "Timestamp (optional)",
  "status": "pending" | "in_progress" | "completed" | "skipped",
  "assignedAt": "Timestamp"
}
```

**Access Rules**:
- Read: Client (if `clientId` matches) OR Coach (if `coachId` matches)
- Write: Only coaches (must be the assigning coach)

**Data Flow**:
1. Coach assigns workout → Creates `assigned_workouts/{assignmentId}`
2. Client sees assignment → Reads from `assigned_workouts` filtered by `clientId`
3. Client logs workout → Creates document in `workout_logs` with `assignedWorkoutId`

---

#### 6. `workout_logs` Collection
**Purpose**: Actual workout sessions logged by clients

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "assignedWorkoutId": "string (links to assigned_workouts)",
  "clientId": "string (links to clients)",
  "date": "Timestamp",
  "exercises": [
    {
      "id": "string",
      "exerciseName": "string",
      "sets": [
        {
          "setNumber": "number",
          "weight": "number (optional)",
          "reps": "number (optional)",
          "rpe": "number (optional)",
          "completed": "boolean"
        }
      ]
    }
  ],
  "completed": "boolean",
  "loggedAt": "Timestamp"
}
```

**Access Rules**:
- Read: Client (if `clientId` matches) OR Coach (if client's `coachId` matches)
- Write: Only clients (must match `clientId`)

**Data Flow**:
1. Client completes workout → Creates `workout_logs/{logId}`
2. Coach views client progress → Reads from `workout_logs` filtered by `clientId`
3. Analytics calculated → Aggregates data from `workout_logs` for trends

---

### Diet Management Collections

#### 7. `diet_plans` Collection
**Purpose**: Reusable diet plans created by coaches

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "name": "string",
  "description": "string (optional)",
  "calories": "number",
  "protein": "number (grams)",
  "carbs": "number (grams)",
  "fat": "number (grams)",
  "createdBy": "string (coachId)",
  "createdAt": "Timestamp"
}
```

**Access Rules**:
- Public read (all authenticated users)
- Write: Only the coach who created it (`createdBy`)

---

#### 8. `assigned_diets` Collection
**Purpose**: Links diet plans to specific clients

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "planId": "string (links to diet_plans)",
  "clientId": "string (links to clients)",
  "coachId": "string (links to coaches)",
  "startDate": "Timestamp",
  "endDate": "Timestamp (optional)",
  "assignedAt": "Timestamp"
}
```

**Access Rules**:
- Read: Client (if `clientId` matches) OR Coach (if `coachId` matches)
- Write: Only coaches

---

#### 9. `food_logs` Collection
**Purpose**: Daily food intake logged by clients

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "clientId": "string (links to clients)",
  "date": "Timestamp",
  "meals": [
    {
      "name": "string",
      "calories": "number",
      "protein": "number (grams)",
      "carbs": "number (grams)",
      "fat": "number (grams)",
      "photoUrl": "string (optional, Firebase Storage URL)"
    }
  ],
  "totalCalories": "number",
  "totalProtein": "number",
  "totalCarbs": "number",
  "totalFat": "number",
  "loggedAt": "Timestamp"
}
```

**Access Rules**:
- Read: Client (if `clientId` matches) OR Coach (if client's `coachId` matches)
- Write: Only clients

**Data Flow**:
1. Client logs food → Creates/updates `food_logs/{logId}` for that date
2. Daily totals calculated → Aggregates all meals for the day
3. Coach views compliance → Compares `totalCalories` vs assigned diet plan

---

### Tracking Collections

#### 10. `body_metrics` Collection
**Purpose**: Body measurements tracked over time

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "clientId": "string (links to clients)",
  "date": "Timestamp",
  "weight": "number (kg, optional)",
  "bodyFat": "number (percentage, optional)",
  "waist": "number (cm, optional)",
  "chest": "number (cm, optional)",
  "hips": "number (cm, optional)",
  "bmi": "number (calculated, optional)",
  "loggedAt": "Timestamp"
}
```

**Access Rules**:
- Read: Client (if `clientId` matches) OR Coach (if client's `coachId` matches)
- Write: Only clients

**Data Flow**:
1. Client logs metrics → Creates `body_metrics/{metricId}`
2. Analytics service aggregates → Creates trend graphs
3. Coach views progress → Reads all metrics for client, sorted by date

---

#### 11. `water_logs` Collection
**Purpose**: Daily water intake tracking

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "clientId": "string (links to clients)",
  "date": "Timestamp",
  "amount": "number (liters)",
  "loggedAt": "Timestamp"
}
```

**Access Rules**:
- Read/Write: Only the client (`clientId` must match)

---

#### 12. `sleep_logs` Collection
**Purpose**: Sleep duration and quality tracking

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "clientId": "string (links to clients)",
  "date": "Timestamp",
  "duration": "number (hours)",
  "efficiency": "number (percentage, optional)",
  "notes": "string (optional)",
  "loggedAt": "Timestamp"
}
```

**Access Rules**:
- Read/Write: Only the client (`clientId` must match)

---

### Analytics & Progress Collections

#### 13. `progress_photos` Collection
**Purpose**: Visual progress tracking photos

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "clientId": "string (links to clients)",
  "date": "Timestamp",
  "photoUrl": "string (Firebase Storage URL)",
  "notes": "string (optional)",
  "uploadedAt": "Timestamp"
}
```

**Access Rules**:
- Read: Client (if `clientId` matches) OR Coach (if client's `coachId` matches)
- Write: Only clients

**Storage**:
- Images stored in Firebase Storage: `progress_photos/{clientId}/{photoId}.jpg`
- URL stored in Firestore document

---

#### 14. `personal_records` Collection
**Purpose**: Personal best achievements

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "clientId": "string (links to clients)",
  "exerciseName": "string",
  "metric": "max_weight" | "max_volume" | "max_reps",
  "value": "number",
  "date": "Timestamp",
  "workoutLogId": "string (links to workout_logs, optional)"
}
```

**Access Rules**:
- Read/Write: Only the client (`clientId` must match)

**Data Flow**:
- Calculated automatically from `workout_logs` when new PR detected
- Displayed in Personal Records screen

---

### Gamification Collections

#### 15. `leaderboards` Collection
**Purpose**: Coach-specific leaderboard configurations

**Document Structure**:
```json
{
  "id": "string (document ID = coachId)",
  "enabledMetrics": [
    "daily_steps" | "monthly_steps" | "workout_consistency" | "progress_score"
  ],
  "entries": [
    {
      "clientId": "string",
      "name": "string",
      "score": "number",
      "metric": "string",
      "rank": "number",
      "date": "Timestamp",
      "isAnonymous": "boolean"
    }
  ],
  "updatedAt": "Timestamp"
}
```

**Access Rules**:
- Read/Write: Only the coach (`coachId` must match)

**Data Flow**:
1. Coach enables leaderboard → Updates `leaderboards/{coachId}`
2. Analytics service calculates scores → Updates `entries` array
3. Clients view leaderboard → Reads from `leaderboards/{coachId}`

---

#### 16. `badges` Collection
**Purpose**: Available badges in the system (system-wide)

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "name": "string",
  "description": "string",
  "iconUrl": "string (Firebase Storage URL)",
  "criteria": {
    "type": "workout_count" | "streak" | "goal_achievement",
    "value": "number"
  }
}
```

**Access Rules**:
- Public read (all authenticated users)
- Write: Admin only (currently disabled in security rules)

---

#### 17. `user_badges` Collection
**Purpose**: Badges earned by users

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "userId": "string (links to users)",
  "badgeId": "string (links to badges)",
  "earnedAt": "Timestamp"
}
```

**Access Rules**:
- Read/Write: Only the user (`userId` must match)

---

### Invitation System

#### 18. `invitations` Collection
**Purpose**: Coach-generated client invitations

**Document Structure**:
```json
{
  "id": "string (document ID)",
  "coachId": "string (links to coaches)",
  "code": "string (unique invitation code)",
  "email": "string (optional, if sent via email)",
  "createdAt": "Timestamp",
  "expiresAt": "Timestamp",
  "used": "boolean",
  "usedBy": "string (clientId, optional)",
  "usedAt": "Timestamp (optional)"
}
```

**Access Rules**:
- Read: Coach (if `coachId` matches) OR if invitation not used
- Write: Only coaches (for creation)
- Update: Coach OR client (when accepting invitation)

**Data Flow**:
1. Coach creates invitation → Creates `invitations/{inviteId}` with unique code
2. Client accepts invitation → Updates `invitations/{inviteId}` (sets `used`, `usedBy`, `usedAt`)
3. Client's `coachId` updated → Updates `clients/{clientId}` with `coachId`
4. Coach's `clientIds` updated → Updates `coaches/{coachId}` with new client ID

---

## Coach-Client Relationship Model

### Relationship Establishment

```
┌─────────────┐
│   Coach     │
│ (coaches/{  │
│  coachId})  │
└──────┬──────┘
       │
       │ clientIds: ["client1", "client2", ...]
       │
       ▼
┌─────────────┐
│   Client    │
│ (clients/{  │
│  clientId})  │
└─────────────┘
       │
       │ coachId: "coachId"
       │
```

**Key Points**:
- **Bidirectional Link**: 
  - `coaches/{coachId}.clientIds` → Array of client IDs
  - `clients/{clientId}.coachId` → Single coach ID
- **Establishment**: Via invitation system
- **Access Control**: Coach can read all client data where `clientId` is in their `clientIds` array

---

## Data Flow Diagrams

### 1. Client Onboarding Flow

```
User Signs Up
    ↓
Firebase Auth creates user
    ↓
UserService.createUser() → users/{userId}
    ↓
User selects "Client" role
    ↓
ClientModel.fromUserModel() → clients/{userId}
    ↓
Onboarding Screens:
    ↓
1. Demographics Screen
   → Updates clients/{userId}.demographics
    ↓
2. Health Screening Screen
   → Updates clients/{userId}.healthData
    ↓
3. Lifestyle & Goals Screen
   → Updates clients/{userId}.lifestyleGoals
    ↓
onboardingCompleted = true
    ↓
Client Dashboard (Today View)
```

**Database Writes**:
- `users/{userId}` - Created once
- `clients/{userId}` - Created, then updated 3 times during onboarding
- Total: 4 write operations

---

### 2. Coach Invites Client Flow

```
Coach taps "Invite Clients"
    ↓
InvitationService.createInvitation()
    ↓
Creates invitations/{inviteId}:
  - coachId: current coach
  - code: unique code (e.g., "ABC123")
  - expiresAt: 30 days from now
  - used: false
    ↓
Coach shares link/code
    ↓
Client enters code OR clicks link
    ↓
InvitationService.acceptInvitation(code)
    ↓
1. Validates invitation (not used, not expired)
    ↓
2. Updates invitations/{inviteId}:
   - used: true
   - usedBy: clientId
   - usedAt: now
    ↓
3. Updates clients/{clientId}:
   - coachId: coachId
    ↓
4. Updates coaches/{coachId}:
   - clientIds: [...existing, clientId]
    ↓
Client now linked to Coach
```

**Database Operations**:
- Read: `invitations/{inviteId}` (validate)
- Update: `invitations/{inviteId}` (mark used)
- Update: `clients/{clientId}` (set coachId)
- Update: `coaches/{coachId}` (add to clientIds)
- Total: 1 read + 3 updates

---

### 3. Coach Assigns Workout Flow

```
Coach: Plans Overview
    ↓
Coach creates/selects workout template
    ↓
WorkoutService.createTemplate()
    ↓
Creates workout_templates/{templateId}:
  - createdBy: coachId
  - exercises: [...]
    ↓
Coach: Assign Plans Screen
    ↓
Coach selects:
  - Template: workout_templates/{templateId}
  - Clients: [clientId1, clientId2, ...]
  - Start Date: date
    ↓
For each selected client:
  WorkoutService.assignWorkout()
    ↓
Creates assigned_workouts/{assignmentId}:
  - templateId: templateId
  - clientId: clientId
  - coachId: coachId
  - startDate: date
  - status: "pending"
    ↓
Client sees assignment in "Assigned Workouts List"
```

**Database Operations**:
- Create: `workout_templates/{templateId}` (if new template)
- Create: `assigned_workouts/{assignmentId}` (one per client)
- Total: 1 + N writes (N = number of clients)

---

### 4. Client Logs Workout Flow

```
Client: Assigned Workouts List
    ↓
Client taps "Start" on assigned workout
    ↓
Client: Workout Details & Logging Screen
    ↓
Client logs sets for each exercise:
  - Weight, Reps, RPE for each set
    ↓
Client taps "Complete Workout"
    ↓
WorkoutService.logWorkout()
    ↓
Creates workout_logs/{logId}:
  - assignedWorkoutId: assignmentId
  - clientId: clientId
  - date: today
  - exercises: [ExerciseLogModel...]
  - completed: true
    ↓
Updates assigned_workouts/{assignmentId}:
  - status: "completed"
    ↓
Analytics Service calculates:
  - Personal Records (if new PR)
  - Compliance score
  - Progress trends
```

**Database Operations**:
- Create: `workout_logs/{logId}`
- Update: `assigned_workouts/{assignmentId}` (status)
- Create: `personal_records/{recordId}` (if PR achieved)
- Total: 2-3 writes

---

### 5. Client Logs Food Flow

```
Client: Today View → Calorie Goal Card
    ↓
Client taps "+" button
    ↓
Client: Daily Macro Goals Screen
    ↓
Client taps "Log Food"
    ↓
Client: Manual Food Logging OR Food Photo Log
    ↓
DietService.logFood()
    ↓
Reads existing food_logs/{logId} for today
  (if exists)
    ↓
If exists:
  Updates food_logs/{logId}:
    - meals: [...existing, newMeal]
    - totalCalories: recalculated
    - totalProtein: recalculated
    - totalCarbs: recalculated
    - totalFat: recalculated
    ↓
If not exists:
  Creates food_logs/{logId}:
    - clientId: clientId
    - date: today
    - meals: [newMeal]
    - totals: calculated
    ↓
Client: Today View updates
  (shows new calorie progress)
```

**Database Operations**:
- Read: `food_logs/{logId}` (check if exists for today)
- Create OR Update: `food_logs/{logId}`
- Total: 1 read + 1 write

---

### 6. Coach Views Client Analytics Flow

```
Coach: Client List View
    ↓
Coach taps client card
    ↓
Coach: Client Profile View
    ↓
Coach taps "Data" tab
    ↓
Coach: Client Trend Analysis
    ↓
AnalyticsService.getExerciseAnalytics()
    ↓
1. Reads workout_logs (filtered by clientId)
    ↓
2. Filters by exercise name
    ↓
3. Calculates metrics:
   - Max weight over time
   - Total volume over time
   - Estimated 1RM over time
   - Adherence % (actual vs prescribed)
    ↓
4. Returns aggregated data
    ↓
UI displays line graph
```

**Database Operations**:
- Read: `workout_logs` (query: `clientId == X`)
- Read: `assigned_workouts` (query: `clientId == X`)
- Total: 2 queries

---

### 7. Compliance Dashboard Flow

```
Coach: Analytics Tab
    ↓
Coach: Compliance Dashboard
    ↓
AnalyticsService.getComplianceMetrics()
    ↓
For each client:
  1. Reads assigned_workouts (filtered by coachId)
  2. Reads workout_logs (for each client)
  3. Calculates:
     - Workout compliance: (completed / assigned) × 100
     - Nutrition compliance: (actual calories / target) × 100
     - Overall compliance: weighted average
    ↓
Aggregates across all clients:
  - Overall compliance: average of all clients
  - Workouts logged: % of clients who logged today
    ↓
Displays:
  - Summary cards
  - Trend chart (last 7 days)
  - Client list sorted by compliance
```

**Database Operations**:
- Read: `clients` (query: `coachId == X`)
- Read: `assigned_workouts` (query: `coachId == X`)
- Read: `workout_logs` (query: `clientId IN [clientIds]`)
- Read: `food_logs` (query: `clientId IN [clientIds]`)
- Total: 4 queries (can be optimized with composite queries)

---

## Key Workflows

### Workflow 1: Complete Client Journey

```
1. SIGN UP
   User → AuthService.signUp() → Firebase Auth
   User → UserService.createUser() → users/{userId}

2. ROLE SELECTION
   User selects "Client" → ClientModel created → clients/{userId}

3. ONBOARDING
   Demographics → clients/{userId}.demographics
   Health Screening → clients/{userId}.healthData
   Lifestyle Goals → clients/{userId}.lifestyleGoals
   onboardingCompleted = true

4. INVITATION ACCEPTANCE
   Coach sends invitation → invitations/{inviteId}
   Client accepts → clients/{userId}.coachId = coachId
   → coaches/{coachId}.clientIds += userId

5. PLAN ASSIGNMENT
   Coach assigns workout → assigned_workouts/{assignmentId}
   Coach assigns diet → assigned_diets/{assignmentId}

6. DAILY TRACKING
   Client logs workout → workout_logs/{logId}
   Client logs food → food_logs/{logId}
   Client logs water → water_logs/{logId}
   Client logs metrics → body_metrics/{metricId}

7. COACH MONITORING
   Coach views compliance → Analytics calculated from logs
   Coach views trends → Aggregated data from logs
```

---

### Workflow 2: Real-time Updates

**Client Side**:
```dart
// Client subscribes to assigned workouts
WorkoutService.streamAssignedWorkouts(clientId)
  → Listens to assigned_workouts collection
  → UI updates automatically when coach assigns new workout
```

**Coach Side**:
```dart
// Coach subscribes to client list
UserService.streamClientList(coachId)
  → Listens to clients collection
  → UI updates when new client accepts invitation

// Coach subscribes to client logs
WorkoutService.streamWorkoutHistory(clientId)
  → Listens to workout_logs collection
  → UI updates when client logs workout
```

---

## Real-time Data Synchronization

### Stream-Based Architecture

All services support real-time streams using Firestore's `snapshots()`:

**Example: Client Today View**
```dart
// Real-time assigned workouts
WorkoutProvider.streamAssignedWorkouts()
  → WorkoutService.streamAssignedWorkouts(clientId)
  → FirestoreService.streamQuery('assigned_workouts', whereField: 'clientId')
  → UI automatically updates when coach assigns workout

// Real-time food logs
DietProvider.streamFoodLogs()
  → DietService.streamFoodLogs(clientId)
  → FirestoreService.streamQuery('food_logs', whereField: 'clientId')
  → UI automatically updates when client logs food
```

**Benefits**:
- No manual refresh needed
- Instant updates across devices
- Reduced server load (push vs pull)

---

## Security & Access Control

### Firestore Security Rules Summary

| Collection | Read Access | Write Access |
|------------|-------------|--------------|
| `users` | Own document | Own document |
| `coaches` | Own document | Own document |
| `clients` | Own OR coach's client | Own document |
| `workout_templates` | All authenticated | Creator only |
| `assigned_workouts` | Own OR coach's client | Coach only |
| `workout_logs` | Own OR coach's client | Own only |
| `diet_plans` | All authenticated | Creator only |
| `assigned_diets` | Own OR coach's client | Coach only |
| `food_logs` | Own OR coach's client | Own only |
| `body_metrics` | Own OR coach's client | Own only |
| `water_logs` | Own only | Own only |
| `sleep_logs` | Own only | Own only |
| `progress_photos` | Own OR coach's client | Own only |
| `personal_records` | Own only | Own only |
| `leaderboards` | Coach only | Coach only |
| `invitations` | Coach OR unused | Coach OR accept |
| `badges` | All authenticated | Admin only |
| `user_badges` | Own only | Own only |

### Access Pattern Examples

**Coach Reading Client Data**:
```javascript
// Security rule checks:
1. Is user authenticated? → Yes
2. Is user a coach? → Check exists(/databases/$(database)/documents/coaches/$(userId))
3. Is client linked to coach? → Check clients/{clientId}.coachId == userId
4. Allow read → Yes
```

**Client Writing Own Log**:
```javascript
// Security rule checks:
1. Is user authenticated? → Yes
2. Does log belong to user? → Check resource.data.clientId == userId
3. Allow write → Yes
```

---

## Data Aggregation & Analytics

### Compliance Score Calculation

**Workout Compliance**:
```
For each assigned workout:
  - Check if workout_log exists for assigned date
  - If exists and completed: count as completed
  - If not exists or incomplete: count as missed

Compliance = (completed / total assigned) × 100
```

**Nutrition Compliance**:
```
For each day:
  - Get assigned_diet for client
  - Get food_log for that day
  - Calculate: (actual calories / target calories) × 100
  - Cap at 100% (over-eating doesn't increase compliance)

Average = Sum of daily compliance / number of days
```

**Overall Compliance**:
```
Weighted average:
  - Workout compliance: 50% weight
  - Nutrition compliance: 30% weight
  - Other metrics (water, sleep): 20% weight

Overall = (Workout × 0.5) + (Nutrition × 0.3) + (Other × 0.2)
```

---

### Personal Records Detection

**Algorithm**:
```dart
For each workout_log:
  For each exercise in log:
    Calculate max weight for exercise
    Calculate total volume for exercise
    Calculate estimated 1RM
    
    Check existing personal_records for exercise:
      If new max weight > existing max weight:
        Create/update personal_records/{recordId}
          - metric: "max_weight"
          - value: new max weight
          - date: workout date
```

---

## Performance Considerations

### Indexing Strategy

**Required Composite Indexes** (Firestore):
1. `assigned_workouts`: `coachId` + `startDate` (descending)
2. `workout_logs`: `clientId` + `date` (descending)
3. `food_logs`: `clientId` + `date` (descending)
4. `body_metrics`: `clientId` + `date` (descending)
5. `clients`: `coachId` + `createdAt` (descending)

### Query Optimization

**Batch Reads**:
- When loading client list, use `getAll()` for multiple client documents
- When loading workout history, limit to last 30 days initially

**Caching Strategy**:
- Templates and plans cached in Provider state
- Recent logs cached to reduce reads
- Images cached using `cached_network_image`

---

## Data Consistency

### Transactional Operations

**Invitation Acceptance** (should use transaction):
```dart
Firestore.instance.runTransaction((transaction) async {
  // 1. Mark invitation as used
  transaction.update(invitationRef, {'used': true, 'usedBy': clientId});
  
  // 2. Link client to coach
  transaction.update(clientRef, {'coachId': coachId});
  
  // 3. Add client to coach's list
  transaction.update(coachRef, {
    'clientIds': FieldValue.arrayUnion([clientId])
  });
});
```

**Note**: Current implementation uses separate updates. Should be wrapped in transaction for production.

---

## Summary

### Key Data Flow Principles

1. **Separation of Concerns**:
   - Templates/Plans: Created by coaches, reusable
   - Assignments: Links templates to clients with dates
   - Logs: Actual data entered by clients

2. **Real-time Updates**:
   - All collections support streaming
   - UI automatically updates when data changes
   - No manual refresh needed

3. **Security First**:
   - Firestore rules enforce access at database level
   - Clients can only write their own logs
   - Coaches can read their clients' data

4. **Scalability**:
   - Collections designed for efficient queries
   - Composite indexes for common query patterns
   - Batch operations where possible

### Database Collections Count

- **Total Collections**: 18
- **User Management**: 3 (users, coaches, clients)
- **Workout Management**: 3 (templates, assignments, logs)
- **Diet Management**: 3 (plans, assignments, logs)
- **Tracking**: 3 (body_metrics, water_logs, sleep_logs)
- **Analytics**: 2 (progress_photos, personal_records)
- **Gamification**: 3 (leaderboards, badges, user_badges)
- **System**: 1 (invitations)

This architecture provides a robust, scalable foundation for the coach-client fitness platform.

