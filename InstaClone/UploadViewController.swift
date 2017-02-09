//
//  UploadViewController.swift
//  InstaClone
//
//  Created by Tom Seymour on 2/6/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit
import Photos
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

enum ViewIdentifier: String {
    case smallPhoto, largePhoto, overlay
}

enum UploadType {
    case category, profile
}

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    let categories = MainViewController.categories  
    var assests: PHFetchResult<PHAsset>!
    let imageManager = PHImageManager()
    let storageManager = FIRStorage.storage()
    let databaseManager = FIRDatabase.database().reference()
    var currentCategory: String?
    
    var uploadType: UploadType = .category
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.instaPrimaryLight()
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        view.backgroundColor = UIColor.instaPrimary()
        
        setUpIdentifiers()
        setUpViewHierarchyAndDelegates()
        configureConstraints()
        setUpPhotoFetcher()
        setUpNavigationItems()
    }
    
    //MARK: - PhotoFetcher Functions
    
    func setUpPhotoFetcher () {
        let allPhotos = PHFetchOptions()
        allPhotos.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.assests = PHAsset.fetchAssets(with: .image, options: allPhotos)
    }
    
    func getImage(for cell: PhotoPickerCollectionViewCell, at indexPath: IndexPath) {
        imageManager.requestImage(for: self.assests[indexPath.row], targetSize: cell.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { (image, dict) in
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        })
    }
    
    //MARK: - Views -- Set Up
    override func viewDidLayoutSubviews() {
        self.smallPhotoCollectionView.setUpItemLayout()
        self.largePhotoCollectionView.setUpItemLayout()
    }
    
    func setUpNavigationItems() {
        self.navigationItem.title = "UPLOAD"
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "up_arrow"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.addTarget(self, action: #selector(didPressUploadButton), for: .touchUpInside)
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: button), animated: true)
    }
    
    func setUpOverlay () {
        self.view.addSubview(overlayView)
        overlayView.snp.makeConstraints({ (view) in
            view.top.trailing.bottom.leading.equalToSuperview()
        })
        self.overlayView.addSubview(progressContainterView)
        self.progressContainterView.addSubview(progressLabel)
        self.progressContainterView.addSubview(downloadProgressBar)
        
        downloadProgressBar.progress = 0.0
        progressLabel.text = "UPLOADING..."
        
        progressContainterView.snp.makeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
            view.width.equalToSuperview().dividedBy(1.5)
            view.height.equalTo(overlayView.snp.width).dividedBy(6)
        }
        
        progressLabel.snp.makeConstraints { (view) in
            view.bottom.equalTo(progressContainterView.snp.centerY)
            view.centerX.equalToSuperview()
        }
        
        downloadProgressBar.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.centerY.equalToSuperview().multipliedBy(1.5)
            view.trailing.equalToSuperview().inset(16)
            view.leading.equalToSuperview().offset(16)
        }
    }
    
    func setUpViewHierarchyAndDelegates() {
        let views = [smallPhotoCollectionView, largePhotoCollectionView]
        _ = views.map{ $0.dataSource = self }
        _ = views.map{ $0.delegate = self }
        _ = views.map{ self.view.addSubview($0) }
        largePhotoCollectionView.isPagingEnabled = true
        
        switch self.uploadType {
        case .category:
            self.view.addSubview(categoryScrollView)
            self.view.addSubview(titleTextField)
            self.titleTextField.delegate = self
            configureCategoryUploadConstraints()
        case .profile:
            self.view.addSubview(profilePicBanner)
            configureProfileUploadConstraints()
        }
    }
    
    func configureConstraints() {
        smallPhotoCollectionView.snp.makeConstraints { (view) in
            view.height.equalTo(self.view.snp.width).multipliedBy(0.29)
            view.trailing.leading.bottom.equalToSuperview()
        }
        
        largePhotoCollectionView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.width.height.equalTo(self.view.snp.width)
            view.bottom.equalTo(self.smallPhotoCollectionView.snp.top)
        }
    }
    
    func configureCategoryUploadConstraints() {
        titleTextField.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.leading.equalToSuperview().offset(6)
            view.trailing.equalToSuperview().inset(6)
            view.bottom.equalTo(categoryScrollView.snp.top).inset(-6)
        }
        
        categoryScrollView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.bottom.equalTo(largePhotoCollectionView.snp.top)
        }
        
        for (index, category) in categories.enumerated() {
            let buttons = categoryScrollView.subviews
            let buttonToAdd = WhiteBorderButton()
            buttonToAdd.contentEdgeInsets = UIEdgeInsets(top: 2, left: 16, bottom: 2, right: 16)
            buttonToAdd.setTitle(category, for: .normal)
            buttonToAdd.addTarget(self, action: #selector(didSelectCategoryButton(sender:)), for: .touchUpInside)
            categoryScrollView.addSubview(buttonToAdd)
            buttonToAdd.snp.remakeConstraints({ (view) in
                
                view.top.bottom.equalToSuperview()
                
                switch index {
                case 0:
                    view.leading.equalToSuperview().offset(8)
                case categories.count - 1:
                    view.trailing.equalToSuperview().inset(8)
                    fallthrough
                default:
                    let previousButton = buttons[index - 1]
                    view.leading.equalTo(previousButton.snp.trailing).offset(8)
                }
            })
        }
        categoryScrollView.snp.makeConstraints { (view) in
            view.height.equalTo(categoryScrollView.subviews.first!.snp.height).offset(8)
        }
    }
    
    func configureProfileUploadConstraints() {
        profilePicBanner.snp.makeConstraints { (view) in
            view.top.left.right.equalToSuperview()
            view.bottom.equalTo(largePhotoCollectionView.snp.top)
        }
    }
    
    func setUpIdentifiers() {
        self.smallPhotoCollectionView.accessibilityIdentifier = ViewIdentifier.smallPhoto.rawValue
        self.largePhotoCollectionView.accessibilityIdentifier = ViewIdentifier.largePhoto.rawValue
    }
    
    
    //MARK: - CollectionView Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        guard let viewID = collectionView.accessibilityIdentifier else { return cell }
        
        switch viewID {
        case ViewIdentifier.smallPhoto.rawValue:
            let smallPhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPickerCollectionViewCell.cellID, for: indexPath) as! PhotoPickerCollectionViewCell
            
            self.getImage(for: smallPhotoCell, at: indexPath)
            
            return smallPhotoCell
        case ViewIdentifier.largePhoto.rawValue:
            let largePhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPickerCollectionViewCell.cellID, for: indexPath) as! PhotoPickerCollectionViewCell
            
            self.getImage(for: largePhotoCell, at: indexPath)
            return largePhotoCell
        default:
            break
        }
        return cell
    }
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        <#code#>
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let indexPath = self.largePhotoCollectionView.indexPathsForVisibleItems.first!
        self.smallPhotoCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
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
    
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.largePhotoCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
        self.smallPhotoCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    //MARK: - Actions
    func didSelectCategoryButton (sender: WhiteBorderButton) {
        let buttons = self.categoryScrollView.subviews
        _ = buttons.map {
            if let button = $0 as? UIButton {
                button.layer.borderColor = UIColor.instaIconWhite().cgColor
                button.setTitleColor(UIColor.instaIconWhite(), for: .normal)
            }
        }
        sender.layer.borderColor = UIColor.instaAccent().cgColor
        sender.setTitleColor(UIColor.instaAccent(), for: .normal)
        currentCategory = sender.title(for: .normal)
    }
    
    
    func didPressUploadButton() {
        
        var category = ""
        var title = ""
        switch self.uploadType {
        case .category:
            guard let titleText = self.titleTextField.text,
                !titleText.isEmpty,
                let categoryText = self.currentCategory else {
                    self.showOKAlert(title: "Missing Title or Category", message: "Please make sure title and category are filled out")
                    return
            }
            title = titleText
            category = categoryText
        case .profile:
            guard let titleText = FIRAuth.auth()?.currentUser?.email else { return }
            let categoryText = "PROFILE PIC"
            title = titleText
            category = categoryText
        }
        
        if let currentUser = FIRAuth.auth()?.currentUser {
            let currentCell = largePhotoCollectionView.visibleCells.first! as! PhotoPickerCollectionViewCell
            let data = UIImageJPEGRepresentation(currentCell.imageView.image!, 0.8)!
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpg"
            let storageReference = self.storageManager.reference()
            let imagePath = currentUser.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            
            self.setUpOverlay()
            let uploadTask = storageReference.child(imagePath).put(data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    Photo.createPhotoInDatabase(for: title, category: category, imagePath: imagePath, uploadType: self.uploadType)
                }
            }
            uploadTask.observe(.progress, handler: { (snapshot) in
                let fractionCompleted = Float(snapshot.progress!.fractionCompleted)
                self.downloadProgressBar.setProgress(fractionCompleted, animated: true)
                print(snapshot.status.rawValue)
                
                if fractionCompleted == 1.0 && snapshot.status.rawValue == 1 {
                    self.animateSuccessLabel(completion: { 
                        self.completedUpload(image: currentCell.imageView.image!)
                    })
                }
            })
            
        } else {
            self.showOKAlert(title: "Not Logged In", message: "Please log in or register to continue")
        }
        print("I uploaded an image. LOL.")
    }
    
    func completedUpload(image: UIImage) {
        switch uploadType {
        case .category:
            print("completed category upload")
            // needs to switch screen to that category's photo feed
        case .profile:
            if let profileVC = navigationController?.viewControllers[1] as? ProfileViewController {
                profileVC.profileImageView.image = image
                _ = navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //MARK: - Views
    
    var smallPhotoCollectionView: PickerCollectionView = {
        let view = PickerCollectionView()
        return view
    }()
    
    var largePhotoCollectionView: PickerCollectionView = {
        let view = PickerCollectionView()
        return view
    }()
    
    var categoryScrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceHorizontal = true
        return view
    }()
    
    var titleTextField: UnderlineTextField = {
        let view = UnderlineTextField()
        view.backgroundColor = .clear
        view.attributedPlaceholder = NSAttributedString(string: " TITLE", attributes: [NSForegroundColorAttributeName: UIColor.instaAccent(), NSFontAttributeName: UIFont.systemFont(ofSize: 24)])
        view.font = UIFont.systemFont(ofSize: 24)
        view.textColor = UIColor.instaAccent()
        return view
    }()
    

    lazy var profilePicBanner: UILabel = {
        let view = UILabel()
        view.backgroundColor = UIColor.instaPrimaryDark()
        view.textColor = UIColor.instaAccent()
        view.text = "CHOOSE YOUR NEW PROFILE PICTURE"
        view.font = UIFont.systemFont(ofSize: 16)
        view.textAlignment = .center
        return view
    }()
    
    //MARK: - Overlay View and Subview
    let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.accessibilityIdentifier = ViewIdentifier.overlay.rawValue
        return view
    }()
    
    let progressContainterView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.instaPrimaryDark()
        view.layer.cornerRadius = 16
        return view
    }()
    
    let progressLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.instaAccent()
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 18)
        return view
    }()
    
    let downloadProgressBar: UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = UIColor.instaAccent()
        return view
    }()
    
    //MARK: - Animations
    
    func animateSuccessLabel (completion: @escaping ()->Void) {
        self.progressLabel.text = "¡SUCCESS!"
        _ = progressContainterView.subviews.map {
            if $0 is UIProgressView {
                $0.removeFromSuperview()
            }
        }
        
        let animator = UIViewPropertyAnimator(duration: 0.75, curve: .easeOut, animations: {
            self.progressLabel.snp.remakeConstraints({ (view) in
                view.centerY.centerX.equalToSuperview()
            })
            self.view.layoutIfNeeded()
        })
        animator.addCompletion { _ in
            _ = self.progressContainterView.subviews.map{ $0.removeFromSuperview() }
            self.progressContainterView.removeFromSuperview()
            self.overlayView.removeFromSuperview()
            completion()
        }
        animator.startAnimation()
    }
    
    //MARK: - Helper Functions
    func showOKAlert(title: String, message: String?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: completion)
    }
    
}
