from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

class AIRequest(BaseModel):
    prompt: str
    context: Optional[str] = None

@router.post("/ai/chat")
async def ai_chat(request: AIRequest):
    """Get AI response to a prompt"""
    try:
        from main import jarvis_service
        response = await jarvis_service.ai_service.get_response(
            request.prompt,
            jarvis_service.conversation_history
        )
        return {"response": response}
    except Exception as e:
        logger.error(f"AI chat error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/ai/capabilities")
async def get_capabilities():
    """Get AI capabilities"""
    return {
        "capabilities": [
            "Conversational AI",
            "Voice Recognition",
            "System Control",
            "Information Queries",
            "File Operations",
            "Media Control"
        ]
    }