from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from dotenv import load_dotenv
import os
from contextlib import asynccontextmanager

from app.routers import commands, voice, system, ai
from app.services.jarvis_service import JarvisService

load_dotenv()

# Initialize Jarvis Service
jarvis_service = JarvisService()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("🤖 Jarvis AI Backend Starting...")
    await jarvis_service.initialize()
    yield
    # Shutdown
    print("👋 Jarvis AI Backend Shutting Down...")
    await jarvis_service.cleanup()

app = FastAPI(
    title="Jarvis AI Backend",
    description="Cross-platform voice assistant backend",
    version="1.0.0",
    lifespan=lifespan
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(commands.router, prefix="/api", tags=["commands"])
app.include_router(voice.router, prefix="/api", tags=["voice"])
app.include_router(system.router, prefix="/api", tags=["system"])
app.include_router(ai.router, prefix="/api", tags=["ai"])

@app.get("/")
async def root():
    return {
        "message": "🤖 Jarvis AI Backend",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "Jarvis AI"
    }

@app.post("/process-command")
async def process_command(data: dict):
    command = data.get("command", "")
    if not command:
        return {"error": "No command provided"}
    
    try:
        response = await jarvis_service.process_command(command)
        return {"response": response}
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8000))
    debug = os.getenv("DEBUG", "True") == "True"
    
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=debug
    )