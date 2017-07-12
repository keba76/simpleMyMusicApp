//
//  MainViewController.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage

struct SomeData {
    var image: UIImage?
    var index: IndexPath?
    var convert: CGRect?
    var convertTriangle: CGRect?
}

struct AppUtility {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {  delegate.restrictRotation = orientation }
    }
}

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var viewProgress: NVActivityIndicatorView?
    
    var data: SomeData?
    
    var reload = false
    fileprivate let imageLoadQueue = OperationQueue()
    fileprivate var imageLoadOperations = [IndexPath: ImageLoadOperation]()
    
    var animationController: AnimationController = AnimationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if #available(iOS 10.0, *) {
            collectionView?.prefetchDataSource = self
        }
        self.navigationItem.title = "Sounds Of Nature"
        
        let rectProgress = CGRect(x: view.bounds.width/2 - 20.0, y: (view.bounds.height)/2 - 20.0, width: 40.0, height: 40.0)
        viewProgress = NVActivityIndicatorView(frame: rectProgress, type: .lineScalePulseOut, color: UIColor(red: 255/255, green: 0/255, blue: 104/255, alpha: 1), padding: 0)
        self.view.addSubview(self.viewProgress!)
        self.view.bringSubview(toFront: self.viewProgress!)
        self.viewProgress?.startAnimating()
        
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        if #available(iOS 10.0, *) { collectionView.prefetchDataSource = self }
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        AudioViewModelController.share.retrieveData { [weak self] (success, error) in
            guard let strongSelf = self else { return }
            if !success {
                let title = "Error"
                if let error = error {
                    strongSelf.showError(title, message: error.localizedDescription)
                } else {
                    strongSelf.showError(title, message: NSLocalizedString("Can't retrieve contacts.", comment: "Can't retrieve contacts."))
                }
            } else {
                strongSelf.viewProgress?.stopAnimating()
                strongSelf.viewProgress?.removeFromSuperview()
                
                if strongSelf.reload {
                    if let indexPath = self?.collectionView?.indexPathsForVisibleItems {
                        strongSelf.reload = false
                        strongSelf.collectionView.performBatchUpdates({
                            UIView.setAnimationsEnabled(false)
                            strongSelf.collectionView.reloadItems(at: indexPath)
                            UIView.setAnimationsEnabled(true)
                        }, completion: { ok in strongSelf.reload = true })
                    }
                } else {
                    strongSelf.collectionView.reloadData()
                    strongSelf.reload = true
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AudioViewModelController.share.viewModelsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        
        if let viewModel = AudioViewModelController.share.viewModel(at: indexPath.row) {
            cell.configure(viewModel)
            cell.index = indexPath
            cell.delegate = self
            
            if let imageLoadOperation = imageLoadOperations[indexPath],
                let image = imageLoadOperation.image {
                cell.pic.image = image
            } else {
                let imageLoadOperation = ImageLoadOperation(url: viewModel.images)
                imageLoadOperation.completionHandler = { (image) in
                    cell.pic.image = image
                }
                imageLoadQueue.addOperation(imageLoadOperation)
                imageLoadOperations[indexPath] = imageLoadOperation
            }
        }
        return cell
    }
}

extension MainViewController: CollectionViewCellDelegate {
    
    func tapImage(index: IndexPath, image: UIImage, convert: CGRect) {
        
        let controllerPhotoScale = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PhotoScaleVC") as! PhotoScaleVC
        var frameCell = UICollectionViewLayoutAttributes()
        frameCell = collectionView.layoutAttributesForItem(at: index)!
        frameCell.frame = CGRect(x: frameCell.frame.origin.x, y: frameCell.frame.origin.y, width: convert.size.width, height: convert.size.height)
        
        let convertFinal = self.collectionView.convert(frameCell.frame, to: collectionView.superview)
        let convertFrameTriangle = CGRect(x: convertFinal.midX  - 15.0, y: convertFinal.midY - 15.0, width: 30.0, height: 30.0)
        self.data = SomeData(image: image, index: index, convert: convertFinal, convertTriangle: convertFrameTriangle)
        controllerPhotoScale.transitioningDelegate = self
        controllerPhotoScale.index = index
        controllerPhotoScale.image = image
        controllerPhotoScale.delegateOffset = self
        present(controllerPhotoScale, animated: true, completion: nil)
    }
}

extension MainViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        for indexPath in indexPaths {
            if let _ = imageLoadOperations[indexPath] { return }
            if let viewModel = AudioViewModelController.share.viewModel(at: (indexPath as NSIndexPath).row) {
                let imageLoadOperation = ImageLoadOperation(url: viewModel.images)
                imageLoadQueue.addOperation(imageLoadOperation)
                imageLoadOperations[indexPath] = imageLoadOperation
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let imageLoadOperation = imageLoadOperations[indexPath] else { return }
            imageLoadOperation.cancel()
            imageLoadOperations.removeValue(forKey: indexPath)
        }
    }
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if self.reload {
            guard let imageLoadOperation = imageLoadOperations[indexPath] else { return }
            imageLoadOperation.cancel()
            imageLoadOperations.removeValue(forKey: indexPath)
            }
        }
}


extension MainViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let photoViewController = presented as! PhotoScaleVC
        let alphaVariety = "up"
        animationController.setupImageTransition(data: data!, fromDelegate: self, toDelegate: photoViewController, alphaTabs: alphaVariety)
        return animationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let photoViewController = dismissed as! PhotoScaleVC
        let alphaVariety = "down"
        animationController.setupImageTransition(data: data!, fromDelegate: photoViewController, toDelegate: self, alphaTabs: alphaVariety)
        return animationController
    }
}

extension MainViewController: ImageTransitionProtocol {
    
    func tranisitionSetup() {}
    
    func tranisitionCleanup() { self.data = nil }
    
    func imageWindowFrame() -> CGRect { return (self.data?.convert)! }
}

extension MainViewController: OffserCell {
    
    func offset(index: IndexPath, image: UIImage) {
        if let dataConvert = self.data {
            self.data!.image = image
            var frameCell = UICollectionViewLayoutAttributes()
            frameCell = collectionView.layoutAttributesForItem(at: index)!
            frameCell.frame = CGRect(x: frameCell.frame.origin.x, y: frameCell.frame.origin.y, width: dataConvert.convert!.size.width, height: dataConvert.convert!.size.height)
            let convertFinal = self.collectionView.convert(frameCell.frame, to: collectionView.superview)
            let convertFrameTriangle = CGRect(x: convertFinal.midX  - 15.0, y: convertFinal.midY - 15.0, width: 30.0, height: 30.0)
            self.data!.convert = convertFinal
            self.data!.convertTriangle = convertFrameTriangle
        }
    }
}

//extension UICollectionView {
//    func reloadItems(index: [IndexPath], animation: Bool) {
//        if !animation {
//            CATransaction.begin()
//            CATransaction.setDisableActions(true)
//            self.reloadItems(at: index)
//            if !animation { CATransaction.commit() }
//        }
//    }
//}

