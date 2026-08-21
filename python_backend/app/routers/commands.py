from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

class CommandRequest(BaseModel):
    command: str
    context: Optional[dict] = None

class CommandResponse(BaseModel):
    response: str
    intent: Optional[str] = None
    success: bool = True

@router.post("/commands/process", response_model=CommandResponse)
async def process_command(request: CommandRequest):
    """Process a text command"""
    try:
        from main import jarvis_service
        response = await jarvis_service.process_command(request.command)
        return CommandResponse(response=response, success=True)
    except Exception as e:
        logger.error(f"Command processing error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/commands/history")
async def get_command_history():
    """Get command history"""
    try:
        from main import jarvis_service
        return {"history": jarvis_service.conversation_history}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/commands/clear-history")
async def clear_history():
    """Clear command history"""
    try:
        from main import jarvis_service
        jarvis_service.conversation_history = []
        return {"message": "History cleared"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))