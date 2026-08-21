# Jarvis AI - API Documentation

## Base URL
```
http://localhost:8000
```

## Authentication
Currently no authentication required. (Optional: Add JWT in future)

---

## Endpoints

### ✅ Health Check

**GET** `/health`

Check if backend is running.

**Response:**
```json
{
  "status": "healthy",
  "service": "Jarvis AI"
}
```

---

### 💬 Process Command

**POST** `/process-command`

Process a text command.

**Request:**
```json
{
  "command": "What time is it?"
}
```

**Response:**
```json
{
  "response": "The current time is 10:30:45"
}
```

---

### 🎤 Process Voice

**POST** `/api/voice/process`

Process audio input (voice).

**Request:** multipart/form-data
- `file`: Audio file (WAV, MP3)

**Response:**
```json
{
  "response": "Transcribed text and AI response"
}
```

---

### 🗣️ Text-to-Speech

**POST** `/api/voice/speak`

Convert text to speech.

**Request:**
```json
{
  "text": "Hello, this is Jarvis!"
}
```

**Response:**
```json
{
  "message": "Spoken successfully"
}
```

---

### 📋 Get Command History

**GET** `/api/commands/history`

Get conversation history.

**Response:**
```json
{
  "history": [
    {
      "user": "What time is it?",
      "assistant": "The current time is 10:30:45",
      "intent": "information"
    }
  ]
}
```

---

### 🧹 Clear History

**POST** `/api/commands/clear-history`

Clear conversation history.

**Response:**
```json
{
  "message": "History cleared"
}
```

---

### 🖥️ Execute System Command

**POST** `/api/system/execute`

Execute system control command.

**Request:**
```json
{
  "action": "open",
  "target": "notepad"
}
```

**Supported Actions:**
- `open` - Open application
- `close` - Close application
- `shutdown` - Shutdown system
- `restart` - Restart system
- `sleep` - Sleep mode
- `get_info` - Get system info
- `list_files` - List directory files

**Response:**
```json
{
  "result": "Opening notepad"
}
```

---

### ℹ️ System Information

**GET** `/api/system/info`

Get system resource information.

**Response:**
```json
{
  "platform": "Windows",
  "cpu_percent": 15.3,
  "memory_percent": 45.2,
  "disk_percent": 60.8
}
```

---

### 🤖 AI Chat

**POST** `/api/ai/chat`

Get AI response to a prompt.

**Request:**
```json
{
  "prompt": "Tell me a joke",
  "context": "Optional context"
}
```

**Response:**
```json
{
  "response": "Why did the AI cross the road? To process the other side!"
}
```

---

### 🎯 AI Capabilities

**GET** `/api/ai/capabilities`

Get available AI capabilities.

**Response:**
```json
{
  "capabilities": [
    "Conversational AI",
    "Voice Recognition",
    "System Control",
    "Information Queries",
    "File Operations",
    "Media Control"
  ]
}
```

---

## Error Handling

All endpoints return appropriate HTTP status codes:

- `200` - Success
- `400` - Bad Request
- `404` - Not Found
- `500` - Server Error

**Error Response Format:**
```json
{
  "detail": "Error message here"
}
```

---

## Examples

### Using cURL

```bash
# Health check
curl http://localhost:8000/health

# Process command
curl -X POST "http://localhost:8000/process-command" \
  -H "Content-Type: application/json" \
  -d '{"command": "What time is it?"}'

# Execute system command
curl -X POST "http://localhost:8000/api/system/execute" \
  -H "Content-Type: application/json" \
  -d '{"action": "open", "target": "notepad"}'
```

### Using Python

```python
import requests

# Process command
response = requests.post(
    "http://localhost:8000/process-command",
    json={"command": "What time is it?"}
)
print(response.json())
```

### Using JavaScript/Fetch

```javascript
// Process command
fetch('http://localhost:8000/process-command', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ command: 'What time is it?' })
})
.then(res => res.json())
.then(data => console.log(data))
```

---

## Rate Limiting

Currently no rate limiting. Can be added in future.

---

## Versioning

API Version: **1.0.0**

Future versions may use `/api/v2/` prefix.

---

## Interactive API Docs

Access Swagger UI: `http://localhost:8000/docs`

Access ReDoc: `http://localhost:8000/redoc`

---

For more info, visit the backend README!