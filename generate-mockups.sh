#!/bin/bash
# Generate all UI mockups from declarative files

echo "🎨 Generating DroneAI UI Mockups..."
echo ""

cd ~/ai_lab/mockups

# Check if d2 is installed
if ! command -v d2 &> /dev/null; then
    echo "⚠️  D2 not found. Installing..."
    curl -fsSL https://d2lang.com/install.sh | sh -s --
fi

# Check if PlantUML is available
if ! command -v plantuml &> /dev/null; then
    echo "⚠️  PlantUML not found. Install with:"
    echo "   sudo dnf install plantuml"
    echo "   OR use online: https://www.plantuml.com/plantuml/uml/"
    echo ""
fi

# Generate D2 diagrams
echo "📐 Generating D2 diagrams..."

if command -v d2 &> /dev/null; then
    d2 --theme=200 drone-dashboard.d2 drone-dashboard.svg
    echo "   ✓ drone-dashboard.svg"

    d2 --theme=200 mission-planning.d2 mission-planning.svg
    echo "   ✓ mission-planning.svg"

    # Generate PNG versions too
    d2 --theme=200 drone-dashboard.d2 drone-dashboard.png
    d2 --theme=200 mission-planning.d2 mission-planning.png
    echo "   ✓ PNG versions created"
fi

# Generate PlantUML diagrams
echo ""
echo "🎨 Generating PlantUML wireframes..."

if command -v plantuml &> /dev/null; then
    plantuml dashboard.salt
    echo "   ✓ dashboard.png"
else
    echo "   ⚠️  Run manually:"
    echo "   plantuml dashboard.salt"
    echo "   OR paste content into: https://www.plantuml.com/plantuml/uml/"
fi

echo ""
echo "✅ Done! Generated files:"
echo ""
ls -lh *.svg *.png 2>/dev/null | awk '{print "   " $9 " (" $5 ")"}'
echo ""
echo "📂 View mockups:"
echo "   xdg-open drone-dashboard.svg"
echo "   xdg-open mission-planning.svg"
echo "   xdg-open dashboard.png"
echo ""
echo "🎯 Next steps:"
echo "   1. Review the generated mockups"
echo "   2. Edit the .d2 or .salt files to customize"
echo "   3. Re-run this script to regenerate"
