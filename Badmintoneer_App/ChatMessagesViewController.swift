//
//  ChatMessagesViewController.swift
//  Badmintoneer_App
//
//  Created by Shawn Tham on 27/5/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import FirebaseAuth

class ChatMessagesViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    var sender : Sender?
    var currentChannel : Channel?
    
    var messagesList = [ChatMessage]()
    
    var channelRef : CollectionReference?
    var usersRef : CollectionReference?
    var databaseListener : ListenerRegistration?
    
    let formatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm dd/MM/yy"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        let database = Firestore.firestore()
        
        if currentChannel != nil {
            channelRef = database.collection("channels").document(currentChannel!.id).collection(("messages"))
            
            navigationItem.title = "\(currentChannel!.name)"
        }
        
        usersRef = database.collection("users")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        databaseListener = channelRef?.order(by: "time").addSnapshotListener()
            {(querySnapshot, error) in
                if let error = error {
                    print(error)
                    return
                }
            
            querySnapshot?.documentChanges.forEach(){ change in
                if change.type == .added {
                    let snapshot = change.document
                    
                    let id = snapshot.documentID
                    let senderId = snapshot["senderId"] as! String
                    let senderName = snapshot["senderName"] as! String
                    let messageText = snapshot["text"] as! String
                    let sentTimestamp = snapshot["time"] as! Timestamp
                    let sentDate = sentTimestamp.dateValue()
                    let sender = Sender(id: senderId, name: senderName)
                    let message = ChatMessage(sender: sender, messageId: id, sentDate: sentDate, message:messageText)
                    self.messagesList.append(message)
                    self.messagesCollectionView.insertSections([self.messagesList.count-1])
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }
    
    // MARK: - Messages Data Source Required Function
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messagesList[indexPath.section]
    }
    
    func currentSender() -> SenderType {
        guard let sender = sender
        else {
            return Sender(id: "",name: "")
        }
        return sender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messagesList.count
    }
    
    // MARK: - messagesfunctions
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        if message.sender.senderId == self.currentSender().senderId{
            avatarView.isHidden = true
        } else {
            avatarView.isHidden = false
            
            let userRef = usersRef?.document(message.sender.senderId)
            
            userRef?.getDocument {( document, error ) in
                if let document = document, document.exists {
                    let image = document.get(ConstantsList.FirestoreKeys.profilePicKey)
                    
                    if let image = image {
                        avatarView.image = UIImage(data: (image as! NSData) as Data)
                    }
                }
            }
        }
        
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font:UIFont.preferredFont(forTextStyle: .caption1)])
   }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font:UIFont.preferredFont(forTextStyle: .caption2)])
   }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        if text.isEmpty {
            return
        }
        
        channelRef?.addDocument(data: [
           "senderId" : sender!.senderId,
           "senderName" : sender!.displayName,
            "text" : text,
            "time" : Timestamp(date: Date.init())
           ])
        
        inputBar.inputTextView.text = ""
       }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView)
   -> CGFloat {
        return 16
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView)
   -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
