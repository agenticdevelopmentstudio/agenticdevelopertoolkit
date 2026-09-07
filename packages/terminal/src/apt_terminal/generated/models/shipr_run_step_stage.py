from enum import Enum


class ShiprRunStepStage(str, Enum):
    ADVANCE = "advance"
    ARRIVAL = "arrival"
    VERIFY = "verify"

    def __str__(self) -> str:
        return str(self.value)
