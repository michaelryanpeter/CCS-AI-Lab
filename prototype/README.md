# SkyRescue Interactive Prototype

Fully functional HTML prototype of the dispatcher console with simulated mission workflow.

---

## Features

### ✅ Implemented

1. **SkyRescue Color Scheme**
   - Sky Blue (#00AEEF) - Primary UI elements
   - Neon Green (#39FF14) - Accents and active states
   - White (#FFFFFF) - Text and secondary elements
   - Charcoal (#333333) - Background

2. **Emergency Call Information**
   - Cardiac arrest alert display
   - Location details (address + coordinates)
   - Caller information
   - Bystander availability status

3. **AI Recommendation Panel**
   - Launch recommendation with confidence score
   - Nearest drone selection
   - ETA comparison (drone vs ambulance)
   - Weather and risk assessment
   - Battery and distance information

4. **Live Map Simulation**
   - Emergency location marker
   - Drone position and distance
   - Flight progress visualization
   - Real-time ETA countdown
   - Mission status updates

5. **Voice AI Transcript**
   - Live conversation between drone and bystander
   - Language detection display
   - Speaker identification (DRONE/BYSTANDER/AED)
   - Timestamps for all messages
   - Auto-scroll for new messages

6. **Drone Telemetry**
   - Real-time altitude, speed, battery
   - GPS status
   - AI detection count
   - Landing zone confidence

7. **Mission Log**
   - Chronological event timeline
   - Launch, flight, arrival, AED deployment events
   - Voice AI status updates

8. **Interactive Controls**
   - Launch button (triggers full simulation)
   - Voice mute/unmute control
   - Manual voice override (custom messages)

---

## How to Use

### Open Prototype

**Option 1: Direct Browser**
```bash
cd ~/ai_lab/prototype
xdg-open dispatcher-console.html
```

**Option 2: Simple HTTP Server** (recommended for full features)
```bash
cd ~/ai_lab/prototype
python3 -m http.server 8000
# Open http://localhost:8000/dispatcher-console.html
```

### Simulation Flow

1. **Initial State**
   - Emergency information displayed
   - AI recommendation shows 95% confidence to launch
   - Drone Alpha-3 is 2.1 miles away
   - ETA comparison: Drone 2:15 vs Ambulance 8:00

2. **Click "LAUNCH SKYRESCUE"**
   - Mission simulation begins
   - Flight progress bar activates
   - Telemetry updates in real-time
   - Mission log populates with events

3. **Flight Phase (0-30 seconds)**
   - Drone takes off
   - Altitude increases to 120m
   - Speed: 15 m/s
   - Distance to emergency decreases
   - GPS shows "Fixed (12 satellites)"
   - AI detections update randomly

4. **Arrival Phase (30-40 seconds)**
   - Drone reaches emergency location
   - Landing sequence begins
   - Altitude decreases to 0m
   - Landing zone confidence: 92%
   - **Voice AI activates**

5. **Voice Conversation (30-50 seconds)**
   - Drone initiates conversation:
     - "This is SkyRescue. I have an AED. Can you help?"
   - Bystander responds: "Yes! What do I do?!"
   - Drone guides through:
     - Breathing check
     - AED retrieval
     - AED activation
   - AED device takes over with instructions

6. **AED Deployment (50+ seconds)**
   - AED compartment opens
   - Bystander removes device
   - AED provides shock/CPR instructions
   - Mission status: "AED Deployed"

7. **Interactive Features** (during mission)
   - **Mute Button**: Toggle voice AI on/off
   - **Override Button**: Send custom voice commands
     - Click "Override"
     - Enter message in prompt
     - Drone will "speak" your message

---

## Simulation Timeline

| Time | Event |
|------|-------|
| 0:00 | Launch button clicked |
| 0:01 | Drone acknowledges launch |
| 0:03 | Takeoff complete |
| 0:05 | Autonomous flight active |
| 0:15 | Waypoint 1/3 reached |
| 0:25 | Landing zone detected (92% confidence) |
| 0:30 | **Arrived at scene** |
| 0:30 | Voice AI: "This is SkyRescue..." |
| 0:33 | Bystander: "Yes! What do I do?!" |
| 0:35 | Voice AI: Breathing check instructions |
| 0:39 | Bystander: "No! It's not moving!" |
| 0:41 | AED compartment opens |
| 0:45 | Bystander has AED |
| 0:47 | Voice AI: Turn on AED |
| 0:50 | AED device active |
| 2:15 | Mission complete |

---

## Customization

### Change Flight Duration

Edit line 294 in `dispatcher-console.html`:

```javascript
const totalFlightTime = 135; // 2:15 in seconds
// Change to desired duration (e.g., 180 for 3:00 minutes)
```

### Modify Conversation Script

Edit `conversationScript` array (line 276):

```javascript
const conversationScript = [
    { time: 30, speaker: 'DRONE', text: 'Your custom message' },
    { time: 33, speaker: 'BYSTANDER', text: 'Bystander response' },
    // Add more messages...
];
```

**Speaker options:**
- `'DRONE'` - Voice AI on drone
- `'BYSTANDER'` - Person at scene
- `'AED'` - AED device voice

### Add Custom Log Events

Edit `logEvents` array (line 287):

```javascript
const logEvents = [
    { time: 0, event: 'Your custom event' },
    // Add more events...
];
```

### Change Telemetry Values

Edit `updateFlight()` function (line 353) to modify:
- Altitude calculation
- Speed values
- GPS satellite count
- AI detection range
- Landing zone confidence

---

## Technical Details

### Technologies Used
- **HTML5**: Structure and semantic markup
- **CSS3**: Grid layout, animations, custom styling
- **Vanilla JavaScript**: Simulation logic, no frameworks

### Browser Compatibility
- ✅ Chrome/Edge (Chromium-based)
- ✅ Firefox
- ✅ Safari
- ⚠️ Internet Explorer (not supported)

### Performance
- **Lightweight**: Single 25KB HTML file
- **No dependencies**: Pure vanilla JavaScript
- **Smooth animations**: CSS transitions and transforms
- **Update frequency**: 1 second telemetry updates

---

## Workshop Demo Tips

### 1. Presenting the Prototype

**Start with overview:**
> "This is the SkyRescue dispatcher console that 911 operators will use. Let me show you a complete emergency response workflow."

**Click Launch and narrate:**
> "The dispatcher clicks LAUNCH, and the AI takes over. Watch the telemetry - the drone is flying autonomously at 15 m/s at 120 meters altitude."

**Highlight voice AI:**
> "At 30 seconds, the drone arrives and the voice AI activates automatically. See the conversation transcript - it's guiding the bystander through AED deployment in real-time."

**Show interactive features:**
> "Dispatchers can mute the drone if needed, or use the override button to send custom instructions."

### 2. Key Selling Points

1. **AI-Driven Decision Making**
   - 95% confidence score
   - Weather and risk assessment
   - Automatic drone selection

2. **Time Advantage**
   - Drone ETA: 2:15
   - Ambulance ETA: 8:00
   - **5 minutes 45 seconds faster**

3. **Voice AI Innovation**
   - Multi-language support (auto-detect)
   - Calm, clear instructions
   - Guides untrained bystanders
   - Works offline (edge AI)

4. **Full Autonomy**
   - Dispatcher launches with one click
   - AI handles flight, landing, AED deployment
   - Real-time telemetry and monitoring

### 3. Common Questions to Address

**Q: What if the bystander doesn't speak English?**
> The Voice AI auto-detects language using Whisper. See the "Language: English (detected)" indicator? That switches automatically to Spanish, Chinese, etc.

**Q: What if there's no cell signal?**
> All voice AI runs on the drone itself - Whisper for speech recognition, small LLM for dialogue, Piper for text-to-speech. No internet required.

**Q: How does the dispatcher know what's happening?**
> Everything is visible in real-time: live transcript of the conversation, telemetry showing exact drone position, and a mission log of all events.

**Q: What if the drone can't land safely?**
> The AI detects landing zones with 92% confidence. If confidence is too low, it will hover and wait, or return to base if instructed.

---

## Next Steps

1. ✅ Review prototype in browser
2. ⏭️ Test all interactive features
3. ⏭️ Customize for your demo scenario
4. ⏭️ Practice narration for workshop presentation

---

## Files in This Directory

```
prototype/
├── dispatcher-console.html   # Complete interactive prototype (this file)
└── README.md                  # This documentation
```

---

## For Developers

### Extracting Code

The prototype is a single HTML file with embedded CSS and JavaScript. To separate:

**Extract CSS:**
```bash
sed -n '/<style>/,/<\/style>/p' dispatcher-console.html > styles.css
```

**Extract JavaScript:**
```bash
sed -n '/<script>/,/<\/script>/p' dispatcher-console.html > app.js
```

### Convert to React Component

The prototype uses vanilla JS with clear state management. Key variables to track:
- `missionActive` - boolean
- `flightProgress` - 0-100
- `elapsedSeconds` - mission timer

Example React conversion:
```javascript
const [missionActive, setMissionActive] = useState(false);
const [flightProgress, setFlightProgress] = useState(0);
const [elapsedSeconds, setElapsedSeconds] = useState(0);

useEffect(() => {
  if (missionActive) {
    const interval = setInterval(() => {
      setElapsedSeconds(prev => prev + 1);
      setFlightProgress(prev => (prev / totalFlightTime) * 100);
    }, 1000);
    return () => clearInterval(interval);
  }
}, [missionActive]);
```

---

## Feedback & Improvements

This prototype demonstrates core functionality. Potential enhancements:

- **Real map integration** (Mapbox/Google Maps)
- **Actual WebSocket connection** to backend API
- **Audio playback** of voice conversation
- **Camera feed** (simulated video)
- **Multiple simultaneous missions**
- **Historical mission replay**

For the 4-hour workshop, this prototype is sufficient to demonstrate the complete user flow and AI capabilities.
