//
//  MainViewController.swift
//  InstaClone
//
//  Created by Tom Seymour on 2/6/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeIn, animations: nil)
    var topCellIndex: IndexPath?
    var normalSize: CGSize?
    var largeSize: CGSize?
    static let categories = ["ANIMALS", "PEOPLE", "NATURE", "CITYSCAPE", "TECH", "EVAN", "PIGS"]
    let ReuseIdentifierForCell = "MainCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.instaPrimary()
        self.normalSize = CGSize(width: self.view.frame.width, height: self.view.frame.width/2.5)
        self.largeSize = CGSize(width: self.view.frame.width, height: self.view.frame.width/1.7)
        
        setupViewHierarchy()
        configureConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainCollectionV.reloadData()
    }
    
    func setupViewHierarchy(){
        self.navigationItem.title = "CATEGORIES"
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.view.addSubview(mainCollectionV)
        mainCollectionV.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: ReuseIdentifierForCell)
    }
    
    func configureConstraints(){
        mainCollectionV.snp.makeConstraints { (view) in
            view.leading.trailing.bottom.top.equalToSuperview()
        }
    }
    
    //MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MainViewController.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifierForCell, for: indexPath) as! MainCollectionViewCell
        
        let categoriesAtRow = MainViewController.categories[indexPath.row]
//        cell.BGImageView.image = UIImage(named: "\(categoriesAtRow)1")
//        cell.BGImageView.animationImages = [UIImage(named: "\(categoriesAtRow)2")!, UIImage(named: "\(categoriesAtRow)3")!]
//        cell.BGImageView.animationDuration = Double(arc4random_uniform(7) + 3)
//        cell.BGImageView.animationRepeatCount = 0
//        cell.BGImageView.startAnimating()
        
        animateImages(for: categoriesAtRow, cellView: cell.BGImageView, count: 0)
        
        cell.categoryLabel.text = categoriesAtRow
        
        return cell
    }
    
    func animateImages(for category: String, cellView: UIImageView, count: Int) {
        
        var images = [UIImage(named: "\(category)1"), UIImage(named: "\(category)2"), UIImage(named: "\(category)3")]
        
        let image: UIImage = images[(count % images.count)]!
        
        let toImage = image
        UIView.transition(with: cellView, duration: 2.0, options: .transitionCrossDissolve, animations: {
            cellView.image = toImage
        }, completion: {(finished: Bool) -> Void in
            self.animateImages(for: category, cellView: cellView, count: count + 1)
        })
    }
    
//    func setNewImageWithFade(imageData: Data) {
//        UIView.animate(withDuration: 0.2, animations: {
//            self.BGImageView.alpha = 0.0
//            self.view.setNeedsLayout()
//        }, completion: { (bool) in
//            self.BGImageView.image = UIImage(data: imageData)
//            UIView.animate(withDuration: 0.2, animations: {
//                self.BGImageView.alpha = 1.0
//                self.view.setNeedsLayout()
//            })
//        })
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = collectionView.cellForItem(at: indexPath) as! MainCollectionViewCell
        let animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeOut, animations: nil)
        animator.addAnimations {
            currentCell.categoryLabel.layer.borderWidth = 10.0
            currentCell.categoryLabel.snp.remakeConstraints({ (view) in
                view.width.height.equalToSuperview()
                view.center.equalToSuperview()
            })
            currentCell.layoutIfNeeded()
        }
        
        animator.addCompletion { (_) in
            let categoryView = CategoryListViewController()
            categoryView.navigationItem.title = MainViewController.categories[indexPath.row]
            self.navigationController?.pushViewController(categoryView, animated: true)
        }
        
        animator.startAnimation()
    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        if let current = self.topCellIndex{
    //            if indexPath == current{
    //                self.animator.addAnimations({
    //                })
    //                return largeSize!
    //            }
    //        }else{
    //            if indexPath.row == 0{
    //                return largeSize!
    //            }
    //        }
    //        return normalSize!
    //    }
    
    //    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    //        let currrentCell = mainCollectionV.indexPathsForVisibleItems.sorted()
    //        if currrentCell[0].row == 0{
    //            topCellIndex = currrentCell[0]
    //        }else if currrentCell[0] == topCellIndex{
    //            topCellIndex = currrentCell[1]
    //        }else{
    //            topCellIndex = currrentCell[0]
    //        }
    //
    //        self.mainCollectionV.reloadData()
    //        self.mainCollectionV.scrollToItem(at: topCellIndex!, at: UICollectionViewScrollPosition.top, animated: true)
    //    }
    
    //Mark: - Lazy Inits
    lazy var mainCollectionV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = self.largeSize!
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        cView.backgroundColor = UIColor.instaPrimary()
        cView.delegate = self
        cView.dataSource = self
        return cView
    }()
}
