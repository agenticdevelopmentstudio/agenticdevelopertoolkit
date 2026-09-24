import { fireEvent, render } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { FAVICON_PATHS, Favicon } from "../components/favicon"

describe("Favicon", () => {
  it("asks the site itself for its icon", () => {
    const { container } = render(<Favicon href="https://example.com/some/page" />)
    expect(container.querySelector("img")?.getAttribute("src")).toBe(
      "https://example.com/favicon.ico",
    )
  })

  it("tries each candidate in turn, then shows the fallback", () => {
    const { container, getByText } = render(
      <Favicon href="https://example.com" fallback={<span>globe</span>} />,
    )
    for (const path of FAVICON_PATHS) {
      const img = container.querySelector("img")
      expect(img?.getAttribute("src")).toBe(`https://example.com${path}`)
      fireEvent.error(img!)
    }
    expect(container.querySelector("img")).toBeNull()
    expect(getByText("globe")).toBeTruthy()
  })

  it("shows the fallback for an address that is not one", () => {
    const { getByText } = render(<Favicon href="not a url" fallback={<span>globe</span>} />)
    expect(getByText("globe")).toBeTruthy()
  })
})
