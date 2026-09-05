import Foundation

/// A `CredentialStore` that also remembers the refresh token. The
/// `CredentialStore` half is derived: `currentCredentials()` is the session's
/// credentials, `save(_ credentials:)` replaces the session with one that has
/// no refresh token (that is what adopting an API token means).
public protocol SessionStore: CredentialStore {
    func currentSession() -> Session?
    func save(_ session: Session)
}

extension SessionStore {
    public func currentCredentials() -> Credentials? {
        currentSession()?.credentials
    }

    public func save(_ credentials: Credentials) {
        save(Session(credentials: credentials, refreshToken: nil))
    }
}

public final class InMemorySessionStore: SessionStore, @unchecked Sendable {

    private let lock = NSLock()
    private var session: Session?

    public init(_ session: Session? = nil) {
        self.session = session
    }

    public func currentSession() -> Session? {
        lock.withLock { session }
    }

    public func save(_ session: Session) {
        lock.withLock { self.session = session }
    }

    public func clear() {
        lock.withLock { session = nil }
    }
}

/// Keychain-backed session. Shares `<prefix>.token` / `<prefix>.token.kind`
/// with `KeychainCredentialStore` (same default prefix `adh.api`), so a
/// credential saved by the older store is readable here as a session with
/// no refresh token, and vice versa.
public struct KeychainSessionStore: SessionStore {

    let tokenKey: String
    let kindKey: String
    let refreshKey: String

    public init(keyPrefix: String = "adh.api") {
        self.tokenKey = "\(keyPrefix).token"
        self.kindKey = "\(keyPrefix).token.kind"
        self.refreshKey = "\(keyPrefix).refresh"
    }

    public func currentSession() -> Session? {
        guard let token = KeychainHelper.get(forKey: tokenKey) else { return nil }
        let kind = KeychainHelper.get(forKey: kindKey)
            .flatMap(Credentials.Kind.init(rawValue:)) ?? .jwt
        return Session(
            credentials: Credentials(token: token, kind: kind),
            refreshToken: KeychainHelper.get(forKey: refreshKey)
        )
    }

    public func save(_ session: Session) {
        KeychainHelper.set(session.credentials.token, forKey: tokenKey)
        KeychainHelper.set(session.credentials.kind.rawValue, forKey: kindKey)
        if let refreshToken = session.refreshToken {
            KeychainHelper.set(refreshToken, forKey: refreshKey)
        } else {
            KeychainHelper.delete(forKey: refreshKey)
        }
    }

    public func clear() {
        KeychainHelper.delete(forKey: tokenKey)
        KeychainHelper.delete(forKey: kindKey)
        KeychainHelper.delete(forKey: refreshKey)
    }
}
