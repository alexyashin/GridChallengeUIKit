//
//  ViewController.swift
//  GridChallengeUIKit
//
//  Created by Alexey Yashin on 28.04.2021.
//

import UIKit

enum PinchState {
    case none
    case pinchIn
    case pinchOut
}

class CollectionLayout {
    var size: Int
    var layout: UICollectionViewLayout
    var biggerLayout: CollectionLayout?
    var smallerLayout: CollectionLayout?
    
    init(size: Int) {
        self.size = size
        
        let height = UIScreen.main.bounds.width / CGFloat(size)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: height * 5, height: height)
        self.layout = layout
    }
}

class ViewController: UICollectionViewController {
    
    let samplePhotos = (1...500).map { UIImage(named: "coffee-\($0 % 20 + 1)") }
    var layoutTransition: UICollectionViewTransitionLayout?
    var prevScale: CGFloat = 1
    var lastPinch: PinchState = .none
    var currentLayout: CollectionLayout!
    var nextLayout: CollectionLayout?
    var transitionFinished = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLayouts()
        collectionView.collectionViewLayout = currentLayout.layout
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinch(sender:))))
    }
    
    func initLayouts() {
        let singleLayout = CollectionLayout(size: 1)
        let threeLayout = CollectionLayout(size: 3)
        let fiveLayout = CollectionLayout(size: 5)
        
        singleLayout.biggerLayout = threeLayout
        threeLayout.biggerLayout = fiveLayout
        threeLayout.smallerLayout = singleLayout
        fiveLayout.smallerLayout = threeLayout
        
        currentLayout = threeLayout
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        if sender.state == .changed {
            updateTransition(scale: sender.scale)
        }
        if sender.state == .ended || sender.state == .cancelled {
            if (layoutTransition != nil) {
                collectionView.finishInteractiveTransition()
                currentLayout = nextLayout
                layoutTransition = nil
                nextLayout = nil
            }
            
            prevScale = 1
            lastPinch = .none
            return
        }
        
        if sender.scale > prevScale {
            lastPinch = .pinchOut
        } else if sender.scale < prevScale {
            lastPinch = .pinchIn
        }
        prevScale = sender.scale
    }
    
    func updateTransition(scale: CGFloat) {
        if let transition = layoutTransition {
            var multiplier: CGFloat = 1
            if let nextLayout = nextLayout {
                if lastPinch == .pinchOut {
                    multiplier = currentLayout.size > nextLayout.size ? -1 : 1
                } else if lastPinch == .pinchIn {
                    multiplier = currentLayout.size > nextLayout.size ? -1 : 1
                }
            }
            transition.transitionProgress += multiplier * (scale - prevScale)
        } else {
            if lastPinch == .pinchOut {
                if let biggerLayout = currentLayout.biggerLayout {
                    startNewTransition(with: biggerLayout)
                }
            } else if lastPinch == .pinchIn {
                if let smallerLayout = currentLayout.smallerLayout {
                    startNewTransition(with: smallerLayout)
                }
            }
        }
    }
    
    func startNewTransition(with collectionLayout: CollectionLayout) {
        if !transitionFinished {
            return
        }
        transitionFinished = false
        layoutTransition = collectionView.startInteractiveTransition(to: collectionLayout.layout) {_,_ in
            self.transitionFinished = true
        }
        nextLayout = collectionLayout
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return samplePhotos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GridCollectionViewCell
        let firstSliceIndex = indexPath.item * 5
        let lastSliceIndex = firstSliceIndex + 4
        let images = samplePhotos[firstSliceIndex...lastSliceIndex]
        cell.change(images: Array(images))
        return cell
    }
}
