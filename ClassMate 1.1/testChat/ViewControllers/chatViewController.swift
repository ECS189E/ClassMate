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
    var messageList: [Dictionary<String, String>] = []
    var member: Member!
    var username: String?
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
        
        retrieveMessages()
        //listenForUpdate() // Init the listener
    }
    
    // Helper for saving the newly sent message to the server
    private func save() {
        
        guard let name: String = self.channelName else {
            print("channelName is not set yet")
            return
        } // channelName is nill
        
        print(name)
        Firestore.firestore().collection("channels").document(name).setData([
            "messages": self.messageList])
    }
    
    func retrieveMessages()
    {
        
        let docRef = Firestore.firestore().collection("channels").document(self.channelName!)
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // load the data
                
                guard let messageDict: [String: Any] = document.data() else {
                    return
                } // this chat room has no messages
                
                let messageArr: [Dictionary<String, String>] = messageDict["messages"] as! [Dictionary<String, String>]
                
                for eachMessage in messageArr
                {
                    
                    let member = Member(name: eachMessage["userName"]! , color: .blue)

                    guard let newDate = dateFormatterGet.date(from: eachMessage["date"]!) else {
                        fatalError()
                    }
                    
                    let newMessage = Message(
                        member: member,
                        text: eachMessage["text"]!,
                        messageId: UUID().uuidString,
                        date: newDate)
                    
                    self.messages.append(newMessage)
                    self.messageList.append([
                        "date": dateFormatterGet.string(from: newDate),
                        "text": eachMessage["text"]!,
                        "userName": newMessage.member.name
                    ])
                    
                    //need to sort messages based on sentDate later
                }
                
                self.messagesCollectionView.reloadData()
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func updateMessages()
    {
        
    }
    
    func listenForUpdate()
    {
        self.messageListener = Firestore.firestore().collection("channels").document(self.channelName!).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.get("messages")
            snapshot.get
            self.updateMessages()
        }
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
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return isFromCurrentSender(message: messages[indexPath.row]) ? UIColor(red: 1 / 255, green: 93 / 255, blue: 48 / 255, alpha: 1) : UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    } // TODO: FIX the bubble color
    
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
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let newMessage = Message(
            member: self.member,
            text: text,
            messageId: UUID().uuidString,
            date: Date())
        
        messages.append(newMessage)
        
        messageList.append([
            "date": dateFormatterGet.string(from: newMessage.sentDate),
            "text": newMessage.text,
            "userName": self.member.name
            ])
        
        save()
        
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
}
