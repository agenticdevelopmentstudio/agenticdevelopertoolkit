from enum import Enum


class IntegrationConnectGithubAppType(str, Enum):
    GITHUB_APP = "github_app"

    def __str__(self) -> str:
        return str(self.value)
