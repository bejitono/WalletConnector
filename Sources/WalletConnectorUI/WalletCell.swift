//
//  WalletCell.swift
//  
//
//  Created by Stefano on 16.04.21.
//

import UIKit

final class WalletCell: UICollectionViewCell {
    
    static let reuseId = "WalletConnector.WalletCell"
    
    private let containerStackView = UIStackView()
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String, icon: UIImage?) {
        iconImageView.image = icon?.withRenderingMode(.alwaysOriginal)
        nameLabel.text = name
    }
}

// MARK: - View Setup

private extension WalletCell {
    
    func setupViews() {
        setupContainerStackView()
        setupIconImageView()
        setupNameLabel()
    }
    
    func setupContainerStackView() {
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerStackView)
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        containerStackView.axis = .vertical
        containerStackView.distribution = .fillProportionally
        containerStackView.spacing = .spacing
    }
    
    func setupIconImageView() {
        containerStackView.addArrangedSubview(iconImageView)
        iconImageView.layer.cornerRadius = .cornerRadius
        iconImageView.layer.masksToBounds = true
        iconImageView.applyShadow()
        iconImageView.contentMode = .scaleAspectFill
    }
    
    func setupNameLabel() {
        containerStackView.addArrangedSubview(nameLabel)
        nameLabel.font = UIFont.systemFont(ofSize: .titleSize)
        nameLabel.textColor = Colors.text
        nameLabel.textAlignment = .center
    }
}

extension UIView {
    
    func applyShadow() {
        layer.shadowColor = UIColor(red: 0.196, green: 0.196, blue: 0.279, alpha: 0.06).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
    }
}

// MARK: - View Constants

private extension CGFloat {
    static let spacing: CGFloat = 3
    static let titleSize: CGFloat = 10
    static let cornerRadius: CGFloat = 12
}
