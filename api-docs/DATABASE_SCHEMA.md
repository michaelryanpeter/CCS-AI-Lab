# SkyRescue Database Schema
## Multi-Database Architecture for Emergency Response

---

## Database Strategy

SkyRescue uses a **polyglot persistence** approach with specialized databases for different data types:

```
┌─────────────────────────────────────────────────┐
│         OPERATIONAL DATA (Primary)              │
│  PostgreSQL + PostGIS + TimescaleDB             │
│  - Mission records                              │
│  - Drone fleet management                       │
│  - Geographic data (locations, no-fly zones)    │
│  - Time-series telemetry                        │
└─────────────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────────────┐
│         REAL-TIME CACHE                         │
│  Redis                                          │
│  - Active mission state                         │
│  - Drone availability status                    │
│  - Rate limiting                                │
│  - Session management                           │
└─────────────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────────────┐
│         ANALYTICS & ML                          │
│  Amazon DynamoDB / S3                           │
│  - Voice transcripts (7-day retention)          │
│  - Model training data                          │
│  - Historical mission logs                      │
│  - Performance metrics                          │
└─────────────────────────────────────────────────┘
```

---

## Primary Database: PostgreSQL

### Extensions Required

```sql
-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";     -- UUID generation
CREATE EXTENSION IF NOT EXISTS "postgis";       -- Geographic data
CREATE EXTENSION IF NOT EXISTS "timescaledb";   -- Time-series data
CREATE EXTENSION IF NOT EXISTS "pg_trgm";       -- Fuzzy text search
```

---

## Core Tables

### 1. Emergencies

Stores 911 emergency call information.

```sql
CREATE TABLE emergencies (
    emergency_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Emergency details
    emergency_type VARCHAR(50) NOT NULL,  -- 'cardiac_arrest', 'respiratory_arrest', etc.
    call_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Location (PostGIS geography type)
    location_point GEOGRAPHY(POINT, 4326) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(2),
    zip_code VARCHAR(10),

    -- Caller information
    caller_phone VARCHAR(20),
    caller_on_scene BOOLEAN DEFAULT FALSE,
    bystander_available BOOLEAN DEFAULT FALSE,
    caller_language VARCHAR(10) DEFAULT 'en',

    -- Additional context
    victim_age INTEGER,
    symptoms TEXT,
    additional_info JSONB,

    -- CAD system integration
    cad_incident_id VARCHAR(100),  -- External 911 CAD ID
    dispatch_center_id VARCHAR(50),

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Indexes
    INDEX idx_emergencies_timestamp (call_timestamp DESC),
    INDEX idx_emergencies_location USING GIST (location_point),
    INDEX idx_emergencies_type (emergency_type),
    INDEX idx_emergencies_cad (cad_incident_id)
);

-- Trigger to update updated_at
CREATE TRIGGER update_emergencies_updated_at
    BEFORE UPDATE ON emergencies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

### 2. Drones

Fleet inventory and status.

```sql
CREATE TABLE drones (
    drone_id VARCHAR(50) PRIMARY KEY,  -- e.g., 'Alpha-3'

    -- Hardware specifications
    model VARCHAR(100) NOT NULL DEFAULT 'SkyRescue SR-1000',
    serial_number VARCHAR(100) UNIQUE NOT NULL,
    manufacture_date DATE,

    -- AI compute
    ai_compute_model VARCHAR(100) DEFAULT 'NVIDIA Jetson Orin Nano 8GB',
    firmware_version VARCHAR(20),
    ai_model_version VARCHAR(20),
    voice_ai_enabled BOOLEAN DEFAULT TRUE,

    -- Current status
    status VARCHAR(20) NOT NULL,  -- 'READY', 'CHARGING', 'IN_FLIGHT', 'MAINTENANCE', 'OFFLINE'
    battery_level INTEGER CHECK (battery_level >= 0 AND battery_level <= 100),

    -- Location (current position)
    current_location GEOGRAPHY(POINT, 4326),
    current_altitude_meters DECIMAL(6, 2),

    -- Home base
    base_station_id VARCHAR(50),
    base_location GEOGRAPHY(POINT, 4326),

    -- Mission history
    total_missions INTEGER DEFAULT 0,
    total_flight_hours DECIMAL(10, 2) DEFAULT 0,
    last_mission_at TIMESTAMPTZ,
    last_maintenance_at TIMESTAMPTZ,
    next_maintenance_due DATE,

    -- Health metrics
    hardware_health JSONB,  -- {motors: 'OK', cameras: 'OK', gps: 'OK', etc.}

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Indexes
    INDEX idx_drones_status (status),
    INDEX idx_drones_battery (battery_level),
    INDEX idx_drones_location USING GIST (current_location),
    INDEX idx_drones_base (base_station_id)
);
```

---

### 3. Missions

Complete mission records from launch to completion.

```sql
CREATE TABLE missions (
    mission_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Relations
    emergency_id UUID NOT NULL REFERENCES emergencies(emergency_id),
    drone_id VARCHAR(50) NOT NULL REFERENCES drones(drone_id),

    -- Dispatcher
    dispatcher_id VARCHAR(100) NOT NULL,
    dispatcher_name VARCHAR(200),

    -- Mission status
    status VARCHAR(30) NOT NULL,
    -- 'LAUNCHED', 'IN_FLIGHT', 'ARRIVED', 'LANDED', 'AED_DEPLOYED',
    -- 'RETURNING', 'COMPLETED', 'ABORTED'

    -- Destination
    destination_location GEOGRAPHY(POINT, 4326) NOT NULL,
    destination_address TEXT,

    -- Flight details
    launch_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    arrival_time TIMESTAMPTZ,
    aed_deployed_time TIMESTAMPTZ,
    completion_time TIMESTAMPTZ,

    -- ETAs (estimated time of arrival)
    estimated_eta_seconds INTEGER,
    actual_eta_seconds INTEGER,  -- Calculated from launch_time to arrival_time

    -- Flight path (GeoJSON LineString)
    flight_path GEOGRAPHY(LINESTRING, 4326),

    -- Voice AI
    voice_ai_active BOOLEAN DEFAULT FALSE,
    language_detected VARCHAR(10),
    total_voice_exchanges INTEGER DEFAULT 0,
    conversation_state VARCHAR(50),  -- Current FSM state

    -- AI decision data
    ai_recommendation JSONB,  -- Store the /emergency/assess response
    risk_assessment_score INTEGER,
    landing_zone_confidence DECIMAL(3, 2),

    -- Outcome
    aed_successfully_deployed BOOLEAN,
    bystander_used_aed BOOLEAN,
    shock_delivered BOOLEAN,
    ambulance_arrival_time TIMESTAMPTZ,
    patient_outcome VARCHAR(50),  -- 'SURVIVED', 'TRANSPORTED', 'DECEASED', 'UNKNOWN'

    -- Abort information (if applicable)
    abort_reason TEXT,
    abort_time TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Indexes
    INDEX idx_missions_status (status),
    INDEX idx_missions_drone (drone_id),
    INDEX idx_missions_emergency (emergency_id),
    INDEX idx_missions_launch_time (launch_time DESC),
    INDEX idx_missions_destination USING GIST (destination_location)
);
```

---

### 4. Telemetry (TimescaleDB Hypertable)

Real-time drone telemetry data - optimized for time-series queries.

```sql
CREATE TABLE telemetry (
    time TIMESTAMPTZ NOT NULL,
    mission_id UUID NOT NULL REFERENCES missions(mission_id),
    drone_id VARCHAR(50) NOT NULL REFERENCES drones(drone_id),

    -- Position
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    altitude_meters DECIMAL(6, 2) NOT NULL,

    -- Movement
    speed_ms DECIMAL(5, 2),  -- meters per second
    heading_degrees DECIMAL(5, 2),  -- 0-360

    -- Status
    battery_level INTEGER CHECK (battery_level >= 0 AND battery_level <= 100),
    gps_satellites INTEGER,
    gps_fix_quality VARCHAR(20),  -- 'NO_FIX', 'GPS', 'DGPS', 'RTK'

    -- AI detections
    obstacles_detected INTEGER DEFAULT 0,
    persons_detected INTEGER DEFAULT 0,
    landing_zone_confidence DECIMAL(3, 2),

    -- Navigation
    navigation_mode VARCHAR(20),  -- 'MANUAL', 'ASSISTED', 'AUTONOMOUS'
    distance_to_destination_meters DECIMAL(10, 2),

    -- System health
    temperature_celsius DECIMAL(4, 1),

    PRIMARY KEY (time, mission_id)
);

-- Convert to TimescaleDB hypertable (partitioned by time)
SELECT create_hypertable('telemetry', 'time');

-- Create continuous aggregates for analytics
CREATE MATERIALIZED VIEW telemetry_1min
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 minute', time) AS bucket,
    mission_id,
    drone_id,
    AVG(speed_ms) AS avg_speed,
    AVG(altitude_meters) AS avg_altitude,
    MIN(battery_level) AS min_battery,
    MAX(battery_level) AS max_battery
FROM telemetry
GROUP BY bucket, mission_id, drone_id;

-- Retention policy: Keep raw telemetry for 90 days
SELECT add_retention_policy('telemetry', INTERVAL '90 days');
```

---

### 5. Voice Transcripts

Conversation logs between drone and bystanders.

```sql
CREATE TABLE voice_transcripts (
    transcript_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mission_id UUID NOT NULL REFERENCES missions(mission_id),

    -- Message details
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    speaker VARCHAR(20) NOT NULL,  -- 'DRONE', 'BYSTANDER', 'AED_DEVICE'
    text TEXT NOT NULL,

    -- Recognition metadata
    language VARCHAR(10) NOT NULL,
    confidence_score DECIMAL(3, 2),  -- 0.00 to 1.00
    audio_duration_ms INTEGER,

    -- AI model info
    stt_model VARCHAR(50),  -- e.g., 'whisper-tiny-v3'
    dialogue_model VARCHAR(50),  -- e.g., 'phi-3-mini' or 'FSM'
    is_scripted_response BOOLEAN DEFAULT FALSE,

    -- Context
    conversation_state VARCHAR(50),  -- FSM state when message was generated

    -- Indexes
    INDEX idx_voice_transcripts_mission (mission_id),
    INDEX idx_voice_transcripts_time (timestamp DESC),
    INDEX idx_voice_transcripts_speaker (speaker)
);

-- Retention policy: 7 days for HIPAA compliance
CREATE OR REPLACE FUNCTION delete_old_voice_transcripts()
RETURNS void AS $$
BEGIN
    DELETE FROM voice_transcripts
    WHERE timestamp < NOW() - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

-- Schedule daily cleanup
CREATE EXTENSION IF NOT EXISTS pg_cron;
SELECT cron.schedule('delete-old-transcripts', '0 2 * * *', 'SELECT delete_old_voice_transcripts()');
```

---

### 6. Mission Events

Discrete events during mission execution.

```sql
CREATE TABLE mission_events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mission_id UUID NOT NULL REFERENCES missions(mission_id),

    -- Event details
    event_type VARCHAR(50) NOT NULL,
    -- 'LAUNCH_ACKNOWLEDGED', 'TAKEOFF_COMPLETE', 'ARRIVED_AT_SCENE',
    -- 'LANDING_INITIATED', 'LANDED', 'AED_COMPARTMENT_OPENED',
    -- 'AED_DEPLOYED', 'VOICE_CONVERSATION_STARTED', 'EMERGENCY_LAND', etc.

    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    event_data JSONB,  -- Additional structured data

    -- Source
    source VARCHAR(50),  -- 'DRONE', 'CLOUD', 'DISPATCHER'

    -- Indexes
    INDEX idx_mission_events_mission (mission_id),
    INDEX idx_mission_events_type (event_type),
    INDEX idx_mission_events_time (timestamp DESC)
);
```

---

### 7. Base Stations

Drone charging and storage facilities.

```sql
CREATE TABLE base_stations (
    base_station_id VARCHAR(50) PRIMARY KEY,

    -- Location
    name VARCHAR(200) NOT NULL,
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(2),

    -- Facility details
    facility_type VARCHAR(50),  -- 'FIRE_STATION', 'HOSPITAL', 'DEDICATED_FACILITY'
    capacity INTEGER NOT NULL,  -- Number of drones it can house
    current_occupancy INTEGER DEFAULT 0,

    -- Coverage
    coverage_radius_miles DECIMAL(5, 2) DEFAULT 5.0,

    -- Contact
    contact_name VARCHAR(200),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(200),

    -- Status
    operational BOOLEAN DEFAULT TRUE,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Indexes
    INDEX idx_base_stations_location USING GIST (location),
    INDEX idx_base_stations_operational (operational)
);
```

---

### 8. No-Fly Zones

Restricted airspace areas.

```sql
CREATE TABLE no_fly_zones (
    zone_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Zone definition
    name VARCHAR(200) NOT NULL,
    zone_polygon GEOGRAPHY(POLYGON, 4326) NOT NULL,  -- GeoJSON polygon

    -- Restrictions
    zone_type VARCHAR(50) NOT NULL,
    -- 'AIRPORT', 'MILITARY', 'STADIUM', 'PRISON', 'SCHOOL', 'TEMPORARY'

    altitude_restriction_meters INTEGER,  -- Max altitude if partial restriction

    -- Temporal (for temporary restrictions)
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,

    -- Authority
    authority VARCHAR(100),  -- FAA, Local PD, etc.
    authority_reference VARCHAR(200),  -- Reference number

    -- Status
    active BOOLEAN DEFAULT TRUE,

    -- Indexes
    INDEX idx_no_fly_zones_polygon USING GIST (zone_polygon),
    INDEX idx_no_fly_zones_type (zone_type),
    INDEX idx_no_fly_zones_active (active)
);
```

---

### 9. Dispatchers

User accounts for 911 dispatchers.

```sql
CREATE TABLE dispatchers (
    dispatcher_id VARCHAR(100) PRIMARY KEY,

    -- Personal info
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(200) UNIQUE NOT NULL,

    -- Authentication
    password_hash VARCHAR(255) NOT NULL,  -- bcrypt hash
    mfa_enabled BOOLEAN DEFAULT FALSE,
    mfa_secret VARCHAR(100),

    -- Authorization
    role VARCHAR(50) NOT NULL DEFAULT 'DISPATCHER',  -- 'DISPATCHER', 'SUPERVISOR', 'ADMIN'
    permissions JSONB,

    -- Dispatch center
    dispatch_center_id VARCHAR(50),
    dispatch_center_name VARCHAR(200),

    -- Coverage area
    coverage_states TEXT[],  -- Array of state codes

    -- Status
    active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMPTZ,

    -- Statistics
    total_launches INTEGER DEFAULT 0,
    total_successful_missions INTEGER DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Indexes
    INDEX idx_dispatchers_email (email),
    INDEX idx_dispatchers_center (dispatch_center_id),
    INDEX idx_dispatchers_active (active)
);
```

---

## Supporting Tables

### 10. Weather Conditions

Historical weather data for missions.

```sql
CREATE TABLE weather_conditions (
    weather_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mission_id UUID REFERENCES missions(mission_id),

    -- Location and time
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    observation_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Conditions
    condition VARCHAR(50),  -- 'CLEAR', 'CLOUDY', 'RAIN', 'SNOW', 'FOG'
    temperature_celsius DECIMAL(4, 1),
    wind_speed_mph DECIMAL(4, 1),
    wind_direction_degrees INTEGER,
    precipitation_mm DECIMAL(5, 2),
    visibility_meters INTEGER,

    -- Source
    data_source VARCHAR(50),  -- 'NOAA', 'OpenWeatherMap', etc.

    INDEX idx_weather_mission (mission_id),
    INDEX idx_weather_time (observation_time DESC)
);
```

---

### 11. AI Model Versions

Track AI model deployments.

```sql
CREATE TABLE ai_model_versions (
    model_version_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Model details
    model_type VARCHAR(50) NOT NULL,
    -- 'YOLO_PERSON_DETECTION', 'LANDING_ZONE', 'WHISPER_STT',
    -- 'PHI3_DIALOGUE', 'PIPER_TTS'

    version VARCHAR(20) NOT NULL,
    model_file_path VARCHAR(500),
    model_size_mb INTEGER,

    -- Performance metrics
    accuracy_percent DECIMAL(5, 2),
    latency_ms INTEGER,
    power_watts DECIMAL(5, 2),

    -- Deployment
    deployed_at TIMESTAMPTZ,
    deployed_to_drones INTEGER DEFAULT 0,

    -- Status
    active BOOLEAN DEFAULT FALSE,

    -- Metadata
    training_data_info JSONB,
    notes TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    INDEX idx_ai_models_type (model_type),
    INDEX idx_ai_models_version (version),
    INDEX idx_ai_models_active (active)
);
```

---

## Views

### Active Missions View

```sql
CREATE VIEW active_missions AS
SELECT
    m.mission_id,
    m.drone_id,
    d.model AS drone_model,
    m.status,
    e.emergency_type,
    e.address AS emergency_address,
    m.launch_time,
    m.estimated_eta_seconds,
    EXTRACT(EPOCH FROM (NOW() - m.launch_time)) AS elapsed_seconds,
    m.voice_ai_active,
    m.language_detected,
    d.battery_level,
    d.current_location AS drone_location,
    m.destination_location
FROM missions m
JOIN drones d ON m.drone_id = d.drone_id
JOIN emergencies e ON m.emergency_id = e.emergency_id
WHERE m.status IN ('LAUNCHED', 'IN_FLIGHT', 'ARRIVED', 'LANDED')
ORDER BY m.launch_time DESC;
```

### Fleet Availability View

```sql
CREATE VIEW fleet_availability AS
SELECT
    base_station_id,
    COUNT(*) FILTER (WHERE status = 'READY') AS ready_drones,
    COUNT(*) FILTER (WHERE status = 'CHARGING') AS charging_drones,
    COUNT(*) FILTER (WHERE status = 'IN_FLIGHT') AS in_flight_drones,
    COUNT(*) FILTER (WHERE status = 'MAINTENANCE') AS maintenance_drones,
    COUNT(*) FILTER (WHERE status = 'OFFLINE') AS offline_drones,
    AVG(battery_level) FILTER (WHERE status = 'READY') AS avg_ready_battery
FROM drones
GROUP BY base_station_id;
```

---

## Redis Cache Structure

For real-time operations.

```
KEY PATTERNS:

mission:{mission_id}:state
├── status: "IN_FLIGHT"
├── drone_id: "Alpha-3"
├── elapsed_seconds: 45
├── eta_remaining: 90
└── TTL: Until mission complete

drone:{drone_id}:available
├── value: "true"
└── TTL: 60 seconds (refreshed by drone heartbeat)

dispatcher:{dispatcher_id}:session
├── token: "jwt_token_here"
├── last_activity: "2025-12-01T14:23:45Z"
└── TTL: 24 hours

rate_limit:api:{endpoint}:{ip}
├── count: 45
└── TTL: 60 seconds
```

---

## Sample Queries

### 1. Find Nearest Available Drone

```sql
SELECT
    drone_id,
    ST_Distance(
        current_location,
        ST_SetSRID(ST_MakePoint(-71.0589, 42.3601), 4326)::geography
    ) / 1609.34 AS distance_miles,  -- Convert meters to miles
    battery_level,
    model
FROM drones
WHERE
    status = 'READY'
    AND battery_level >= 50
ORDER BY distance_miles ASC
LIMIT 1;
```

### 2. Get Mission Timeline

```sql
SELECT
    event_type,
    timestamp,
    EXTRACT(EPOCH FROM (timestamp - m.launch_time)) AS seconds_since_launch,
    event_data
FROM mission_events me
JOIN missions m ON me.mission_id = m.mission_id
WHERE me.mission_id = 'uuid-here'
ORDER BY timestamp ASC;
```

### 3. Voice Transcript for Mission

```sql
SELECT
    timestamp,
    speaker,
    text,
    language,
    confidence_score
FROM voice_transcripts
WHERE mission_id = 'uuid-here'
ORDER BY timestamp ASC;
```

### 4. Calculate Success Rate by Base Station

```sql
SELECT
    bs.name AS base_station,
    COUNT(*) AS total_missions,
    SUM(CASE WHEN m.aed_successfully_deployed THEN 1 ELSE 0 END) AS successful_deployments,
    ROUND(
        100.0 * SUM(CASE WHEN m.aed_successfully_deployed THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS success_rate_percent,
    AVG(m.actual_eta_seconds) AS avg_eta_seconds
FROM missions m
JOIN drones d ON m.drone_id = d.drone_id
JOIN base_stations bs ON d.base_station_id = bs.base_station_id
WHERE m.status = 'COMPLETED'
GROUP BY bs.base_station_id, bs.name
ORDER BY success_rate_percent DESC;
```

### 5. Detect No-Fly Zone Conflicts

```sql
SELECT
    nfz.name AS no_fly_zone,
    nfz.zone_type,
    m.mission_id,
    m.drone_id
FROM missions m
JOIN no_fly_zones nfz ON ST_Intersects(
    m.destination_location,
    nfz.zone_polygon
)
WHERE
    m.status IN ('LAUNCHED', 'IN_FLIGHT')
    AND nfz.active = TRUE;
```

---

## Backup & Recovery

### Automated Backups

```bash
# Daily full backup (using pg_dump)
pg_dump -Fc skyrescue > skyrescue_$(date +%Y%m%d).dump

# Continuous archiving (WAL)
wal_level = replica
archive_mode = on
archive_command = 'cp %p /backup/wal/%f'

# Retention: Keep 30 days of backups
find /backup -name "skyrescue_*.dump" -mtime +30 -delete
```

### Point-in-Time Recovery

```bash
# Restore to specific time
pg_restore -d skyrescue skyrescue_20251201.dump
# Then replay WAL to desired timestamp
```

---

## Security

### Row-Level Security (RLS)

```sql
-- Enable RLS on sensitive tables
ALTER TABLE emergencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE voice_transcripts ENABLE ROW LEVEL SECURITY;

-- Policy: Dispatchers can only see emergencies in their coverage area
CREATE POLICY dispatcher_coverage ON emergencies
FOR SELECT
USING (
    state = ANY(
        SELECT unnest(coverage_states)
        FROM dispatchers
        WHERE dispatcher_id = current_setting('app.dispatcher_id')
    )
);
```

### Encryption

- **At Rest:** AWS RDS encryption enabled
- **In Transit:** SSL/TLS for all connections
- **Sensitive Fields:** `password_hash`, `mfa_secret` using bcrypt/AES-256

---

## Monitoring

### Key Metrics to Track

```sql
-- Active missions count
SELECT COUNT(*) FROM active_missions;

-- Average response time (last 24 hours)
SELECT AVG(actual_eta_seconds)
FROM missions
WHERE launch_time > NOW() - INTERVAL '24 hours';

-- Drone availability
SELECT status, COUNT(*)
FROM drones
GROUP BY status;

-- Database size
SELECT pg_size_pretty(pg_database_size('skyrescue'));
```

---

## Migration Scripts

Use Flyway or similar for versioned migrations.

```sql
-- V1__initial_schema.sql
-- V2__add_voice_transcripts.sql
-- V3__add_weather_conditions.sql
-- etc.
```

---

## Next Steps

1. ✅ Review schema design
2. ⏭️ Set up PostgreSQL + PostGIS + TimescaleDB
3. ⏭️ Run migration scripts
4. ⏭️ Load sample data for testing
5. ⏭️ Configure Redis cache
6. ⏭️ Set up automated backups
7. ⏭️ Implement connection pooling (PgBouncer)
8. ⏭️ Add monitoring (Prometheus + Grafana)

---

**Database Optimization Notes:**
- Use connection pooling (PgBouncer) for API servers
- Partition large tables (telemetry, mission_events) by date
- Create appropriate indexes based on query patterns
- Use EXPLAIN ANALYZE to optimize slow queries
- Monitor and vacuum regularly (autovacuum enabled)
