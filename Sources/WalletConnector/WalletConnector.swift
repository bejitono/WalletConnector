//
//  File.swift
//  
//
//  Created by Stefano on 15.04.21.
//

import Foundation
import WalletConnectSwift

public protocol WalletConnectorDelegate: AnyObject {
    
    func walletConnectorDidConnect(_ connector: WalletConnector)
    func walletConnectorDidDisconnect(_ connector: WalletConnector)
    func walletConnectorDidFailToConnect(_ connector: WalletConnector)
}

open class WalletConnector {
    
    public var urlString: String?
    public weak var delegate: WalletConnectorDelegate?
    
    private let sessionKey = "WalletConnector.Session"
    private var client: Client?
    private var session: Session?
    private let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func connect() throws {
        let wcUrl = WCURL(
            topic: UUID().uuidString,
            bridgeURL: URL(string: "https://bridge.walletconnect.org")!,
            key: try randomKey()
        )
        let clientMeta = Session.ClientMeta(
            name: "WalletConnector",
            description: "WalletConnector",
            icons: [],
            url: URL(string: "https://bitcoin.org")!
        )
        let dAppInfo = Session.DAppInfo(peerId: UUID().uuidString, peerMeta: clientMeta)
        self.client = Client(delegate: self, dAppInfo: dAppInfo)
        
        try client?.connect(to: wcUrl)
    }
    
    func reconnectIfNeeded() throws {
        if let previousSessionObject = userDefaults.object(forKey: sessionKey) as? Data,
           let session = try JSONDecoder().decode(Session.self, from: previousSessionObject) {
            client = Client(delegate: self, dAppInfo: session.dAppInfo)
            try client?.reconnect(to: session)
        }
    }
    
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

    public func client(_ client: Client, didDisconnect session: Session) {
        userDefaults.removeObject(forKey: sessionKey)
        delegate?.walletConnectorDidDisconnect(self)
    }
}
