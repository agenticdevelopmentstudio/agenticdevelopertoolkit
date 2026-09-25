import { afterEach, describe, expect, it } from "vitest";
import { cleanup, render } from "@testing-library/react";
import { HierarchicalTopicDetail, type TopicLevel } from "../blocks/hierarchical-topic-detail";

// `detailWidth`: a detail that is a document gets one width in the wide layouts, not whatever the
// lists leave, and the pane shows where it ends.

const levels: TopicLevel[] = [
  {
    id: "companies",
    title: "Companies",
    items: [{ id: "acme", label: "Acme" }],
    selectedId: "acme",
    onSelect: () => {},
    onClear: () => {},
  },
];

function renderWith(style: "covered" | "minimized", detailWidth?: string) {
  return render(
    <HierarchicalTopicDetail levels={levels} layoutMode="wide" disclosureStyle={style} detailWidth={detailWidth}>
      <p>detail</p>
    </HierarchicalTopicDetail>,
  );
}

afterEach(() => {
  cleanup();
});

describe("HierarchicalTopicDetail detailWidth", () => {
  it("caps the covered pane at the width, keeping its left edge", () => {
    const { container } = renderWith("covered", "60rem");
    const pane = container.querySelector<HTMLElement>("[data-htd-detail]")!;
    expect(pane.style.maxWidth).toBe("60rem");
    expect(pane.className).toContain("border-r");
    // It is also the floor the pane holds before the lists give way.
    expect(pane.querySelector<HTMLElement>("section > div:last-child")!.style.minWidth).toBe("min(60rem, 100%)");
  });

  it("sizes the minimized detail column to the width instead of the leftover", () => {
    const { container } = renderWith("minimized", "60rem");
    const grid = container.querySelector<HTMLElement>("[style*='--cols']")!;
    expect(grid.style.getPropertyValue("--cols")).toMatch(/minmax\(0,60rem\)$/);
  });

  it("fills what the lists leave when unset", () => {
    const { container } = renderWith("covered");
    const pane = container.querySelector<HTMLElement>("[data-htd-detail]")!;
    expect(pane.style.maxWidth).toBe("");
    expect(pane.className).not.toContain("border-r");
    const { container: min } = renderWith("minimized");
    expect(min.querySelector<HTMLElement>("[style*='--cols']")!.style.getPropertyValue("--cols")).toMatch(
      /minmax\(0,1fr\)$/,
    );
  });
});
