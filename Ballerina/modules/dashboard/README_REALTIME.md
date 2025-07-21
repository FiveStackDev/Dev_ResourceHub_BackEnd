# Real-Time Admin Dashboard with WebSocket

This module has been enhanced to provide real-time dashboard functionality using WebSockets. The admin dashboard now supports live updates for statistics and notifications.

## Features

### WebSocket Real-Time Updates
- Live statistics updates every 30 seconds
2. **Connection Fails**
   - Check if WebSocket service is running on port 9095
   - Verify JWT token is valid and user has Admin/SuperAdmin role
   - Check CORS settings if connecting from browseral-time notifications
- Connection management for admin users
- Authentication and authorization for WebSocket connections

### New Endpoints

#### WebSocket Endpoint
- **URL**: `ws://localhost:9095/dashboard/admin/ws`
- **Protocol**: `admin-dashboard`
- **Authentication**: JWT token via WebSocket message

#### REST API Endpoints

1. **Trigger Real-Time Updates**
   - **Method**: POST
   - **URL**: `/dashboard/admin/notify`
   - **Purpose**: Manually trigger stats updates to all connected clients
   - **Auth**: Admin/SuperAdmin required

2. **Send Custom Notifications**
   - **Method**: POST
   - **URL**: `/dashboard/admin/notification`
   - **Purpose**: Send custom notifications to admin users
   - **Auth**: Admin/SuperAdmin required
   - **Body**:
     ```json
     {
       "type": "info|warning|error|success",
       "title": "Notification Title",
       "message": "Notification message"
     }
     ```

3. **Get WebSocket Connections**
   - **Method**: GET
   - **URL**: `/dashboard/admin/connections`
   - **Purpose**: View active WebSocket connections
   - **Auth**: SuperAdmin required

## WebSocket Message Protocol

### Client to Server Messages

#### Authentication
```json
{
  "event": "authenticate",
  "token": "your-jwt-token"
}
```

#### Ping/Pong
```json
{
  "event": "ping"
}
```

### Server to Client Messages

#### Authentication Success
```json
{
  "event": "authenticated",
  "message": "Successfully authenticated",
  "timestamp": "1642678800000"
}
```

#### Initial/Updated Statistics
```json
{
  "event": "initial_stats" | "stats_update",
  "data": {
    "userCount": 150,
    "mealEventsCount": 1250,
    "assetRequestsCount": 358,
    "maintenanceCount": 523,
    "monthlyUserCounts": [10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65],
    "monthlyMealCounts": [100, 120, 140, 160, 180, 200, 220, 240, 260, 280, 300, 320],
    "monthlyAssetRequestCounts": [20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75],
    "monthlyMaintenanceCounts": [15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48],
    "monthLabels": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  },
  "timestamp": "1642678800000"
}
```

#### Real-Time Notifications
```json
{
  "event": "notification",
  "data": {
    "type": "info",
    "title": "New User Registration",
    "message": "5 new users registered in the last hour",
    "orgId": "123"
  },
  "timestamp": "1642678800000"
}
```

#### Pong Response
```json
{
  "event": "pong",
  "timestamp": "1642678800000"
}
```

#### Error Messages
```json
{
  "event": "error",
  "message": "Authentication failed: Invalid token",
  "timestamp": "1642678800000"
}
```

## Usage

### 1. Start the Services
The WebSocket service starts automatically when the dashboard module is initialized:
```ballerina
check ResourceHub.dashboard:startDashboardAdminService();
```

### 2. Connect from Frontend
```javascript
// Connect to WebSocket
const ws = new WebSocket('ws://localhost:9095/dashboard/admin/ws', ['admin-dashboard']);

// Authenticate after connection opens
ws.onopen = function() {
    ws.send(JSON.stringify({
        event: 'authenticate',
        token: 'your-jwt-token'
    }));
};

// Handle messages
ws.onmessage = function(event) {
    const message = JSON.parse(event.data);
    switch(message.event) {
        case 'authenticated':
            console.log('Successfully authenticated');
            break;
        case 'stats_update':
            updateDashboardStats(message.data);
            break;
        case 'notification':
            showNotification(message.data);
            break;
    }
};
```

### 3. Trigger Manual Updates
```javascript
// Trigger stats update for all connected clients
fetch('/dashboard/admin/notify', {
    method: 'POST',
    headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
    }
});

// Send custom notification
fetch('/dashboard/admin/notification', {
    method: 'POST',
    headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        type: 'warning',
        title: 'System Maintenance',
        message: 'Scheduled maintenance in 1 hour'
    })
});
```

## Testing

A test client is provided in `websocket-test-client.html`. Open this file in a browser to:
- Test WebSocket connections
- Send authentication messages
- View real-time updates
- Trigger manual updates
- Send test notifications

## Configuration

### Ports
- HTTP Service: Port 9092
- WebSocket Service: Port 9095

### Update Frequency
Real-time updates are sent every 30 seconds. This can be modified in the `startDashboardAdminService()` function.

### CORS Settings
The HTTP service includes CORS configuration for local development. Update the `allowOrigins` array for production deployment.

## Security

- WebSocket connections require JWT authentication
- Only Admin and SuperAdmin roles can connect
- Connection information is isolated by organization
- Invalid tokens result in connection termination
- Failed connections are automatically cleaned up

## Integration with Frontend

The real-time dashboard is designed to work with modern frontend frameworks:

### React Example
```jsx
import { useEffect, useState } from 'react';

const useWebSocketDashboard = (token) => {
    const [stats, setStats] = useState(null);
    const [connected, setConnected] = useState(false);

    useEffect(() => {
        const ws = new WebSocket('ws://localhost:9095/dashboard/admin/ws', ['admin-dashboard']);
        
        ws.onopen = () => {
            setConnected(true);
            ws.send(JSON.stringify({ event: 'authenticate', token }));
        };

        ws.onmessage = (event) => {
            const message = JSON.parse(event.data);
            if (message.event === 'stats_update' || message.event === 'initial_stats') {
                setStats(message.data);
            }
        };

        ws.onclose = () => setConnected(false);

        return () => ws.close();
    }, [token]);

    return { stats, connected };
};
```

### Vue Example
```vue
<template>
  <div class="dashboard">
    <div v-if="connected" class="stats">
      <div class="stat-card">
        <h3>Users</h3>
        <p>{{ stats?.userCount || 0 }}</p>
      </div>
      <!-- More stat cards -->
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      ws: null,
      connected: false,
      stats: null
    }
  },
  mounted() {
    this.connectWebSocket();
  },
  methods: {
    connectWebSocket() {
      this.ws = new WebSocket('ws://localhost:9095/dashboard/admin/ws', ['admin-dashboard']);
      
      this.ws.onopen = () => {
        this.connected = true;
        this.ws.send(JSON.stringify({
          event: 'authenticate',
          token: this.$store.state.authToken
        }));
      };

      this.ws.onmessage = (event) => {
        const message = JSON.parse(event.data);
        if (message.event === 'stats_update' || message.event === 'initial_stats') {
          this.stats = message.data;
        }
      };

      this.ws.onclose = () => {
        this.connected = false;
      };
    }
  }
}
</script>
```

## Troubleshooting

### Common Issues

1. **Connection Fails**
   - Check if WebSocket service is running on port 9093
   - Verify JWT token is valid and user has Admin/SuperAdmin role
   - Check CORS settings if connecting from browser

2. **Authentication Fails**
   - Ensure JWT token is properly formatted
   - Verify token contains required claims (org_id, role, id)
   - Check token expiration

3. **No Real-Time Updates**
   - Verify periodic task is scheduled successfully
   - Check database connectivity
   - Monitor server logs for errors

4. **Connection Drops**
   - Implement reconnection logic in client
   - Check network stability
   - Monitor server resource usage

### Monitoring

Monitor the service logs for:
- WebSocket connection events
- Authentication attempts
- Periodic update execution
- Error messages
- Connection cleanup events

### Performance Considerations

- Limit number of concurrent WebSocket connections
- Optimize database queries for real-time stats
- Consider caching frequently accessed data
- Monitor memory usage for connection storage
- Implement connection timeouts for inactive clients
