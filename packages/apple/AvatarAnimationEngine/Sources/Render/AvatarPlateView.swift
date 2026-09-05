#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif
import CoreGraphics

/// A character above a host's content: a plate `plateHeight` tall painted
/// `plateColor` with the avatar filling it, and `content` — when there is one —
/// taking the rest of the view.
///
/// This is the arrangement every host that wants a character *over* something
/// else has to build, and the interesting part of it is not the four
/// constraints. It is what happens when the character isn't there: a `nil`
/// engine (its config would not load) and a running engine that fails later
/// both leave the content filling the whole view, so a chat whose character
/// dies is still a chat. A host that assembles the stack itself gets that wrong
/// by omission — the character leaves a blank rectangle where it was.
///
/// It takes an `Engine` rather than loading one, because which character this is
/// and where its config lives are the host's questions, not the plate's. With no
/// content the avatar has the whole view, which is the avatar-only window.
@MainActor
public final class AvatarPlateView: PlatformView {

    /// Tall enough for a character to be a character rather than a favicon,
    /// short enough that the content below it is still the point.
    public static let defaultPlateHeight: CGFloat = 160

    /// `nil` when the host had no engine to give — the plate is then just its
    /// content, and every method here is a no-op.
    public private(set) var avatar: AvatarLayerView?
    public let content: PlatformView?

    /// Reported when the *running* engine fails. The avatar is already
    /// collapsed by the time this is called.
    public var onError: ((Error) -> Void)?

    /// The colour under the character. Held rather than forwarded on the spot so
    /// a host can set it before an engine exists and after one dies.
    public var plateColor: CGColor? {
        didSet { avatar?.plateColor = plateColor }
    }

    private var avatarHeight: NSLayoutConstraint?

    /// The pin that gives the avatar the whole view when there is no content.
    /// Held because collapsing has to take it back — see `collapse()`.
    private var avatarBottom: NSLayoutConstraint?

    public init(engine: Engine?,
                content: PlatformView?,
                plateHeight: CGFloat = AvatarPlateView.defaultPlateHeight,
                plateColor: CGColor? = nil) {
        self.content = content
        self.plateColor = plateColor
        super.init(frame: .zero)

        var constraints: [NSLayoutConstraint] = []
        if let engine {
            let view = AvatarLayerView(engine: engine)
            avatar = view
            view.translatesAutoresizingMaskIntoConstraints = false
            view.plateColor = plateColor
            addSubview(view)
            constraints += [
                view.topAnchor.constraint(equalTo: topAnchor),
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
            if content != nil {
                let height = view.heightAnchor.constraint(equalToConstant: plateHeight)
                avatarHeight = height
                constraints.append(height)
            } else {
                let bottom = view.bottomAnchor.constraint(equalTo: bottomAnchor)
                avatarBottom = bottom
                constraints.append(bottom)
            }
            view.onError = { [weak self] error in
                self?.collapse()
                self?.onError?(error)
            }
        }

        if let content {
            content.translatesAutoresizingMaskIntoConstraints = false
            addSubview(content)
            let top = avatar.map { content.topAnchor.constraint(equalTo: $0.bottomAnchor) }
                ?? content.topAnchor.constraint(equalTo: topAnchor)
            constraints += [
                top,
                content.leadingAnchor.constraint(equalTo: leadingAnchor),
                content.trailingAnchor.constraint(equalTo: trailingAnchor),
                content.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        }
        NSLayoutConstraint.activate(constraints)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("AvatarPlateView is code-only; there is no nib to load it from")
    }

    public func start() { avatar?.start() }
    public func stop() { avatar?.stop() }

    /// Zero the avatar's height, whichever shape the plate has.
    ///
    /// With content there is a height constraint to shrink. WITHOUT content
    /// there is none — the avatar is pinned to the bottom to fill the view — so
    /// the pin is *swapped* for a zero height rather than joined by one: top +
    /// bottom + height 0 is unsatisfiable in a plate whose own height is fixed
    /// from outside, which is every plate in a window. Collapsing is one-way, so
    /// nothing has to put the pin back.
    private func collapse() {
        guard let avatar else { return }
        avatar.isHidden = true
        if let avatarHeight {
            avatarHeight.constant = 0
            return
        }
        avatarBottom?.isActive = false
        avatarBottom = nil
        let height = avatar.heightAnchor.constraint(equalToConstant: 0)
        height.isActive = true
        avatarHeight = height
    }
}
