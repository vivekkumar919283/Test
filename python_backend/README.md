# Jarvis AI - Python Backend

Powerful Python backend for Jarvis AI voice assistant with FastAPI, voice processing, AI, and system control.

## Features
- 🎤 Speech-to-Text conversion
- 🗣️ Text-to-Speech synthesis
- 🤖 AI-powered responses (OpenAI or Local Models)
- 🔧 System control (open apps, shutdown, restart, etc.)
- 📊 Command history and logging
- 🌐 RESTful API with FastAPI
- 🔄 Real-time WebSocket support
- 💾 Persistent storage

## Supported Platforms
- ✅ Windows
- ✅ macOS
- ✅ Linux

## Prerequisites
- Python 3.8+
- pip or conda

## Installation

```bash
cd python_backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\\Scripts\\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Configuration

1. Copy `.env.example` to `.env`
2. Update settings as needed:

```env
HOST=0.0.0.0
PORT=8000
DEBUG=True
VOICE_LANGUAGE=en-US
ALLOW_SYSTEM_CONTROL=True
```

## Running the Backend

```bash
# Development mode
python main.py

# Or with uvicorn
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`
API documentation: `http://localhost:8000/docs`

## API Endpoints

### Commands
- `POST /api/commands/process` - Process text command
- `GET /api/commands/history` - Get conversation history
- `POST /api/commands/clear-history` - Clear history

### Voice
- `POST /api/voice/process` - Process voice input (audio file)
- `POST /api/voice/speak` - Convert text to speech

### System
- `POST /api/system/execute` - Execute system command
- `GET /api/system/info` - Get system information

### AI
- `POST /api/ai/chat` - Get AI response
- `GET /api/ai/capabilities` - Get AI capabilities

## Project Structure
```
python_backend/
├── app/
│   ├── __init__.py
│   ├── config.py           # Configuration
│   ├── routers/            # API endpoints
│   │   ├── commands.py
│   │   ├── voice.py
│   │   ├── system.py
│   │   └── ai.py
│   └── services/           # Business logic
│       ├── jarvis_service.py
│       ├── voice_service.py
│       ├── ai_service.py
│       ├── command_parser.py
│       └── system_control.py
├── main.py                 # Entry point
├── requirements.txt        # Dependencies
├── .env.example           # Environment template
└── README.md
```

## Dependencies
- **fastapi** - Web framework
- **uvicorn** - ASGI server
- **speech-recognition** - Voice recognition
- **pyttsx3** - Text-to-speech
- **transformers** - NLP models
- **requests** - HTTP client
- **python-dotenv** - Environment management
- **psutil** - System utilities

## Usage Examples

### Process Text Command
```bash
curl -X POST "http://localhost:8000/api/commands/process" \
  -H "Content-Type: application/json" \
  -d '{"command": "What time is it?"}'
```

### Execute System Command
```bash
curl -X POST "http://localhost:8000/api/system/execute" \
  -H "Content-Type: application/json" \
  -d '{"action": "open", "target": "notepad"}'
```

### Get AI Response
```bash
curl -X POST "http://localhost:8000/api/ai/chat" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Hello Jarvis!"}'
```

## Troubleshooting

### Voice recognition not working
- Install portaudio: `brew install portaudio` (macOS) or `apt-get install portaudio19-dev` (Linux)
- Reinstall pyaudio: `pip install --upgrade pyaudio`

### pyttsx3 issues on Linux
- Install espeak: `apt-get install espeak`

### Permission denied on system commands
- Run with appropriate permissions
- On Linux: Use `sudo` for system control

## Contributing
Feel free to contribute improvements!

## License
MIT License

---
Created with ❤️ using FastAPI