import logging
from typing import Dict, Any

logger = logging.getLogger(__name__)

class CommandParser:
    """Parse user commands to extract intent and parameters"""
    
    def __init__(self):
        self.intents = {
            "system_control": [
                "open", "close", "launch", "start", "stop", "shutdown",
                "restart", "sleep", "wake", "lock", "unlock"
            ],
            "file_operations": [
                "create file", "delete file", "copy", "move", "rename",
                "read file", "list files"
            ],
            "information": [
                "what", "who", "when", "where", "why", "how",
                "tell me", "show me", "weather", "news"
            ],
            "media_control": [
                "play", "pause", "stop", "volume", "mute", "unmute"
            ],
            "chat": [
                "hello", "hi", "hey", "thanks", "thank you",
                "good morning", "good night"
            ]
        }
    
    def parse(self, command: str) -> Dict[str, Any]:
        """Parse command and extract intent"""
        command_lower = command.lower().strip()
        
        parsed = {
            "original": command,
            "intent": "chat",
            "action": None,
            "parameters": {}
        }
        
        # Detect intent
        for intent, keywords in self.intents.items():
            if any(keyword in command_lower for keyword in keywords):
                parsed["intent"] = intent
                parsed["action"] = self._extract_action(command_lower, intent)
                parsed["parameters"] = self._extract_parameters(command_lower, intent)
                break
        
        logger.info(f"Parsed command: {parsed}")
        return parsed
    
    def _extract_action(self, command: str, intent: str) -> str:
        """Extract action from command"""
        if intent == "system_control":
            for action in ["open", "close", "launch", "start", "stop", "shutdown", "restart"]:
                if action in command:
                    return action
        return command.split()[0]
    
    def _extract_parameters(self, command: str, intent: str) -> Dict[str, Any]:
        """Extract parameters from command"""
        params = {}
        parts = command.split()
        
        if intent == "system_control" and len(parts) > 1:
            params["target"] = " ".join(parts[1:])
        
        return params