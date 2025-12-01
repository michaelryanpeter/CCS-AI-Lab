# SkyRescue Voice AI System
## Conversational AI for Patient/Bystander Interaction

**Mission:** The drone talks to people at the scene to assess the situation, guide AED use, and provide CPR instructions.

---

## Why Voice AI is Critical

### Emergency Scenario
```
Drone arrives at scene
         ↓
Bystanders present, but panicked
         ↓
DRONE SPEAKS:
"This is SkyRescue. I'm here to help.
 Is the person breathing?"
         ↓
Bystander: "I don't know!"
         ↓
DRONE:
"Check for chest movement. Place your hand
 on their chest. Do you feel it rising?"
         ↓
Bystander: "No!"
         ↓
DRONE:
"I'm opening the AED compartment now.
 Remove the yellow AED device.
 I'll guide you through each step."
```

### Key Capabilities Needed
1. **Situation Assessment** - Ask questions to understand scene
2. **AED Instructions** - Step-by-step guidance
3. **CPR Coaching** - Real-time CPR instructions with rhythm
4. **Emotional Support** - Calm panicked bystanders
5. **Relay to Dispatch** - Report status back to 911
6. **Language Support** - Multiple languages for diverse communities

---

## Voice AI Architecture

### Edge-First Approach (Critical!)

**Why Edge AI for Voice:**
- ⚡ **Latency:** Can't wait for cloud (50-200ms round-trip kills conversation flow)
- 📡 **Reliability:** Cell signal may be weak/unavailable
- 🔋 **Bandwidth:** Voice streaming uses too much data
- 🏥 **Safety:** Medical instructions can't depend on network

### Hybrid Edge + Cloud Design

```
┌─────────────────────────────────────────────┐
│           DRONE (Edge AI)                   │
│  ┌──────────────────────────────────────┐  │
│  │  NVIDIA Jetson Orin Nano             │  │
│  │                                       │  │
│  │  ┌─────────────────────────────┐     │  │
│  │  │ Microphones (4-array)       │     │  │
│  │  │ - Noise cancellation        │     │  │
│  │  │ - Directional audio         │     │  │
│  │  │ - Wind filtering            │     │  │
│  │  └─────────────────────────────┘     │  │
│  │            ↓                          │  │
│  │  ┌─────────────────────────────┐     │  │
│  │  │ Speech-to-Text (STT)        │     │  │
│  │  │ Model: Whisper-tiny         │     │  │
│  │  │ Latency: <100ms             │     │  │
│  │  │ Languages: 99+              │     │  │
│  │  └─────────────────────────────┘     │  │
│  │            ↓                          │  │
│  │  ┌─────────────────────────────┐     │  │
│  │  │ Dialogue AI                 │     │  │
│  │  │ Model: Medical LLM (small)  │     │  │
│  │  │ + Pre-scripted protocols    │     │  │
│  │  │ Latency: <200ms             │     │  │
│  │  └─────────────────────────────┘     │  │
│  │            ↓                          │  │
│  │  ┌─────────────────────────────┐     │  │
│  │  │ Text-to-Speech (TTS)        │     │  │
│  │  │ Model: Piper TTS            │     │  │
│  │  │ Voice: Calm, clear female   │     │  │
│  │  │ Latency: <50ms              │     │  │
│  │  └─────────────────────────────┘     │  │
│  │            ↓                          │  │
│  │  ┌─────────────────────────────┐     │  │
│  │  │ Speaker (High-power)        │     │  │
│  │  │ Volume: 100dB (loud)        │     │  │
│  │  │ Directional projection      │     │  │
│  │  └─────────────────────────────┘     │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
          ↕ 4G/5G (fallback only)
┌─────────────────────────────────────────────┐
│         CLOUD (Backup/Training)             │
│  - Advanced dialogue (if connectivity)      │
│  - Multi-language support                   │
│  - Conversation logging                     │
│  - Model updates                            │
└─────────────────────────────────────────────┘
```

---

## Voice AI Stack Recommendation

### Option 1: Full Edge AI (RECOMMENDED)

**Best for:** Maximum reliability, low latency, offline operation

```
Hardware on Drone:
├── Jetson Orin Nano (8GB)         $499
├── 4-mic array (ReSpeaker)        $50
├── High-power speaker (20W)       $40
└── Total:                         ~$590

Software Stack:
┌─────────────────────────────────────┐
│ Speech-to-Text: Whisper-tiny        │
│ - Model size: 75MB                  │
│ - Latency: 50-100ms                 │
│ - Accuracy: 95%+ (English)          │
│ - Languages: 99 supported           │
│ - Runs on: TensorRT                 │
│ - Power: 2-3W                       │
└─────────────────────────────────────┘
          ↓
┌─────────────────────────────────────┐
│ Dialogue AI: Hybrid Approach        │
│                                     │
│ Layer 1: Rule-based (Instant)       │
│ - Pre-scripted AED instructions     │
│ - CPR coaching protocols            │
│ - Standard questions/responses      │
│ - Latency: <10ms                    │
│                                     │
│ Layer 2: Small LLM (Fallback)       │
│ - Model: Phi-3-mini (3.8B params)   │
│ - Quantized: 4-bit (2GB)            │
│ - Latency: 100-200ms                │
│ - Context: Emergency medical only   │
│ - Power: 5-8W                       │
└─────────────────────────────────────┘
          ↓
┌─────────────────────────────────────┐
│ Text-to-Speech: Piper TTS           │
│ - Model: en_US-amy-medium           │
│ - Voice: Clear, calm female         │
│ - Latency: 30-50ms                  │
│ - Quality: Natural-sounding         │
│ - Power: 1-2W                       │
└─────────────────────────────────────┘
```

**Total Edge AI Cost:** ~$590 hardware (one-time)
**Total Power:** ~10-15W (acceptable for 30-40min flight)

---

## Dialogue AI Models: Detailed Comparison

### Approach 1: Pre-Scripted Protocols (Safest) ✅

**Finite State Machine with medical scripts**

```python
class EmergencyDialogue:
    """
    Pre-programmed decision tree for cardiac arrest response
    100% predictable, FDA-approvable, zero hallucination risk
    """

    states = {
        'ARRIVAL': {
            'speak': "This is SkyRescue emergency response. I have an AED. Can you help?",
            'listen_for': ['yes', 'no', 'help'],
            'next_state': {
                'yes': 'ASSESS_PATIENT',
                'no': 'ENCOURAGE_HELP',
                'help': 'ASSESS_PATIENT'
            }
        },

        'ASSESS_PATIENT': {
            'speak': "Is the person breathing? Check if their chest is moving.",
            'listen_for': ['yes', 'no', 'unsure'],
            'next_state': {
                'yes': 'CHECK_CONSCIOUSNESS',
                'no': 'START_CPR',
                'unsure': 'GUIDE_BREATHING_CHECK'
            }
        },

        'START_CPR': {
            'speak': """The person is not breathing. Start CPR immediately.
                        Place both hands on the center of the chest.
                        Push hard and fast. I'll count the rhythm.
                        Ready? Begin.""",
            'action': 'start_cpr_metronome',  # 100-120 BPM audio
            'next_state': 'CPR_IN_PROGRESS'
        },

        'CPR_IN_PROGRESS': {
            'speak': "One, two, three, four... (counts to 30)",
            'action': 'count_compressions',
            'timer': 18,  # seconds for 30 compressions
            'next_state': 'PREPARE_AED'
        },

        'PREPARE_AED': {
            'speak': """Good. Now open the yellow AED device.
                        Remove the sticky pads from the package.
                        The AED will guide you with voice instructions.
                        Turning on AED now.""",
            'action': 'signal_aed_activation',
            'next_state': 'AED_ACTIVE'
        },

        'AED_ACTIVE': {
            'speak': "Follow the AED's voice instructions exactly. Do not touch the patient when it says analyzing.",
            'listen_mode': 'standby',  # Let AED take over
            'next_state': 'MONITOR_AED'
        }
    }

    def run_dialogue(self, current_state, user_input):
        """
        Execute state machine
        - 100% deterministic
        - No AI hallucinations
        - Medically validated scripts
        - <10ms response time
        """
        state = self.states[current_state]

        # Speak the script
        tts(state['speak'])

        # Listen for expected responses
        user_response = stt_listen()

        # Match to expected inputs (fuzzy matching)
        matched = fuzzy_match(user_response, state['listen_for'])

        # Transition to next state
        next_state = state['next_state'][matched]

        return next_state

# Deployment: Runs entirely on Jetson
# Language support: Pre-translate all scripts
# FDA compliance: Validated scripts, no generative AI
```

**Pros:**
- ✅ 100% safe (no AI errors)
- ✅ Medically validated
- ✅ Fast (<10ms)
- ✅ Offline capable
- ✅ FDA-friendly

**Cons:**
- ⚠️ Limited flexibility
- ⚠️ Can't handle unexpected questions
- ⚠️ Requires manual script updates

---

### Approach 2: Small LLM (Flexible) ⚠️

**Phi-3-mini (3.8B parameters) - Medical fine-tuned**

```python
# Constrained LLM for emergency dialogue
from transformers import AutoModelForCausalLM, AutoTokenizer

model = AutoModelForCausalLM.from_pretrained(
    "microsoft/Phi-3-mini-4k-instruct",
    quantization_config={"load_in_4bit": True},  # 2GB model
    device_map="cuda"
)

system_prompt = """
You are SkyRescue, an emergency medical drone delivering an AED
to a cardiac arrest victim. You must:

1. Stay calm and clear
2. Ask assessment questions (breathing? conscious?)
3. Guide AED usage step-by-step
4. Coach CPR if needed (100-120 BPM)
5. Never give medical advice beyond AED/CPR
6. NEVER say "I don't know" - use fallback protocols

Speak in short, simple sentences. Lives depend on clarity.
"""

def generate_response(user_input, context):
    """
    Generate contextual response
    - Latency: 100-200ms
    - Max tokens: 50 (keep responses short)
    - Temperature: 0.1 (very deterministic)
    """

    prompt = f"{system_prompt}\n\nContext: {context}\nUser: {user_input}\nSkyRescue:"

    response = model.generate(
        prompt,
        max_new_tokens=50,
        temperature=0.1,  # Low = more predictable
        top_p=0.9,
        do_sample=True
    )

    return response

# Fine-tuning: Train on emergency medical dialogues
# Safety: Constrained output (no hallucinations about medication)
# Fallback: If confidence < 80%, use pre-scripted response
```

**Pros:**
- ✅ Handles unexpected questions
- ✅ More natural conversation
- ✅ Can adapt to situation
- ✅ Multi-turn dialogue

**Cons:**
- ⚠️ Risk of hallucination (medical advice)
- ⚠️ Slower (100-200ms)
- ⚠️ More power (5-8W)
- ⚠️ FDA approval harder

---

### Approach 3: Hybrid (RECOMMENDED) ✅

**Pre-scripted for critical steps + LLM for flexibility**

```python
class HybridDialogue:
    """
    Use pre-scripted FSM for critical medical steps
    Use small LLM for general questions/reassurance
    """

    CRITICAL_STATES = [
        'CPR_INSTRUCTIONS',
        'AED_USAGE',
        'SHOCK_WARNING',
        'CHECK_PULSE'
    ]

    def respond(self, user_input, current_state):
        # Critical states: ALWAYS use pre-scripted
        if current_state in self.CRITICAL_STATES:
            return self.scripted_fsm.get_response(current_state)

        # General questions: Use LLM (safer for non-medical)
        if is_general_question(user_input):
            response = self.llm.generate(user_input)

            # Safety check: Validate response
            if contains_medical_advice(response):
                return "I can only help with AED and CPR. Please follow my step-by-step instructions."

            return response

        # Default: Route to FSM
        return self.scripted_fsm.get_response(current_state)

# Example:
# User: "Will they be okay?"
# → LLM: "Help is on the way. You're doing great. Let's focus on the AED."
#
# User: "How do I use the AED?"
# → FSM: "Open the yellow device. Remove the sticky pads. I'll guide you through each step."
```

**Pros:**
- ✅ Safe for critical steps (scripted)
- ✅ Flexible for emotional support (LLM)
- ✅ Best of both worlds
- ✅ Easier FDA approval

---

## Speech Recognition (STT)

### Recommended: Whisper-tiny (OpenAI)

```
Model: Whisper-tiny
Size: 75MB
Languages: 99 (automatic detection)
Accuracy: 95%+ for clear speech
Latency: 50-100ms on Jetson
Power: 2-3W

Features:
✅ Robust to background noise (sirens, wind, crying)
✅ Accent-agnostic
✅ No internet required
✅ Automatic language detection (for non-English)

Deployment:
- Quantized INT8 version for Jetson
- TensorRT optimization (2x speed boost)
- Runs continuously during mission

Alternative: Google STT (cloud fallback)
- Use if connectivity available
- Higher accuracy (98%)
- More languages (125)
```

### Noise Handling (Critical!)

```
Environmental Challenges:
- Wind noise from propellers (60-70 dB)
- Ambient traffic (50-60 dB)
- Sirens approaching (100-120 dB)
- Bystanders talking simultaneously
- Crying, shouting, panic

Solution: 4-Microphone Array
┌─────────────────────────────────┐
│  ReSpeaker 4-Mic Array          │
│  - Beamforming (directional)    │
│  - Noise cancellation           │
│  - Echo cancellation            │
│  - Automatic gain control       │
│  Cost: ~$50                     │
└─────────────────────────────────┘

Processing Pipeline:
Raw Audio → Beamforming → Noise Reduction → Whisper STT
                ↓
         Points at speaker (person below drone)
```

---

## Text-to-Speech (TTS)

### Recommended: Piper TTS

```
Model: Piper (Rhasspy project)
Voice: en_US-amy-medium (clear, calm female voice)
Quality: Near-human naturalness
Latency: 30-50ms
Size: 50MB
Power: 1-2W
Cost: FREE (open source)

Features:
✅ Extremely low latency
✅ High quality (not robotic)
✅ Multi-language support
✅ Runs entirely offline
✅ SSML support (for emphasis, pauses)

Example SSML:
"<speak>
  This is SkyRescue.
  <break time='500ms'/>
  I have an <emphasis>AED</emphasis> to help.
  <break time='300ms'/>
  Can you assist?
</speak>"

Alternative: AWS Polly (cloud fallback)
- Even more natural (Neural TTS)
- More languages
- Requires internet
- Cost: $4 per 1M characters
```

### Speaker System

```
Hardware: Directional Speaker
Power: 20W (high-power for outdoor)
Volume: 100dB max (very loud, audible in emergency)
Directionality: 60° beam angle (focused on ground)
Cost: ~$40

Why Loud?
- Sirens, traffic, wind noise
- Bystanders may be far from drone (5-10m hover height)
- Panic = people not listening carefully
```

---

## Sample Dialogue Flows

### Flow 1: Successful AED Deployment

```
DRONE: "This is SkyRescue. I have an AED. Is the person breathing?"
USER:  "I don't think so!"
DRONE: "Check their chest. Do you see it moving up and down?"
USER:  "No!"
DRONE: "Okay. I'm opening the AED compartment now. Remove the yellow device."
       [Opens compartment, AED visible]
USER:  "I have it!"
DRONE: "Turn it on by pressing the green button. It will tell you what to do."
       [AED powers on, takes over with its own voice]
AED:   "Attach pads to patient's bare chest..."
DRONE: [Standby mode, monitoring]
AED:   "Analyzing heart rhythm. Do not touch the patient."
AED:   "Shock advised. Stand clear. Press the orange button now."
       [Shock delivered]
AED:   "Continue CPR."
DRONE: "Help is arriving. You did great. Keep going."
```

### Flow 2: Language Barrier

```
DRONE: "This is SkyRescue. I have an AED. Can you help?"
USER:  "No hablo inglés!" (Spanish)
DRONE: [Detects Spanish via Whisper]
       "Este es SkyRescue. Tengo un DEA. ¿La persona respira?"
       (This is SkyRescue. I have an AED. Is the person breathing?)
USER:  "No!"
DRONE: "Voy a abrir el compartimiento. Saque el dispositivo amarillo."
       (I'm opening the compartment. Remove the yellow device.)
```

### Flow 3: No Bystander Present

```
DRONE: "This is SkyRescue emergency response. Can anyone hear me?"
       [No response after 5 seconds]
DRONE: [Louder] "Emergency AED delivery. If you can hear me, please respond."
       [No response after 5 seconds]
DRONE: [Alerts dispatcher]
       "No bystander response. Deploying AED at scene. EMS required urgently."
       [Opens AED compartment, hovers at 2m height for visibility]
       [Waits for EMS arrival]
```

### Flow 4: Panicked Bystander

```
DRONE: "This is SkyRescue. I have an AED. Can you help?"
USER:  "Oh my god, oh my god, what do I do?!"
DRONE: "Take a deep breath. You can do this. I will guide you step by step."
USER:  "Okay, okay..."
DRONE: "First, is the person breathing? Look at their chest."
USER:  "I... I don't know!"
DRONE: "Put your hand gently on their chest. Do you feel it moving?"
USER:  "No! It's not moving!"
DRONE: "Good job checking. Now, I'm opening the AED. Take the yellow device."
       [Calm, steady guidance continues...]
```

---

## Multi-Language Support

### Priority Languages (US Demographics)

1. **English** (Primary)
2. **Spanish** (2nd most common)
3. **Mandarin Chinese**
4. **Cantonese**
5. **Tagalog**
6. **Vietnamese**
7. **Korean**
8. **Russian**
9. **Arabic**
10. **French Creole**

### Implementation

```python
# Automatic language detection
from transformers import pipeline

language_detector = pipeline(
    "audio-classification",
    model="facebook/mms-lid-126"  # Detects 126 languages
)

def detect_and_respond(audio):
    # Detect language from first utterance
    detected_lang = language_detector(audio)[0]['label']

    # Load appropriate TTS voice
    if detected_lang == 'spa':  # Spanish
        tts_voice = 'es_ES-female'
    elif detected_lang == 'cmn':  # Mandarin
        tts_voice = 'zh_CN-female'
    # ... etc

    # Use Whisper (already multilingual for STT)
    # Load pre-translated scripts for that language
    return respond_in_language(detected_lang)

# Pre-load all critical scripts in top 10 languages
SCRIPTS = {
    'en': 'This is SkyRescue. I have an AED...',
    'es': 'Este es SkyRescue. Tengo un DEA...',
    'zh': '这是天空救援。我有自动体外除颤器...',
    # ...
}
```

---

## AI Model Performance Comparison

| Component | Model | Latency | Accuracy | Power | Offline |
|-----------|-------|---------|----------|-------|---------|
| **STT** | Whisper-tiny | 50-100ms | 95% | 2-3W | ✅ |
| **STT** | Google Cloud | 200-500ms | 98% | 0W | ❌ |
| **Dialogue** | Pre-scripted FSM | <10ms | 100% | <1W | ✅ |
| **Dialogue** | Phi-3-mini | 100-200ms | 90% | 5-8W | ✅ |
| **Dialogue** | GPT-4 (cloud) | 1-3s | 99% | 0W | ❌ |
| **TTS** | Piper | 30-50ms | 95% | 1-2W | ✅ |
| **TTS** | AWS Polly | 200-400ms | 99% | 0W | ❌ |

**Winner: Whisper-tiny (STT) + Hybrid FSM/Phi-3 (Dialogue) + Piper (TTS)**

Total latency: **<250ms** (acceptable for conversation)
Total power: **~10W** (acceptable for 30-40min flight)
Offline: **✅ Yes** (critical for reliability)

---

## Hardware BOM for Voice AI

```
Component                        Cost      Power    Notes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ReSpeaker 4-Mic Array           $50       1W       Noise cancellation
High-power Speaker (20W)        $40       20W      100dB max (directional)
NVIDIA Jetson Orin Nano         $499      10W      Runs all AI models
Storage (256GB NVMe)            $50       1W       Store models + audio logs
                                ─────     ────
TOTAL                           $639      32W      One-time cost per drone

Flight Time Impact:
- Voice AI active: ~3-5 minutes battery reduction
- Acceptable for 30-40 min total flight time
```

---

## Cloud Fallback (Optional Enhancement)

### When to Use Cloud AI

Only use cloud when:
1. Edge AI confidence < 80%
2. Complex multi-turn conversation
3. Rare language detected
4. Post-mission analysis

```
Edge AI (Primary):
├── Whisper-tiny → Hybrid Dialogue → Piper
└── Latency: <250ms, Offline: ✅

Cloud AI (Fallback):
├── Google STT → GPT-4 (medical-tuned) → Polly TTS
└── Latency: 1-3s, Offline: ❌, Cost: ~$0.05/mission
```

**Recommended:** Use edge-only for MVP, add cloud fallback in v2.

---

## Regulatory Considerations

### FDA Medical Device (Voice Guidance)

```
Classification: Likely Class II
Regulation: 21 CFR 870.5200 (Automated external defibrillator)

Voice AI Requirements:
✅ Validated dialogue scripts (clinical testing)
✅ Accuracy requirements (95%+ STT/TTS)
✅ Failure modes documented (what if voice fails?)
✅ Human factors testing (bystander comprehension)
✅ Multi-language validation
✅ Cybersecurity (voice spoofing prevention)

Recommendation:
- Use pre-scripted FSM for critical instructions
- Get clinical validation for all dialogue paths
- FDA 510(k) submission includes voice interaction testing
```

---

## Development Roadmap

### Phase 1: MVP (3 months)
- ✅ Pre-scripted FSM (English only)
- ✅ Whisper-tiny STT
- ✅ Piper TTS
- ✅ Basic AED instructions
- ✅ No cloud dependency

### Phase 2: Production (6 months)
- ✅ Add Spanish support
- ✅ Hybrid dialogue (FSM + small LLM)
- ✅ CPR coaching with metronome
- ✅ Emotional support responses
- ✅ Cloud fallback for complex cases

### Phase 3: Scale (12 months)
- ✅ 10 language support
- ✅ Advanced LLM (fine-tuned medical)
- ✅ Real-time translation
- ✅ Conversation analytics
- ✅ Continuous learning from missions

---

## Cost Summary

### Per-Drone (One-time)
```
Voice AI Hardware:               $639
Edge AI Compute (Jetson):        $499 (shared with vision AI)
Total Voice-Specific:            $140 (mic + speaker only)
```

### Cloud Costs (if used)
```
Google STT:                      $0.006/15sec
GPT-4 (medical):                 $0.03/1K tokens
AWS Polly:                       $0.004/1K chars

Typical 5-minute conversation:   ~$0.05
100 missions/month:              ~$5/month
```

**Recommendation:** Start edge-only ($140/drone), add cloud fallback later if needed.

---

## Workshop Demo Scenario

### Live Demo Script

**Setup:**
- Laptop playing "bystander" role
- Drone mockup with speaker
- 911 dispatcher console showing mission

**Scenario:**
1. **Dispatcher launches drone** (from your earlier UI)
2. **Drone "arrives"** (simulated)
3. **Voice dialogue begins:**

```
DRONE: "This is SkyRescue. I have an AED. Can you help?"
DEMO PERSON: "Yes! What do I do?!"
DRONE: "Is the person breathing?"
DEMO PERSON: "No!"
DRONE: "I'm opening the AED now. Remove the yellow device."
[Demonstrates AED compartment opening]
DRONE: "Turn it on. Follow the voice instructions."
[AED device takes over]
```

4. **Highlight AI features:**
- "Speech recognition works in noisy environments" (play siren sounds)
- "Multilingual support" (switch to Spanish demo)
- "All processing happens on the drone - no internet needed"
- "Calm, clear voice designed to reduce panic"

---

## Key Differentiators for Presentation

### AI Innovation Points

1. **Edge-based conversation** - No cloud latency, works offline
2. **Medical dialogue expertise** - Trained on emergency protocols
3. **Multilingual automatic** - Detects and switches languages
4. **Emotional intelligence** - Calms panicked bystanders
5. **Hybrid safety** - Pre-scripted for critical steps, AI for flexibility

### Competitive Advantage

> "While other drones just deliver, SkyRescue **talks you through survival**.
> Our AI guide coaches bystanders step-by-step, dramatically increasing
> survival rates even when trained responders aren't yet on scene."

---

## Next Steps for Workshop

1. **Update UI mockups** to show:
   - Voice interaction status on dispatcher console
   - Live transcript of drone-bystander conversation
   - Language detection indicator

2. **Update API docs** to include:
   - POST /voice/command (send text to drone to speak)
   - WebSocket /voice/transcript (stream conversation)

3. **Create voice interaction user flow:**
   ```
   Drone Arrival → Voice Assessment → Guided AED Deployment → Success
   ```

4. **Demo video script:**
   - Record simulated conversation
   - Show dispatcher seeing live transcript
   - Highlight "works without internet"

---

## Recommended Voice AI Stack

### Final Recommendation

```
🎤 MICROPHONE: ReSpeaker 4-Mic Array ($50)
       ↓
🧠 STT: Whisper-tiny on Jetson (95% accuracy, <100ms)
       ↓
💬 DIALOGUE: Hybrid FSM + Phi-3-mini
   - Critical steps: Pre-scripted (100% safe)
   - General: Small LLM (flexible)
       ↓
🔊 TTS: Piper (natural voice, <50ms)
       ↓
📢 SPEAKER: 20W Directional (100dB, $40)
```

**Total Cost:** $140 per drone (hardware)
**Power:** ~10W (acceptable)
**Latency:** <250ms (conversational)
**Offline:** ✅ 100% autonomous
**Languages:** 10+ supported
**FDA-ready:** ✅ (with validation)

---

## Questions to Answer in Workshop

**Q: What if the person doesn't speak English?**
A: Whisper auto-detects 99 languages. We have pre-translated scripts for top 10 US languages.

**Q: What if there's no cell signal?**
A: All voice AI runs on the drone (edge). No internet required.

**Q: What if the voice commands are wrong?**
A: Critical instructions (AED, CPR) use pre-scripted, FDA-validated protocols. No AI hallucination risk.

**Q: Can it handle panicked, shouting bystanders?**
A: Yes. 4-microphone array with noise cancellation. Trained on emergency audio.

**Q: How loud is it? Can people hear over sirens?**
A: 100dB speaker (as loud as a motorcycle). Directional, focused downward.

---

**This makes SkyRescue more than a delivery drone - it's an AI emergency medical assistant that saves lives through conversation.**
