//
//  MainViewController.swift
//  InstaClone
//
//  Created by Tom Seymour on 2/6/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

<<<<<<< HEAD
    var animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeIn, animations: nil)
    var topCellIndex: IndexPath?
    var normalSize: CGSize?
    var largeSize: CGSize?
    let categories = ["ANIMALS", "BEACH DAY", "LANDSCAPE", "CATS", "DOGS", "PIGS", "SPORTS", "MACRO", "PORTRAIT", "TRUMP"]
    let ReuseIdentifierForCell = "MainCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.instaPrimary()
        self.normalSize = CGSize(width: self.view.frame.width, height: self.view.frame.width/2.5)
        self.largeSize = CGSize(width: self.view.frame.width, height: self.view.frame.width/1.8)
=======
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.instaPrimary()
>>>>>>> 17336ff695b406198ddcd19805f4d4c632e40a94

        // Do any additional setup after loading the view.
    }

<<<<<<< HEAD
    func configureConstraints(){
        mainCollectionV.snp.makeConstraints { (view) in
            view.leading.trailing.bottom.top.equalToSuperview()
        }
    }
    
    //MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifierForCell, for: indexPath) as! MainCollectionViewCell
        
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: cell.frame.width - 10, height: cell.frame.width - 10))
//        let some = UIImage(named: "sample")
//        let another = some?.cgImage
//        let tempImage = CIImage(cgImage: another!)
//        let brightnessFilter = CIFilter(name: "CIColorControls")!
//        brightnessFilter.setValue(0.8, forKey: "inputImage")
//        let newImage = UIImage(cgImage: CIContext(options: nil).createCGImage(tempImage, from: (brightnessFilter.outputImage?.extent)!)!)
        imageView.contentMode = .scaleToFill
        imageView.animationImages = [#imageLiteral(resourceName: "sample"), #imageLiteral(resourceName: "sample2")]
        imageView.animationDuration = Double(arc4random_uniform(7
            ) + 3)
        imageView.animationRepeatCount = 0
        imageView.startAnimating()
        cell.backgroundView = imageView
        //testing data
        cell.categoryLabel.text = categories[indexPath.row]
        
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
                self.animator.addAnimations({
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
=======
>>>>>>> 17336ff695b406198ddcd19805f4d4c632e40a94
    
}
