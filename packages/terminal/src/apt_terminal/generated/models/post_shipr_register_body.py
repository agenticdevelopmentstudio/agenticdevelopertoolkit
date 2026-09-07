from collections.abc import Mapping
from typing import Any, TypeVar

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..types import UNSET, Unset

T = TypeVar("T", bound="PostShiprRegisterBody")


@_attrs_define
class PostShiprRegisterBody:
    """
    Attributes:
        slug (str): owner/name on the forge.
        connection_id (Union[Unset, str]): A GitHub App installation belonging to the caller, from `GET
            /shipr/connections`. Omitted, the repository is read anonymously — status works, nothing that writes does.
        group_id (Union[Unset, str]): Where a FIRST registration files the mirrors it invents.
        main_branch (Union[Unset, str]):
        prepared_branch (Union[Unset, str]):
        deployment_owner (Union[Unset, str]): Where the ONE mirror goes when `.shipr` declares no shards. Read only on
            that fallback — a declared shard’s slug is never overridden, because the file and the form must not be able to
            say two different things.
        deployment_name (Union[Unset, str]): The mirror’s name on the same fallback. Defaults to `<name>-deployment`;
            overridable independently of the owner, because changing the org almost always keeps the name.
    """

    slug: str
    connection_id: Unset | str = UNSET
    group_id: Unset | str = UNSET
    main_branch: Unset | str = UNSET
    prepared_branch: Unset | str = UNSET
    deployment_owner: Unset | str = UNSET
    deployment_name: Unset | str = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        slug = self.slug

        connection_id = self.connection_id

        group_id = self.group_id

        main_branch = self.main_branch

        prepared_branch = self.prepared_branch

        deployment_owner = self.deployment_owner

        deployment_name = self.deployment_name

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "slug": slug,
            }
        )
        if connection_id is not UNSET:
            field_dict["connectionId"] = connection_id
        if group_id is not UNSET:
            field_dict["groupId"] = group_id
        if main_branch is not UNSET:
            field_dict["mainBranch"] = main_branch
        if prepared_branch is not UNSET:
            field_dict["preparedBranch"] = prepared_branch
        if deployment_owner is not UNSET:
            field_dict["deploymentOwner"] = deployment_owner
        if deployment_name is not UNSET:
            field_dict["deploymentName"] = deployment_name

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        slug = d.pop("slug")

        connection_id = d.pop("connectionId", UNSET)

        group_id = d.pop("groupId", UNSET)

        main_branch = d.pop("mainBranch", UNSET)

        prepared_branch = d.pop("preparedBranch", UNSET)

        deployment_owner = d.pop("deploymentOwner", UNSET)

        deployment_name = d.pop("deploymentName", UNSET)

        post_shipr_register_body = cls(
            slug=slug,
            connection_id=connection_id,
            group_id=group_id,
            main_branch=main_branch,
            prepared_branch=prepared_branch,
            deployment_owner=deployment_owner,
            deployment_name=deployment_name,
        )

        post_shipr_register_body.additional_properties = d
        return post_shipr_register_body

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
