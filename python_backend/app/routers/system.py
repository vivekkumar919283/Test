from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

class SystemCommand(BaseModel):
    action: str
    target: str = None

@router.post("/system/execute")
async def execute_system_command(cmd: SystemCommand):
    """Execute system control command"""
    try:
        from main import jarvis_service
        result = await jarvis_service.system_control.execute(
            cmd.action,
            {"target": cmd.target} if cmd.target else {}
        )
        return {"result": result}
    except Exception as e:
        logger.error(f"System command error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/system/info")
async def get_system_info():
    """Get system information"""
    try:
        from main import jarvis_service
        import platform
        import psutil
        
        return {
            "platform": platform.system(),
            "cpu_percent": psutil.cpu_percent(interval=1),
            "memory_percent": psutil.virtual_memory().percent,
            "disk_percent": psutil.disk_usage('/').percent
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))