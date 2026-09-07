from enum import Enum


class PutGamificationRealmsEcosystemIdConfigBodyMode(str, Enum):
    GAME = "game"
    GAMIFICATION = "gamification"
    NONE = "none"

    def __str__(self) -> str:
        return str(self.value)
