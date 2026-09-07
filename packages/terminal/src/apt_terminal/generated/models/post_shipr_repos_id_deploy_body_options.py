from collections.abc import Mapping
from typing import Any, TypeVar

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..types import UNSET, Unset

T = TypeVar("T", bound="PostShiprReposIdDeployBodyOptions")


@_attrs_define
class PostShiprReposIdDeployBodyOptions:
    """Per-operation arguments. Read defensively; unknown keys are ignored.

    Attributes:
        sha (Union[Unset, str]): prepare: the tip to pin. Absent means the dev repo’s main as it stands.
        acknowledged_unverified (Union[Unset, bool]): prepare: proceed although the gate has posted no verdict for the
            sha. Never overrides a verdict that exists and is red.
        shard (Union[Unset, str]): register: which [deployments] key this mirror is.
        group_id (Union[Unset, str]): register: the folder a FIRST registration files its new mirrors under.
    """

    sha: Unset | str = UNSET
    acknowledged_unverified: Unset | bool = UNSET
    shard: Unset | str = UNSET
    group_id: Unset | str = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        sha = self.sha

        acknowledged_unverified = self.acknowledged_unverified

        shard = self.shard

        group_id = self.group_id

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update({})
        if sha is not UNSET:
            field_dict["sha"] = sha
        if acknowledged_unverified is not UNSET:
            field_dict["acknowledgedUnverified"] = acknowledged_unverified
        if shard is not UNSET:
            field_dict["shard"] = shard
        if group_id is not UNSET:
            field_dict["groupId"] = group_id

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        sha = d.pop("sha", UNSET)

        acknowledged_unverified = d.pop("acknowledgedUnverified", UNSET)

        shard = d.pop("shard", UNSET)

        group_id = d.pop("groupId", UNSET)

        post_shipr_repos_id_deploy_body_options = cls(
            sha=sha,
            acknowledged_unverified=acknowledged_unverified,
            shard=shard,
            group_id=group_id,
        )

        post_shipr_repos_id_deploy_body_options.additional_properties = d
        return post_shipr_repos_id_deploy_body_options

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
