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

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    let categories = ["ANIMALS", "BEACH DAY", "LANDSCAPE", "CATS", "DOGS", "PIGS", "EVAN"]
    var assests: PHFetchResult<PHAsset>!
    let imageManager = PHImageManager()
    let storageManager = FIRStorage.storage()
    let databaseManager = FIRDatabase.database().reference()
    var currentCategory: String?
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.instaPrimaryLight()
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        setUpIdentifiersAndCells()
        setUpViewHierarchyAndDelegates()
        configureConstraints()
        view.backgroundColor = UIColor.instaPrimary()
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
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlayView.accessibilityIdentifier = ViewIdentifier.overlay.rawValue
        self.view.addSubview(overlayView)
        overlayView.snp.makeConstraints({ (view) in
            view.top.trailing.bottom.leading.equalToSuperview()
        })
    }
    
    func setUpViewHierarchyAndDelegates() {
        let views = [smallPhotoCollectionView, largePhotoCollectionView]
        _ = views.map{ $0.dataSource = self }
        _ = views.map{ $0.delegate = self }
        self.titleTextField.delegate = self
        _ = views.map{ self.view.addSubview($0) }
        self.view.addSubview(categoryScrollView)
        self.view.addSubview(titleTextField)
        largePhotoCollectionView.isPagingEnabled = true
    }
    
    func configureConstraints() {
        smallPhotoCollectionView.snp.makeConstraints { (view) in
            view.height.equalTo(self.view.snp.width).multipliedBy(0.29)
            view.trailing.leading.bottom.equalToSuperview()
        }
        
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
        
        largePhotoCollectionView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.width.height.equalTo(self.view.snp.width)
            view.bottom.equalTo(self.smallPhotoCollectionView.snp.top)
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
    
    func setUpIdentifiersAndCells() {
        self.smallPhotoCollectionView.accessibilityIdentifier = ViewIdentifier.smallPhoto.rawValue
        self.smallPhotoCollectionView.registerPhotoCell()
        
        self.largePhotoCollectionView.accessibilityIdentifier = ViewIdentifier.largePhoto.rawValue
        self.largePhotoCollectionView.registerPhotoCell()
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.accessibilityIdentifier ?? "" == ViewIdentifier.smallPhoto.rawValue {
            self.largePhotoCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
        }
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
        
        guard let title = self.titleTextField.text,
            let category = self.currentCategory else {
                self.showOKAlert(title: "Missing Title or Category", message: "Please make sure title and category are filled out")
                return
        }
        if let currentUser = FIRAuth.auth()?.currentUser {
            let currentCell = largePhotoCollectionView.visibleCells.first! as! PhotoPickerCollectionViewCell
            let data = UIImageJPEGRepresentation(currentCell.imageView.image!, 0.8)!
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpg"
            let storageReference = self.storageManager.reference(forURL: "gs://fir-testapp-989e7.appspot.com")
            let imagePath = currentUser.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            
            let uploadTask = storageReference.child(imagePath).put(data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    Photo.createPhotoInDatabase(for: title, category: category, imagePath: imagePath)
                }
            }
            uploadTask.observe(.progress, handler: { (snapshot) in
                
                print(snapshot.progress?.fractionCompleted)
            })
        } else {
            self.showOKAlert(title: "Not Logged In", message: "Please log in or register to continue")
        }
        print("I uploaded an image. LOL.")
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
    
    func showOKAlert(title: String, message: String?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: completion)
    }
}
