# SkyRescue MQTT Integration

## Overview

SkyRescue uses **AWS IoT Core** for real-time communication between the cloud backend and drone fleet.

- **Protocol**: MQTT 3.1.1 over TLS 1.3
- **QoS**: 1 (at least once delivery)
- **Retention**: Critical commands retained for 24 hours

---

## MQTT Topics

### Command Topics (Cloud → Drone)

#### `/drone/{drone_id}/command`

Cloud backend sends mission commands to specific drone.

**Payload Example: Launch Command**
```json
{
  "command": "LAUNCH",
  "mission_id": "M-20251201-001",
  "timestamp": "2025-12-01T14:23:15Z",
  "destination": {
    "latitude": 42.3601,
    "longitude": -71.0589
  },
  "priority": "EMERGENCY",
  "return_to_base": true,
  "voice_ai_enabled": true,
  "expected_ack_timeout": 5000
}
```

**Payload Example: Abort Command**
```json
{
  "command": "ABORT",
  "mission_id": "M-20251201-001",
  "timestamp": "2025-12-01T14:25:30Z",
  "abort_mode": "RETURN_TO_BASE",
  "reason": "Incorrect location"
}
```

**Payload Example: Voice Override**
```json
{
  "command": "VOICE_SPEAK",
  "mission_id": "M-20251201-001",
  "timestamp": "2025-12-01T14:24:10Z",
  "text": "The ambulance will arrive in 3 minutes.",
  "language": "en",
  "interrupt": false
}
```

**Available Commands:**
- `LAUNCH` - Start mission
- `ABORT` - Abort active mission
- `RETURN_TO_BASE` - Return to charging station
- `EMERGENCY_LAND` - Emergency landing
- `UPDATE_ROUTE` - Adjust flight path
- `VOICE_SPEAK` - Manual voice command
- `VOICE_MUTE` - Mute voice AI
- `VOICE_UNMUTE` - Unmute voice AI

---

### Telemetry Topics (Drone → Cloud)

#### `/drone/{drone_id}/telemetry`

Drone publishes telemetry every **2 seconds** during flight.

**Payload Example:**
```json
{
  "drone_id": "Alpha-3",
  "mission_id": "M-20251201-001",
  "timestamp": "2025-12-01T14:23:45Z",
  "location": {
    "latitude": 42.3589,
    "longitude": -71.0602,
    "altitude": 120
  },
  "speed": 15.5,
  "heading": 87.3,
  "battery": 84,
  "gps_satellites": 12,
  "status": "IN_FLIGHT",
  "ai_status": {
    "obstacles_detected": 0,
    "landing_zone_confidence": 0.92,
    "navigation_mode": "AUTONOMOUS",
    "person_detected": true,
    "person_tracking": true
  }
}
```

**Update Frequency:**
- In-flight: Every 2 seconds
- Idle: Every 30 seconds
- Critical events: Immediate

---

#### `/drone/{drone_id}/voice/transcript`

Real-time voice conversation transcript stream.

**Payload Example:**
```json
{
  "mission_id": "M-20251201-001",
  "timestamp": "2025-12-01T14:23:52Z",
  "speaker": "DRONE",
  "text": "This is SkyRescue. I have an AED. Can you help?",
  "language": "en",
  "confidence": 0.99,
  "audio_duration_ms": 3200
}
```

**Speaker Values:**
- `DRONE` - Voice AI on drone
- `BYSTANDER` - Person at scene
- `AED_DEVICE` - AED device voice prompts

**Languages Supported:** `en`, `es`, `zh`, `yue`, `tl`, `vi`, `ko`, `ru`, `ar`, `fr`

---

#### `/drone/{drone_id}/events`

Mission-critical events published immediately.

**Payload Example: AED Deployed**
```json
{
  "event": "AED_DEPLOYED",
  "mission_id": "M-20251201-001",
  "timestamp": "2025-12-01T14:24:15Z",
  "details": {
    "compartment_opened": true,
    "aed_removed": true,
    "bystander_confirmed": true
  }
}
```

**Event Types:**
- `LAUNCH_ACKNOWLEDGED` - Drone received launch command
- `TAKEOFF_COMPLETE` - Drone airborne
- `ARRIVED_AT_SCENE` - Reached emergency location
- `LANDING_INITIATED` - Beginning landing sequence
- `LANDED` - Successful landing
- `AED_COMPARTMENT_OPENED` - AED accessible
- `AED_DEPLOYED` - AED removed by bystander
- `VOICE_CONVERSATION_STARTED` - Voice AI active
- `VOICE_LANGUAGE_DETECTED` - Language identified
- `MISSION_COMPLETE` - Returned to base
- `EMERGENCY_LAND` - Emergency landing triggered
- `LOW_BATTERY_WARNING` - Battery below threshold

---

### Status Topics (Drone → Cloud)

#### `/drone/{drone_id}/status`

Drone health and readiness status (published every 60 seconds when idle).

**Payload Example:**
```json
{
  "drone_id": "Alpha-3",
  "timestamp": "2025-12-01T14:00:00Z",
  "status": "READY",
  "location": {
    "latitude": 42.3500,
    "longitude": -71.0600,
    "altitude": 0
  },
  "battery": 98,
  "charging": false,
  "last_mission": "2025-12-01T13:45:00Z",
  "total_missions": 127,
  "hardware_health": {
    "motors": "OK",
    "cameras": "OK",
    "gps": "OK",
    "microphones": "OK",
    "speaker": "OK",
    "ai_compute": "OK",
    "temperature_c": 32
  },
  "software_versions": {
    "firmware": "1.2.5",
    "ai_models": "2.1.0",
    "voice_ai": "1.0.3"
  }
}
```

**Status Values:**
- `READY` - Available for launch
- `CHARGING` - At charging station
- `IN_FLIGHT` - Active mission
- `MAINTENANCE` - Requires service
- `OFFLINE` - Not responding

---

## MQTT Integration Examples

### Python Example: Subscribe to Telemetry

```python
import paho.mqtt.client as mqtt
import json
import ssl

# AWS IoT Core connection settings
BROKER = "a1b2c3d4e5f6g7.iot.us-east-1.amazonaws.com"
PORT = 8883
DRONE_ID = "Alpha-3"

# Certificates for TLS
CA_CERT = "AmazonRootCA1.pem"
CLIENT_CERT = "dispatcher-cert.pem"
CLIENT_KEY = "dispatcher-key.pem"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to AWS IoT Core")
        # Subscribe to telemetry topic
        client.subscribe(f"/drone/{DRONE_ID}/telemetry")
        print(f"Subscribed to /drone/{DRONE_ID}/telemetry")
    else:
        print(f"Connection failed with code {rc}")

def on_message(client, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode())
        print(f"\n📡 Telemetry Update:")
        print(f"  Location: {payload['location']['latitude']}, {payload['location']['longitude']}")
        print(f"  Altitude: {payload['location']['altitude']}m")
        print(f"  Speed: {payload['speed']} m/s")
        print(f"  Battery: {payload['battery']}%")
        print(f"  Status: {payload['status']}")

        if payload.get('ai_status'):
            print(f"  Landing Zone Confidence: {payload['ai_status']['landing_zone_confidence']*100:.0f}%")
            print(f"  Person Detected: {payload['ai_status']['person_detected']}")
    except Exception as e:
        print(f"Error parsing message: {e}")

# Create MQTT client
client = mqtt.Client(client_id="dispatcher-console-001")

# Configure TLS
client.tls_set(
    ca_certs=CA_CERT,
    certfile=CLIENT_CERT,
    keyfile=CLIENT_KEY,
    tls_version=ssl.PROTOCOL_TLSv1_2
)

# Set callbacks
client.on_connect = on_connect
client.on_message = on_message

# Connect and loop
client.connect(BROKER, PORT, keepalive=60)
client.loop_forever()
```

---

### Python Example: Send Launch Command

```python
import paho.mqtt.client as mqtt
import json
import ssl
from datetime import datetime, timezone

BROKER = "a1b2c3d4e5f6g7.iot.us-east-1.amazonaws.com"
PORT = 8883
DRONE_ID = "Alpha-3"

def send_launch_command():
    client = mqtt.Client(client_id="dispatcher-backend")

    # Configure TLS
    client.tls_set(
        ca_certs="AmazonRootCA1.pem",
        certfile="backend-cert.pem",
        keyfile="backend-key.pem",
        tls_version=ssl.PROTOCOL_TLSv1_2
    )

    # Connect
    client.connect(BROKER, PORT, keepalive=60)
    client.loop_start()

    # Create launch command
    command = {
        "command": "LAUNCH",
        "mission_id": "M-20251201-001",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "destination": {
            "latitude": 42.3601,
            "longitude": -71.0589
        },
        "priority": "EMERGENCY",
        "return_to_base": True,
        "voice_ai_enabled": True
    }

    # Publish command
    topic = f"/drone/{DRONE_ID}/command"
    result = client.publish(
        topic,
        json.dumps(command),
        qos=1,
        retain=True
    )

    if result.rc == mqtt.MQTT_ERR_SUCCESS:
        print(f"✅ Launch command sent to {DRONE_ID}")
        print(f"   Mission ID: {command['mission_id']}")
        print(f"   Destination: {command['destination']}")
    else:
        print(f"❌ Failed to send command: {result.rc}")

    client.loop_stop()
    client.disconnect()

if __name__ == "__main__":
    send_launch_command()
```

---

### Node.js Example: WebSocket Proxy for Voice Transcript

```javascript
const mqtt = require('mqtt');
const WebSocket = require('ws');

// MQTT connection to AWS IoT Core
const mqttClient = mqtt.connect('mqtts://a1b2c3d4e5f6g7.iot.us-east-1.amazonaws.com', {
  clientId: 'voice-proxy-001',
  ca: fs.readFileSync('AmazonRootCA1.pem'),
  cert: fs.readFileSync('proxy-cert.pem'),
  key: fs.readFileSync('proxy-key.pem'),
  protocol: 'mqtts',
  port: 8883
});

// WebSocket server for dispatchers
const wss = new WebSocket.Server({ port: 8080 });

mqttClient.on('connect', () => {
  console.log('Connected to AWS IoT Core');

  // Subscribe to all drone voice transcripts
  mqttClient.subscribe('/drone/+/voice/transcript', (err) => {
    if (!err) {
      console.log('Subscribed to voice transcripts');
    }
  });
});

// Forward MQTT messages to WebSocket clients
mqttClient.on('message', (topic, message) => {
  const data = JSON.parse(message.toString());

  // Broadcast to all connected dispatcher consoles
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify({
        type: 'VOICE_TRANSCRIPT',
        data: data
      }));
    }
  });
});

wss.on('connection', (ws) => {
  console.log('Dispatcher console connected');

  ws.on('message', (message) => {
    const command = JSON.parse(message.toString());

    // Allow dispatcher to send voice commands
    if (command.type === 'VOICE_COMMAND') {
      const topic = `/drone/${command.drone_id}/command`;
      mqttClient.publish(topic, JSON.stringify({
        command: 'VOICE_SPEAK',
        mission_id: command.mission_id,
        text: command.text,
        language: command.language || 'en'
      }));
    }
  });
});

console.log('WebSocket server running on port 8080');
```

---

## Security & Authentication

### AWS IoT Core Policies

**Dispatcher Console Policy** (read-only):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iot:Subscribe",
        "iot:Receive"
      ],
      "Resource": [
        "arn:aws:iot:us-east-1:123456789012:topicfilter/drone/*/telemetry",
        "arn:aws:iot:us-east-1:123456789012:topicfilter/drone/*/voice/transcript",
        "arn:aws:iot:us-east-1:123456789012:topicfilter/drone/*/events"
      ]
    }
  ]
}
```

**Backend Service Policy** (read-write):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iot:Publish",
        "iot:Subscribe",
        "iot:Receive"
      ],
      "Resource": [
        "arn:aws:iot:us-east-1:123456789012:topic/drone/*/command",
        "arn:aws:iot:us-east-1:123456789012:topicfilter/drone/*/telemetry",
        "arn:aws:iot:us-east-1:123456789012:topicfilter/drone/*/events"
      ]
    }
  ]
}
```

**Drone Policy** (device-specific):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iot:Subscribe",
        "iot:Receive"
      ],
      "Resource": [
        "arn:aws:iot:us-east-1:123456789012:topicfilter/drone/Alpha-3/command"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "iot:Publish",
      "Resource": [
        "arn:aws:iot:us-east-1:123456789012:topic/drone/Alpha-3/telemetry",
        "arn:aws:iot:us-east-1:123456789012:topic/drone/Alpha-3/voice/transcript",
        "arn:aws:iot:us-east-1:123456789012:topic/drone/Alpha-3/events",
        "arn:aws:iot:us-east-1:123456789012:topic/drone/Alpha-3/status"
      ]
    }
  ]
}
```

---

## Message Validation

All MQTT messages are validated against JSON schemas before processing:

### Command Schema Validation (backend)
```python
from jsonschema import validate

LAUNCH_COMMAND_SCHEMA = {
    "type": "object",
    "required": ["command", "mission_id", "destination"],
    "properties": {
        "command": {"enum": ["LAUNCH"]},
        "mission_id": {"type": "string"},
        "destination": {
            "type": "object",
            "required": ["latitude", "longitude"],
            "properties": {
                "latitude": {"type": "number"},
                "longitude": {"type": "number"}
            }
        }
    }
}

# Validate before publishing
try:
    validate(instance=command_payload, schema=LAUNCH_COMMAND_SCHEMA)
    mqtt_client.publish(topic, json.dumps(command_payload))
except Exception as e:
    print(f"Invalid command: {e}")
```

---

## Monitoring & Debugging

### CloudWatch Metrics

AWS IoT Core automatically publishes metrics:
- `PublishIn.Success` - Messages published by drones
- `Subscribe.Success` - Topic subscriptions
- `Connect.Success` - MQTT connections

### Custom Metrics
```python
import boto3

cloudwatch = boto3.client('cloudwatch')

# Track mission launch latency
cloudwatch.put_metric_data(
    Namespace='SkyRescue/Missions',
    MetricData=[
        {
            'MetricName': 'LaunchLatency',
            'Value': latency_ms,
            'Unit': 'Milliseconds',
            'Dimensions': [
                {'Name': 'DroneID', 'Value': 'Alpha-3'}
            ]
        }
    ]
)
```

---

## Message Retention & History

- **Command Messages**: Retained for 24 hours
- **Telemetry**: Stored in DynamoDB for 90 days
- **Voice Transcripts**: Stored for 7 days (HIPAA compliance)
- **Events**: Permanent storage in Aurora

---

## Testing MQTT Integration

### Using mosquitto_pub (Command Line)

```bash
# Subscribe to telemetry
mosquitto_sub \
  --cafile AmazonRootCA1.pem \
  --cert dispatcher-cert.pem \
  --key dispatcher-key.pem \
  -h a1b2c3d4e5f6g7.iot.us-east-1.amazonaws.com \
  -p 8883 \
  -t '/drone/Alpha-3/telemetry' \
  -v

# Publish test command
mosquitto_pub \
  --cafile AmazonRootCA1.pem \
  --cert backend-cert.pem \
  --key backend-key.pem \
  -h a1b2c3d4e5f6g7.iot.us-east-1.amazonaws.com \
  -p 8883 \
  -t '/drone/Alpha-3/command' \
  -m '{"command":"RETURN_TO_BASE","mission_id":"TEST-001","timestamp":"2025-12-01T14:00:00Z"}'
```

---

## Next Steps

1. **Generate certificates**: Request X.509 certificates from AWS IoT Core
2. **Test connection**: Use mosquitto_pub/sub to verify connectivity
3. **Implement client**: Use provided Python/Node.js examples
4. **Monitor metrics**: Set up CloudWatch dashboards
5. **Production deploy**: Configure auto-scaling and failover

**Documentation:**
- AWS IoT Core: https://docs.aws.amazon.com/iot/
- MQTT 3.1.1 Spec: https://mqtt.org/mqtt-specification/
