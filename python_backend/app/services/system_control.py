import asyncio
import logging
import subprocess
import platform
import os
import shutil
from pathlib import Path
from typing import Dict, Any

logger = logging.getLogger(__name__)

class SystemControl:
    """Handle system control commands"""
    
    def __init__(self):
        self.system = platform.system()
    
    async def execute(self, action: str, params: Dict[str, Any]) -> str:
        """Execute system control command"""
        try:
            if action == "open":
                return await self._open_application(params.get("target", ""))
            elif action == "get_info":
                return await self._get_system_info()
            elif action == "shutdown":
                return await self._shutdown_system()
            elif action == "restart":
                return await self._restart_system()
            elif action == "sleep":
                return await self._sleep_system()
            elif action == "list_files":
                return await self._list_files(params.get("target", "."))
            else:
                return f"Unknown action: {action}"
        except Exception as e:
            logger.error(f"System control error: {e}")
            return f"Error executing command: {str(e)}"
    
    async def _open_application(self, app_name: str) -> str:
        """Open an application"""
        try:
            if self.system == "Windows":
                os.startfile(app_name)
            elif self.system == "Darwin":  # macOS
                subprocess.Popen(["open", "-a", app_name])
            elif self.system == "Linux":
                subprocess.Popen([app_name])
            return f"Opening {app_name}"
        except Exception as e:
            return f"Could not open {app_name}: {str(e)}"
    
    async def _get_system_info(self) -> str:
        """Get system information"""
        try:
            import psutil
            cpu_percent = psutil.cpu_percent(interval=1)
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage('/')
            
            info = f"""System Information:
            CPU: {cpu_percent}%
            Memory: {memory.percent}%
            Disk: {disk.percent}%
            """
            return info
        except ImportError:
            return "psutil not installed"
    
    async def _shutdown_system(self) -> str:
        """Shutdown the system"""
        if self.system == "Windows":
            subprocess.run(["shutdown", "/s", "/t", "60"])
        elif self.system in ["Darwin", "Linux"]:
            subprocess.run(["shutdown", "-h", "1"])
        return "System shutdown initiated"
    
    async def _restart_system(self) -> str:
        """Restart the system"""
        if self.system == "Windows":
            subprocess.run(["shutdown", "/r", "/t", "60"])
        elif self.system in ["Darwin", "Linux"]:
            subprocess.run(["shutdown", "-r", "1"])
        return "System restart initiated"
    
    async def _sleep_system(self) -> str:
        """Put system to sleep"""
        if self.system == "Windows":
            subprocess.run(["rundll32.exe", "powrprof.dll", "SetSuspendState", "0", "1", "0"])
        elif self.system == "Darwin":
            subprocess.run(["osascript", "-e", "tell application \"System Events\" to sleep"])
        elif self.system == "Linux":
            subprocess.run(["systemctl", "suspend"])
        return "System entering sleep mode"
    
    async def _list_files(self, path: str = ".") -> str:
        """List files in directory"""
        try:
            files = os.listdir(path)
            return f"Files in {path}: {', '.join(files[:10])}..."
        except Exception as e:
            return f"Error listing files: {str(e)}"