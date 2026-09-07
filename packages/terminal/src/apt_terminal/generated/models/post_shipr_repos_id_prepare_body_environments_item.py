from enum import Enum


class PostShiprReposIdPrepareBodyEnvironmentsItem(str, Enum):
    PRODUCTION = "production"
    STAGING = "staging"
    TESTING = "testing"

    def __str__(self) -> str:
        return str(self.value)
