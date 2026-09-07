from collections.abc import Mapping
from typing import Any, TypeVar, cast

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..types import UNSET, Unset

T = TypeVar("T", bound="ShiprDevRepo")


@_attrs_define
class ShiprDevRepo:
    """The source repository a mirror is fed from.

    Attributes:
        id (Union[Unset, str]):
        slug (Union[Unset, str]):
        main_branch (Union[Unset, str]):
        prepared_branch (Union[Unset, str]):
        declaration_sha (Union[None, Unset, str]):
        connection_id (Union[None, Unset, str]):
    """

    id: Unset | str = UNSET
    slug: Unset | str = UNSET
    main_branch: Unset | str = UNSET
    prepared_branch: Unset | str = UNSET
    declaration_sha: None | Unset | str = UNSET
    connection_id: None | Unset | str = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        id = self.id

        slug = self.slug

        main_branch = self.main_branch

        prepared_branch = self.prepared_branch

        declaration_sha: None | Unset | str
        if isinstance(self.declaration_sha, Unset):
            declaration_sha = UNSET
        else:
            declaration_sha = self.declaration_sha

        connection_id: None | Unset | str
        if isinstance(self.connection_id, Unset):
            connection_id = UNSET
        else:
            connection_id = self.connection_id

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update({})
        if id is not UNSET:
            field_dict["id"] = id
        if slug is not UNSET:
            field_dict["slug"] = slug
        if main_branch is not UNSET:
            field_dict["mainBranch"] = main_branch
        if prepared_branch is not UNSET:
            field_dict["preparedBranch"] = prepared_branch
        if declaration_sha is not UNSET:
            field_dict["declarationSha"] = declaration_sha
        if connection_id is not UNSET:
            field_dict["connectionId"] = connection_id

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        id = d.pop("id", UNSET)

        slug = d.pop("slug", UNSET)

        main_branch = d.pop("mainBranch", UNSET)

        prepared_branch = d.pop("preparedBranch", UNSET)

        def _parse_declaration_sha(data: object) -> None | Unset | str:
            if data is None:
                return data
            if isinstance(data, Unset):
                return data
            return cast(None | Unset | str, data)

        declaration_sha = _parse_declaration_sha(d.pop("declarationSha", UNSET))

        def _parse_connection_id(data: object) -> None | Unset | str:
            if data is None:
                return data
            if isinstance(data, Unset):
                return data
            return cast(None | Unset | str, data)

        connection_id = _parse_connection_id(d.pop("connectionId", UNSET))

        shipr_dev_repo = cls(
            id=id,
            slug=slug,
            main_branch=main_branch,
            prepared_branch=prepared_branch,
            declaration_sha=declaration_sha,
            connection_id=connection_id,
        )

        shipr_dev_repo.additional_properties = d
        return shipr_dev_repo

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
