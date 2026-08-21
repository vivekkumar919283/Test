import asyncio
import logging
from typing import Optional
from app.services.voice_service import VoiceService
from app.services.ai_service import AIService
from app.services.command_parser import CommandParser
from app.services.system_control import SystemControl
from app.config import settings

logger = logging.getLogger(__name__)

class JarvisService:
    """Main Jarvis Service - orchestrates all components"""
    
    def __init__(self):
        self.voice_service = VoiceService()
        self.ai_service = AIService()
        self.command_parser = CommandParser()
        self.system_control = SystemControl()
        self.conversation_history = []
    
    async def initialize(self):
        """Initialize all services"""
        logger.info("Initializing Jarvis Services...")
        try:
            await self.voice_service.initialize()
            await self.ai_service.initialize()
            logger.info("✅ All services initialized successfully")
        except Exception as e:
            logger.error(f"❌ Initialization error: {e}")
            raise
    
    async def process_command(self, command: str) -> str:
        """Process a user command and return response"""
        logger.info(f"Processing command: {command}")
        
        # Parse command intent
        parsed = self.command_parser.parse(command)
        intent = parsed.get("intent", "chat")
        
        response = ""
        
        if intent == "system_control":
            # System control command
            action = parsed.get("action", "")
            response = await self.system_control.execute(action, parsed)
        
        elif intent == "information":
            # Information query
            response = await self.ai_service.get_response(command, self.conversation_history)
        
        else:
            # General conversation
            response = await self.ai_service.get_response(command, self.conversation_history)
        
        # Store in conversation history
        self.conversation_history.append({
            "user": command,
            "assistant": response,
            "intent": intent
        })
        
        return response
    
    async def process_voice(self, audio_bytes: bytes) -> str:
        """Process voice input"""
        try:
            # Convert speech to text
            text = await self.voice_service.speech_to_text(audio_bytes)
            logger.info(f"Transcribed: {text}")
            
            # Process command
            response = await self.process_command(text)
            
            return response
        except Exception as e:
            logger.error(f"Voice processing error: {e}")
            return "Sorry, I couldn't process your voice command."
    
    async def cleanup(self):
        """Cleanup services"""
        logger.info("Cleaning up services...")
        await self.voice_service.cleanup()
        await self.ai_service.cleanup()