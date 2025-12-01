import asyncio
import random
import json
from datetime import datetime

# Load Mock Data (Simplified for script)
drones = [
    {"id": 101, "callsign": "ResQ-Alpha", "status": "EN_ROUTE", "battery": 82, "lat": 34.0522, "lon": -118.2437},
    {"id": 103, "callsign": "ResQ-Gamma", "status": "ON_SCENE", "battery": 45, "lat": 34.0600, "lon": -118.2500}
]

async def simulate_drone(drone):
    """Simulates a single drone's telemetry stream."""
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Connection established: {drone['callsign']}")
    
    while drone['battery'] > 0:
        # Simulate Movement (Random jitter for demo)
        drone['lat'] += random.uniform(-0.0001, 0.0001)
        drone['lon'] += random.uniform(-0.0001, 0.0001)
        
        # Simulate Battery Drain
        drain = random.choice([0, 0, 1]) # Randomly drain 1%
        drone['battery'] -= drain
        
        # Determine Status Log
        log_msg = {
            "timestamp": datetime.now().isoformat(),
            "drone_id": drone['id'],
            "coords": (round(drone['lat'], 6), round(drone['lon'], 6)),
            "battery": f"{drone['battery']}%",
            "status": drone['status']
        }
        
        print(f"TELEMETRY >> {json.dumps(log_msg)}")
        
        # Wait 2 seconds before next ping
        await asyncio.sleep(2)

async def main():
    print("--- STARTING RESQ DRONE DISPATCH SIMULATION ---")
    print("Initializing Voice AI Link... Connected.")
    print("Dispatching active fleet...")
    
    # Create tasks for all active drones
    tasks = [simulate_drone(d) for d in drones]
    await asyncio.gather(*tasks)

# To run this, you would strictly need Python installed, 
# but for the lab, you can copy this code block into your documentation.
# asyncio.run(main())
