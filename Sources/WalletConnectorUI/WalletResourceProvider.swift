//
//  WalletResourceProvider.swift
//  
//
//  Created by Stefano on 17.04.21.
//

import Foundation
import UIKit

typealias WalletID = String

protocol WalletResourceProvidable {
    func getWallets() -> [Wallet]
    func get(walletId: String) -> Wallet?
}

final class WalletResourceProvider: WalletResourceProvidable {
    
    private lazy var wallets: [String: Wallet] = {
        guard let url = Bundle.module.url(forResource: "wallets", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let wallets = try? JSONDecoder().decode([WalletID: Wallet].self, from: data) else {
            return [:]
        }
        return wallets
    }()
    
    func getWallets() -> [Wallet] {
        wallets.map { $0.value }
    }
    
    func get(walletId: String) -> Wallet? {
        wallets[walletId]
    }
}
