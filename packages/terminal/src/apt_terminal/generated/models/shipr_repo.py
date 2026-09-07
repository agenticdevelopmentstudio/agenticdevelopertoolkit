from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar, Union, cast

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..types import UNSET, Unset

if TYPE_CHECKING:
    from ..models.shipr_repo_env_branches import ShiprRepoEnvBranches
    from ..models.shipr_repo_provisioned_type_0 import ShiprRepoProvisionedType0


T = TypeVar("T", bound="ShiprRepo")


@_attrs_define
class ShiprRepo:
    """One deployment repository — a mirror. A dev repo with several `[deployments]` shards has one of these per shard.

    Attributes:
        id (Union[Unset, str]):
        dev_repo_id (Union[Unset, str]):
        group_id (Union[None, Unset, str]):
        slug (Union[Unset, str]): owner/name on the forge.
        shard (Union[Unset, str]):
        ship_branch (Union[Unset, str]):
        ci_context (Union[Unset, str]):
        env_branches (Union[Unset, ShiprRepoEnvBranches]): environment → branch. An environment absent here is one this
            repository does not deploy to, and its ladder column is not drawn.
        registered_at (Union[None, Unset, str]):
        provisioned (Union['ShiprRepoProvisionedType0', None, Unset]):
        position (Union[Unset, int]):
    """

    id: Unset | str = UNSET
    dev_repo_id: Unset | str = UNSET
    group_id: None | Unset | str = UNSET
    slug: Unset | str = UNSET
    shard: Unset | str = UNSET
    ship_branch: Unset | str = UNSET
    ci_context: Unset | str = UNSET
    env_branches: Union[Unset, "ShiprRepoEnvBranches"] = UNSET
    registered_at: None | Unset | str = UNSET
    provisioned: Union["ShiprRepoProvisionedType0", None, Unset] = UNSET
    position: Unset | int = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        from ..models.shipr_repo_provisioned_type_0 import ShiprRepoProvisionedType0

        id = self.id

        dev_repo_id = self.dev_repo_id

        group_id: None | Unset | str
        if isinstance(self.group_id, Unset):
            group_id = UNSET
        else:
            group_id = self.group_id

        slug = self.slug

        shard = self.shard

        ship_branch = self.ship_branch

        ci_context = self.ci_context

        env_branches: Unset | dict[str, Any] = UNSET
        if not isinstance(self.env_branches, Unset):
            env_branches = self.env_branches.to_dict()

        registered_at: None | Unset | str
        if isinstance(self.registered_at, Unset):
            registered_at = UNSET
        else:
            registered_at = self.registered_at

        provisioned: None | Unset | dict[str, Any]
        if isinstance(self.provisioned, Unset):
            provisioned = UNSET
        elif isinstance(self.provisioned, ShiprRepoProvisionedType0):
            provisioned = self.provisioned.to_dict()
        else:
            provisioned = self.provisioned

        position = self.position

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update({})
        if id is not UNSET:
            field_dict["id"] = id
        if dev_repo_id is not UNSET:
            field_dict["devRepoId"] = dev_repo_id
        if group_id is not UNSET:
            field_dict["groupId"] = group_id
        if slug is not UNSET:
            field_dict["slug"] = slug
        if shard is not UNSET:
            field_dict["shard"] = shard
        if ship_branch is not UNSET:
            field_dict["shipBranch"] = ship_branch
        if ci_context is not UNSET:
            field_dict["ciContext"] = ci_context
        if env_branches is not UNSET:
            field_dict["envBranches"] = env_branches
        if registered_at is not UNSET:
            field_dict["registeredAt"] = registered_at
        if provisioned is not UNSET:
            field_dict["provisioned"] = provisioned
        if position is not UNSET:
            field_dict["position"] = position

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.shipr_repo_env_branches import ShiprRepoEnvBranches
        from ..models.shipr_repo_provisioned_type_0 import ShiprRepoProvisionedType0

        d = dict(src_dict)
        id = d.pop("id", UNSET)

        dev_repo_id = d.pop("devRepoId", UNSET)

        def _parse_group_id(data: object) -> None | Unset | str:
            if data is None:
                return data
            if isinstance(data, Unset):
                return data
            return cast(None | Unset | str, data)

        group_id = _parse_group_id(d.pop("groupId", UNSET))

        slug = d.pop("slug", UNSET)

        shard = d.pop("shard", UNSET)

        ship_branch = d.pop("shipBranch", UNSET)

        ci_context = d.pop("ciContext", UNSET)

        _env_branches = d.pop("envBranches", UNSET)
        env_branches: Unset | ShiprRepoEnvBranches
        if isinstance(_env_branches, Unset):
            env_branches = UNSET
        else:
            env_branches = ShiprRepoEnvBranches.from_dict(_env_branches)

        def _parse_registered_at(data: object) -> None | Unset | str:
            if data is None:
                return data
            if isinstance(data, Unset):
                return data
            return cast(None | Unset | str, data)

        registered_at = _parse_registered_at(d.pop("registeredAt", UNSET))

        def _parse_provisioned(data: object) -> Union["ShiprRepoProvisionedType0", None, Unset]:
            if data is None:
                return data
            if isinstance(data, Unset):
                return data
            try:
                if not isinstance(data, dict):
                    raise TypeError()
                provisioned_type_0 = ShiprRepoProvisionedType0.from_dict(data)

                return provisioned_type_0
            except:  # noqa: E722
                pass
            return cast(Union["ShiprRepoProvisionedType0", None, Unset], data)

        provisioned = _parse_provisioned(d.pop("provisioned", UNSET))

        position = d.pop("position", UNSET)

        shipr_repo = cls(
            id=id,
            dev_repo_id=dev_repo_id,
            group_id=group_id,
            slug=slug,
            shard=shard,
            ship_branch=ship_branch,
            ci_context=ci_context,
            env_branches=env_branches,
            registered_at=registered_at,
            provisioned=provisioned,
            position=position,
        )

        shipr_repo.additional_properties = d
        return shipr_repo

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
