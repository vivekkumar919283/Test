# Jarvis AI - Complete Setup Guide

## 🎯 Quick Start (All Platforms)

### Prerequisites
- Python 3.8+ ([Download](https://www.python.org/downloads/))
- Flutter 3.0+ ([Download](https://flutter.dev/docs/get-started/install))
- Git
- For macOS: Xcode Command Line Tools
- For Linux: Build essentials

---

## 🔧 Backend Setup (Python)

### Step 1: Install Python Dependencies

#### Windows
```powershell
cd python_backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```

#### macOS/Linux
```bash
cd python_backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Step 2: Configure Environment

```bash
cp .env.example .env
```

Edit `.env` file with your settings:
```env
HOST=0.0.0.0
PORT=8000
DEBUG=True
VOICE_LANGUAGE=en-US
VOICE_RATE=150
ALLOW_SYSTEM_CONTROL=True
```

### Step 3: Run Backend

```bash
python main.py
```

OR

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

✅ Backend will run at: `http://localhost:8000`
📚 API Docs: `http://localhost:8000/docs`

---

## 📱 Frontend Setup (Flutter)

### Step 1: Install Flutter

#### Windows
```powershell
# Download from https://flutter.dev
# Add to PATH
flutter --version
```

#### macOS
```bash
brew install flutter
flutter --version
```

#### Linux
```bash
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
flutter --version
```

### Step 2: Setup Flutter App

```bash
cd flutter_app
flutter pub get
```

### Step 3: Configure Backend URL

Edit `flutter_app/.env`:
```env
BACKEND_URL=http://localhost:8000
BACKEND_WS_URL=ws://localhost:8000
VOICE_LANGUAGE=en-US
```

### Step 4: Run Flutter App

#### Android
```bash
flutter run -d android
```

#### iOS (macOS only)
```bash
flutter run -d ios
```

#### Windows (Windows only)
```bash
flutter run -d windows
```

#### macOS (macOS only)
```bash
flutter run -d macos
```

---

## 🐛 Platform-Specific Setup

### Windows Setup

```powershell
# Install required tools
choco install python flutter

# Setup backend
cd python_backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
python main.py

# In new terminal, setup frontend
cd flutter_app
flutter pub get
flutter run
```

### macOS Setup

```bash
# Install required tools
brew install python@3.11 flutter
brew install portaudio  # For speech recognition

# Setup backend
cd python_backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py

# In new terminal, setup frontend
cd flutter_app
flutter pub get
flutter run
```

### Linux Setup

```bash
# Install required tools
sudo apt-get update
sudo apt-get install python3 python3-pip python3-venv
sudo apt-get install portaudio19-dev espeak

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$PWD/flutter/bin"

# Setup backend
cd python_backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py

# In new terminal, setup frontend
cd flutter_app
flutter pub get
flutter run
```

---

## 📦 Troubleshooting

### Backend Issues

#### Port 8000 already in use
```bash
# Change port in .env
PORT=8001
```

#### Speech recognition not working
```bash
# macOS
brew install portaudio
pip install --upgrade pyaudio

# Linux
sudo apt-get install portaudio19-dev
pip install --upgrade pyaudio

# Windows - use pre-built wheels
pip install pipwin
pipwin install pyaudio
```

#### pyttsx3 issues
```bash
# macOS
brew install espeak

# Linux
sudo apt-get install espeak

# Windows - should work out of box
```

### Frontend Issues

#### Flutter doctor errors
```bash
flutter doctor
flutter doctor --android-licenses  # Accept all Android licenses
```

#### Microphone permission denied (Android)
- Check `android/app/src/main/AndroidManifest.xml`
- Ensure RECORD_AUDIO permission is added
- Grant permission at runtime

#### iOS microphone permission
- Check `ios/Runner/Info.plist`
- Ensure NSMicrophoneUsageDescription key is present

---

## 🧪 Testing

### Test Backend

```bash
# Test API
curl http://localhost:8000/health

# Test command processing
curl -X POST "http://localhost:8000/process-command" \
  -H "Content-Type: application/json" \
  -d '{"command": "What time is it?"}'
```

### Test Frontend

1. Run the app
2. Press and hold the microphone button
3. Say: "What time is it?"
4. Release and listen to response

---

## 🚀 Production Deployment

### Backend

```bash
# Install Gunicorn
pip install gunicorn

# Run with Gunicorn
gunicorn main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker
```

### Frontend

```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Build for Windows
flutter build windows --release

# Build for macOS
flutter build macos --release
```

---

## 📞 Support

For issues:
1. Check the logs
2. Run `flutter doctor` for Flutter issues
3. Check backend logs at `http://localhost:8000/docs`
4. Ensure both frontend and backend are running

---

Happy coding! 🎉