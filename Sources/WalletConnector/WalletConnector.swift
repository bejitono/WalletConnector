//
//  WalletConnector.swift
//  
//
//  Created by Stefano on 15.04.21.
//

import Foundation
import WalletConnectSwift

public protocol WalletConnectorDelegate: AnyObject {
    
    func walletConnectorDidConnect(_ connector: WalletConnector)
    func walletConnectorDidUpdate(_ connector: WalletConnector)
    func walletConnectorDidDisconnect(_ connector: WalletConnector)
    func walletConnectorDidFailToConnect(_ connector: WalletConnector)
}

open class WalletConnector {
    
    public var urlString: String?
    public weak var delegate: WalletConnectorDelegate?
    
    private let appName: String
    private let appDescription: String
    private let icons: [URL]
    private let url: URL
    private let sessionKey = "WalletConnector.Session"
    private var client: Client?
    private var session: Session?
    private let userDefaults: UserDefaults
    
    init(
        appName: String,
        appDescription: String,
        icons: [URL] = [],
        url: URL,
        userDefaults: UserDefaults
    ) {
        self.appName = appName
        self.appDescription = appDescription
        self.icons = icons
        self.url = url
        self.userDefaults = userDefaults
    }
    
    public convenience init(
        appName: String,
        appDescription: String,
        icons: [URL] = [],
        url: URL
    ) {
        self.init(
            appName: appName,
            appDescription: appDescription,
            icons: icons,
            url: url,
            userDefaults: .standard
        )
    }
    
    /// Opens a connection with the wallet connect bridge. Call this method
    /// before attempting to link to a wallet.
    public func connect() throws {
        let wcUrl = WCURL(
            topic: UUID().uuidString,
            bridgeURL: URL(string: "https://bridge.walletconnect.org")!,
            key: try randomKey()
        )
        let clientMeta = Session.ClientMeta(
            name: appName,
            description: appDescription,
            icons: icons,
            url: url
        )
        let dAppInfo = Session.DAppInfo(peerId: UUID().uuidString, peerMeta: clientMeta)
        self.client = Client(delegate: self, dAppInfo: dAppInfo)
        
        try client?.connect(to: wcUrl)
        self.urlString = wcUrl.absoluteString
    }
    
    public func reconnectIfNeeded() throws {
        if let previousSessionObject = userDefaults.object(forKey: sessionKey) as? Data {
            let session = try JSONDecoder().decode(Session.self, from: previousSessionObject)
            client = Client(delegate: self, dAppInfo: session.dAppInfo)
            try client?.reconnect(to: session)
        }
    }
    
    public func deeplinkURL(fromBaseURL baseURL: URL) -> URL? {
        guard let wcUrlString = urlString else { return nil }
        let urlString = baseURL.absoluteString + "//wc?uri=" + wcUrlString // improve
        return URL(string: urlString)
    }
    
    // TODO: add sign/transact methods
}

// MARK: - ClientDelegate

extension WalletConnector: ClientDelegate {
    
    public func client(_ client: Client, didFailToConnect url: WCURL) {
        delegate?.walletConnectorDidFailToConnect(self)
    }

    public func client(_ client: Client, didConnect session: Session) {
        self.session = session
        let sessionData = try? JSONEncoder().encode(session)
        userDefaults.set(sessionData, forKey: sessionKey)
        delegate?.walletConnectorDidConnect(self)
    }
    
    public func client(_ client: Client, didConnect url: WCURL) {
        userDefaults.set(url.key, forKey: sessionKey)
        delegate?.walletConnectorDidConnect(self)
    }
    
    public func client(_ client: Client, didUpdate session: Session) {
        self.session = session
        let sessionData = try? JSONEncoder().encode(session)
        userDefaults.set(sessionData, forKey: sessionKey)
        delegate?.walletConnectorDidUpdate(self)
    }

    public func client(_ client: Client, didDisconnect session: Session) {
        userDefaults.removeObject(forKey: sessionKey)
        delegate?.walletConnectorDidDisconnect(self)
    }
}

// MARK: - Private

private extension WalletConnector {
    
    // https://developer.apple.com/documentation/security/1399291-secrandomcopybytes
    private func randomKey() throws -> String {
        var bytes = [Int8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status == errSecSuccess {
            return Data(bytes: bytes, count: 32).toHexString()
        } else {
            throw WalletConnectorError.failedToCreateKey
        }
    }
}
