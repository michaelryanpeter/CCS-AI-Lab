# SkyRescue AI Architecture
## AI-Powered Cardiac Arrest Response Drone

**Mission:** Deliver AED (Automated External Defibrillator) to cardiac arrest victims in <3 minutes

---

## AI Backend Strategy: Hybrid Edge + Cloud

### Critical Principle
**Edge-First, Cloud-Assisted** - All life-critical decisions must happen on-device. Cloud is for coordination, not control.

---

## Edge AI Stack (On-Drone) 🚨 CRITICAL PATH

### Why Edge-First?
- ⏱️ **Latency:** <50ms response time required
- 🔌 **Reliability:** Can't depend on cellular connectivity
- 🔋 **Battery:** Cloud communication drains battery
- 🏥 **Safety:** Medical device regulations require autonomous operation

### Recommended Edge AI Runtime

**Primary: NVIDIA Jetson Nano/Orin Nano**
```
Hardware: NVIDIA Jetson Orin Nano (8GB)
- 1024 CUDA cores
- 32 Tensor Cores
- AI Performance: 40 TOPS
- Power: 5-15W
- Cost: ~$499

Software Stack:
├── OS: JetPack 6.0 (Ubuntu 22.04)
├── AI Framework: TensorRT
├── Inference: ONNX Runtime + TensorRT
├── CV Library: OpenCV (CUDA-accelerated)
└── Flight Stack: PX4 + ROS 2
```

**Alternative: Google Coral Edge TPU**
```
Hardware: Coral Dev Board / USB Accelerator
- 4 TOPS (INT8)
- 2-4W power consumption
- Cost: ~$150-300

Software Stack:
├── OS: Mendel Linux (Debian)
├── AI Framework: TensorFlow Lite
├── Inference: Edge TPU Runtime
└── Lower cost, less flexible
```

### Edge AI Models (On-Drone)

**1. Person Detection & Tracking**
```
Model: YOLOv8n (Nano) or YOLOv10n
Task: Detect fallen person, bystanders, emergency responders
Inference Time: <20ms @ 640x640
Accuracy: 95%+ for person detection
Framework: TensorRT-optimized ONNX

Training Data:
- Fallen person poses (various angles)
- Crowd scenarios
- Emergency responder uniforms
- Day/night/weather conditions
```

**2. Landing Zone Detection**
```
Model: Semantic Segmentation (DeepLabV3-MobileNet)
Task: Identify safe landing areas
- Flat surfaces (grass, pavement, rooftop)
- Obstacle-free zones
- Size validation (2m x 2m minimum)
Inference Time: <30ms
Output: Confidence map of landing zones
```

**3. Obstacle Avoidance**
```
Model: Depth Estimation (MiDaS or custom stereo)
Hardware: Stereo cameras OR LiDAR
Task: Real-time collision avoidance
Processing: <50ms end-to-end
Range: 100m detection, 50m active avoidance
```

**4. Weather & Environmental Assessment**
```
Inputs:
- Camera (visibility, rain detection)
- Barometer (wind patterns)
- GPS (geofencing, no-fly zones)

Decision: Go/No-Go for flight safety
Processing: <100ms
```

**5. AED Deployment Readiness**
```
Computer Vision:
- Verify person is supine (lying down)
- Clear zone around person (no obstacles)
- Bystander proximity (for assistance)
- Landing precision (<1m accuracy)

Audio Processing (optional):
- Detect screams/shouts
- Emergency siren detection
```

---

## Cloud AI Backend 🌐 COORDINATION

### Why Cloud?
- 📊 Mission coordination across multiple drones
- 🚑 Integration with 911/emergency dispatch
- 🗺️ Route optimization with live traffic data
- 📈 Post-mission analytics
- 🔄 Model training and updates

### Recommended Cloud Stack

**Option 1: AWS (Healthcare Compliant)**
```
Platform: AWS (HIPAA-eligible services)

Services:
├── Compute: ECS Fargate (serverless containers)
├── AI/ML: SageMaker (model training)
├── Real-time: AWS IoT Core + Kinesis
├── Database: Aurora (mission logs) + DynamoDB (telemetry)
├── Geospatial: Amazon Location Service
├── Integration: API Gateway + Lambda
└── Compliance: AWS HIPAA, ISO 27001

Why AWS:
✅ HIPAA compliance (medical device requirement)
✅ IoT Core for drone fleet management
✅ Location services for emergency routing
✅ Strong SLA guarantees (99.99%)
```

**Option 2: Google Cloud (Best AI Tools)**
```
Platform: Google Cloud (Healthcare API)

Services:
├── Compute: Cloud Run (serverless)
├── AI/ML: Vertex AI
├── Real-time: Cloud Pub/Sub + IoT Core
├── Database: Firestore (real-time) + BigQuery (analytics)
├── Geospatial: Google Maps Platform
└── Compliance: Google Cloud Healthcare API

Why Google Cloud:
✅ Best-in-class AI/ML tools
✅ Superior geospatial services
✅ Healthcare API (HIPAA compliant)
✅ AutoML for rapid model iteration
```

**Option 3: Hybrid (Edge + Self-Hosted)**
```
Edge: Jetson devices on drones
Coordination: Self-hosted Kubernetes cluster
Database: PostgreSQL + TimescaleDB
Message Queue: RabbitMQ / Apache Kafka
APIs: FastAPI (Python) or Node.js

Why Self-Hosted:
✅ Full control over medical data
✅ Lower ongoing costs
✅ Customizable for regulatory needs
❌ Requires DevOps expertise
❌ You handle compliance/security
```

### Cloud AI Services

**1. Emergency Dispatch Integration**
```
Service: Real-time API integration
Protocol:
- Inbound: 911 dispatch system (CAD integration)
- Outbound: Drone status updates to EMS

Data Flow:
911 Call → Dispatch → SkyRescue API → Nearest Drone
         ← ETA updates ← Drone telemetry
         ← Arrival confirmation ← AED deployed

Technology:
- REST API (emergency request)
- WebSocket (real-time telemetry)
- FHIR (medical data interchange)
```

**2. Mission Route Optimization**
```
AI Model: Reinforcement Learning (PPO/DQN)
Inputs:
- Emergency location (lat/lon)
- Live traffic data
- Weather conditions
- No-fly zones (FAA data)
- Building heights (3D maps)
- Historical response times

Output: Optimal flight path
Processing Time: <2 seconds
Update Frequency: Real-time during flight

ML Framework: TensorFlow or PyTorch
Training: Historical emergency data
Deployment: TensorFlow Serving
```

**3. Fleet Coordination**
```
Multi-Drone Optimization:
- Assign nearest available drone
- Coordinate multiple simultaneous emergencies
- Battery/maintenance scheduling
- Coverage area optimization

Algorithm:
- Graph-based routing (Dijkstra with constraints)
- Multi-agent reinforcement learning
- Real-time constraint solving

Platform: Redis (state management) + ML model
```

**4. Predictive Analytics**
```
Model: XGBoost or Random Forest
Predictions:
- High-risk areas (where to stage drones)
- Peak emergency times
- Seasonal patterns
- Maintenance prediction

Training Data:
- Historical cardiac arrest data
- Weather patterns
- Geographic factors
- Time-of-day patterns

Use Case: Proactive drone positioning
```

**5. Model Training Pipeline**
```
Data Collection:
├── Flight telemetry (all missions)
├── Camera footage (anonymized)
├── Landing success/failure
├── Weather conditions
└── Response times

Training:
├── Vertex AI AutoML (Google Cloud)
├── SageMaker (AWS)
├── Or self-hosted MLflow + Kubeflow

Model Registry:
├── Version control (Git LFS)
├── Performance tracking
├── A/B testing framework
└── OTA (Over-The-Air) updates to drones
```

---

## AI Model Summary Table

| Component | Model | Runtime | Latency | Power | Where |
|-----------|-------|---------|---------|-------|-------|
| Person Detection | YOLOv8n | TensorRT | <20ms | 5W | Edge |
| Landing Zone | DeepLabV3-Mobile | ONNX | <30ms | 3W | Edge |
| Obstacle Avoid | MiDaS/Stereo | TensorRT | <50ms | 5W | Edge |
| Weather Analysis | Custom CNN | TFLite | <100ms | 1W | Edge |
| Route Optimization | RL (PPO) | TF Serving | <2s | - | Cloud |
| Fleet Coordination | Graph + RL | Redis + Python | <500ms | - | Cloud |
| Predictive Analytics | XGBoost | Cloud | Batch | - | Cloud |

---

## Recommended Full Stack Architecture

### The Winning Combination

```
┌─────────────────────────────────────────────┐
│           EDGE (ON-DRONE)                   │
│  ┌──────────────────────────────────────┐  │
│  │  NVIDIA Jetson Orin Nano (8GB)       │  │
│  │  - TensorRT (inference)              │  │
│  │  - YOLOv8n (person detection)        │  │
│  │  - DeepLabV3 (landing zone)          │  │
│  │  - Stereo vision (obstacles)         │  │
│  │  - PX4 (flight control)              │  │
│  │  - ROS 2 (middleware)                │  │
│  └──────────────────────────────────────┘  │
│              ↕ 4G/5G ↕                      │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│         CLOUD (AWS Healthcare)              │
│  ┌──────────────────────────────────────┐  │
│  │  AWS IoT Core (drone communication)  │  │
│  │  Lambda (serverless API)             │  │
│  │  SageMaker (model training)          │  │
│  │  DynamoDB (telemetry)                │  │
│  │  Aurora (mission logs)               │  │
│  │  Location Service (routing)          │  │
│  └──────────────────────────────────────┘  │
│              ↕ API ↕                        │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│      EMERGENCY DISPATCH INTEGRATION         │
│  - 911 CAD system                           │
│  - EMS coordination                         │
│  - Hospital notification                    │
└─────────────────────────────────────────────┘
```

---

## Development Roadmap

### Phase 1: MVP (3 months)
- ✅ Jetson Nano with TensorFlow Lite
- ✅ Basic person detection (YOLOv8n)
- ✅ Simple cloud API (AWS Lambda)
- ✅ Manual emergency triggering
- ✅ GPS-based routing

### Phase 2: Production (6 months)
- ✅ Upgrade to Jetson Orin Nano
- ✅ TensorRT optimization (2-3x faster)
- ✅ Landing zone detection
- ✅ 911 dispatch integration
- ✅ Fleet management system
- ✅ HIPAA compliance audit

### Phase 3: Scale (12 months)
- ✅ Multi-city deployment
- ✅ Predictive positioning
- ✅ Advanced weather handling
- ✅ Model continuous improvement
- ✅ FDA clearance (if required)

---

## Cost Estimates

### Per-Drone Hardware (Edge AI)
```
NVIDIA Jetson Orin Nano 8GB:  $499
Stereo cameras (2x):          $200
GPS module (RTK):             $150
4G/5G modem:                  $100
Storage (256GB NVMe):         $50
------------------------------------------
Edge AI Total per drone:      ~$1,000
```

### Cloud Costs (Monthly, 100 drones)
```
AWS IoT Core (100 drones):    $50/month
Lambda (1M requests):         $20/month
DynamoDB (10GB + traffic):    $30/month
Aurora (100GB):               $150/month
Data transfer (500GB):        $45/month
Location Service (100K requests): $40/month
------------------------------------------
Cloud Total:                  ~$335/month
                              ($3.35/drone/month)
```

### Development Costs
```
Model development:            $50,000 (one-time)
Cloud setup:                  $20,000 (one-time)
Regulatory compliance:        $100,000+ (ongoing)
```

---

## Regulatory Considerations

### FDA Medical Device Classification
```
Likely Class II Medical Device
- Requires 510(k) premarket notification
- AI/ML as a Medical Device (AI/ML-based SaMD)
- Quality Management System (ISO 13485)
- Cybersecurity requirements
- Post-market surveillance

AI Implications:
- Model versioning and tracking
- Explainability requirements
- Validation datasets
- Performance monitoring
- Update procedures
```

### FAA Drone Regulations
```
Part 107 Waiver Required:
- Beyond Visual Line of Sight (BVLOS)
- Flight over people
- Night operations
- Emergency response exemptions

Remote ID:
- Required for all operations
- Real-time location broadcast
```

---

## Security & Privacy

### Data Protection
```
In-Flight Data:
- Encrypted communication (TLS 1.3)
- No storage of identifiable footage
- Automatic deletion after 24-48 hours

Medical Data:
- HIPAA compliance (cloud)
- De-identification of training data
- Secure multi-party computation

Model Security:
- Signed firmware updates
- Model encryption at rest
- Adversarial attack protection
```

---

## Why This Stack Wins

### Edge AI (Jetson Orin Nano)
✅ Proven in medical robotics
✅ CUDA acceleration for real-time processing
✅ Low power consumption (critical for flight time)
✅ Strong ecosystem (ROS 2, OpenCV, TensorRT)
✅ OTA update capability

### Cloud (AWS Healthcare)
✅ HIPAA-compliant infrastructure
✅ Strong SLA for emergency services
✅ IoT Core for drone management
✅ Integration with emergency dispatch systems
✅ Global availability

### ML Stack (TensorRT + TensorFlow)
✅ Best performance on Jetson hardware
✅ Industry-standard frameworks
✅ Easy model conversion pipeline
✅ Extensive pre-trained models
✅ Active development community

---

## Alternative Considerations

### When to Use Alternatives

**Use Google Cloud if:**
- You prioritize best-in-class AI tools
- You need superior mapping/geospatial
- You're comfortable with Google's ecosystem

**Use Azure if:**
- You have existing Microsoft enterprise agreements
- You need strong IoT Edge capabilities
- You want hybrid cloud deployment

**Use Coral TPU if:**
- Budget is extremely tight (<$300/drone)
- Power consumption is critical (>40min flight)
- You only need basic inference (no training on edge)

---

## Next Steps for Your Workshop

1. **Demo the concept:**
   - Show Jetson Nano running YOLOv8 detection
   - Simulate 911 dispatch integration
   - Display real-time flight path optimization

2. **Architecture diagram:**
   - Edge-to-cloud data flow
   - Emergency response timeline
   - AI decision points

3. **Key differentiators:**
   - "AI decides landing zone in <50ms"
   - "Operates even without cell coverage"
   - "Learns from every mission to improve response times"

4. **Business case:**
   - Cardiac arrest survival drops 10% per minute
   - Target: <3 minute AED delivery
   - Traditional EMS average: 8-12 minutes

---

## Questions to Answer in Your Workshop

1. **How does the drone know where to land?**
   - AI landing zone detection
   - Real-time obstacle avoidance
   - Person tracking

2. **What if the network goes down?**
   - Full autonomy on edge
   - Pre-programmed emergency procedures
   - Local decision-making

3. **How do you ensure accuracy in life-critical scenarios?**
   - Triple redundancy (GPS, vision, LiDAR)
   - Confidence thresholds (95%+ for landing)
   - Human-in-loop fallback

4. **How does it integrate with 911?**
   - Direct API to dispatch centers
   - Real-time EMS coordination
   - Hospital pre-notification

---

**Recommended Stack: NVIDIA Jetson Orin Nano + AWS Healthcare + TensorRT**

This gives you the best balance of:
- ⚡ Performance (real-time edge AI)
- 🏥 Compliance (HIPAA, FDA-ready)
- 💰 Cost (reasonable per-drone cost)
- 🚀 Scalability (proven in production)
- 🔒 Reliability (medical-grade infrastructure)
