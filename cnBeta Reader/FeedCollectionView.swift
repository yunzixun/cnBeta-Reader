//
//  FeedCell.swift
//  cnBeta Reader
//
//  Created by Juncheng Han on 12/11/16.
//  Copyright © 2016 JasonH. All rights reserved.
//

import UIKit
import CoreData
import Toast_Swift
import MJRefresh
import DZNEmptyDataSet

protocol FeedCollectionViewDelegate:class {
    func feedCollectionViewDidSelectFeed(_ feed: Feed);
}

class FeedCollectionView: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    weak var delegate: FeedCollectionViewDelegate?
    
    fileprivate let headerHeight: CGFloat = 34.0
    fileprivate var heightDic: [IndexPath : CGFloat] = Dictionary()
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Feed> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Feed")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "publishedDate", ascending: false)]
        fetchRequest.fetchLimit = Constants.FETCH_LIMIT

        let context = CoreDataStack.sharedInstance.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "sectionIdentifier", cacheName: nil)
        frc.delegate = self
        
        return frc as! NSFetchedResultsController<Feed>
    }()
    
    fileprivate lazy var refreshHeader: MJRefreshNormalHeader = {
        let refreshHeader = MJRefreshNormalHeader.init(refreshingBlock: {
            ApiService.sharedInstance.fetchFeed(withURL: Constants.API_URL_2, completion: { (newFeedsCount) in
                
                DispatchQueue.main.async {
                    self.collectionView.mj_header.endRefreshing()
                    
                    //self.makeToast("\(newFeedsCount) new feeds", duration: 1.2, position: CGPoint(x: self.collectionView.frame.width / 2.0,y: self.collectionView.frame.height - 80))
                }
            })
        })
        return refreshHeader!
    }()
    
    fileprivate lazy var refreshFooter: MJRefreshAutoStateFooter = {
        let refreshFooter = MJRefreshAutoStateFooter.init(refreshingBlock: {
            
            var numberOfAllItems: Int = 0;
            
            self.fetchedResultsController.fetchRequest.fetchLimit += Constants.FETCH_LIMIT

            do {
                try self.fetchedResultsController.performFetch()
                
                self.collectionView.reloadData()
                
                //  self.makeToast("No more feed", duration: 1.2, position: CGPoint(x: self.collectionView.frame.width / 2.0,y: self.collectionView.frame.height - 100))

                self.collectionView.mj_footer.endRefreshing()
            } catch let err {
                print(err)
            }
        })
        
        refreshFooter?.triggerAutomaticallyRefreshPercent = 0.5
        return refreshFooter!
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = StickyHeaderFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    fileprivate let cellId = "NewFeedCellId"
    fileprivate let headerId = "headerId"
    
    override func setupViews() {
        
        // load the data from local device
        do {
            try fetchedResultsController.performFetch()
        } catch let err {
            print(err)
        }
        
        super.setupViews()
        
        backgroundColor = .white
        
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        
        collectionView.mj_header = refreshHeader
        collectionView.mj_footer = refreshFooter
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(CustomFeedHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        // update the data from sever
        collectionView.mj_header.beginRefreshing()
    }
    
    override func layoutSubviews() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let count = fetchedResultsController.sections?.count {
            return count;
        }
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?[section].numberOfObjects {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
        
        let feed = fetchedResultsController.object(at: indexPath) 
        cell.feed = feed;
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
//        let translation = collectionView.panGestureRecognizer.translation(in: collectionView.superview)
//        
//        if translation.y < 0 && collectionView.contentOffset.y < (collectionView.contentSize.height - collectionView.frame.height) && collectionView.contentOffset.y > collectionView.frame.height {
//            cell.alpha = 0
//            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 50, 0)
//            cell.layer.transform = rotationTransform
//            UIView.animate(withDuration: 0.3, animations: {
//                cell.alpha = 1
//                cell.layer.transform = CATransform3DIdentity
//            })
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedObject = fetchedResultsController.object(at: indexPath)
        delegate?.feedCollectionViewDidSelectFeed(feedObject)
    }
    
    // MARK: CollectionView layout delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if heightDic[indexPath] == nil {
            let feed = fetchedResultsController.object(at: indexPath)
            let size = CGSize(width: Constants.SCREEN_WIDTH - 40, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
            var estimatedTitleFrame: CGRect = .zero
            if let title = feed.title {
                estimatedTitleFrame = NSString(string: title).boundingRect(with: size, options: options, attributes: Constants.FEED_TITLE_STYLE, context: nil)
            }
        
            var estimatedContentFrame: CGRect = .zero
            if let content = feed.contentSnippet {
                estimatedContentFrame = NSString(string: content).boundingRect(with: size, options: options, attributes: Constants.FEED_SUMM_STYLE, context: nil)
            }
            
            heightDic[indexPath] = estimatedContentFrame.height + estimatedTitleFrame.height + 30 + 30 + 4 + 12 + 16
        }
        
        return CGSize(width: frame.width, height: heightDic[indexPath]!)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // collection view header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: headerHeight);
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        
        // Create header
        if (kind == UICollectionElementKindSectionHeader) {
            // Create Header
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! CustomFeedHeader
            
            if let dateString = fetchedResultsController.object(at: indexPath).sectionIdentifier {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MMM-yyyy"
                let feedDate = dateFormatter.date(from: dateString)
            
                let displayDateFormatter = DateFormatter()
            
                let elapsedTimeInSeconds = Date().timeIntervalSince(feedDate! as Date)
                let secondInDays: TimeInterval = 60 * 60 * 24
            
                if elapsedTimeInSeconds <= secondInDays {
                    headerView.timeLabel.text = "Today"
                }
                else if elapsedTimeInSeconds > secondInDays && elapsedTimeInSeconds <= 2 * secondInDays {
                    headerView.timeLabel.text = "Yesterday"
                }
                else if elapsedTimeInSeconds > secondInDays {
                    displayDateFormatter.dateFormat = "MMM-dd-yyyy"
                    headerView.timeLabel.text = displayDateFormatter.string(from: feedDate!)
                }
            }
            reusableView = headerView
        }
        return reusableView!
    }
    
    // MARK: NSFetchedResultsController delegate
    
//    var blockOperation = [BlockOperation]()
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        if type == .insert {
//            blockOperation.append(BlockOperation(block: {
//                UIView.animate(withDuration: 1, animations: {
//                    self.collectionView.insertItems(at: [newIndexPath!])
//                    print(newIndexPath!)
//                })
//            }))
        } else if type == .update {
            
        } else if type == .delete {
            
        } else if type == .move {
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        collectionView.performBatchUpdates({
//            for operation in self.blockOperation {
//                operation.start()
//            }
//        }, completion: { (completed) in
//            
//            
//        })
        
        
        do {
            try controller.performFetch()
            self.heightDic.removeAll()
            self.collectionView.reloadData()
        } catch let err {
            print(err)
        }
    }
}

extension FeedCollectionView: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    // MARK: DZNEmptyDataSetSource
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No new feeds yet, try pull down to refreash"
        let attribute = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 18.0), NSForegroundColorAttributeName : UIColor.darkGray]
        
        return NSAttributedString(string: text, attributes: attribute)
    }
    
//    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
//        let attribute = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 18.0), NSForegroundColorAttributeName : UIColor.darkGray]
//        return NSAttributedString(string: "Hit", attributes: attribute)
//    }
    
    // MARK: DZNEmptyDataSetDelegate
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
//    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
//        print("tap")
//    }
    
}
