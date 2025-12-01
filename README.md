# DroneAI Workshop - AI Lab

This directory contains all materials for the 4-hour AI-first drone company startup simulation.

## Directory Structure

```
ai_lab/
├── mockups/          # UI mockups (declarative)
│   ├── drone-dashboard.d2       # Main dashboard (D2 format)
│   ├── mission-planning.d2      # Mission planner (D2 format)
│   └── dashboard.salt           # Detailed wireframe (PlantUML)
├── api-docs/         # API documentation
├── prototype/        # Interactive HTML prototype
├── flows/            # User flow diagrams
└── generate-mockups.sh  # Script to generate all visualizations
```

## Quick Start

### 1. Generate UI Mockups

```bash
cd ~/ai_lab
./generate-mockups.sh
```

This will create SVG and PNG files from the declarative mockup definitions.

### 2. View Mockups

```bash
# View in browser/image viewer
xdg-open mockups/drone-dashboard.svg
xdg-open mockups/mission-planning.svg
xdg-open mockups/dashboard.png
```

### 3. Edit Mockups

The mockups are **declarative** - just edit the text files:

- **D2 files** (`.d2`): Modern diagram syntax
  - Edit `mockups/drone-dashboard.d2`
  - Edit `mockups/mission-planning.d2`
  - Re-run `./generate-mockups.sh` to regenerate

- **PlantUML files** (`.salt`): Detailed wireframes
  - Edit `mockups/dashboard.salt`
  - Run `plantuml dashboard.salt` or use online editor

## Tools Used

### D2 (Declarative Diagrams)

Install:
```bash
curl -fsSL https://d2lang.com/install.sh | sh -s --
```

Usage:
```bash
d2 mockups/drone-dashboard.d2 output.svg
d2 --theme=200 mockups/drone-dashboard.d2 output.svg  # Dark theme
```

### PlantUML (UI Wireframes)

Install:
```bash
sudo dnf install plantuml
```

Usage:
```bash
plantuml mockups/dashboard.salt
```

Or use online: https://www.plantuml.com/plantuml/uml/

## Mockup Files Explained

### drone-dashboard.d2
Main control dashboard with:
- Live video feed with AI overlay
- Real-time telemetry panel
- AI status indicators
- Flight mode controls
- Emergency buttons
- System log

### mission-planning.d2
Mission planning interface with:
- Map view with waypoints
- Mission parameters
- AI objectives configuration
- Mission validation controls

### dashboard.salt
Detailed wireframe showing:
- Exact layout and spacing
- All UI elements and labels
- System log with sample data
- Complete interaction elements

## Customization Guide

### Change Colors

Edit the D2 files and modify `style.fill` values:

```d2
VideoFeed: {
  style.fill: "#000000"  # Black background
  style.stroke: "#0A84FF"  # Blue border
}
```

DroneAI Color Palette:
- Primary: `#0A84FF` (Tech Blue)
- Success: `#30D158` (Active Green)
- Warning: `#FF9F0A` (Alert Orange)
- Danger: `#FF453A` (Emergency Red)
- Background: `#1C1C1E` (Dark)
- Panel: `#2C2C2E` (Card)

### Add New Elements

In D2, just add new blocks:

```d2
Dashboard: {
  NewPanel: {
    style.fill: "#2C2C2E"
    Title: "New Feature"
    Content: "Description"
  }
}
```

### Create Connections

Show data flow with arrows:

```d2
VideoFeed -> AIStatus: "AI Processing" {
  style.stroke: "#FF9F0A"
}
```

## Workshop Timeline

- **Hour 1:** Setup + UI Mockups (this directory)
- **Hour 2:** API Documentation (`api-docs/`)
- **Hour 3:** Interactive Prototype (`prototype/`)
- **Hour 4:** User Flows + Presentation (`flows/`)

## Next Steps

1. ✅ Generate mockups: `./generate-mockups.sh`
2. ⏭️ Review and customize the `.d2` and `.salt` files
3. ⏭️ Create API documentation in `api-docs/`
4. ⏭️ Build interactive prototype in `prototype/`
5. ⏭️ Design user flows in `flows/`

## Resources

- D2 Documentation: https://d2lang.com/
- PlantUML Guide: https://plantuml.com/salt
- Workshop Plan: `~/sessions/2025-12-01-ai-drone-workshop-plan.md`

---

**Need Help?**

- Edit any `.d2` file and run `./generate-mockups.sh`
- View generated files with `xdg-open mockups/*.svg`
- Check the workshop plan for detailed instructions
