//
//  WalletConnectorViewController.swift
//  
//
//  Created by Stefano on 15.04.21.
//

import UIKit

public protocol WalletConnectorViewControllerDelegate: AnyObject {
    
    func walletConnectorViewController(
        _ viewController: WalletConnectorViewController,
        didTap wallet: String,
        deeplinkBaseURL: URL,
        universalLinkBaseURL: URL
    )
}

open class WalletConnectorViewController: UIViewController {
    
    public weak var delegate: WalletConnectorViewControllerDelegate?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}


// MARK: - View Setup

private extension WalletConnectorViewController {
    
    func setupViews() {
        
    }
}
