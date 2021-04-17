//
//  WalletConnectorViewController.swift
//  
//
//  Created by Stefano on 15.04.21.
//

import UIKit
import WalletConnector

public protocol WalletConnectorViewControllerDelegate: AnyObject {
    
    func walletConnectorViewController(
        _ viewController: WalletConnectorViewController,
        didTap wallet: String,
        deeplinkBaseURL: URL
//        universalLinkBaseURL: URL
    )
}

/// A modal displaying all supported wallets to be connected.
/// Tapping on a wallet will deeplink to a wallet. Please make sure to add
/// all supported wallet deeplinks to URL Schemes in your Info.plist.
/// - Deeplink URL schemes: metamask
open class WalletConnectorViewController: UIViewController {
    
    public weak var delegate: WalletConnectorViewControllerDelegate?
    public let titleLabel = UILabel()
    
    private lazy var walletCollectionViewController: UICollectionViewController = {
        let layout = UICollectionViewFlowLayout()
        let vc = UICollectionViewController(collectionViewLayout: layout)
        vc.collectionView.register(WalletCell.self, forCellWithReuseIdentifier: WalletCell.reuseId)
        vc.collectionView.delegate = self
        vc.collectionView.dataSource = self
        return vc
    }()
    private let overlayView = UIView()
    private let walletResourceProvider: WalletResourceProvidable
    private let walletConnector: WalletConnector
    
    init(walletResourceProvider: WalletResourceProvidable,
         walletConnector: WalletConnector) {
        self.walletResourceProvider = walletResourceProvider
        self.walletConnector = walletConnector
        super.init(nibName: nil, bundle: nil)
        try? walletConnector.connect()
    }
    
    public convenience init(
        appName: String,
        appDescription: String,
        url: URL
    ) {
        self.init(
            walletResourceProvider: WalletResourceProvider(),
            walletConnector: WalletConnector(
                appName: appName,
                appDescription: appDescription,
                icons: [],
                url: url
            )
        )
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

// MARK: - UICollectionViewDelegate / UICollectionViewDataSource

extension WalletConnectorViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        walletResourceProvider.getWallets().count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WalletCell.reuseId,
                for: indexPath) as? WalletCell else {
            return UICollectionViewCell()
        }
        let wallet = walletResourceProvider.getWallets()[indexPath.row]
        cell.configure(
            name: wallet.name,
            icon: UIImage(named: wallet.iconName, in: .module, compatibleWith: nil)
        )
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wallet = walletResourceProvider.getWallets()[indexPath.row]
        if let baseURL = wallet.deeplinkBaseURL,
           let url = walletConnector.deeplinkURL(fromBaseURL: baseURL),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - View Setup

private extension WalletConnectorViewController {
    
    func setupViews() {
        modalTransitionStyle = .crossDissolve
        view.backgroundColor = UIColor.gray.withAlphaComponent(.backgroundAlpha)
        setupOverlayView()
        setupTitleLabel()
        setupWalletCollectionView()
    }
    
    func setupOverlayView() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .overlayVerticalPadding),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.overlayVerticalPadding),
            overlayView.heightAnchor.constraint(equalToConstant: .overlayHeight)
        ])
        overlayView.backgroundColor = Colors.background
        overlayView.layer.cornerRadius = .overlayCornerRadius
        overlayView.applyShadow()
    }
    
    func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: .padding),
            titleLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: .padding),
            titleLabel.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -.padding)
        ])
        
        titleLabel.text = .title
        titleLabel.font = UIFont.systemFont(ofSize: .titleSize)
        titleLabel.textColor = Colors.text
        titleLabel.textAlignment = .center
    }
    
    func setupWalletCollectionView() {
        walletCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(walletCollectionViewController.view)
        NSLayoutConstraint.activate([
            walletCollectionViewController.view.leadingAnchor.constraint(
                equalTo: overlayView.leadingAnchor,
                constant: .padding
            ),
            walletCollectionViewController.view.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: .padding
            ),
            walletCollectionViewController.view.trailingAnchor.constraint(
                equalTo: overlayView.trailingAnchor,
                constant: -.padding
            ),
            walletCollectionViewController.view.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: overlayView.bottomAnchor,
                constant: -.padding
            )
        ])
        walletCollectionViewController.collectionView.backgroundColor = Colors.background
    }
}

// MARK: - View Constants

private extension CGFloat {
    static let padding: CGFloat = 20
    static let overlayVerticalPadding: CGFloat = 50
    static let spacing: CGFloat = 10
    static let titleSize: CGFloat = 16
    static let overlayCornerRadius: CGFloat = 10
    static let backgroundAlpha: CGFloat = 0.6
    static let overlayHeight: CGFloat = 400
}

private extension String {
    static let title: String = "Choose your preferred wallet"
}

enum Colors {
    static let background: UIColor? = UIColor(named: "Background", in: .module, compatibleWith: nil)
    static let text: UIColor? = UIColor(named: "Text", in: .module, compatibleWith: nil)
}
