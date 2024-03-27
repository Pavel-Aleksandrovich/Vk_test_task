//
//  File.swift
//  Vk_test_task
//
//  Created by pavel mishanin on 25/3/24.
//

import UIKit

final class SimulationViewController: UIViewController {
    
    struct Model {
        var isHealthy = true
    }
    
    private lazy var dataSource: [Model] = []
    
    private let layout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    private let containerView = UIView()
    
    private let personsCounterView = PersonsCounterView()
    
    private let toolbar = UIToolbar()
    
    private var timer: Timer?
    
    private let scrollView = UIScrollView()
    
    private lazy var multiSelectionView = ImageViewWithBlur(UIImage(systemName: "hand.draw")) {
        self.isMultiselectionActive.toggle()
    }
    
    private lazy var plusView = ImageViewWithBlur(UIImage(systemName: "plus")) {
        UIView.animate(withDuration: 0.3) {
            self.scrollView.zoomScale += 0.2
        }
    }
    
    private lazy var minusView = ImageViewWithBlur(UIImage(systemName: "minus")) {
        UIView.animate(withDuration: 0.3) {
            self.scrollView.zoomScale -= 0.2
        }
    }
    
    private var isMultiselectionActive = false {
        didSet {
            collectionView.isScrollEnabled = !isMultiselectionActive
            scrollView.isScrollEnabled = !isMultiselectionActive
            
            multiSelectionView.image = UIImage(systemName: isMultiselectionActive ? "hand.raised.slash" : "hand.draw")
            
            personsCounterView.setInfoText(isMultiselectionActive ? "Multiselect is enabled" : "Multiselect is disabled",
                                           image: UIImage(systemName: isMultiselectionActive ? "hand.draw" : "hand.raised.slash"))
        }
    }
    
    private let numberOfColumns = 10
    
    private let numberOfCells: Int
    private let timerDuration: Double
    private let numberOfSick: Int
    
    init(numberOfCells: Int, numberOfSick: Int, timerDuration: Double) {
        self.numberOfCells = numberOfCells
        self.numberOfSick = numberOfSick
        self.timerDuration = timerDuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.dataSource = Array(repeating: Model(), count: self.numberOfCells)
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }
        
        setupUI()
        setupConstraints()
        setupTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.setZoomScale(1.0, animated: false)
        
        updateCounter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.layoutMargins.bottom + 50 + 10, right: 0)
        
        toolbar.frame = CGRect(x: 0, y: view.frame.maxY-112 - view.layoutMargins.bottom, width: UIScreen.main.bounds.width, height: 80 + 32)
        
        personsCounterView.frame = CGRect(x: 16, y: toolbar.frame.minY+8, width: UIScreen.main.bounds.width-32, height: 80)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer?.fire()
        timer = nil
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension SimulationViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

// MARK: - UIScrollViewDelegate

extension SimulationViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return containerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        personsCounterView.setInfoText("\(Int(scrollView.zoomScale*100))%", image: UIImage(systemName: "magnifyingglass"))
        
        var horizontalInset: CGFloat = 0
        var verticalInset: CGFloat = 0

        var size = scrollView.contentSize
        let minSize = collectionView.bounds.size.multiply(scrollView.minimumZoomScale)
        let maxSize = collectionView.bounds.size.multiply(scrollView.maximumZoomScale)
        size.width = size.width.clamp(minSize.width, maxSize.width)
        size.height = size.height.clamp(minSize.height, maxSize.height)
        
        if size.width < scrollView.bounds.width {
            horizontalInset = (scrollView.bounds.width - size.width) * 0.5
            horizontalInset = max(0, horizontalInset)
        }
        
        if size.height < scrollView.bounds.height {
            verticalInset = (scrollView.bounds.height - size.height) * 0.5
            verticalInset = max(0, verticalInset)
        }
        
        let inset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
        if inset != scrollView.contentInset {
            scrollView.contentInset = inset
        }
    }
    
}

// MARK: - CollectionView Delegate & DataSource

extension SimulationViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / CGFloat(numberOfColumns)
        
        return CGSize.init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didTapAtIndexPath(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SimulationCollectionCell.id,
            for: indexPath) as? SimulationCollectionCell else { return UICollectionViewCell() }
        
        let isHealthy = dataSource[indexPath.item].isHealthy
        let image = UIImage(systemName: isHealthy ? "checkmark.circle" : "xmark.circle")
        let color: UIColor = isHealthy ? .baseGreen : .baseOrange
        
        cell.setData(image: image, color: color)
        
        return cell
    }
}

extension SimulationViewController {
    
    func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timerDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                let dataSourceCopy = self.dataSource // Создаём копию dataSource для работы в фоновом режиме
                
                // Условие выхода проверяем на копии данных
                guard !dataSourceCopy.filter({ $0.isHealthy }).isEmpty else { return }
                
                print("\nTIMER Tick\n")
                
                // Фильтрацию и выбор соседей проводим на копии
                let sicksListOffsets = dataSourceCopy.enumerated().filter { !$0.element.isHealthy }.compactMap { $0.offset }
                
                var indexPathsToUpdate = [IndexPath]()
                let group = DispatchGroup()
                
                for offset in sicksListOffsets {
                    group.enter()
                    self.getListNeighborsForIndex(offset, numberOfSick: self.numberOfSick, count: dataSourceCopy.count) { list in
                        let listIndexPath = list.filter { index in dataSourceCopy.indices.contains(index) && dataSourceCopy[index].isHealthy }.map { IndexPath(item: $0, section: 0) }
                        
                        DispatchQueue.main.async {
                            listIndexPath.forEach { indexPath in
                                if self.dataSource.indices.contains(indexPath.item) {
                                    self.dataSource[indexPath.item].isHealthy = false
                                    indexPathsToUpdate.append(indexPath)
                                }
                            }
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    if !indexPathsToUpdate.isEmpty {
                        self.collectionView.reloadItems(at: indexPathsToUpdate)
                    }
                    
                    // Работаем с актуальными данными для получения количества здоровых и больных
                    let healthy = self.dataSource.filter { $0.isHealthy }.count
                    let sick = self.dataSource.filter { !$0.isHealthy }.count
                    self.personsCounterView.setData(healthy: healthy, sick: sick)
                }
            }
        }
    }

    
    
    @objc func didPanGesture(_ gesture: UIPanGestureRecognizer) {
        guard isMultiselectionActive else {return}
        
        let location = gesture.location(in: collectionView)
        
        switch gesture.state {
        case .began, .changed:
            if let indexPath = collectionView.indexPathForItem(at: location) {
                didTapAtIndexPath(indexPath)
            }
        default: break
        }
    }
    
    func updateCounter() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let healthy = self.dataSource.filter { $0.isHealthy }.count
            let sick = self.dataSource.filter { $0.isHealthy == false }.count
            
            DispatchQueue.main.async {
                self.personsCounterView.setData(healthy: healthy, sick: sick)
            }
            
        }
    }
    
    func getListNeighborsForIndex(_ index: Int, numberOfSick: Int, count: Int, completion: @escaping([Int])->()) {
        let columns = numberOfColumns
        let rows = count/columns
        var neighbors = [Int]()
        
        let rowIndex = index / columns
        let columnIndex = index % columns
        
        // Вычисляем максимально возможное расстояние в ячейках от текущей позиции до края сетки
        let maxDistance = max(max(rowIndex, rows - rowIndex - 1), max(columnIndex, columns - columnIndex - 1))
        
        // Постепенно увеличиваем расстояние поиска от выбранной ячейки
        for distance in 1...maxDistance {
            if neighbors.count >= numberOfSick { break }
            let minRow = max(rowIndex - distance, 0)
            let maxRow = min(rowIndex + distance, rows - 1)
            let minColumn = max(columnIndex - distance, 0)
            let maxColumn = min(columnIndex + distance, columns - 1)
            
            // Перебираем крайние точки текущего "слоя" поиска
            
            let newMinRow = min(minRow, maxRow)
            let newMaxRow = max(minRow, maxRow)
            
            for row in newMinRow...newMaxRow {
                for column in minColumn...maxColumn {
                    if (row == newMinRow || row == newMaxRow || column == minColumn || column == maxColumn),
                       row * columns + column != index {
                        let neighborIndex = row * columns + column
                        if !neighbors.contains(neighborIndex) {
                            
                            if neighborIndex >= 0 && neighborIndex < numberOfCells {
                                neighbors.append(neighborIndex)
                                if neighbors.count >= numberOfSick { break }
                            }
                        }
                    }
                }
                if neighbors.count >= numberOfSick { break }
            }
        }
        
        let randomCount = Int.random(in: 0...neighbors.count)
        
        let randomElements = neighbors.shuffled().prefix(randomCount)
        
        completion(Array(randomElements))
    }
    
    func didTapAtIndexPath(_ indexPath: IndexPath) {
        let isHealthy = dataSource[indexPath.item].isHealthy
        
        guard isHealthy else {return}
        
        dataSource[indexPath.item].isHealthy.toggle()
        collectionView.reloadItems(at: [indexPath])
        
        updateCounter()
    }
    
    func setupUI() {
        toolbar.barStyle = .black
        
        view.backgroundColor = .black
        
        title = "Simulation"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = .black
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(SimulationCollectionCell.self, forCellWithReuseIdentifier: SimulationCollectionCell.id)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanGesture))
        panGesture.delegate = self
        collectionView.addGestureRecognizer(panGesture)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.4
        scrollView.maximumZoomScale = 5.0
        scrollView.zoomScale = 1.0
        scrollView.bouncesZoom = true
        scrollView.contentSize = collectionView.bounds.size
    }
    
    func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        
        containerView.frame = view.bounds
        scrollView.addSubview(containerView)
        
        containerView.addSubview(collectionView)
        collectionView.frame = containerView.bounds
        
        let buttonHeight: CGFloat = 70
        let buttonPadding: CGFloat = 16
        
        multiSelectionView.frame = CGRect(x: view.frame.maxX - buttonHeight - buttonPadding, y: view.frame.midY - buttonHeight - buttonPadding, width: buttonHeight, height: buttonHeight)
        view.addSubview(multiSelectionView)
        
        plusView.frame = CGRect(x: view.frame.maxX - buttonHeight - buttonPadding, y: view.frame.midY, width: buttonHeight, height: buttonHeight)
        view.addSubview(plusView)
        
        minusView.frame = CGRect(x: plusView.frame.minX, y: plusView.frame.maxY + buttonPadding, width: buttonHeight, height: buttonHeight)
        view.addSubview(minusView)
        
        view.addSubview(toolbar)
        
        view.addSubview(personsCounterView)
    }
}

// MARK: - Simulation Collection Cell

final class SimulationCollectionCell: UICollectionViewCell {
    
    static let id = String(describing: SimulationCollectionCell.self)
    
    private let backImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(image: UIImage?, color: UIColor) {
        backImageView.image = image
        backImageView.tintColor = color
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 2
        addSubview(backImageView)
        backImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            backImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            backImageView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            backImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
        ])
    }
    
}
