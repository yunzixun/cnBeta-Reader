//
//  ImageDisplayController.swift
//  cnBeta-Reader
//
//  Created by Juncheng Han on 1/13/17.
//  Copyright © 2017 JasonH. All rights reserved.
//

import UIKit
import Kingfisher

class ImageDisplayController: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var imagesInfo = (imageContent: [Paragraph](), imageIndex: 0)
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tapGesture.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(tapGesture)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTap.numberOfTapsRequired = 2
        collectionView.addGestureRecognizer(doubleTap)

        tapGesture.require(toFail: doubleTap)
        
        return collectionView
    }()
    
    let fakeNavigationBar: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0.3, alpha: 0.95)
        return view
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "image_download_icon"), for: .normal)
        button.addTarget(self, action: #selector(handleSaveAction), for: .touchUpInside)
        return button
    }()
    
    var pageControl: CNPageControlBaguette?
    
    let imageIndexView: ImageIndexView = {
        let view = ImageIndexView()
        return view
    }()
    
    @objc fileprivate func dismiss() {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.collectionView.alpha = 0
            self.fakeNavigationBar.alpha = 0
        }, completion: {_ in
            self.collectionView.removeFromSuperview()
            self.pageControl?.removeFromSuperview()
            self.pageControl = nil
            self.fakeNavigationBar.removeFromSuperview()
            self.imageIndexView.removeFromSuperview()
        })

    }
    
    @objc fileprivate func doubleTapAction() {
        // zoom the image
        let currentImageCell = self.collectionView.visibleCells[0] as! ImageCell
        guard currentImageCell.imageView.image != nil else {
            return
        }
    
        if currentImageCell.imageScrollView.zoomScale > 1 {
            UIView.animate(withDuration: 0.2, animations: { 
                currentImageCell.imageScrollView.zoomScale = 1
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                currentImageCell.imageScrollView.zoomScale = 2
            })
        }
    
    }
    
    func show() {
        
        if let window = UIApplication.shared.keyWindow {
        
            window.addSubview(self.collectionView)
            window.addSubview(self.fakeNavigationBar)
            
            window.addConstraintsWithFormat("H:|[v0]|", views: self.collectionView)
            window.addConstraintsWithFormat("H:|[v0]|", views: self.fakeNavigationBar)
            window.addConstraintsWithFormat("V:|-20-[v0][v1(44)]|", views: self.collectionView, self.fakeNavigationBar)
            
            collectionView.backgroundColor = UIColor(white: 0.3, alpha: 0.6)
            collectionView.alpha = 0
            
            setupFakeNavigationBar()
            
            // show the display view animated
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.collectionView.alpha = 1
                self.fakeNavigationBar.alpha = 1
            }, completion: nil)
            
            collectionView.layoutIfNeeded()
            // scroll to selected image
            let indexPath = IndexPath(item: self.imagesInfo.imageIndex, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        }
    }
    
    func setupFakeNavigationBar() {
        fakeNavigationBar.addSubview(saveButton)
        fakeNavigationBar.addConstraintsWithFormat("H:[v0(24)]-10-|", views: saveButton)
        fakeNavigationBar.addConstraintsWithFormat("V:|-10-[v0(24)]", views: saveButton)
        
        if (imagesInfo.imageContent.count > 10) {
            fakeNavigationBar.addSubview(self.imageIndexView)
            fakeNavigationBar.addConstraintsWithFormat("H:|-10-[v0]-40-|", views: self.imageIndexView)
            fakeNavigationBar.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.imageIndexView)
            
            imageIndexView.sumLabel.text = "/  \(imagesInfo.imageContent.count)"
            imageIndexView.indexLabel.text = "\(imagesInfo.imageIndex + 1)"
        } else {
          
            self.pageControl = CNPageControlBaguette()
            self.pageControl?.radius = 4;
            self.pageControl?.tintColor = .lightGray
            self.pageControl?.currentPageTintColor = .white
            self.pageControl?.hideForSinglePage = true;

            fakeNavigationBar.addSubview(self.pageControl!)
            fakeNavigationBar.addConstraintsWithFormat("H:|-40-[v0]-40-|", views: self.pageControl!)
            fakeNavigationBar.addConstraintsWithFormat("V:|-10-[v0]-10-|", views: self.pageControl!)
        
            // Setup Page Control
            pageControl?.numberOfPages = imagesInfo.imageContent.count
            pageControl?.progress = Double(imagesInfo.imageIndex)
        }
        
        fakeNavigationBar.alpha = 0
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesInfo.imageContent.count
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCell
        
        let imageString = imagesInfo.imageContent[indexPath.item].paragraphString
        let resource = ImageResource(downloadURL: URL(string: imageString!)!, cacheKey: imageString)
        
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.kf.setImage(with: resource)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! ImageCell).imageScrollView.zoomScale = 1 
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = targetContentOffset.pointee.x / scrollView.frame.size.width
        if (imagesInfo.imageContent.count > 10) {
            imageIndexView.indexLabel.text = "\(Int(index) + 1)"
        } else {
            pageControl?.set(progress: Int(index), animated: true)
        }
    }
    
    // save image
    @objc fileprivate func handleSaveAction() {
        if let cell = collectionView.cellForItem(at: IndexPath(item: (pageControl?.currentPage)!, section: 0)) as? ImageCell {
            
            if let savedImage = cell.imageView.image {
                UIImageWriteToSavedPhotosAlbum(savedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil);
            }
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print("Image save failed\(error.localizedDescription)")
            if let window = UIApplication.shared.keyWindow {
                window.makeToast("Failed. Try again.", duration: 0.5, position: CGPoint(x: window.frame.width / 2.0, y: window.frame.height - 80))
            }
        } else {
            if let window = UIApplication.shared.keyWindow {
                window.makeToast("Successed.", duration: 0.5, position: CGPoint(x: window.frame.width / 2.0, y: window.frame.height - 80))
            }
        }
    }
    
    // MARK: Lifecycle
    override init() {
        super.init()
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    deinit {
        print("ImageDisplayController deinit")
    }

}
