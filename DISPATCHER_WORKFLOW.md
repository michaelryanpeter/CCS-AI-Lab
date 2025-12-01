# SkyRescue: 911 Dispatcher-Initiated Drone Launch System

## Workflow Overview

```
Cardiac Arrest Emergency
        ↓
   911 Call Received
        ↓
Dispatcher Confirms Location
        ↓
[DISPATCHER LAUNCHES SKYRESCUE DRONE] ← YOUR SYSTEM
        ↓
Autonomous Flight (AI-Controlled)
        ↓
AED Delivery at Scene
        ↓
Bystander/EMS Uses AED
```

---

## System Architecture: Dispatcher-Centric

### 1. Dispatcher Console (Primary UI)

**Web-Based Dispatch Interface** (Not drone operator interface)

```
┌─────────────────────────────────────────────────┐
│  911 DISPATCH CENTER - SkyRescue Integration   │
├─────────────────────────────────────────────────┤
│                                                  │
│  ACTIVE CALL: Cardiac Arrest                    │
│  Location: 123 Main St, Boston MA               │
│  Caller: Witness (on scene)                     │
│  Coordinates: 42.3601°N, 71.0589°W              │
│                                                  │
│  ┌─────────────────────────────────────────┐   │
│  │  🚁 SKYRESCUE AVAILABLE                 │   │
│  │                                          │   │
│  │  Nearest Drone: Unit Alpha-3            │   │
│  │  Distance: 2.1 miles                    │   │
│  │  ETA: 2 min 15 sec                      │   │
│  │  Battery: 87% (40 min flight time)      │   │
│  │  Status: Ready                           │   │
│  │                                          │   │
│  │  Weather: Clear, 15mph wind WSW         │   │
│  │  Flight Risk: LOW                       │   │
│  │                                          │   │
│  │  [ LAUNCH SKYRESCUE ]  [Cancel]         │   │
│  └─────────────────────────────────────────┘   │
│                                                  │
│  Ambulance Dispatched: Unit E-12                │
│  ETA: 8 minutes                                 │
│                                                  │
└─────────────────────────────────────────────────┘
```

### 2. Dispatch Decision Support (AI Backend)

**AI helps dispatcher make the launch decision:**

```javascript
// Backend AI Service
POST /api/emergency/assess

Request:
{
  "emergency_type": "cardiac_arrest",
  "location": {
    "latitude": 42.3601,
    "longitude": -71.0589,
    "address": "123 Main St, Boston MA"
  },
  "caller_info": {
    "on_scene": true,
    "can_assist": true
  }
}

Response:
{
  "recommendation": "LAUNCH",
  "confidence": 0.95,
  "reasoning": {
    "nearest_drone": "Alpha-3",
    "drone_eta": "2:15",
    "ambulance_eta": "8:00",
    "time_advantage": "5:45",  // Drone arrives 5m45s earlier
    "weather_safe": true,
    "landing_zones_available": 3,
    "bystander_present": true,  // Can assist with AED
    "risk_level": "LOW"
  },
  "alternative_drones": [
    {"unit": "Beta-1", "eta": "3:20", "battery": "92%"},
    {"unit": "Gamma-5", "eta": "4:10", "battery": "78%"}
  ]
}
```

---

## AI Backend Components

### Component 1: Drone Selection AI

**Task:** Choose optimal drone for emergency

```python
# AI Model: Multi-Criteria Decision Making
class DroneSelector:
    def select_best_drone(self, emergency_location, available_drones):
        """
        Inputs:
        - Emergency GPS coordinates
        - List of available drones (location, battery, status)
        - Current weather conditions
        - No-fly zones

        AI Processing:
        1. Calculate flight distances (A* pathfinding)
        2. Estimate flight times (wind-adjusted)
        3. Assess battery sufficiency (30% reserve required)
        4. Check weather safety (max wind: 25mph)
        5. Validate landing zones at destination

        Output:
        - Best drone ID
        - ETA
        - Confidence score
        - Alternative options
        """

        # Graph-based routing with constraints
        for drone in available_drones:
            path = a_star_path(
                start=drone.location,
                goal=emergency_location,
                obstacles=get_no_fly_zones(),
                weather=get_current_weather()
            )

            eta = calculate_eta(path, wind_speed, drone_specs)
            battery_required = estimate_battery(path, return_trip=True)

            if battery_required < drone.battery * 0.7:  # 30% reserve
                candidates.append({
                    'drone_id': drone.id,
                    'eta': eta,
                    'confidence': calculate_confidence(path, weather),
                    'path': path
                })

        return ranked_by_eta(candidates)[0]  # Fastest, safe option

# Deployment: FastAPI endpoint + Redis cache
# Response time: <500ms
```

### Component 2: Launch Authorization AI

**Task:** Risk assessment for dispatcher

```python
class LaunchRiskAssessment:
    def should_launch(self, emergency_data):
        """
        AI Risk Scoring (0-100)

        Factors:
        ✅ Positive (increase score):
        - Bystander present (can use AED)       +30 points
        - Clear weather                         +20 points
        - Multiple landing zones available      +15 points
        - Drone ETA < Ambulance ETA             +20 points
        - Confirmed cardiac arrest              +15 points

        ❌ Negative (decrease score):
        - High wind (>25mph)                    -40 points
        - Heavy rain/snow                       -30 points
        - No safe landing zones                 -50 points
        - Drone battery <50%                    -30 points
        - Dense urban area (obstacles)          -20 points

        Decision:
        - Score >70: RECOMMEND LAUNCH (green)
        - Score 40-70: CAUTION (yellow) - dispatcher decides
        - Score <40: DO NOT LAUNCH (red)
        """

        score = 50  # Baseline

        # Positive factors
        if emergency_data.bystander_present:
            score += 30
        if weather.condition == "clear":
            score += 20
        if landing_zones.count >= 2:
            score += 15
        if drone_eta < ambulance_eta:
            score += 20

        # Negative factors
        if weather.wind_speed > 25:
            score -= 40
        if weather.precipitation == "heavy":
            score -= 30
        if landing_zones.count == 0:
            score -= 50

        return {
            'score': score,
            'recommendation': 'LAUNCH' if score > 70 else 'CAUTION' if score > 40 else 'DO_NOT_LAUNCH',
            'explanation': generate_explanation(score, factors)
        }

# ML Model: XGBoost trained on historical emergency data
# Features: weather, location, time-of-day, outcome success rate
# Retraining: Monthly with new data
```

### Component 3: Real-Time Tracking for Dispatcher

**Task:** Keep dispatcher informed during flight

```javascript
// WebSocket updates to dispatcher console

{
  "type": "FLIGHT_UPDATE",
  "drone_id": "Alpha-3",
  "mission_id": "CA-20251201-001",
  "status": "IN_FLIGHT",
  "telemetry": {
    "latitude": 42.3589,
    "longitude": -71.0602,
    "altitude": 120,  // meters
    "speed": 15,      // m/s
    "battery": 84,    // percent
    "eta": "1:45"     // minutes remaining
  },
  "ai_status": {
    "obstacles_detected": 0,
    "landing_zone_confidence": 0.92,
    "weather_risk": "LOW",
    "navigation_mode": "AUTONOMOUS"
  }
}

// Update frequency: Every 2 seconds
// Dispatcher sees live drone position on map
```

---

## Dispatcher UI Screens (What You Need to Build)

### Screen 1: Launch Decision Dashboard

```
Primary View: Emergency Details + Drone Recommendation

Elements:
1. Emergency info (location, caller details, type)
2. AI-recommended drone (with confidence score)
3. ETA comparison (drone vs ambulance)
4. Weather/risk assessment
5. Large "LAUNCH DRONE" button
6. Live map showing:
   - Emergency location (red marker)
   - Available drones (blue markers)
   - Recommended flight path (green line)
   - No-fly zones (red zones)
```

### Screen 2: Active Mission Monitoring

```
View: Real-time flight tracking

Elements:
1. Live map with drone position
2. Telemetry panel (altitude, speed, battery)
3. ETA countdown
4. AI status (obstacles, landing zone)
5. Communication log
6. "Abort Mission" button (emergency)
7. Link to AED instructions (for caller/bystander)
```

### Screen 3: Fleet Overview

```
View: All drones in dispatcher's coverage area

Elements:
1. Map with all drone locations
2. Status: Ready / Charging / In Flight / Maintenance
3. Battery levels
4. Last mission time
5. Quick launch capability
```

---

## Backend AI Stack for Dispatcher System

### Recommended Architecture

```
┌─────────────────────────────────────────────┐
│         DISPATCHER CONSOLE (Web App)        │
│  Tech: React + MapBox + WebSocket           │
│  Deploy: AWS CloudFront (CDN)               │
└─────────────────────────────────────────────┘
                    ↕ HTTPS/WSS
┌─────────────────────────────────────────────┐
│           API BACKEND (AWS Lambda)          │
│  ┌───────────────────────────────────────┐  │
│  │  POST /emergency/assess               │  │
│  │  → Drone selection AI                 │  │
│  │  → Risk scoring AI                    │  │
│  │  → Route calculation                  │  │
│  │                                        │  │
│  │  POST /emergency/launch               │  │
│  │  → Authorize drone launch             │  │
│  │  → Send command to drone              │  │
│  │  → Create mission record              │  │
│  │                                        │  │
│  │  WebSocket: /mission/:id/updates      │  │
│  │  → Stream telemetry to dispatcher     │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
                    ↕ IoT MQTT
┌─────────────────────────────────────────────┐
│          AWS IOT CORE (Drone Fleet)         │
│  ┌───────────────────────────────────────┐  │
│  │  Topic: /drone/{id}/command           │  │
│  │  → Send launch command                │  │
│  │                                        │  │
│  │  Topic: /drone/{id}/telemetry         │  │
│  │  → Receive real-time data             │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
                    ↕ 4G/5G
┌─────────────────────────────────────────────┐
│           DRONE (Edge AI)                   │
│  - Receives launch command                  │
│  - Autonomous flight to coordinates         │
│  - AI landing zone selection                │
│  - AED deployment                           │
└─────────────────────────────────────────────┘
```

### AI Services Running on Backend

**1. Drone Selection Service**
```
Technology: Python FastAPI + Redis
AI Model: Graph-based routing (A*) + ML ETA prediction
Input: Emergency location, available drones
Output: Best drone ID, path, ETA
Response Time: <500ms
Cost: ~$50/month (100 drones)
```

**2. Risk Assessment Service**
```
Technology: Python FastAPI + XGBoost
AI Model: Gradient boosting (trained on historical launches)
Input: Weather, location, drone status, time-of-day
Output: Risk score (0-100), recommendation
Response Time: <200ms
Cost: ~$30/month
```

**3. Weather Integration**
```
Technology: Weather API (OpenWeatherMap or NOAA)
Data: Real-time wind, precipitation, visibility
Update Frequency: Every 5 minutes
Cost: ~$100/month
```

**4. Geospatial Service**
```
Technology: PostGIS (PostgreSQL) or Amazon Location Service
Data: No-fly zones, landing zones, building heights
API: Fast radius queries (<100ms)
Cost: ~$40/month
```

---

## Launch Command Flow

```
DISPATCHER CLICKS "LAUNCH" BUTTON
         ↓
┌─────────────────────────────────────┐
│ 1. Frontend sends API request       │
│    POST /emergency/launch            │
│    {                                 │
│      emergency_id: "CA-001",         │
│      drone_id: "Alpha-3",            │
│      destination: {lat, lon}         │
│    }                                 │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 2. Backend creates mission record   │
│    Database: DynamoDB or PostgreSQL │
│    Status: LAUNCHED                  │
│    Timestamp: 2025-12-01T14:23:45Z  │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 3. Send command to drone via IoT    │
│    MQTT Topic:                       │
│      /drone/Alpha-3/command          │
│    Message:                          │
│    {                                 │
│      "command": "LAUNCH",            │
│      "mission_id": "CA-001",         │
│      "destination": {                │
│        "lat": 42.3601,               │
│        "lon": -71.0589               │
│      },                              │
│      "priority": "EMERGENCY",        │
│      "return_to_base": true          │
│    }                                 │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 4. Drone acknowledges (within 2s)   │
│    Status: ACKNOWLEDGED              │
│    ETA: 2:15                         │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 5. Autonomous flight begins          │
│    - Takeoff                         │
│    - Navigate to destination         │
│    - AI landing zone detection       │
│    - AED deployment                  │
│    - Return to base                  │
│                                      │
│    Dispatcher sees real-time updates │
└─────────────────────────────────────┘
```

---

## What AI Does vs What Dispatcher Does

### Dispatcher Actions (Human Decision)
✅ Receive 911 call
✅ Confirm cardiac arrest emergency
✅ **DECIDE** whether to launch drone (based on AI recommendation)
✅ Click "LAUNCH" button
✅ Monitor flight progress
✅ Communicate with EMS/caller

### AI Actions (Automated)
🤖 Select best available drone
🤖 Calculate optimal flight path
🤖 Assess weather/risk
🤖 Provide launch recommendation
🤖 Control autonomous flight
🤖 Detect landing zone
🤖 Avoid obstacles
🤖 Deploy AED
🤖 Return drone to base

---

## AI Models You Need

| AI Task | Model Type | Where | Cost |
|---------|-----------|-------|------|
| **Drone Selection** | Graph algorithm + ML | Cloud | $50/mo |
| **Risk Scoring** | XGBoost | Cloud | $30/mo |
| **Route Optimization** | A* + RL | Cloud | $40/mo |
| **Landing Zone Detection** | DeepLabV3 | Edge | $0 (on-drone) |
| **Person Detection** | YOLOv8n | Edge | $0 (on-drone) |
| **Obstacle Avoidance** | Stereo Vision | Edge | $0 (on-drone) |
| **Weather Analysis** | Rule-based + CNN | Cloud | $20/mo |

**Total Cloud AI Cost: ~$140/month for 100-drone fleet**

---

## Workshop Presentation Angle

### Key Message
**"AI assists the dispatcher, but the dispatcher makes the life-or-death decision to launch."**

### Demo Flow
1. **Show simulated 911 call**
   - Cardiac arrest at 123 Main St

2. **Dispatcher console pops up recommendation**
   - AI: "Recommend launch - 95% confidence"
   - Drone ETA: 2:15, Ambulance ETA: 8:00
   - Risk: LOW

3. **Dispatcher clicks LAUNCH**
   - Drone takes off automatically

4. **Show live tracking**
   - Real-time map
   - AI detecting landing zone
   - ETA countdown

5. **Successful delivery**
   - Drone lands
   - AED deployed
   - Bystander assisted by 911 dispatcher (audio)
   - EMS arrives 5 minutes later

### AI Differentiators
- **2-second decision support** (which drone to send)
- **95% accuracy** in risk prediction
- **Fully autonomous flight** (dispatcher just launches)
- **Real-time tracking** (dispatcher has full visibility)
- **Learns from every mission** (AI improves over time)

---

## Next Steps for Your Workshop

1. **Update your UI mockups** to show:
   - Dispatcher console (not drone operator)
   - Launch decision screen
   - Live tracking screen

2. **Update API docs** to include:
   - `POST /emergency/assess` (AI recommendation)
   - `POST /emergency/launch` (dispatcher command)
   - WebSocket telemetry stream

3. **Create dispatcher workflow diagram** showing:
   - 911 call → AI recommendation → Launch → Autonomous flight

4. **Emphasize human-AI collaboration:**
   - AI recommends, human decides
   - AI flies, human monitors
   - AI learns, human validates

---

**Recommended AI Backend: AWS Lambda + IoT Core + XGBoost/A***

Perfect for dispatcher-initiated system because:
- ✅ Fast API responses (<500ms) for emergency situations
- ✅ IoT Core handles drone communication reliably
- ✅ Serverless = scales automatically during peak emergencies
- ✅ Pay per use (cost-effective for variable call volume)
- ✅ HIPAA-compliant for medical data
