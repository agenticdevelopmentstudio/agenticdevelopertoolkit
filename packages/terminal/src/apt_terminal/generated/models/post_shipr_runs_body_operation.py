from enum import Enum


class PostShiprRunsBodyOperation(str, Enum):
    DEPLOY = "deploy"
    PREPARE = "prepare"
    REGISTER = "register"
    STATUS = "status"
    UNREGISTER = "unregister"

    def __str__(self) -> str:
        return str(self.value)
