-- 1. Drones Table: Tracks the physical fleet
CREATE TABLE Drones (
    drone_id SERIAL PRIMARY KEY,
    callsign VARCHAR(50) NOT NULL, -- e.g., "ResQ-Alpha"
    status VARCHAR(20) CHECK (status IN ('IDLE', 'EN_ROUTE', 'ON_SCENE', 'RETURNING', 'MAINTENANCE')),
    current_lat DECIMAL(9,6),
    current_lon DECIMAL(9,6),
    battery_level INT CHECK (battery_level BETWEEN 0 AND 100),
    capabilities JSONB -- e.g., {"thermal": true, "defibrillator": true}
);

-- 2. Incidents Table: Created by the Voice AI System
CREATE TABLE Incidents (
    incident_id SERIAL PRIMARY KEY,
    description TEXT NOT NULL, -- Transcribed from Voice AI
    priority_level VARCHAR(10) CHECK (priority_level IN ('CRITICAL', 'HIGH', 'MEDIUM', 'LOW')),
    location_lat DECIMAL(9,6),
    location_lon DECIMAL(9,6),
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

-- 3. DispatcherLog: The link between Voice commands and Drone actions
CREATE TABLE DispatcherLog (
    log_id SERIAL PRIMARY KEY,
    incident_id INT REFERENCES Incidents(incident_id),
    drone_id INT REFERENCES Drones(drone_id),
    command_issued VARCHAR(100), -- e.g., "Deploy to sector 4"
    voice_transcript TEXT,       -- Raw audio transcript
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Telemetry: High-frequency flight data
CREATE TABLE Telemetry (
    telemetry_id BIGSERIAL PRIMARY KEY,
    drone_id INT REFERENCES Drones(drone_id),
    altitude_meters DECIMAL(10,2),
    speed_kph DECIMAL(10,2),
    heading INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance (Crucial for Real-Time Dashboards)
CREATE INDEX idx_drone_status ON Drones(status);
CREATE INDEX idx_incident_active ON Incidents(status) WHERE status != 'RESOLVED';
CREATE INDEX idx_telemetry_time ON Telemetry(timestamp DESC);
