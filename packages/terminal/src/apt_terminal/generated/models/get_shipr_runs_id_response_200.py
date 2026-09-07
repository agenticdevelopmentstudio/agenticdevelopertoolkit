from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar, Union

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..types import UNSET, Unset

if TYPE_CHECKING:
    from ..models.shipr_run import ShiprRun
    from ..models.shipr_run_step import ShiprRunStep


T = TypeVar("T", bound="GetShiprRunsIdResponse200")


@_attrs_define
class GetShiprRunsIdResponse200:
    """
    Attributes:
        run (Union[Unset, ShiprRun]): One queued or completed operation over a scope.
        steps (Union[Unset, list['ShiprRunStep']]):
    """

    run: Union[Unset, "ShiprRun"] = UNSET
    steps: Unset | list["ShiprRunStep"] = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        run: Unset | dict[str, Any] = UNSET
        if not isinstance(self.run, Unset):
            run = self.run.to_dict()

        steps: Unset | list[dict[str, Any]] = UNSET
        if not isinstance(self.steps, Unset):
            steps = []
            for steps_item_data in self.steps:
                steps_item = steps_item_data.to_dict()
                steps.append(steps_item)

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update({})
        if run is not UNSET:
            field_dict["run"] = run
        if steps is not UNSET:
            field_dict["steps"] = steps

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.shipr_run import ShiprRun
        from ..models.shipr_run_step import ShiprRunStep

        d = dict(src_dict)
        _run = d.pop("run", UNSET)
        run: Unset | ShiprRun
        if isinstance(_run, Unset):
            run = UNSET
        else:
            run = ShiprRun.from_dict(_run)

        steps = []
        _steps = d.pop("steps", UNSET)
        for steps_item_data in _steps or []:
            steps_item = ShiprRunStep.from_dict(steps_item_data)

            steps.append(steps_item)

        get_shipr_runs_id_response_200 = cls(
            run=run,
            steps=steps,
        )

        get_shipr_runs_id_response_200.additional_properties = d
        return get_shipr_runs_id_response_200

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
