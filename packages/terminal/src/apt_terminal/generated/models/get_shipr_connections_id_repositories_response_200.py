from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar

from attrs import define as _attrs_define
from attrs import field as _attrs_field

if TYPE_CHECKING:
    from ..models.get_shipr_connections_id_repositories_response_200_repositories_item import (
        GetShiprConnectionsIdRepositoriesResponse200RepositoriesItem,
    )


T = TypeVar("T", bound="GetShiprConnectionsIdRepositoriesResponse200")


@_attrs_define
class GetShiprConnectionsIdRepositoriesResponse200:
    """
    Attributes:
        repositories (list['GetShiprConnectionsIdRepositoriesResponse200RepositoriesItem']):
    """

    repositories: list["GetShiprConnectionsIdRepositoriesResponse200RepositoriesItem"]
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        repositories = []
        for repositories_item_data in self.repositories:
            repositories_item = repositories_item_data.to_dict()
            repositories.append(repositories_item)

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "repositories": repositories,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.get_shipr_connections_id_repositories_response_200_repositories_item import (
            GetShiprConnectionsIdRepositoriesResponse200RepositoriesItem,
        )

        d = dict(src_dict)
        repositories = []
        _repositories = d.pop("repositories")
        for repositories_item_data in _repositories:
            repositories_item = (
                GetShiprConnectionsIdRepositoriesResponse200RepositoriesItem.from_dict(
                    repositories_item_data
                )
            )

            repositories.append(repositories_item)

        get_shipr_connections_id_repositories_response_200 = cls(
            repositories=repositories,
        )

        get_shipr_connections_id_repositories_response_200.additional_properties = d
        return get_shipr_connections_id_repositories_response_200

    @property
    def additional_keys(self) -> list[str]:
        return list(self.additional_properties.keys())

    def __getitem__(self, key: str) -> Any:
        return self.additional_properties[key]

    def __setitem__(self, key: str, value: Any) -> None:
        self.additional_properties[key] = value

    def __delitem__(self, key: str) -> None:
        del self.additional_properties[key]

    def __contains__(self, key: str) -> bool:
        return key in self.additional_properties
