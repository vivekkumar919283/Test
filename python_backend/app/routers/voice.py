from fastapi import APIRouter, File, UploadFile, HTTPException
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/voice/process")
async def process_voice(file: UploadFile = File(...)):
    """Process voice input"""
    try:
        from main import jarvis_service
        audio_bytes = await file.read()
        response = await jarvis_service.process_voice(audio_bytes)
        return {"response": response}
    except Exception as e:
        logger.error(f"Voice processing error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/voice/speak")
async def speak(text: str):
    """Convert text to speech"""
    try:
        from main import jarvis_service
        await jarvis_service.voice_service.text_to_speech(text)
        return {"message": "Spoken successfully"}
    except Exception as e:
        logger.error(f"Speech error: {e}")
        raise HTTPException(status_code=500, detail=str(e))