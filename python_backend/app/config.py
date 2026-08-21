from pydantic_settings import BaseSettings
from dotenv import load_dotenv
import os

load_dotenv()

class Settings(BaseSettings):
    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    DEBUG: bool = True
    
    # AI Configuration
    AI_MODEL: str = "distilbert-base-uncased-finetuned-sst-2-english"
    OPENAI_API_KEY: str = ""
    USE_OPENAI: bool = False
    
    # Voice
    VOICE_ENGINE: str = "pyttsx3"
    VOICE_RATE: int = 150
    VOICE_LANGUAGE: str = "en-US"
    
    # System Control
    ALLOW_SYSTEM_CONTROL: bool = True
    ALLOW_FILE_OPERATIONS: bool = True
    
    # Database
    DATABASE_URL: str = "sqlite:///./jarvis.db"
    
    # Logging
    LOG_LEVEL: str = "INFO"
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()