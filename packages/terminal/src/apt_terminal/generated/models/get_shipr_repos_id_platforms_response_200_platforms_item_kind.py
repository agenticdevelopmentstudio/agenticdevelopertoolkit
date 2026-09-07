from enum import Enum


class GetShiprReposIdPlatformsResponse200PlatformsItemKind(str, Enum):
    VERCEL = "vercel"

    def __str__(self) -> str:
        return str(self.value)
