from enum import Enum


class ShiprRunStepState(str, Enum):
    FAILED = "failed"
    PENDING = "pending"
    RUNNING = "running"
    SKIPPED = "skipped"
    SUCCEEDED = "succeeded"

    def __str__(self) -> str:
        return str(self.value)
