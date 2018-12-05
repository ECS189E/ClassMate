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
        
        member = Member(name: self.username!, color: .blue)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        retrieveMessages()
        listenForUpdate() // Init the listener
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
                    
                    let member = Member(name: eachMessage["userName"]! , color: UIColor(hexString: eachMessage["color"] ?? ""))

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
                        "userName": newMessage.member.name,
                        "color": newMessage.member.color.toHexString()
                    ])
                    
                    //need to sort messages based on sentDate later
                }
                
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: false)
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func updateMessages(withData data: [Dictionary<String, String>])
    {
        messageList = data
        self.messages.removeAll()
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        //reload data
        for eachMessage in messageList
        {
            let memberTemp = Member(name: eachMessage["userName"]!, color: UIColor(hexString: eachMessage["color"] ?? ""))
            
            let newMessage = Message(
                member: memberTemp,
                text: eachMessage["text"]!,
                messageId: UUID().uuidString,
                date: dateFormatterGet.date(from: eachMessage["date"]!)
            )
            
            messages.append(newMessage)
        }
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToBottom(animated: true)
    }
    
    func listenForUpdate()
    {
        self.messageListener = Firestore.firestore().collection("channels").document(self.channelName!).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            let data: [Dictionary<String, String>] = snapshot.get("messages") as! [Dictionary<String, String>]
            self.updateMessages(withData: data)
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

// Handle the message from current user
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
            "userName": self.member.name,
            "color": self.member.color.toHexString()
            ])
        
        save()
        
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
}

// Convert UIColor to hexString
extension UIColor {
    convenience init(hexString:String) {
        
        let scanner  = Scanner(string: hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
}
