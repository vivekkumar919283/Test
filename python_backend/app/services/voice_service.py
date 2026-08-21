import asyncio
import logging
import speech_recognition as sr
import pyttsx3
from typing import Optional
from app.config import settings

logger = logging.getLogger(__name__)

class VoiceService:
    """Service for voice recognition and text-to-speech"""
    
    def __init__(self):
        self.recognizer = sr.Recognizer()
        self.tts_engine = None
    
    async def initialize(self):
        """Initialize voice services"""
        try:
            if settings.VOICE_ENGINE == "pyttsx3":
                self.tts_engine = pyttsx3.init()
                self.tts_engine.setProperty('rate', settings.VOICE_RATE)
            logger.info("✅ Voice service initialized")
        except Exception as e:
            logger.error(f"Voice service initialization error: {e}")
            raise
    
    async def speech_to_text(self, audio_bytes: bytes) -> str:
        """Convert speech to text"""
        try:
            audio = sr.AudioData(audio_bytes, 16000, 2)
            text = self.recognizer.recognize_google(audio, language=settings.VOICE_LANGUAGE)
            return text
        except sr.UnknownValueError:
            logger.warning("Could not understand audio")
            return ""
        except sr.RequestError as e:
            logger.error(f"Speech recognition error: {e}")
            return ""
    
    async def text_to_speech(self, text: str) -> bytes:
        """Convert text to speech"""
        try:
            if self.tts_engine:
                self.tts_engine.say(text)
                self.tts_engine.runAndWait()
            return b""  # Return audio bytes if needed
        except Exception as e:
            logger.error(f"Text-to-speech error: {e}")
            return b""
    
    async def cleanup(self):
        """Cleanup voice service"""
        try:
            if self.tts_engine:
                self.tts_engine.stop()
        except Exception as e:
            logger.error(f"Cleanup error: {e}")