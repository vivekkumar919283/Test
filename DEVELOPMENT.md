# Jarvis AI - Development Guide

## Project Structure

```
Test/
├── flutter_app/              # Flutter Frontend
│   ├── lib/
│   │   ├── main.dart         # Entry point
│   │   ├── screens/          # UI screens
│   │   ├── services/         # Business logic
│   │   └── widgets/          # UI components
│   ├── android/              # Android native
│   ├── ios/                  # iOS native
│   ├── windows/              # Windows native
│   ├── macos/                # macOS native
│   ├── pubspec.yaml          # Dependencies
│   └── .env                  # Configuration
│
├── python_backend/           # Python FastAPI Backend
│   ├── app/
│   │   ├── routers/          # API endpoints
│   │   ├── services/         # Business logic
│   │   └── config.py         # Configuration
│   ├── main.py               # Entry point
│   ├── requirements.txt      # Dependencies
│   └── .env                  # Configuration
│
├── SETUP.md                  # Setup guide
├── FEATURES.md               # Features list
├── API.md                    # API documentation
├── DEVELOPMENT.md            # This file
└── README.md                 # Project overview
```

---

## Backend Development

### Adding a New API Endpoint

1. Create router file in `app/routers/`:

```python
# app/routers/my_feature.py
from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class MyRequest(BaseModel):
    input: str

class MyResponse(BaseModel):
    output: str

@router.post("/my-feature", response_model=MyResponse)
async def my_feature(request: MyRequest):
    """My feature endpoint"""
    result = f"Processed: {request.input}"
    return MyResponse(output=result)
```

2. Register in `main.py`:

```python
from app.routers import my_feature

app.include_router(my_feature.router, prefix="/api", tags=["my-feature"])
```

### Adding a New Service

1. Create service file in `app/services/`:

```python
# app/services/my_service.py
import logging

logger = logging.getLogger(__name__)

class MyService:
    """My service description"""
    
    async def initialize(self):
        """Initialize service"""
        logger.info("Initializing MyService")
    
    async def process(self, data: str) -> str:
        """Process data"""
        return f"Processed: {data}"
    
    async def cleanup(self):
        """Cleanup service"""
        logger.info("Cleaning up MyService")
```

2. Integrate in `JarvisService`:

```python
# app/services/jarvis_service.py
from app.services.my_service import MyService

class JarvisService:
    def __init__(self):
        self.my_service = MyService()
```

---

## Frontend Development

### Adding a New Screen

1. Create screen file in `lib/screens/`:

```dart
// lib/screens/my_screen.dart
import 'package:flutter/material.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Screen')),
      body: Center(
        child: Text('My Screen Content'),
      ),
    );
  }
}
```

2. Navigate in `home_screen.dart`:

```dart
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyScreen()),
    );
  },
  child: const Text('Go to My Screen'),
)
```

### Adding a New Widget

1. Create widget file in `lib/widgets/`:

```dart
// lib/widgets/my_widget.dart
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text('My Widget'),
    );
  }
}
```

2. Use in screens:

```dart
import 'package:jarvis_ai/widgets/my_widget.dart';

// In build method
MyWidget(),
```

### Adding a New Service

1. Create service in `lib/services/`:

```dart
// lib/services/my_service.dart
import 'package:http/http.dart' as http;

class MyService {
  final String baseUrl = 'http://localhost:8000';
  
  Future<String> myMethod() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/my-endpoint'),
    );
    return response.body;
  }
}
```

2. Use in service provider or widget

---

## Code Style Guide

### Python

```python
# Follow PEP 8
# Use type hints
# Use async/await for I/O
# Add docstrings to functions

async def my_function(param: str) -> str:
    """Description of function
    
    Args:
        param: Description
    
    Returns:
        Description
    """
    return result
```

### Dart

```dart
// Follow Dart style guide
// Use const where possible
// Add documentation comments

/// Description of function
Future<String> myFunction(String param) async {
  return result;
}
```

---

## Testing

### Backend Testing

```bash
# Install pytest
pip install pytest pytest-asyncio

# Run tests
pytest
```

### Frontend Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## Debugging

### Backend Debugging

```python
# Add breakpoints
breakpoint()  # Will drop into debugger

# Or use print with logging
logger.debug(f"Debug info: {variable}")
```

### Frontend Debugging

```dart
// Add breakpoints in VS Code/Android Studio
// Or use print for debugging
print('Debug info: $variable');
```

---

## Git Workflow

### Creating Feature Branch

```bash
git checkout -b feature/my-feature
```

### Committing Changes

```bash
git add .
git commit -m "feat: add my feature description"
```

### Pushing Changes

```bash
git push origin feature/my-feature
```

### Creating Pull Request

1. Go to GitHub repository
2. Create pull request from your branch
3. Add description and screenshots
4. Request review

---

## Performance Tips

### Backend
- Use connection pooling
- Cache frequently used data
- Optimize database queries
- Use async/await properly

### Frontend
- Use const constructors
- Minimize rebuilds
- Cache API responses
- Optimize image sizes
- Use lazy loading

---

## Deployment

### Backend Deployment

```bash
# Build Docker image
docker build -t jarvis-backend .

# Push to registry
docker push your-registry/jarvis-backend

# Deploy with docker-compose
docker-compose up -d
```

### Frontend Deployment

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

## Contributing

1. Fork repository
2. Create feature branch
3. Make changes
4. Write tests
5. Submit pull request
6. Request review

---

Happy coding! 🎉