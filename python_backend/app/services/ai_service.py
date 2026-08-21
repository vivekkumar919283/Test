import asyncio
import logging
from typing import List, Dict, Optional
import os
from app.config import settings

logger = logging.getLogger(__name__)

class AIService:
    """AI Service for conversational responses"""
    
    def __init__(self):
        self.use_openai = settings.USE_OPENAI
        self.model = settings.AI_MODEL
        self.client = None
    
    async def initialize(self):
        """Initialize AI service"""
        try:
            if self.use_openai:
                try:
                    import openai
                    openai.api_key = settings.OPENAI_API_KEY
                    self.client = openai
                    logger.info("✅ OpenAI initialized")
                except ImportError:
                    logger.warning("OpenAI not installed, using local models")
                    self.use_openai = False
            
            if not self.use_openai:
                try:
                    from transformers import pipeline
                    self.nlp_pipeline = pipeline(
                        "sentiment-analysis",
                        model=self.model
                    )
                    logger.info("✅ Local AI model loaded")
                except Exception as e:
                    logger.warning(f"Could not load local model: {e}")
        
        except Exception as e:
            logger.error(f"AI service initialization error: {e}")
            raise
    
    async def get_response(self, prompt: str, history: List[Dict] = None) -> str:
        """Get AI response"""
        try:
            if self.use_openai and self.client:
                return await self._get_openai_response(prompt, history)
            else:
                return await self._get_local_response(prompt, history)
        except Exception as e:
            logger.error(f"AI response error: {e}")
            return "I'm sorry, I couldn't generate a response."
    
    async def _get_openai_response(self, prompt: str, history: List[Dict] = None) -> str:
        """Get response from OpenAI"""
        try:
            import openai
            messages = [{"role": "user", "content": prompt}]
            
            if history:
                for item in history[-5:]:  # Last 5 messages for context
                    messages.append({"role": "user", "content": item.get("user", "")})
                    messages.append({"role": "assistant", "content": item.get("assistant", "")})
            
            response = await asyncio.to_thread(
                openai.ChatCompletion.create,
                model="gpt-3.5-turbo",
                messages=messages,
                max_tokens=150
            )
            
            return response.choices[0].message.content
        except Exception as e:
            logger.error(f"OpenAI error: {e}")
            return await self._get_local_response(prompt, history)
    
    async def _get_local_response(self, prompt: str, history: List[Dict] = None) -> str:
        """Get response using local model"""
        # Simple response generation based on keywords
        prompt_lower = prompt.lower()
        
        # Greeting responses
        if any(word in prompt_lower for word in ["hello", "hi", "hey", "howdy"]):
            return "Hello! I'm Jarvis, your AI assistant. How can I help you today?"
        
        # Time responses
        if "time" in prompt_lower:
            from datetime import datetime
            return f"The current time is {datetime.now().strftime('%H:%M:%S')}"
        
        # Date responses
        if "date" in prompt_lower:
            from datetime import datetime
            return f"Today's date is {datetime.now().strftime('%A, %B %d, %Y')}"
        
        # Help responses
        if "help" in prompt_lower:
            return "I can help you with voice commands, system control, information queries, and general conversation. What would you like to know?"
        
        # Default response
        return f"I understand you said: '{prompt}'. I'm still learning, but I'll do my best to help!"
    
    async def cleanup(self):
        """Cleanup AI service"""
        logger.info("AI service cleaned up")