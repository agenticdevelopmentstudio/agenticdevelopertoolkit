import { afterEach, describe, expect, it, vi } from "vitest";
import { cleanup, render } from "@testing-library/react";
import { HierarchicalTopicDetail, type TopicLevel } from "../blocks/hierarchical-topic-detail";

// `defaultSelectedWhen: "wide"`: the default is chosen beside a disclosed list, never in the
// narrow stack, where the list is its own pane and is what the reader opened.

type SelectFn = TopicLevel["onSelect"];

function levels(onSelect: SelectFn, when?: "always" | "wide"): TopicLevel[] {
  return [
    {
      id: "companies",
      title: "Companies",
      items: [{ id: "acme", label: "Acme" }],
      selectedId: "acme",
      onSelect: () => {},
      onClear: () => {},
    },
    {
      id: "acme",
      title: "Acme",
      items: [
        { id: "~overview", label: "Overview" },
        { id: "rockets", label: "Rockets" },
      ],
      selectedId: null,
      defaultSelectedId: "~overview",
      defaultSelectedWhen: when,
      onSelect,
      onClear: () => {},
    },
  ];
}

// The stack remembers each surface's applied defaults outside React, so every render gets a fresh
// surface — otherwise one test's spent default silences the next.
let surface = 0;

function renderIn(layoutMode: "wide" | "narrow", onSelect: SelectFn, when?: "always" | "wide") {
  surface += 1;
  return render(
    <HierarchicalTopicDetail levels={levels(onSelect, when)} layoutMode={layoutMode} surfaceScope={`t${surface}`}>
      {null}
    </HierarchicalTopicDetail>,
  );
}

afterEach(() => {
  cleanup();
});

describe("HierarchicalTopicDetail defaultSelectedWhen", () => {
  it("chooses the default beside the list in the wide layout", () => {
    const onSelect = vi.fn<SelectFn>();
    renderIn("wide", onSelect, "wide");
    expect(onSelect).toHaveBeenCalledWith("~overview", { replace: true });
  });

  it("leaves the list alone in the narrow layout", () => {
    const onSelect = vi.fn<SelectFn>();
    renderIn("narrow", onSelect, "wide");
    expect(onSelect).not.toHaveBeenCalled();
  });

  it("keeps the unconditional default everywhere when unset", () => {
    const onSelect = vi.fn<SelectFn>();
    renderIn("narrow", onSelect);
    expect(onSelect).toHaveBeenCalledWith("~overview", { replace: true });
  });

  it("says which layout won on the measured row", () => {
    const { container } = renderIn("narrow", vi.fn<SelectFn>(), "wide");
    expect(container.querySelector("[data-htd-layout]")).toHaveAttribute("data-htd-layout", "narrow");
  });
});
