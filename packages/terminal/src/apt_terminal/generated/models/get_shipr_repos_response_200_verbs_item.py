from enum import Enum


class GetShiprReposResponse200VerbsItem(str, Enum):
    C = "C"
    D = "D"
    M = "M"
    R = "R"
    U = "U"

    def __str__(self) -> str:
        return str(self.value)
