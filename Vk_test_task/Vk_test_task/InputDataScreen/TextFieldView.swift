//
//  File.swift
//  Vk_test_task
//
//  Created by pavel mishanin on 25/3/24.
//

import UIKit

final class TextFieldView: UIView {
    
    var textFieldHandler: (String)->() = { _ in }
    var nextHandler: ()->() = {}
    
    private let titleLabel = UILabel()
    private let errorLabel = UILabel()
    private let iconImageView = UIImageView()
    private let textField = UITextField()
    private let bottomView = UIView()
    
    private var hideTextTimer: Timer?
    
    private var isActive = false {
        didSet {
            
            bottomView.backgroundColor = isActive ? .baseGreen : .systemGray
            titleLabel.textColor = isActive ? .baseGreen : .systemGray
            iconImageView.tintColor = isActive ? .baseGreen : .systemGray
            
            if isActive {
                guard titleLabel.transform.isIdentity else {return}
                
                UIView.animate(withDuration: 0.3) {
                    self.titleLabel.transform = self.titleLabel.transform.scaledBy(x: 0.9, y: 0.9)
                    self.titleLabel.transform = self.titleLabel.transform.translatedBy(x: -18, y: -28)
                }
                
            } else {
                guard textField.text == "" else {return}
                
                UIView.animate(withDuration: 0.3) {
                    self.titleLabel.transform = .identity
                }
            }
            
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setSubtitle(_ text: String) {
        errorLabel.text = text
        
        hideTextTimer?.invalidate()
        
        hideTextTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            self?.errorLabel.text?.removeAll()
        }
    }
    
    func setData(text: String, image: UIImage?) {
        titleLabel.text = text
        
        iconImageView.image = image
    }
    
    func firstResponder() {
        textField.becomeFirstResponder()
    }
    
    func clearTextField() {
        textField.text?.removeAll()
    }
    
}

// MARK: - UITextFieldDelegate

extension TextFieldView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isActive = textField.isFirstResponder
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isActive = textField.isFirstResponder
    }
    
}

private extension TextFieldView {
    
    @objc func hideKeyboardDidTap() {
        endEditing(true)
    }
    
    @objc func nextDidTap() {
        nextHandler()
    }
    
    @objc func textFieldDidChange() {
        textFieldHandler(textField.text ?? "")
        
        errorLabel.text?.removeAll()
    }
    
    func setupUI() {
        
        backgroundColor = .clear
        
        errorLabel.textColor = .baseOrange
        errorLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        
        titleLabel.textColor = .systemGray
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemGray
        
        let bar = UIToolbar()
        bar.barTintColor = .darkGray
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let left = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(hideKeyboardDidTap))
        left.tintColor = .baseGreen
        
        let right = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextDidTap))
        right.tintColor = .baseGreen
        
        bar.items = [left, space, right]
        bar.sizeToFit()
        
        textField.inputAccessoryView = bar
        textField.keyboardType = .numberPad
        textField.keyboardAppearance = .dark
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        textField.tintColor = .baseGreen
        textField.delegate = self
        textField.borderStyle = .none
        
        bottomView.backgroundColor = .systemGray
    }
    
    func setupConstraints() {
        
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            textField.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])
        
        addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
        ])
        
        textField.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 0),
            bottomView.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 0),
            bottomView.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 1.5),
        ])
        
        textField.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 0),
            titleLabel.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
        ])
        
    }
}
