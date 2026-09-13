/**
 * THE TWO PLACES A DOCUMENT CROSSES BETWEEN THE PAGE AND THE OPERATOR'S DISK.
 *
 * Kept here, in the lowest tier, because every feature that can export something can also
 * import it back, and both halves are pure browser plumbing with no opinion about what the
 * bytes mean: a `Blob`, an object URL, an `<a>` the DOM has to click for us, and a `File`
 * turned into text. A feature package that grows its own copy grows its own version of the
 * three browser quirks recorded below, and discovers each of them the same expensive way.
 *
 * These are the only functions here that need a DOM, which is what makes them cheap to stand
 * in: a test that wants to know what was exported replaces `saveTextFile` and asserts on the
 * text, rather than emulating a download.
 */

/** The `showSaveFilePicker` corner of the File System Access API, which TypeScript's DOM lib
 *  does not declare. Narrowed to what this file actually calls — a fuller type would be a
 *  second, worse copy of a spec nobody here is implementing. */
interface FileSystemWritableStreamLike {
  write: (data: string) => Promise<void>;
  close: () => Promise<void>;
}
interface FileSystemFileHandleLike {
  createWritable: () => Promise<FileSystemWritableStreamLike>;
}
interface SaveFilePickerWindow {
  showSaveFilePicker?: (options: {
    suggestedName?: string;
    types?: { description?: string; accept: Record<string, string[]> }[];
  }) => Promise<FileSystemFileHandleLike>;
}

export interface SaveTextFileOptions {
  /** What to write. */
  text: string;
  /** The name the operator is offered — a real extension, because the picker derives the file
   *  type from it and a plain download names the file with it verbatim. */
  filename: string;
  /** MIME type for the blob and for the picker's filter. Defaults to JSON, which is what every
   *  caller so far exports. */
  type?: string;
  /** What the picker calls this kind of file in its type dropdown. */
  description?: string;
}

/**
 * Hand the operator the file, ASKING WHERE IT GOES when the browser can ask.
 *
 * `showSaveFilePicker` is the whole reason this is not three lines at a call site: a plain
 * anchor download drops the file into whatever folder the browser was last told about, with no
 * dialog and no way to choose, and "prompt me for the destination" is a thing operators
 * reasonably ask for when the file is configuration rather than a screenshot. Where the picker
 * exists, it is the native control, and where it does not (Firefox, Safari, every non-secure
 * context) the anchor is the fallback rather than the plan.
 *
 * CANCELLING MUST NOT FALL BACK. The picker rejects with an `AbortError` when the operator
 * dismisses it, and treating that like an unsupported browser downloads the file they just
 * declined to save. Returns `false` for that case and `true` when the bytes went somewhere.
 *
 * THE OBJECT URL IS REVOKED, and not in the same statement as the click: the blob is held
 * alive by the URL alone, so a page that forgets one leaks the document for as long as the tab
 * lives — but Safari reads the href during the navigation the click starts, and revoking
 * immediately has raced it. A macrotask later is after the dispatch and before anything cares.
 */
export async function saveTextFile({
  text,
  filename,
  type = "application/json",
  description,
}: SaveTextFileOptions): Promise<boolean> {
  const picker = (globalThis as unknown as SaveFilePickerWindow).showSaveFilePicker;
  if (typeof picker === "function") {
    try {
      const handle = await picker({
        suggestedName: filename,
        types: [{ description, accept: { [type]: [extensionOf(filename)] } }],
      });
      const writable = await handle.createWritable();
      await writable.write(text);
      await writable.close();
      return true;
    } catch (err) {
      // A dismissed dialog is an ANSWER — "don't save this" — and the only correct response is
      // to save nothing. Anything else (a permissions failure, a disk error) falls through to
      // the anchor, which is what a browser without the picker would have done anyway.
      if (isAbort(err)) return false;
    }
  }

  const blob = new Blob([text], { type });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = filename;
  // Attached, because a detached anchor's click is ignored by Firefox.
  anchor.style.display = "none";
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
  setTimeout(() => URL.revokeObjectURL(url), 0);
  return true;
}

/** The picked file's text. `File.text()` with a `FileReader` behind it for the browsers that
 *  have the one and not the other, because an import that silently does nothing on an older
 *  browser is worse than one that never drew a button. */
export function readTextFile(file: File): Promise<string> {
  if (typeof file.text === "function") return file.text();
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result ?? ""));
    reader.onerror = () => reject(reader.error ?? new Error("That file could not be read."));
    reader.readAsText(file);
  });
}

/** `".json"` for `"integrations.json"`, and `""` for a name with no extension — which the
 *  picker accepts as "any extension" rather than rejecting. */
function extensionOf(filename: string): string {
  const dot = filename.lastIndexOf(".");
  return dot > 0 ? filename.slice(dot) : "";
}

function isAbort(err: unknown): boolean {
  return (
    typeof err === "object" &&
    err !== null &&
    "name" in err &&
    (err as { name?: unknown }).name === "AbortError"
  );
}
