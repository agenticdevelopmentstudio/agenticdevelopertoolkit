from collections.abc import Mapping
from typing import Any, TypeVar, cast

from attrs import define as _attrs_define

from ..types import UNSET, Unset

T = TypeVar("T", bound="PostShiprGroupsBody")


@_attrs_define
class PostShiprGroupsBody:
    """
    Attributes:
        name (str):
        ecosystem_id (Union[Unset, str]):
        parent_id (Union[None, Unset, str]):
        path (Union[Unset, str]):
        depth (Union[Unset, int]):
        position (Union[Unset, int]):
        deleted_at (Union[None, Unset, str]):
    """

    name: str
    ecosystem_id: Unset | str = UNSET
    parent_id: None | Unset | str = UNSET
    path: Unset | str = UNSET
    depth: Unset | int = UNSET
    position: Unset | int = UNSET
    deleted_at: None | Unset | str = UNSET

    def to_dict(self) -> dict[str, Any]:
        name = self.name

        ecosystem_id = self.ecosystem_id

        parent_id: None | Unset | str
        if isinstance(self.parent_id, Unset):
            parent_id = UNSET
        else:
            parent_id = self.parent_id

        path = self.path

        depth = self.depth

        position = self.position

        deleted_at: None | Unset | str
        if isinstance(self.deleted_at, Unset):
            deleted_at = UNSET
        else:
            deleted_at = self.deleted_at

        field_dict: dict[str, Any] = {}

        field_dict.update(
            {
                "name": name,
            }
        )
        if ecosystem_id is not UNSET:
            field_dict["ecosystemId"] = ecosystem_id
        if parent_id is not UNSET:
            field_dict["parentId"] = parent_id
        if path is not UNSET:
            field_dict["path"] = path
        if depth is not UNSET:
            field_dict["depth"] = depth
        if position is not UNSET:
            field_dict["position"] = position
        if deleted_at is not UNSET:
            field_dict["deletedAt"] = deleted_at

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        name = d.pop("name")

        ecosystem_id = d.pop("ecosystemId", UNSET)

        def _parse_parent_id(data: object) -> None | Unset | str:
            if data is None:
                return data
            if isinstance(data, Unset):
                return data
            return cast(None | Unset | str, data)

        parent_id = _parse_parent_id(d.pop("parentId", UNSET))

        path = d.pop("path", UNSET)

        depth = d.pop("depth", UNSET)

        position = d.pop("position", UNSET)

        def _parse_deleted_at(data: object) -> None | Unset | str:
            if data is None:
                return data
            if isinstance(data, Unset):
                return data
            return cast(None | Unset | str, data)

        deleted_at = _parse_deleted_at(d.pop("deletedAt", UNSET))

        post_shipr_groups_body = cls(
            name=name,
            ecosystem_id=ecosystem_id,
            parent_id=parent_id,
            path=path,
            depth=depth,
            position=position,
            deleted_at=deleted_at,
        )

        return post_shipr_groups_body
