//
//  File.swift
//  Vk_test_task
//
//  Created by pavel mishanin on 27/3/24.
//

import UIKit

final class PersonsCounterView: UIView {
    
    private let healthyCounterButton = UILabel()
    private let sickCounterButton = UILabel()
    private let infoLabel = UILabel()
    
    private var hideTextTimer: Timer?
    
    init() {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let vStack = UIStackView(arrangedSubviews: [infoLabel, healthyCounterButton, sickCounterButton])
        
        vStack.frame = bounds
        addSubview(vStack)
        
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.distribution = .equalSpacing
    }
    
    func setData(healthy: Int, sick: Int) {
        
        setTextAttributed(text: "Healthy persons: \(healthy)",
                          image: UIImage(systemName: "checkmark.circle"),
                          color: .baseGreen,
                          toLabel: healthyCounterButton)
        
        setTextAttributed(text: "Sick persons: \(sick)",
                          image: UIImage(systemName: "xmark.circle"),
                          color: .baseOrange,
                          toLabel: sickCounterButton)
    }
    
    func setInfoText(_ text: String, image: UIImage?) {
        setTextAttributed(text: text, image: image, color: .white, toLabel: infoLabel)
        
        hideTextTimer?.invalidate()
        
        hideTextTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            self?.infoLabel.text?.removeAll()
        }
        
    }
    
    private func setTextAttributed(text: String, image: UIImage?, color: UIColor, toLabel: UILabel) {
        guard let image = image?.withTintColor(color) else {return}
        
        let attachment = NSTextAttachment()
        attachment.image = image
        let attachmentString = NSAttributedString(attachment: attachment)
        let myString = NSMutableAttributedString()
        
        myString.append(attachmentString)
        myString.append(NSAttributedString(string: " " + text))
        
        toLabel.attributedText = myString
        
        toLabel.textAlignment = .center
        toLabel.textColor = .white
        toLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        toLabel.numberOfLines = 0
    }
    
    private func setupUI() {
        backgroundColor = .clear
    }
    
}
