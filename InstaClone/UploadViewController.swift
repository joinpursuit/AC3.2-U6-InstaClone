//
//  UploadViewController.swift
//  InstaClone
//
//  Created by Tom Seymour on 2/6/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit

class UploadViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.instaPrimary()
        // Do any additional setup after loading the view.
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
                //To Do add in progressoverlay
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
