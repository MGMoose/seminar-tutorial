//
//  ViewController.swift
//  GuessWho
//
//  Created by Siraj Hamza on 2019-04-02.
//  Copyright © 2019 devHamza. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar
import NVActivityIndicatorView


class ViewController: MessagesViewController, NVActivityIndicatorViewable {
    
    fileprivate let kCollectionViewCellHeight: CGFloat = 12.5
    
    private var messages: [ChatMessage]!
    private var photoViews: [UIImageView]!
    private var selectedCelebrity: Int!
    private var attempts: Int!
    
    private var twitterRequest: TwitterService!
    private var personalityRequest: PersonalityService!
    private var luisRequest: LuisService!
    
    @IBOutlet var selectionView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.twitterRequest = TwitterService()
        self.personalityRequest = PersonalityService()
        self.luisRequest = LuisService()
        
        self.attempts = 0
        self.selectedCelebrity = 0
        
        self.setupInitialMessages()
        self.setupSelectionView()
        self.setupActivityIndicator()
        self.setupMessagesKit()
        self.setupPhotoViews()
        self.setupGame()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    private func setupInitialMessages() {
        
        self.messages = [ChatMessage]()
        
        for i in 0 ... 2 {
            
            let message = ChatMessage(text: i == 2 ? "Hey, try to guess who I am. Just tap on my photo, when you are confident enough :)" : " ", sender: User.getName(.celebrity))
            
            self.messages.append(message)
        }
    }
    
    
    private func setupSelectionView() {
    
        self.selectionView.clipsToBounds = true
        self.selectionView.layer.cornerRadius = 35
        self.selectionView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    
    private func setupActivityIndicator() {
        
        let size: CGFloat = 50
        let x = self.view.frame.width / 2 - size
        let y = self.view.frame.height / 2 - size
        
        let frame = CGRect(x: x, y: y, width: size, height: size)
        
        _ = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballScaleRipple, color: .gray)
    }
    
    
    private func loadImages(_ array: Array<String>) {
        
        for i in 0 ..< array.count {
            
            self.photoViews[i].layer.borderColor = UIColor.clear.cgColor
            self.photoViews[i].isUserInteractionEnabled = true
            
            self.twitterRequest.getUserInfo(array[i]) { (url) in

                do {

                    let data = try Data(contentsOf: URL(string: url)!)

                    self.photoViews[i].image = UIImage(data: data)
                }
                catch {}
            }
        }
    }
    
    
    private func setupGame() {
        
        while (self.messages.count != 3) {
            
            self.messages.remove(at: self.messages.count - 1)
        }
        
        self.messagesCollectionView.reloadData()
        
        self.startAnimating(message: "We are setting up your game...", type: NVActivityIndicatorType.ballScaleRipple)
        self.messageInputBar.isUserInteractionEnabled = false
        
        let random5Celebrities = Array(celebrities.shuffled()[...4])
        self.selectedCelebrity = Int.random(in: 0 ..< random5Celebrities.count)
        self.attempts = 0
        
        // TODO: Call self.loadImages(random5Celebrities) function here
        
        self.requestGameSetup(for: random5Celebrities[self.selectedCelebrity]) {
            
            self.messageInputBar.isUserInteractionEnabled = true
            self.messagesCollectionView.reloadData()
            
            self.stopAnimating()
        }
    }
    
    
    private func requestGameSetup(for celebrity: String, _ completion: @escaping () -> Void) {
        
        completion()
    }
    
    
    private func setupPhotoViews() {
        
        self.photoViews = [UIImageView]()
        
        self.view.bringSubviewToFront(self.selectionView)
        
        var xPos: CGFloat = 5.0
        let imageSize = self.selectionView.frame.width / 5 - 10
    
        for i in 0 ... 4 {
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTap(_:)))
            
            let imageView = UIImageView(frame: CGRect(x: xPos, y: 25, width: imageSize, height: imageSize))
            imageView.tag = i
            imageView.addGestureRecognizer(tapGesture)
            imageView.isUserInteractionEnabled = true
            imageView.layer.cornerRadius = imageView.frame.height / 2
            imageView.clipsToBounds = true
            
            self.photoViews.append(imageView)
            
            xPos += imageSize + 10
            
            self.selectionView.addSubview(imageView)
        }
    }
    
    
    private func processRequest(_ intent: String) {
        
        defer {
            
            DispatchQueue.main.async {
                
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
        }
    }
    
    
    @objc
    private func imageTap(_ sender: UITapGestureRecognizer) {
        
        if sender.view?.tag == self.selectedCelebrity {
            
            sender.view?.layer.borderColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1).cgColor
            
            self.presentAlert(true)
        }
        else {
            
            sender.view?.layer.borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor
            
            if attempts == 0 {
                
                attempts += 1
                
                let message = ChatMessage(text: "Oops, you guessed wrong. Just one attempt left!",
                                          sender: User.getName(.celebrity))
                    
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }
            }
            else {
                
                self.presentAlert(false)
            }
        }
        
        
        sender.view?.layer.borderWidth = 3
        sender.view?.isUserInteractionEnabled = false
    }
    
    
    private func presentAlert(_ won: Bool) {
        
        let alert = UIAlertController(title: won ? "You won!" : "You Lost =(",
                                      message: "Would like to play again?",
                                      preferredStyle: UIAlertController.Style.alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            
            self.setupGame()
        }
        
        let noAction = UIAlertAction(title: "No", style: .default) { (_) in
            
            
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // Method to set up messages kit data sources and delegates + configure
    private func setupMessagesKit() {
        
        // Register datasources and delegates
        self.messagesCollectionView.messagesDataSource = self
        self.messagesCollectionView.messagesDisplayDelegate = self
        self.messagesCollectionView.messageCellDelegate = self
        self.messagesCollectionView.messagesLayoutDelegate = self
        self.messageInputBar.delegate = self
        
        // Configure views
        self.messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        self.scrollsToBottomOnKeyboardBeginsEditing = true
        self.maintainPositionOnKeyboardFrameChanged = true
    }
}


// MARK: - MessagesDataSource
extension ViewController: MessagesDataSource {
    
    
    internal func currentSender() -> Sender { return User.getName(.me) }
    
    
    internal func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        
        return self.messages.count
    }
    
    
    internal func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return self.messages[indexPath.section]
    }
    
}

// MARK: - MessagesDisplayDelegate
extension ViewController: MessagesDisplayDelegate, MessageCellDelegate {
    
    
    // MARK: - Text Messages
    
    internal func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    
        return self.isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    
    // MARK: - All Messages
    
    internal func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return self.isFromCurrentSender(message: message)
            ? UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
            : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    
    internal func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = self.isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        
        return .bubbleTail(corner, .curved)
    }
    
    
    internal func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        avatarView.backgroundColor = .clear
        
        self.isFromCurrentSender(message: message) ? avatarView.set(avatar: Avatar()) : avatarView.set(avatar: Avatar(image: UIImage(named: "avatar"), initials: "?"))
    }
}


// MARK: - MessagesLayoutDelegate
extension ViewController: MessagesLayoutDelegate {}


// MARK: - MessageInputBarDelegate

extension ViewController: MessageInputBarDelegate {
    
    
    internal func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        let message = ChatMessage(text: text, sender: self.currentSender())
        
        self.messages.append(message)
        
        DispatchQueue.main.async {
            
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
        }
        
        inputBar.inputTextView.text = String()
    }
}
