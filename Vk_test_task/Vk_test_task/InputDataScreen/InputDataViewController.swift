//
//  ViewController.swift
//  Vk_test_task
//
//  Created by pavel mishanin on 25/3/24.
//

import UIKit

final class InputDataViewController: UIViewController {
    
    enum TextFieldType: Int, CaseIterable {
        case groupSize
        case infectionFactor
        case periodT
        
        var title: String {
            switch self {
            case .groupSize: return "Group size"
            case .infectionFactor: return "Infection factor"
            case .periodT: return "Period T"
            }
        }
        
        var imageName: String {
            switch self {
            case .groupSize: return "person"
            case .infectionFactor: return "person.line.dotted.person"
            case .periodT: return "timer"
            }
        }
        
    }
    
    struct Model {
        let title: String
        let imageName: String
        var enteredText = String()
    }
    
    private var dataSource: [Model] = TextFieldType.allCases.map { Model(title: $0.title, imageName: $0.imageName) }
    
    private let vStack = UIStackView()
    private let startButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupStack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        vStack.arrangedSubviews.forEach { textFieldView in
            guard let textFieldView = textFieldView as? TextFieldView else {return}
            textFieldView.clearTextField()
        }
        
        dataSource = dataSource.map({ Model(title: $0.title, imageName: $0.imageName) })
        
        startButton.backgroundColor = isCanStart() ? .systemGreen : .systemGray
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        startButton.frame = CGRect(x: 16, y: view.frame.maxY - 16 - view.layoutMargins.bottom - 50, width: UIScreen.main.bounds.width-32, height: 50)
    }
    
}

private extension InputDataViewController {
    
    @objc func enterDataDidTap() {
        if isCanStart() {
            
            guard let numberOfCells = Int(dataSource[0].enteredText),
                  let numberOfSick = Int(dataSource[1].enteredText),
                    let timerDuration = Double(dataSource[2].enteredText) else {return}
            
            
            let vc = SimulationViewController(numberOfCells: numberOfCells,
                                              numberOfSick: numberOfSick,
                                              timerDuration: timerDuration)
            navigationController?.pushViewController(vc, animated: true)
            
        } else {
            
            for (index, model) in dataSource.enumerated() {
                
                if model.enteredText.isEmpty {
                    
                    guard let textFieldView = vStack.arrangedSubviews[index] as? TextFieldView else {return}
                    textFieldView.setSubtitle("Fill the field")
                    
                }
                
            }
        }
    }
    
    func isCanStart() -> Bool {
        dataSource.filter { $0.enteredText.isEmpty }.isEmpty
    }
    
    func setupUI() {
        
        view.backgroundColor = .black
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        navigationItem.backBarButtonItem?.tintColor = .baseGreen
        title = "Enter the data"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = .black
        
        startButton.backgroundColor = .systemGray
        startButton.setTitleColor(.white, for: .normal)
        startButton.setTitle("Start the simulation", for: .normal)
        startButton.layer.cornerRadius = 8
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        startButton.addTarget(self, action: #selector(enterDataDidTap), for: .touchUpInside)
        
        vStack.axis = .vertical
        vStack.spacing = 10
        vStack.alignment = .center
        vStack.distribution = .equalSpacing
        
    }
    
    func setupConstraints() {
        view.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
        
        view.addSubview(startButton)
    }
    
    func setupStack() {
        for (index, model) in dataSource.enumerated() {
            let textFieldView = TextFieldView()
            
            let image = UIImage(systemName: model.imageName)
            
            let text = model.title
            
            textFieldView.setData(text: text, image: image)
            
            vStack.addArrangedSubview(textFieldView)
            textFieldView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textFieldView.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
                textFieldView.trailingAnchor.constraint(equalTo: vStack.trailingAnchor),
            ])
            
            textFieldView.textFieldHandler = { text in
                self.dataSource[index].enteredText = text
                self.startButton.backgroundColor = self.isCanStart() ? .baseGreen : .systemGray
            }
            
            textFieldView.nextHandler = {
                if TextFieldType(rawValue: index+1) == nil {
                    self.view.endEditing(true)
                } else {
                    guard let textFieldView = self.vStack.arrangedSubviews[index+1] as? TextFieldView else {return}
                    
                    textFieldView.firstResponder()
                }
            }
        }
    }
}
