import SwiftUI
import Photos
import UIKit





struct ScrollPreviewUIKit<ViewModel: ScrollSwipeDelegate>: UIViewRepresentable {
    @EnvironmentObject var viewModel: ViewModel
    
     
    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = viewModel.cellSize
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0
        
        // Create a frame with explicit height to prevent vertical stacking
       // let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        // Force single line
        collectionView.isScrollEnabled = true
       // collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "cell")

        
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .normal
        collectionView.clipsToBounds = true
        
        context.coordinator.collectionView = collectionView
        self.viewModel.collectionView = collectionView
        DispatchQueue.main.async {
            context.coordinator.initialLayoutUpdate()
            context.coordinator.applyFadeMask()

        }
//        
        return collectionView
    }
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        // Update the collection view if needed
//        context.coordinator.parent = self
//        uiView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        var parent: ScrollPreviewUIKit
        weak var collectionView: UICollectionView?
        private var currentCenterIndexPath: IndexPath?
        private let feedbackGenerator = UISelectionFeedbackGenerator()
                
        init(parent: ScrollPreviewUIKit) {
            self.parent = parent
            super.init()
            feedbackGenerator.prepare()
        }
        
        // MARK: - Collection View Data Source & Delegate
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            parent.viewModel.cardQuee.count
        }
        
        func applyFadeMask() {
            guard let collectionView = collectionView else { return }

            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = collectionView.bounds
            gradientLayer.colors = [
                UIColor.clear.cgColor, // Left fade start
                UIColor.black.cgColor, // Fully visible center
                UIColor.black.cgColor, // Fully visible center
                UIColor.clear.cgColor  // Right fade end
            ]
            
            gradientLayer.locations = [0.0, 0.1, 0.9, 1.0] // Adjust as needed
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

            collectionView.layer.mask = gradientLayer
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
            cell.layer.cornerRadius = 4
            let wrapper = parent.viewModel.cardQuee[indexPath.item]
            cell.assetWrapper = wrapper
            cell.greenView.layer.opacity = Float(wrapper.isKept ? self.parent.viewModel.greenOpacity : 0)
            cell.redView.layer.opacity = Float(wrapper.isTrashed ? self.parent.viewModel.redOpacity : 0)
            // Apply initial scale
            let scale = (indexPath == currentCenterIndexPath) ? 1.5 : 1.0
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            return cell
        }
        
        // MARK: - Scroll View Delegate
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
            if scrollView.isDragging || scrollView.isDecelerating {
                updateCenterState(animated: true)
            }
            applyFadeMask() // Update gradient mask when scrolling

        }
        
    
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            
            Task(priority: .userInitiated){
                print("loading cards!")
                try await  self.parent.viewModel.cardContentStackFill(true)
            }
            
        }
        
        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            if let collectionView = collectionView  {
                let scaleAction = {
                    collectionView.visibleCells.forEach { cell in
                        guard let cellIndex = collectionView.indexPath(for: cell) else { return }
                        let scale = (cellIndex == IndexPath(item: self.parent.viewModel.currentIndex, section: 0)) ? 1.5 : 1.0
                
                        cell.transform = CGAffineTransform(scaleX: scale, y: scale)
                    }
                }
                UIView.animate(withDuration: 0.4,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0.5,
                               options: [.allowUserInteraction, .curveEaseOut],
                               animations: scaleAction)
            }
        }
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

            if !decelerate {
                
                Task(priority: .userInitiated){
                    print("loading cards!")
                    try await  self.parent.viewModel.cardContentStackFill(true)
                }
            }
        }
 
        
        // MARK: - Layout Helpers
    
        func updateCenterState(animated: Bool) {
            guard let collectionView = collectionView else { return }
            
            let centerPoint = CGPoint(
                x: collectionView.contentOffset.x + collectionView.bounds.width / 2,
                y: collectionView.bounds.height / 2
            )
            guard let centerIndexPath = collectionView.indexPathForItem(at: centerPoint) else { return }
            if centerIndexPath == currentCenterIndexPath { return }
            feedbackGenerator.selectionChanged()
            currentCenterIndexPath = centerIndexPath
            self.parent.viewModel.currentIndex = centerIndexPath.item
            if centerIndexPath.item < self.parent.viewModel.cardQuee.count {
                self.parent.viewModel.imageLoadingForScrollDetected(self.parent.viewModel.cardQuee[centerIndexPath.item].phasset)
            }
          //  self.parent.viewModel.currentIndex = centerIndexPath.item
            
            updateCellScaling(centerIndexPath: centerIndexPath, animated: true)
          //  print("current index path is \(centerIndexPath)")
        }
        
        func updateCellScaling(centerIndexPath: IndexPath, animated: Bool) {
            guard let collectionView = collectionView else { return }
            
            let scaleAction = {
                collectionView.visibleCells.forEach { cell in
                    guard let cellIndex = collectionView.indexPath(for: cell) else { return }
                    let scale = (cellIndex == centerIndexPath) ? 1.5 : 1.0
                    cell.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
            
            if animated {
                UIView.animate(withDuration: 0.4,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0.5,
                               options: [.allowUserInteraction, .curveEaseOut],
                               animations: scaleAction)
            } else {
                scaleAction()
            }
        }
        
        func initialLayoutUpdate() {
            guard let collectionView = collectionView else {
                    print("returning?")
                return
            }
            print(collectionView.bounds)
            let scaledCellWidth = self.parent.viewModel.cellSize.width * 1.5 / 2
            collectionView.contentInset = .init(top: 0,
                                                left: collectionView.bounds.width / 2 - scaledCellWidth  ,
                                                bottom: 0,
                                                right: collectionView.bounds.width / 2 - scaledCellWidth)

            let initialIndexPath = IndexPath(item: parent.viewModel.currentIndex, section: 0)
            currentCenterIndexPath = initialIndexPath
            
            // Scroll to initial position if needed
            collectionView.scrollToItem(
                at: initialIndexPath,
                at: .centeredHorizontally,
                animated: true
            )
        }
        

    }
}

class Cell: UICollectionViewCell {
    
    var assetWrapper: AssetWrapper? {
        didSet {
            loadImageFromAsset()
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .blue
        return imageView
    }()
    
    lazy var trashSymbol : UIImageView = {
        let trash = UIImageView(image: UIImage(systemName: "trash.fill"))
        trash.translatesAutoresizingMaskIntoConstraints = false
        trash.contentMode = .scaleAspectFit
        trash.tintColor = .red
        return trash
    }()
    
    lazy var loveSymbol : UIImageView = {
        let love = UIImageView(image: UIImage(systemName: "heart.fill"))
        love.translatesAutoresizingMaskIntoConstraints = false
        love.contentMode = .scaleAspectFit
        love.tintColor = .red
        
        return love
    }()
    
    lazy var greenView : UIView = {
        let green = UIView()
        green.translatesAutoresizingMaskIntoConstraints = false
        green.backgroundColor = .green
        green.clipsToBounds = true
        green.layer.cornerRadius = 4
        return green
    }()
    
    lazy var redView : UIView = {
        let red = UIView()
        red.translatesAutoresizingMaskIntoConstraints = false
        red.backgroundColor = .red
        red.layer.cornerRadius = 4
        red.clipsToBounds = true
        return red
    }()
    private var currentRequestID: PHImageRequestID?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(greenView)
        contentView.addSubview(redView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            greenView.topAnchor.constraint(equalTo: contentView.topAnchor),
            greenView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            greenView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            greenView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            redView.topAnchor.constraint(equalTo: contentView.topAnchor),
            redView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            redView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            redView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    private func loadImageFromAsset() {
        // Cancel any previous request
        if let requestID = currentRequestID {
            PHImageManager.default().cancelImageRequest(requestID)
        }
        
        guard let assetWrapper = assetWrapper else {
            imageView.image = nil
            return
        }
        
        let targetSize = CGSize(
            width: bounds.width * UIScreen.main.scale,
            height: bounds.height * UIScreen.main.scale
        )
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        currentRequestID = PHImageManager.default().requestImage(
            for: assetWrapper.phasset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { [weak self] image, info in
            guard let self = self else { return }
            
            if let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, isDegraded {
                // This is the low-quality version, we'll get another callback with the high-quality version
                return
            }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cancel any pending image request
        if let requestID = currentRequestID {
            PHImageManager.default().cancelImageRequest(requestID)
            currentRequestID = nil
        }
        
        // Clear the current image
        redView.layer.opacity = 0
        greenView.layer.opacity = 0
        imageView.image = nil
        assetWrapper = nil
    }
}
