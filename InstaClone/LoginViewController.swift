//
//  LoginViewController.swift
//  InstaClone
//
//  Created by Tom Seymour on 2/6/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SnapKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let databaseReference = FIRDatabase.database().reference().child("users")
    var databaseObserver: FIRDatabaseHandle?

    
    let buttonSize: CGSize = CGSize(width: 280, height: 60)
    
    static let myFont = UIFont.systemFont(ofSize: 16)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.instaPrimary()
        self.navigationItem.title = "LOGIN/REGISTER"
        
        checkForCurrentUser()
        setUpViewHeirachy()
        setConstraints()
        setTextFieldDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        instaCloneLogo.startRotating(duration: 4)
        
//        self.usernameTextField.text = nil
//        self.passwordTextField.text = nil
        
        UIView.animate(withDuration: 0.0, animations: {
            self.usernameTextField.transform = CGAffineTransform.identity
            self.passwordTextField.transform = CGAffineTransform.identity
            self.loginButton.transform = CGAffineTransform.identity
            self.registerButton.transform = CGAffineTransform.identity
        }, completion: nil)
        
        instaCloneLogo.snp.removeConstraints()
        usernameTextField.snp.removeConstraints()
        passwordTextField.snp.removeConstraints()
        loginButton.snp.removeConstraints()
        registerButton.snp.removeConstraints()
        
        setConstraints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.instaCloneLogo.stopRotating()
    }
    
    
    // MARK: SET UP
    
    func checkForCurrentUser() {
        if FIRAuth.auth()?.currentUser != nil {
            goToProfileView(animated: false)
        }
    }
    
    func setTextFieldDelegate() {
        passwordTextField.delegate = self
        usernameTextField.delegate = self
    }
    
    func setUpViewHeirachy() {
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.view.addSubview(instaCloneLogo)
        self.view.addSubview(usernameTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(loginButton)
        self.view.addSubview(registerButton)
        
        self.loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        self.registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
    }
    
    func setConstraints() {
        instaCloneLogo.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(20)
            view.width.height.equalTo(self.view.bounds.width / 2.5)
        }
        
        usernameTextField.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.equalTo(self.view.bounds.width * 0.8)
            view.top.equalTo(self.instaCloneLogo.snp.bottom).offset(30)
        }
        
        passwordTextField.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.equalTo(usernameTextField.snp.width)
            view.top.equalTo(self.usernameTextField.snp.bottom).offset(30)
        }
        
        loginButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.size.equalTo(buttonSize)
            view.bottom.equalTo(self.registerButton.snp.top).offset(-20)
        }
        
        registerButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.size.equalTo(buttonSize)
            view.bottom.equalTo(self.view.snp.bottom).offset(-20)
        }
    }
    
    
    // MARK: TARGET ACTION METHODS
    
    func didTapRegisterButton() {
        animateButton(sender: registerButton)
        print("register")
        if let email = usernameTextField.text, let password = passwordTextField.text {
            registerButton.isEnabled = false
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                if error != nil {
                    print("error with completion while creating new Authentication: \(error!)")
                }
                if user != nil {
                    // create a new user with the UID
                    // on completion, segue to profile screen
                    User.createUserInDatabase(email: email, completion: {
                        self.goToProfileView(animated: true)
                    })
                } else {
                    self.showOKAlert(title: "Error", message: error?.localizedDescription)
                }
                self.registerButton.isEnabled = true
            })
        }
    }
    
    
    func didTapLoginButton() {
        print("login")
        animateButton(sender: loginButton)
        if let username = usernameTextField.text,
            let password = passwordTextField.text{
            loginButton.isEnabled = false
            FIRAuth.auth()?.signIn(withEmail: username, password: password, completion: { (user: FIRUser?, error: Error?) in
                if error != nil {
                    print("Erro \(error)")
                }
                if user != nil {
                    print("SUCCESS.... \(user!.uid)")
                    self.goToProfileView(animated: true)
                } else {
                    self.showOKAlert(title: "Error", message: error?.localizedDescription)
                }
                self.loginButton.isEnabled = true
            })
        }
    }
    
    func showOKAlert(title: String, message: String?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: completion)
    }
    
    func goToProfileView(animated: Bool) {
        instaCloneLogo.stopRotating()
        instaCloneLogo.startRotating()
        if animated {
            let animator = UIViewPropertyAnimator(duration: 2.4, curve: .easeIn, animations: nil)
            
            animator.addAnimations({ 
                self.instaCloneLogo.snp.remakeConstraints { (view) in
                    view.center.equalToSuperview()
                    view.width.height.equalTo(self.view.bounds.width / 1.2)
                }
                self.view.layoutIfNeeded()
            }, delayFactor: 0.0)
            
            animator.addAnimations({ 
                self.usernameTextField.snp.remakeConstraints { (view) in
                    view.width.equalTo(self.view.bounds.width * 0.8)
                    view.centerY.equalToSuperview()
                    view.trailing.equalTo(self.view.snp.leading)
                }
                self.usernameTextField.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                self.view.layoutIfNeeded()
            }, delayFactor: 0.1)
            
            animator.addAnimations({
                self.passwordTextField.snp.remakeConstraints { (view) in
                    view.centerY.equalToSuperview()
                    view.width.equalTo(self.usernameTextField.snp.width)
                    view.leading.equalTo(self.view.snp.trailing)
                }
                self.passwordTextField.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 0.7)
                self.view.layoutIfNeeded()
            }, delayFactor: 0.2)

            animator.addAnimations({
                self.loginButton.snp.remakeConstraints { (view) in
                    view.top.equalToSuperview().offset(100)
                    view.size.equalTo(self.buttonSize)
                    view.trailing.equalTo(self.view.snp.leading)
                }
                self.loginButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.1)
                self.view.layoutIfNeeded()
            }, delayFactor: 0.3)

            animator.addAnimations({
                self.registerButton.snp.remakeConstraints { (view) in
                    view.top.equalToSuperview()
                    view.size.equalTo(self.buttonSize)
                    view.leading.equalTo(self.view.snp.trailing)
                }
                self.registerButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 0.8)
                self.view.layoutIfNeeded()
            }, delayFactor: 0.4)
            
            animator.addCompletion({ (_) in
                let profileView = ProfileViewController()
                self.navigationController?.pushViewController(profileView, animated: animated)
                
            })
            
            animator.startAnimation()
            
//            UIView.animate(withDuration: 0.5, animations: {
//                self.instaCloneLogo.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
//                self.view.layoutIfNeeded()
//            }) { (complete) in
//                let profileView = ProfileViewController()
//                self.navigationController?.pushViewController(profileView, animated: animated)
//                self.usernameTextField.text = nil
//                self.passwordTextField.text = nil
//                UIView.animate(withDuration: 0.0, delay: 0.5, options: [], animations: {
//                    self.instaCloneLogo.transform = CGAffineTransform.identity
//                }, completion: nil)
//            }
        } else {
            let profileView = ProfileViewController()
            self.navigationController?.pushViewController(profileView, animated: animated)
        }
        
    }
    
    
    internal func animateButton(sender: UIButton) {
        let newTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        let originalTransform = sender.imageView!.transform
        UIView.animate(withDuration: 0.1, animations: {
            sender.layer.transform = CATransform3DMakeAffineTransform(newTransform)
        }, completion: { (complete) in
            sender.layer.transform = CATransform3DMakeAffineTransform(originalTransform)
        })
    }

    
    
    // MARK: - LAZY VIEW INITS
    
    lazy var instaCloneLogo: UIImageView = {
        let image = UIImage(named: "logo")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var usernameTextField: UnderlineTextField = {
        let view = UnderlineTextField()
        view.backgroundColor = .clear
        view.attributedPlaceholder = NSAttributedString(string: " EMAIL", attributes: [NSForegroundColorAttributeName: UIColor.instaAccent(), NSFontAttributeName: myFont])
        return view
    }()
    
    lazy var passwordTextField: UnderlineTextField = {
        let view = UnderlineTextField()
        view.backgroundColor = .clear
        view.attributedPlaceholder = NSAttributedString(string: " PASSWORD", attributes: [NSForegroundColorAttributeName: UIColor.instaAccent(), NSFontAttributeName: myFont])
        return view
    }()
    
    lazy var loginButton: WhiteBorderButton = {
       let view = WhiteBorderButton()
        view.setTitle("LOGIN", for: .normal)
        return view
    }()
    
    lazy var registerButton: WhiteBorderButton = {
        let view = WhiteBorderButton()
        view.setTitle("REGISTER", for: .normal)
        return view
    }()
}

extension UIView {
    func startRotating(duration: Double = 1) {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Float(Float.pi * 2.0)
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
    func stopRotating() {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) != nil {
            self.layer.removeAnimation(forKey: kAnimationKey)
        }
    }
}
