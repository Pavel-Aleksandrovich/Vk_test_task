//
//  File.swift
//  Vk_test_task
//
//  Created by pavel mishanin on 27/3/24.
//

import UIKit

final class ImageViewWithBlur: UIView {
    
    private let tapHandler: ()->()
    
    private let backImageView = UIImageView()
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    var image: UIImage? {
        get {
            return nil
        }
        set {
            backImageView.image = newValue
        }
    }
    
    init(_ image: UIImage?, tapHandler: @escaping ()->()) {
        backImageView.image = image
        self.tapHandler = tapHandler
        super.init(frame: .zero)
        
        setupConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurEffectView.frame = bounds
        
        blurEffectView.layer.cornerRadius = frame.height/2
        blurEffectView.clipsToBounds = true
        
    }
    
    private func setupUI() {
        backImageView.tintColor = .white
        backImageView.contentMode = .scaleAspectFit
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        
        addSubview(blurEffectView)
        
        let padding: CGFloat = 15
        addSubview(backImageView)
        backImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            backImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            backImageView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            backImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
        ])
    }
    
    @objc private func tap() {
        tapHandler()
    }
    
}
