# SkyRescue AI Lab - Software Department
## "First to the scene, first to save"

**Company:** SkyRescue - AI-First Emergency Response Drone Startup
**Product:** Cardiac arrest response drones
**Mission:** Deliver AEDs to cardiac arrest victims in <3 minutes via autonomous drones with voice AI guidance

---

## 🚁 Company Overview

**SkyRescue** deploys AI-powered drones that respond to 911 cardiac arrest calls:
- **Speed:** 2-3 minute response vs 8-12 minute ambulance ETA
- **Innovation:** Voice AI talks bystanders through AED deployment and CPR
- **Impact:** Potential to save 50,000-75,000 additional lives per year in the US

**Use Case:** When someone calls 911 for cardiac arrest, a dispatcher launches a drone that flies autonomously to the location, delivers an AED, and the onboard voice AI guides the bystander through life-saving procedures while waiting for the ambulance.

---

## 💙 Core Company Values

| Value | Principle |
|-------|-----------|
| **AI-Powered Velocity** | Speed over Perfection - Use AI to create working prototypes in hours, not months |
| **Uncompromising Safety** | Fail Safe, Not Fast - Multiple redundant safeguards for life-critical operations |
| **Human-AI Partnership** | Augment, Don't Replace - AI amplifies human creativity and judgment |
| **Radical Transparency** | Documentation is Our Default - Build high-quality data foundation for AI systems |

---

## 📁 Software Department Deliverables

This repository contains all technical materials developed by the Software Department for the AI Lab Workshop:

### ✅ Completed Work

1. **UI Mockups** (`mockups/`)
   - Dispatcher console with SkyRescue color scheme
   - Live voice AI transcript interface
   - Real-time telemetry dashboard
   - Emergency assessment and launch controls

2. **API Documentation** (`api-docs/`)
   - Complete OpenAPI 3.0 specification
   - MQTT integration guide with examples
   - Real-time WebSocket endpoints
   - 911 CAD system integration

3. **Interactive Prototype** (`prototype/`)
   - Fully functional HTML/CSS/JS dispatcher console
   - Simulated mission from launch to AED deployment
   - Live voice AI conversation demonstration
   - Interactive controls (mute, override)

4. **Technical Architecture**
   - Edge AI stack (NVIDIA Jetson Orin Nano)
   - Voice AI system (Whisper + Phi-3 + Piper)
   - Cloud backend (AWS IoT Core + Lambda)
   - Hybrid edge/cloud architecture

5. **Presentation Materials**
   - Complete workshop presentation guide
   - Technical deep-dive slides
   - Demo script and talking points
   - Q&A preparation

---

## 🗂️ Directory Structure

```
ai_lab/
├── mockups/                          # UI/UX Design (D2 + PlantUML)
│   ├── dispatcher-console.d2         # Main dispatcher interface
│   ├── dispatcher-console.svg        # Generated mockup
│   ├── drone-dashboard.d2            # Original drone control UI
│   ├── mission-planning.d2           # Mission planner interface
│   └── dashboard.salt                # Detailed wireframe
│
├── api-docs/                         # API Documentation
│   ├── skyrescue-api.yaml            # OpenAPI 3.0 specification
│   ├── MQTT_INTEGRATION.md           # Real-time drone communication
│   └── README.md                     # API quick start guide
│
├── prototype/                        # Interactive Prototype
│   ├── dispatcher-console.html       # Full working demo
│   └── README.md                     # Usage instructions
│
├── Technical Documentation           # AI Architecture
│   ├── SKYRESCUE_AI_ARCHITECTURE.md  # Edge + Cloud AI design
│   ├── DISPATCHER_WORKFLOW.md        # 911 dispatcher integration
│   └── VOICE_AI_SYSTEM.md            # Voice AI technical specs
│
├── PRESENTATION.md                   # Workshop presentation guide
├── generate-mockups.sh               # Build script for UI mockups
└── README.md                         # This file
```

---

## 🚀 Quick Start

### 1. Generate UI Mockups

```bash
cd ~/ai_lab
./generate-mockups.sh
```

This creates SVG and PNG files from declarative D2/PlantUML sources.

### 2. View Interactive Prototype

```bash
cd ~/ai_lab/prototype
python3 -m http.server 8000
# Open http://localhost:8000/dispatcher-console.html
```

Click "LAUNCH SKYRESCUE" to see the complete mission simulation:
- 2:15 minute autonomous flight
- Real-time telemetry updates
- Voice AI conversation with bystander
- AED deployment and guidance

### 3. Explore API Documentation

```bash
# View in Swagger UI (online)
# Go to https://editor.swagger.io/
# Import api-docs/skyrescue-api.yaml

# Or run mock API server
npm install -g @stoplight/prism-cli
prism mock api-docs/skyrescue-api.yaml
```

---

## 🎨 Color Scheme

SkyRescue uses a **Medical + Technology** palette:

- **Primary: Sky Blue** (`#00AEEF`) - Trust and calmness
- **Secondary: White** (`#FFFFFF`) - Clean and clear
- **Accent: Neon Green** (`#39FF14`) - Futuristic and attention-grabbing
- **Dark: Charcoal** (`#333333`) - Text and backgrounds

---

## 🤖 AI Technology Stack

### Edge AI (On-Drone)
**Hardware:** NVIDIA Jetson Orin Nano (8GB) - $499
- **Computer Vision:**
  - YOLOv8n (person detection) - <20ms
  - DeepLabV3 (landing zones) - <30ms
  - Stereo vision (obstacle avoidance) - <50ms
- **Voice AI:**
  - Whisper-tiny (speech-to-text) - 95% accuracy, 99 languages
  - Hybrid FSM + Phi-3-mini (dialogue) - 100-200ms
  - Piper TTS (text-to-speech) - <50ms
- **Total:** ~10W power, <250ms latency, 100% offline capable

### Cloud AI (Backend)
**Platform:** AWS (HIPAA-compliant)
- Drone selection and routing
- Risk assessment (XGBoost)
- Fleet coordination
- 911 CAD system integration
- Model training and OTA updates

**Cost:** ~$3/drone/month

---

## 📊 Key Metrics

### Business Impact
- **US Cardiac Arrests/Year:** ~350,000
- **Out-of-Hospital:** 245,000 (70%)
- **Current Survival Rate:** ~10% (24,500)
- **With SkyRescue:** +20-30% survival increase
- **Additional Lives Saved:** 49,000-73,500 per year

### Technical Performance
- **Drone ETA:** 2-3 minutes
- **Ambulance ETA:** 8-12 minutes
- **Time Advantage:** 5-6 minutes faster
- **Voice AI Latency:** <250ms (conversational)
- **Landing Zone Confidence:** 92%+
- **Multi-language Support:** 10+ languages auto-detected

### Cost Analysis
- **Drone Hardware:** $12,000 (one-time)
- **Voice AI Hardware:** $140/drone (mic array + speaker)
- **Cloud Services:** $3/drone/month
- **Cost per Rescue:** $20-30 (operational)

---

## 🎯 Workshop Demonstration

### Demo Flow (15 minutes)

**Phase 1: Emergency Call (2 min)**
- 911 dispatcher receives cardiac arrest call
- AI recommendation appears: LAUNCH (95% confidence)
- Show ETA comparison: Drone 2:15 vs Ambulance 8:00

**Phase 2: Launch (1 min)**
- Dispatcher clicks "LAUNCH SKYRESCUE"
- Drone acknowledges and takes off
- Live telemetry starts streaming

**Phase 3: Autonomous Flight (2 min)**
- Real-time position updates
- Altitude: 0→120m
- Speed: 15 m/s
- AI detections: obstacles, people
- Landing zone detection: 92% confidence

**Phase 4: Voice AI Activation (5 min)**
- Drone arrives and lands
- Voice AI: "This is SkyRescue. I have an AED. Can you help?"
- Bystander: "Yes! What do I do?!"
- Guides through: breathing check → AED retrieval → activation
- AED device takes over with shock/CPR instructions

**Phase 5: Interactive Features (2 min)**
- Show mute/unmute control
- Demonstrate manual voice override
- Highlight live transcript streaming

**Key Selling Points:**
- 🚀 **Speed:** 5:45 faster than ambulance
- 🗣️ **Voice AI:** Guides untrained bystanders
- 🌍 **Multi-language:** Auto-detects 99 languages
- 📡 **Offline:** Works without cell signal
- 🏥 **Safety:** Pre-scripted for medical accuracy

---

## 📖 Documentation

### For Technical Deep-Dive
- `SKYRESCUE_AI_ARCHITECTURE.md` - Complete AI stack details
- `DISPATCHER_WORKFLOW.md` - 911 integration workflow
- `VOICE_AI_SYSTEM.md` - Voice AI implementation
- `api-docs/MQTT_INTEGRATION.md` - Real-time communication

### For API Development
- `api-docs/skyrescue-api.yaml` - OpenAPI specification
- `api-docs/README.md` - API quick start guide

### For Prototype Customization
- `prototype/README.md` - Interactive demo usage
- `mockups/` - Declarative UI source files

### For Presentation
- `PRESENTATION.md` - Complete workshop script with Q&A

---

## 🛠️ Tools & Technologies

### UI/UX Design
- **D2** - Declarative diagrams (modern, easy)
- **PlantUML Salt** - Detailed wireframes
- Install: See `generate-mockups.sh`

### API Development
- **OpenAPI 3.0** - REST API specification
- **MQTT** - Real-time drone communication
- **AWS IoT Core** - Device management

### Prototype
- **HTML5/CSS3/JavaScript** - Pure vanilla, no frameworks
- **WebSocket** - Real-time updates
- **Single file** - Easy deployment

### AI/ML Stack
- **TensorRT** - Inference optimization
- **Whisper** - Speech recognition
- **Phi-3** - Small language model
- **Piper** - Text-to-speech

---

## 🎤 Presentation Tips

### Key Messages
1. **Time saves lives:** 5:45 faster delivery = 20-30% more survivors
2. **Voice AI is the differentiator:** No other drone talks bystanders through survival
3. **Edge-first = Reliability:** Works offline, <250ms latency
4. **FDA-ready:** Pre-scripted medical protocols are safer than pure generative AI

### Demo Best Practices
- **Test 30 minutes before** - Load prototype, check browser zoom
- **Have backup** - Recorded video if live demo fails
- **Speak slowly** - Complex technical content
- **Pause after key points** - Let information sink in
- **Face the audience** - Not the screen

### Handling Questions
- **Technical failures:** Use recorded backup
- **Unknown answers:** "Let me follow up with you after..."
- **Regulatory concerns:** Emphasize FDA Class II pathway with pre-scripted protocols

---

## 🔄 Customization Guide

### Modify Flight Duration
Edit `prototype/dispatcher-console.html:294`:
```javascript
const totalFlightTime = 135; // 2:15 in seconds
```

### Add Voice Conversation
Edit `prototype/dispatcher-console.html:276`:
```javascript
const conversationScript = [
    { time: 30, speaker: 'DRONE', text: 'Your message' },
    // Add more...
];
```

### Change UI Colors
Edit mockup `.d2` files:
```d2
style: {
  fill: "#00AEEF"    // Sky Blue
  stroke: "#39FF14"  // Neon Green
}
```

Then regenerate: `./generate-mockups.sh`

---

## 📚 Resources

### SkyRescue Links
- **GitHub Repository:** https://github.com/michaelryanpeter/CCS-AI-Lab
- **Workshop Guidelines:** `Control Plane_Edge Pod AI Lab Workshop.md`

### External Documentation
- **D2 Language:** https://d2lang.com/
- **PlantUML:** https://plantuml.com/salt
- **OpenAPI:** https://swagger.io/specification/
- **AWS IoT Core:** https://docs.aws.amazon.com/iot/

### AI/ML Resources
- **Whisper:** https://github.com/openai/whisper
- **Phi-3:** https://huggingface.co/microsoft/Phi-3-mini-4k-instruct
- **Piper TTS:** https://github.com/rhasspy/piper
- **TensorRT:** https://developer.nvidia.com/tensorrt

---

## 🤝 Team Collaboration

### Software Department Roles
- **Michael Peter** - Software (Lead)
- **Shubha** - Software

### Cross-Team Integration
- **Marketing:** Branding, messaging, go-to-market strategy
- **Sales:** Customer acquisition, pilot programs
- **Finance:** Business model, funding, cost analysis
- **HR:** Culture, hiring, remote-first policies
- **Manufacturing:** Drone hardware, assembly, QA

### Communication Standards
- **Asynchronous First:** Slack, Google Docs, Loom
- **AI-Enhanced Meetings:** Transcription, translation, summaries
- **Radical Transparency:** All decisions documented
- **Outcome-Focused:** Measure by deliverables, not hours

---

## ✅ Workshop Checklist

Before presenting:
- [ ] All mockups generated (`./generate-mockups.sh`)
- [ ] Prototype tested in browser
- [ ] API docs viewable in Swagger UI
- [ ] Demo video recorded (backup)
- [ ] Presentation slides prepared
- [ ] Talking points memorized
- [ ] Technical setup tested (screen sharing, zoom level)
- [ ] Handouts printed (API docs, contact info)

After workshop:
- [ ] Follow up with attendees (within 24 hours)
- [ ] Share GitHub repo link
- [ ] Send live demo URL
- [ ] Schedule 1-on-1 for interested investors/partners
- [ ] Measure success metrics (questions, follow-ups, GitHub stars)

---

## 🎓 Next Steps

### For Development
1. ✅ Generate and review all mockups
2. ✅ Test interactive prototype
3. ✅ Explore API documentation
4. ⏭️ Integrate with real backend (if building production)
5. ⏭️ Deploy to staging environment
6. ⏭️ Connect real drone telemetry

### For Workshop
1. ✅ Practice demo flow
2. ✅ Memorize key talking points
3. ⏭️ Prepare backup materials
4. ⏭️ Test all technical equipment
5. ⏭️ Rehearse Q&A responses

### For Production
1. ⏭️ Convert prototype to React/Next.js
2. ⏭️ Implement real WebSocket backend
3. ⏭️ Add map integration (Mapbox/Google Maps)
4. ⏭️ Connect to AWS IoT Core
5. ⏭️ Add authentication and authorization
6. ⏭️ Implement logging and monitoring

---

## 💡 Innovation Highlights

**What makes SkyRescue different:**

1. **Voice AI on drone** - No other AED delivery drone has conversational AI
2. **Edge-first architecture** - Runs offline, ultra-low latency
3. **Multi-language auto-detection** - Serves diverse communities
4. **Hybrid dialogue system** - Safety of scripts + flexibility of AI
5. **Real-time dispatcher visibility** - Live transcript and telemetry
6. **One-click launch** - AI handles everything after dispatcher decides

**Technical achievements in 4 hours:**
- Complete UI mockups with SkyRescue branding
- Full OpenAPI specification with 15+ endpoints
- Interactive HTML prototype with live simulation
- MQTT integration guide with code examples
- Comprehensive technical architecture documentation
- Workshop presentation with demo script and Q&A prep

---

## 📞 Contact

**Software Department Lead:** Michael Peter
**GitHub:** https://github.com/michaelryanpeter/CCS-AI-Lab

**Company Mission:** "First to the scene, first to save"

---

**Built with AI tools in <4 hours** 🚀
*Demonstrating AI-Powered Velocity: Speed over Perfection*
