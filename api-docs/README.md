# SkyRescue API Documentation

Complete technical documentation for the SkyRescue emergency response drone system.

---

## Documentation Files

### 1. [skyrescue-api.yaml](./skyrescue-api.yaml)
**OpenAPI 3.0 specification** for REST API endpoints.

**Covers:**
- Emergency assessment and drone launch
- Mission tracking and telemetry
- Voice AI interaction and transcript streaming
- Fleet management
- 911 CAD system integration

**How to use:**
```bash
# View in Swagger UI (online)
https://editor.swagger.io/
# Paste content of skyrescue-api.yaml

# Generate client SDKs
npm install @openapitools/openapi-generator-cli -g
openapi-generator-cli generate -i skyrescue-api.yaml -g python -o sdk/python
openapi-generator-cli generate -i skyrescue-api.yaml -g typescript-axios -o sdk/typescript

# Generate server stub
openapi-generator-cli generate -i skyrescue-api.yaml -g python-flask -o backend/
```

### 2. [MQTT_INTEGRATION.md](./MQTT_INTEGRATION.md)
**MQTT topic documentation** for real-time drone communication via AWS IoT Core.

**Covers:**
- Command topics (cloud → drone)
- Telemetry topics (drone → cloud)
- Voice transcript streaming
- Event notifications
- Python and Node.js integration examples
- Security policies and authentication

---

## Quick Start

### View API in Swagger UI

1. **Online (easiest):**
   - Go to https://editor.swagger.io/
   - File → Import File → Select `skyrescue-api.yaml`

2. **Local:**
   ```bash
   # Using Docker
   docker run -p 8080:8080 -v $(pwd):/api swaggerapi/swagger-ui
   # Open http://localhost:8080/?url=/api/skyrescue-api.yaml
   ```

### Test API Endpoints (Mock Server)

```bash
# Install Prism (API mocking tool)
npm install -g @stoplight/prism-cli

# Start mock server
prism mock skyrescue-api.yaml

# Test endpoints
curl http://localhost:4010/emergency/assess \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer fake-token" \
  -d '{
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
  }'
```

---

## API Architecture

```
┌────────────────────────────────────────────────┐
│         911 DISPATCHER CONSOLE                 │
│  (Web App - React + WebSocket)                 │
└────────────────────────────────────────────────┘
                    ↕ HTTPS/WSS
┌────────────────────────────────────────────────┐
│           REST API (AWS Lambda)                │
│  ┌──────────────────────────────────────────┐ │
│  │  POST /emergency/assess                  │ │
│  │  POST /emergency/launch                  │ │
│  │  GET  /mission/{id}                      │ │
│  │  GET  /voice/transcript (WebSocket)      │ │
│  │  POST /voice/command                     │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
                    ↕ MQTT (AWS IoT Core)
┌────────────────────────────────────────────────┐
│           DRONE FLEET (Edge AI)                │
│  ┌──────────────────────────────────────────┐ │
│  │  Subscribe: /drone/{id}/command          │ │
│  │  Publish:   /drone/{id}/telemetry        │ │
│  │  Publish:   /drone/{id}/voice/transcript │ │
│  │  Publish:   /drone/{id}/events           │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
```

---

## Key API Endpoints

### 1. Emergency Assessment
```http
POST /emergency/assess
```
AI analyzes emergency and recommends whether to launch drone.

**Returns:**
- Recommended drone (nearest, best ETA)
- Confidence score (0-100)
- Risk assessment (LOW/MEDIUM/HIGH)
- ETA comparison (drone vs ambulance)

### 2. Drone Launch
```http
POST /emergency/launch
```
Dispatcher command to launch drone to emergency location.

**Returns:**
- Mission ID
- WebSocket URL for real-time updates
- Drone acknowledgment status

### 3. Voice Transcript Stream
```http
GET /voice/transcript (WebSocket)
```
Real-time stream of drone-bystander conversation.

**Returns:**
- Speaker (DRONE/BYSTANDER/AED_DEVICE)
- Transcript text
- Language detected
- Confidence score

### 4. Mission Telemetry
```http
GET /mission/{mission_id}
```
Complete mission status and drone telemetry.

**Returns:**
- GPS location, altitude, speed
- Battery level
- AI detection status
- Landing zone confidence
- Voice AI conversation state

---

## Authentication

### Dispatcher Console
Uses **JWT Bearer tokens** issued by authentication service.

```bash
curl https://api.skyrescue.ai/v1/emergency/assess \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5..."
```

### System Integration (CAD)
Uses **API Keys** for 911 dispatch system webhooks.

```bash
curl https://api.skyrescue.ai/v1/dispatch/webhook \
  -H "X-API-Key: sk_live_abc123..."
```

### MQTT (Drones)
Uses **X.509 certificates** for AWS IoT Core authentication.

---

## Error Handling

All errors follow consistent format:

```json
{
  "error": "ERROR_CODE",
  "message": "Human-readable description",
  "details": {
    "field": "Additional context"
  }
}
```

**Common Error Codes:**
- `INVALID_REQUEST` (400) - Missing or invalid parameters
- `UNAUTHORIZED` (401) - Authentication failure
- `NOT_FOUND` (404) - Resource doesn't exist
- `DRONE_UNAVAILABLE` (409) - Selected drone not ready
- `SERVICE_UNAVAILABLE` (503) - AI service temporarily down

---

## WebSocket Events

### Mission Updates (Real-time)

```javascript
const ws = new WebSocket('wss://api.skyrescue.ai/v1/mission/M-001/updates');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);

  switch (data.type) {
    case 'TELEMETRY_UPDATE':
      console.log('Location:', data.location);
      console.log('Battery:', data.battery);
      break;

    case 'EVENT':
      console.log('Event:', data.event);
      // LANDED, AED_DEPLOYED, etc.
      break;

    case 'VOICE_TRANSCRIPT':
      console.log(`${data.speaker}: ${data.text}`);
      break;
  }
};
```

---

## Rate Limits

| Endpoint | Rate Limit |
|----------|-----------|
| POST /emergency/assess | 60 requests/minute |
| POST /emergency/launch | 30 requests/minute |
| GET /mission/{id} | 120 requests/minute |
| WebSocket connections | 10 concurrent per dispatcher |

**Headers returned:**
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1638360000
```

---

## Testing Guide

### 1. Mock Server (Development)
```bash
# Start mock API server
prism mock skyrescue-api.yaml

# Returns realistic mock data based on OpenAPI examples
curl http://localhost:4010/emergency/assess -X POST -d '{...}'
```

### 2. Staging Environment
```bash
export API_BASE_URL="https://staging-api.skyrescue.ai/v1"
export API_TOKEN="your-staging-token"

# Run integration tests
npm test
```

### 3. MQTT Testing
```bash
# Test MQTT connection
cd ~/ai_lab/api-docs
python3 mqtt-test.py --drone-id Alpha-3 --subscribe-telemetry
```

---

## Integration Examples

### Python Client
```python
import requests

API_BASE = "https://api.skyrescue.ai/v1"
TOKEN = "eyJhbGciOiJIUzI1NiIs..."

# Assess emergency
response = requests.post(
    f"{API_BASE}/emergency/assess",
    headers={"Authorization": f"Bearer {TOKEN}"},
    json={
        "emergency_type": "cardiac_arrest",
        "location": {
            "latitude": 42.3601,
            "longitude": -71.0589,
            "address": "123 Main St, Boston MA"
        },
        "caller_info": {
            "on_scene": True,
            "can_assist": True
        }
    }
)

assessment = response.json()
print(f"Recommendation: {assessment['recommendation']}")
print(f"Confidence: {assessment['confidence']*100:.0f}%")
print(f"Nearest drone: {assessment['reasoning']['nearest_drone']}")
print(f"Drone ETA: {assessment['reasoning']['drone_eta']}")

# Launch if recommended
if assessment['recommendation'] == 'LAUNCH':
    launch_response = requests.post(
        f"{API_BASE}/emergency/launch",
        headers={"Authorization": f"Bearer {TOKEN}"},
        json={
            "emergency_id": "CA-20251201-001",
            "drone_id": assessment['reasoning']['nearest_drone'],
            "destination": {
                "latitude": 42.3601,
                "longitude": -71.0589
            },
            "dispatcher_id": "D-Smith-001",
            "priority": "EMERGENCY"
        }
    )

    mission = launch_response.json()
    print(f"Mission ID: {mission['mission_id']}")
    print(f"WebSocket: {mission['websocket_url']}")
```

### JavaScript Client (React)
```javascript
import axios from 'axios';

const API_BASE = 'https://api.skyrescue.ai/v1';
const token = localStorage.getItem('dispatcher_token');

const api = axios.create({
  baseURL: API_BASE,
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

// Assess emergency
async function assessEmergency(emergency) {
  const response = await api.post('/emergency/assess', emergency);
  return response.data;
}

// Launch drone
async function launchDrone(launchRequest) {
  const response = await api.post('/emergency/launch', launchRequest);
  return response.data;
}

// Connect to mission WebSocket
function connectMissionWebSocket(missionId) {
  const ws = new WebSocket(
    `wss://api.skyrescue.ai/v1/mission/${missionId}/updates`
  );

  ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    console.log('Mission update:', data);
  };

  return ws;
}
```

---

## Support

- **API Status**: https://status.skyrescue.ai
- **Technical Docs**: https://docs.skyrescue.ai
- **Developer Portal**: https://developer.skyrescue.ai

---

## Next Steps

1. ✅ Review OpenAPI spec in Swagger UI
2. ✅ Test endpoints with Prism mock server
3. ✅ Read MQTT integration guide
4. ⏭️ Generate SDK for your language
5. ⏭️ Set up WebSocket connection for real-time updates
6. ⏭️ Implement dispatcher console frontend

**Workshop Timeline:**
- ✅ API documentation complete
- ⏭️ Interactive prototypes (next)
- ⏭️ User flows
- ⏭️ Presentation materials
