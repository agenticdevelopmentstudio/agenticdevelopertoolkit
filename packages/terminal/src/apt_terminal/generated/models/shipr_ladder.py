from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar, Union, cast

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..types import UNSET, Unset

if TYPE_CHECKING:
    from ..models.shipr_ladder_rows_item import ShiprLadderRowsItem
    from ..models.shipr_ladder_tips import ShiprLadderTips


T = TypeVar("T", bound="ShiprLadder")


@_attrs_define
class ShiprLadder:
    """The column-aligned commit view: one row per commit, oldest first, with a mark in each branch column whose tip is at
    or above it.

        Attributes:
            columns (Union[Unset, list[str]]):
            rows (Union[Unset, list['ShiprLadderRowsItem']]):
            settled (Union[Unset, bool]): Every live branch is on the newest commit — nothing is in flight.
            tips (Union[Unset, ShiprLadderTips]):
            notes (Union[Unset, list[str]]):
            read_at (Union[Unset, str]): When the last status run read this.
    """

    columns: Unset | list[str] = UNSET
    rows: Unset | list["ShiprLadderRowsItem"] = UNSET
    settled: Unset | bool = UNSET
    tips: Union[Unset, "ShiprLadderTips"] = UNSET
    notes: Unset | list[str] = UNSET
    read_at: Unset | str = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        columns: Unset | list[str] = UNSET
        if not isinstance(self.columns, Unset):
            columns = self.columns

        rows: Unset | list[dict[str, Any]] = UNSET
        if not isinstance(self.rows, Unset):
            rows = []
            for rows_item_data in self.rows:
                rows_item = rows_item_data.to_dict()
                rows.append(rows_item)

        settled = self.settled

        tips: Unset | dict[str, Any] = UNSET
        if not isinstance(self.tips, Unset):
            tips = self.tips.to_dict()

        notes: Unset | list[str] = UNSET
        if not isinstance(self.notes, Unset):
            notes = self.notes

        read_at = self.read_at

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update({})
        if columns is not UNSET:
            field_dict["columns"] = columns
        if rows is not UNSET:
            field_dict["rows"] = rows
        if settled is not UNSET:
            field_dict["settled"] = settled
        if tips is not UNSET:
            field_dict["tips"] = tips
        if notes is not UNSET:
            field_dict["notes"] = notes
        if read_at is not UNSET:
            field_dict["readAt"] = read_at

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.shipr_ladder_rows_item import ShiprLadderRowsItem
        from ..models.shipr_ladder_tips import ShiprLadderTips

        d = dict(src_dict)
        columns = cast(list[str], d.pop("columns", UNSET))

        rows = []
        _rows = d.pop("rows", UNSET)
        for rows_item_data in _rows or []:
            rows_item = ShiprLadderRowsItem.from_dict(rows_item_data)

            rows.append(rows_item)

        settled = d.pop("settled", UNSET)

        _tips = d.pop("tips", UNSET)
        tips: Unset | ShiprLadderTips
        if isinstance(_tips, Unset):
            tips = UNSET
        else:
            tips = ShiprLadderTips.from_dict(_tips)

        notes = cast(list[str], d.pop("notes", UNSET))

        read_at = d.pop("readAt", UNSET)

        shipr_ladder = cls(
            columns=columns,
            rows=rows,
            settled=settled,
            tips=tips,
            notes=notes,
            read_at=read_at,
        )

        shipr_ladder.additional_properties = d
        return shipr_ladder

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
