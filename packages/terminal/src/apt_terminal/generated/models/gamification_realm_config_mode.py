from enum import Enum


class GamificationRealmConfigMode(str, Enum):
    GAME = "game"
    GAMIFICATION = "gamification"
    NONE = "none"

    def __str__(self) -> str:
        return str(self.value)
