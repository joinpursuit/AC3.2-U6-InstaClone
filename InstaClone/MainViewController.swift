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

    var animator: UIViewPropertyAnimator? // use to animate background image inside the cell.
    var topCellIndex: IndexPath?
    var normalSize: CGSize?
    var largeSize: CGSize?
    let categories = ["ANIMALS", "BEACH DAY", "LANDSCAPE", "CATS", "DOGS", "PIGS", "SPORTS", "MACRO", "PORTRAIT", "TRUMP"]
    let ReuseIdentifierForCell = "MainCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.instaPrimary()
        self.animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeIn, animations: nil)
        self.normalSize = CGSize(width: self.view.frame.width, height: self.view.frame.width/2.5)
        self.largeSize = CGSize(width: self.view.frame.width, height: self.view.frame.width/1.8)

        setupViewHierarchy()
        configureConstraints()
    }
    
    func setupViewHierarchy(){
        self.navigationItem.title = "CATEGORIES"
        self.navigationController?.navigationBar.barTintColor = UIColor.instaPrimaryDark()
        self.navigationController?.navigationBar.tintColor = UIColor.instaAccent()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
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
        print(categories.count)
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifierForCell, for: indexPath) as! MainCollectionViewCell
        
        //testing data
        cell.categoryLabel.text = categories[indexPath.row]
        if indexPath.row%2 == 0{
            cell.backgroundColor = .cyan
        }else{
            cell.backgroundColor = .lightGray
        }
        
        //need image and categories names
        //background imge capacity need to increase 10%
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categoryView = CategoryListViewController()
        categoryView.navigationItem.title = categories[indexPath.row]
        self.navigationController?.pushViewController(categoryView, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let current = self.topCellIndex{
            if indexPath == current{
                self.animator?.addAnimations({
                })
                return largeSize!
            }
        }else{
            if indexPath.row == 0{
                return largeSize!
            }
        }
        return normalSize!
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currrentIndex = mainCollectionV.indexPathsForVisibleItems.sorted()[0]
        self.topCellIndex = currrentIndex
        print(currrentIndex.row)
        self.mainCollectionV.reloadData()
        self.mainCollectionV.scrollToItem(at: currrentIndex, at: UICollectionViewScrollPosition.top, animated: true)
    }
    
    //Mark: - Lazy Inits
    lazy var mainCollectionV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = self.normalSize!
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        cView.backgroundColor = .white
        cView.delegate = self
        cView.dataSource = self
        return cView
    }()
}
