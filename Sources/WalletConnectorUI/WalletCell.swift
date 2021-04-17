//
//  WalletButton.swift
//  
//
//  Created by Stefano on 16.04.21.
//

import UIKit

open class WalletButton: UIButton {
    
    public let name: String
    public let deeplinkBaseURL: URL
    
    private let containerStackView = UIStackView()
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let icon: UIImage
    
    public init(frame: CGRect = .zero,
                name: String,
                icon: UIImage,
                deeplinkBaseURL: URL) {
        self.name = name
        self.icon = icon
        self.deeplinkBaseURL = deeplinkBaseURL
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Setup

private extension WalletButton {
    
    func setupViews() {
        setupContainerStackView()
        setupIconImageView()
        setupNameLabel()
    }
    
    func setupContainerStackView() {
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerStackView)
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        containerStackView.spacing = .spacing
    }
    
    func setupIconImageView() {
        containerStackView.addArrangedSubview(iconImageView)
        iconImageView.image = icon
        iconImageView.applyShadow()
    }
    
    func setupNameLabel() {
        containerStackView.addArrangedSubview(nameLabel)
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: .titleSize)
        nameLabel.textColor = .gray
    }
}

private extension UIView {
    
    func applyShadow() {
        layer.shadowColor = UIColor(red: 0.196, green: 0.196, blue: 0.279, alpha: 0.06).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
    }
}

// MARK: - View Constants

private extension CGFloat {
    static let spacing: CGFloat = 6
    static let titleSize: CGFloat = 12
}
