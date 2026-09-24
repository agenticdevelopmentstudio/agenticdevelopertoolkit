"use client"

import * as React from "react"
import { Dialog as DialogPrimitive } from "@base-ui/react/dialog"
import { X } from "lucide-react"

import { cn } from "../lib/utils"

// base-ui dialog (centered modal), themed from `apt-*` tokens. Compose:
//   <Dialog><DialogTrigger/><DialogContent><DialogHeader>…
function Dialog(props: DialogPrimitive.Root.Props) {
  // Modals/alerts are NOT dismissed by clicking the backdrop/outside — only via a
  // button (alert-and-dialog.md §6). Escape/× still close per the keyboard policy.
  // Consumers may override by passing `disablePointerDismissal={false}`.
  return <DialogPrimitive.Root data-slot="dialog" disablePointerDismissal {...props} />
}

function DialogTrigger(props: DialogPrimitive.Trigger.Props) {
  return <DialogPrimitive.Trigger data-slot="dialog-trigger" {...props} />
}

function DialogClose(props: DialogPrimitive.Close.Props) {
  return <DialogPrimitive.Close data-slot="dialog-close" {...props} />
}

// The phone sheet `sheetOnPhone` turns on, built from `max-sm:` classes alone so it switches in
// CSS at exactly Tailwind's `sm` (PHONE_MAX_WIDTH in hooks/useMediaQuery mirrors it for code that
// has to switch in JS). It lives here because the User Settings overlay used to carry its own
// copy as an inline style keyed to a hand-written `(max-width: 639px)`: an inline style beats
// every class, so it overrode these defaults wholesale, and the × never moved clear of the notch
// with the safe-area padding it added.
//
// The safe area is a transparent BORDER, not padding: a border adds to whatever padding the
// dialog brings (`p-5` by default, `p-0` in the overlay) where a padding class would replace it,
// the background still paints under it (background-clip is border-box), and the absolutely
// placed × is positioned from the padding edge, so it moves in with the inset. The `0px`
// fallback matters: an `env()` with none, where the variable is unknown, leaves border-width at
// its initial `medium`. `dvh`, not `vh`: iOS Safari's `vh` is the height with its toolbar
// HIDDEN, so a 100vh sheet runs under the toolbar and hides its own bottom edge. The `-none`
// caps stop a consumer's unprefixed max-width/max-height from cutting the sheet short.
//
// Exported for a surface that is not a DialogContent but has to become the same sheet at the
// same width: adh's FloatingWindow, which had written its own copy of it inline. Such a surface
// must keep width and height OFF its inline style below the line — a style beats these classes.
const PHONE_SHEET_CLASSES =
  "max-sm:inset-0 max-sm:h-dvh max-sm:max-h-none max-sm:w-auto max-sm:max-w-none max-sm:translate-none max-sm:rounded-none max-sm:border-transparent max-sm:border-t-[length:env(safe-area-inset-top,0px)] max-sm:border-r-[length:env(safe-area-inset-right,0px)] max-sm:border-b-[length:env(safe-area-inset-bottom,0px)] max-sm:border-l-[length:env(safe-area-inset-left,0px)]"

function DialogContent({
  className,
  children,
  showClose = true,
  sheetOnPhone = false,
  ...props
}: DialogPrimitive.Popup.Props & {
  showClose?: boolean
  /**
   * Below Tailwind's `sm` breakpoint, fill the screen as a sheet instead of floating centred.
   * Opt-in: a confirmation of a few lines reads better floating on a phone too; a dialog that
   * holds a whole screen of UI (a settings rail, a Save bar) does not fit round a margin.
   * Size the desktop footprint with `sm:` classes, never an inline style — a style beats the
   * sheet's classes at every width.
   */
  sheetOnPhone?: boolean
}) {
  return (
    <DialogPrimitive.Portal>
      {/* HALF the dim this shipped with — 60% black put the page behind the dialog out of
          reach of reading, and a modal that hides its own context is answering a question
          you can no longer see (Mike). At 30% the page is plainly subordinate and still
          legible, which is what the blur is for as well. */}
      <DialogPrimitive.Backdrop className="fixed inset-0 z-50 bg-black/30 backdrop-blur-sm" />
      <DialogPrimitive.Popup
        data-slot="dialog-content"
        className={cn(
          "fixed top-1/2 left-1/2 z-50 grid w-[calc(100%-2rem)] max-w-md -translate-x-1/2 -translate-y-1/2 gap-4 rounded-xl border border-apt-border bg-apt-surface p-5 text-apt-text shadow-xl outline-none",
          sheetOnPhone && PHONE_SHEET_CLASSES,
          className,
        )}
        {...props}
      >
        {children}
        {showClose && (
          <DialogPrimitive.Close
            aria-label="Close"
            className="absolute top-3.5 right-3.5 rounded text-apt-text-muted transition-colors outline-none hover:text-apt-text focus-visible:ring-2 focus-visible:ring-apt-gold/40"
          >
            <X className="size-4" />
          </DialogPrimitive.Close>
        )}
      </DialogPrimitive.Popup>
    </DialogPrimitive.Portal>
  )
}

function DialogHeader({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="dialog-header"
      className={cn("flex flex-col gap-1.5", className)}
      {...props}
    />
  )
}

function DialogFooter({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="dialog-footer"
      className={cn("flex items-center justify-end gap-3", className)}
      {...props}
    />
  )
}

function DialogTitle({ className, ...props }: DialogPrimitive.Title.Props) {
  return (
    <DialogPrimitive.Title
      data-slot="dialog-title"
      className={cn("text-base font-semibold text-apt-text", className)}
      {...props}
    />
  )
}

function DialogDescription({
  className,
  ...props
}: DialogPrimitive.Description.Props) {
  return (
    <DialogPrimitive.Description
      data-slot="dialog-description"
      className={cn("text-sm text-apt-text-muted", className)}
      {...props}
    />
  )
}

export {
  Dialog,
  DialogTrigger,
  DialogClose,
  DialogContent,
  DialogHeader,
  DialogFooter,
  DialogTitle,
  DialogDescription,
  PHONE_SHEET_CLASSES,
}
