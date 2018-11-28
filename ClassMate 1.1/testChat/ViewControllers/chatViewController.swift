//
//  ViewController.swift
//  testChat
//
//  Created by Min Duan on 11/23/18.
//

import UIKit
import MessageKit
import MessageInputBar
import Firebase

class chatViewController: MessagesViewController {
    
    var messages: [Message] = []
    var member: Member!
    var channelName: String?
    var messageListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let name: String = self.channelName else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        self.title = name
        member = Member(name: "bluemoon", color: .blue)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageListener = Firestore.firestore().collection("channels").document(name).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            let source = snapshot.metadata.hasPendingWrites ? "Local" : "Server"
            self.updateMessages()
        }
    }
    
    func retrieveMessages()
    {
        
        let docRef = Firestore.firestore().collection("channels").document(self.channelName!)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //
                self.messagesCollectionView.reloadData()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func updateMessages()
    {
        
    }
}

extension chatViewController: MessagesDataSource {
    func numberOfSections(
        in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return Sender(id: member.name, displayName: member.name)
    }
    
    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 12
    }
    
    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
    
}

extension chatViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    } // MessageKit will take care of calculating the height
}

extension chatViewController: MessagesDisplayDelegate {
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        
        let message = messages[indexPath.section]
        let color = message.member.color
        avatarView.backgroundColor = color
    }
}

extension chatViewController: MessageInputBarDelegate {
    func messageInputBar(
        _ inputBar: MessageInputBar,
        didPressSendButtonWith text: String) {
        
        let newMessage = Message(
            member: member,
            text: text,
            messageId: UUID().uuidString)
        
        messages.append(newMessage)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
}
