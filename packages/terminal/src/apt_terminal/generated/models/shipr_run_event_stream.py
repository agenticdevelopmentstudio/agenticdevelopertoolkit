from enum import Enum


class ShiprRunEventStream(str, Enum):
    ERR = "err"
    META = "meta"
    OUT = "out"

    def __str__(self) -> str:
        return str(self.value)
