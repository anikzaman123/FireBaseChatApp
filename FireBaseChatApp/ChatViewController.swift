//
//  ChatViewController.swift
//  FireBaseChatApp
//
//  Created by Anik Zaman on 4/20/17.
//  Copyright © 2017 Anik Zaman. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


class ChatViewController: JSQMessagesViewController {
    
    var message = [JSQMessage]()
    var avatarDict = [String: JSQMessagesAvatarImage]()
    
    var messageRef = FIRDatabase.database().reference().child("messages")

    override func viewDidLoad() {
        super.viewDidLoad()

        if let currentUseID = FIRAuth.auth()?.currentUser {
            
            self.senderId = currentUseID.uid
        
            print("**************")
            print(currentUseID.uid)
        
        if currentUseID.isAnonymous {
            self.senderDisplayName = "anonymous"
        }
        else {
            self.senderDisplayName = "\(currentUseID.displayName!)"
        }
        
        }
        let rootRef = FIRDatabase.database().reference()
        let messageRef = rootRef.child("messages")
        
//        messageRef.childByAutoId().setValue("third message")
//        messageRef.observe(FIRDataEventType.value) { (snapshot:FIRDataSnapshot) in
//            print(snapshot.value)
//            
//            if let dic = snapshot.value as? NSDictionary {
//                print(dic)
//            }
//        }
        
        
        observeMessage()
    }
    
    //GET USER ID FOR AVATAR SETUP
    
    func observeUsers(id: String) {
        FIRDatabase.database().reference().child("users").child(id).observe(.value, with: {
            snapshot in
            if let dic = snapshot.value as? [String: AnyObject] {
            
                let avatarUrl = dic["profileUrl"] as! String
                
                
                self.setupAvatar(url: avatarUrl, messageId: id)
            }
        })
    }
    
    
    //SETTING UP AVATAR
    
    func setupAvatar(url: String, messageId: String) {
        
        if url != "" {
            
            let fileUrl = NSURL(string: url)
            let data = NSData(contentsOf: fileUrl! as URL)
            let image = UIImage(data: data! as Data)
            let userImage = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
            avatarDict[messageId] = userImage
            
        }
            
        else {
            avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "anonymous1"), diameter: 30)
        }
        
        collectionView.reloadData()
    }
    
    //CHEKING MESSAGE TYPE
    
    func observeMessage() {
        
        messageRef.observe(.childAdded, with: { snapshot in
            
            if let dic = snapshot.value as? [String: AnyObject] {
               let mediaType = dic["Mediatype"] as! String
                let senderID = dic["senderID"] as! String
                let senderName = dic["senderName"] as! String
                
                self.observeUsers(id: senderID)
                
                
                switch mediaType {
                    
                    case "Text":
                    
                        let text = dic["text"] as! String
                        self.message.append(JSQMessage(senderId: senderID, displayName: senderName, text: text))
                    
                    case "PHOTO":
                    
                    let fileUrl = dic["fileUrl"] as! String
                    let url = NSURL(string: fileUrl)
                    let data = NSData(contentsOf: url! as URL)
                    let picture = UIImage(data: data! as Data)
                    let photo = JSQPhotoMediaItem(image: picture)
                    self.message.append(JSQMessage(senderId: senderID, displayName: senderName, media: photo))
                    
                    
                    if self.senderId == senderID {
                        
                        photo?.appliesMediaViewMaskAsOutgoing = true
                    }
                    else {
                        photo?.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                    case "VIDEO":
                    
                    let fileUrl = dic["fileUrl"] as! String
                    let video = NSURL(string: fileUrl)
                    let videoItem = JSQVideoMediaItem(fileURL: video as! URL, isReadyToPlay: true)
                    self.message.append(JSQMessage(senderId: senderID, displayName: senderName, media: videoItem))

                    
                    if self.senderId == senderID {
                        
                        videoItem?.appliesMediaViewMaskAsOutgoing = true
                    }
                    else {
                        videoItem?.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                default:
                    print("unknown data type")
                }
                
                self.collectionView.reloadData()
            }
        })
    }
    
    //SENDING A TEXT MESSAGE ONLY
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {

//        message.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
//        collectionView.reloadData()
//        print(message)

        let newMessage = messageRef.childByAutoId()
        let messageData = ["text": text, "senderID": senderId, "senderName": senderDisplayName, "Mediatype": "Text"]
        newMessage.setValue(messageData)
        
        self.finishSendingMessage()
        
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("didPressAccessory")
        
        let sheet = UIAlertController(title: "Media Message", message: "Please Select an item", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancel =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alert:UIAlertAction) in
            
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Libary", style: UIAlertActionStyle.default) { (alert:UIAlertAction) in
            
            
            self.getMediaFrom(type: kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Video Libary", style: UIAlertActionStyle.default) { (alert:UIAlertAction) in
            
            
            self.getMediaFrom(type: kUTTypeMovie)
        }

        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)
       
    }

    //CHEKING PHOTO/VIDEO TYPE OF DATA?
    
    func getMediaFrom(type: CFString) {

        let mediapicker = UIImagePickerController()
        mediapicker.delegate = self
        mediapicker.mediaTypes = [type as String]
        self.present(mediapicker, animated: true, completion: nil)
        
    }
    
    //DISPLAY MESSAGE ON CHAT VIEW
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return message[indexPath.item]
    }
    
    //SETUP MESSAGE BUBBLE ON CHAT VIEW
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubblefactory = JSQMessagesBubbleImageFactory()
        
        let sendingmessage = message[indexPath.item]
        
        if sendingmessage.senderId == self.senderId {
           
            return bubblefactory!.outgoingMessagesBubbleImage(with: .blue)
        }
        else {
            return bubblefactory!.incomingMessagesBubbleImage(with: .green)
        }
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let newmessage = message[indexPath.item]
        return avatarDict[newmessage.senderId]
//        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "anonymous1"), diameter: 30)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return message.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        return cell
    }
    
    //PLAY VIDEO MESSAGE ON TAPPING 
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        print("didTapMessageBubble: \(indexPath.item)")
        let tapmessage = message[indexPath.item]
        if tapmessage.isMediaMessage {
            if let mediaItem = tapmessage.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                
                self.present(playerViewController, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //SIGN OUT FUNCTIONALITY
    
    @IBAction func LogOutDidTapped(_ sender: Any) {
        
        do {
            try FIRAuth.auth()?.signOut()
        }
        catch let error {
            print(error)
        }
        print(FIRAuth.auth()?.currentUser)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LogInViewController
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        appdelegate.window?.rootViewController = loginVC
    }
    
    //STORE PHOTO/VIDEO IN FIRBASE STORAGE
    
    func sendMedia(picture: UIImage?, video: NSURL?) {
        
        if let picture = picture {
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"

            print("*******************")
            print(filePath)
            
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileUrl": fileUrl, "senderID": self.senderId, "senderName": self.senderDisplayName, "Mediatype": "PHOTO"]
                newMessage.setValue(messageData)
            }
        }
            else if let video = video {
                let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
                print(filePath)
                let data = NSData(contentsOf: video as URL)
                let metadata = FIRStorageMetadata()
                metadata.contentType = "video/mp4"
                FIRStorage.storage().reference().child(filePath).put(data! as Data, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        return
                    }
                    let fileUrl = metadata!.downloadURLs![0].absoluteString
                    
                    let newMessage = self.messageRef.childByAutoId()
                    let messageData = ["fileUrl": fileUrl, "senderID": self.senderId, "senderName": self.senderDisplayName, "Mediatype": "VIDEO"]
                    newMessage.setValue(messageData)
                    
                }
        }
    }
}


extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //PICK PHOTO/VIDEO FROM IMAGE PICKER
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did finsh picking")
        print(info)
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
        sendMedia(picture: picture, video: nil)
        }
        
       else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
        sendMedia(picture: nil, video: video)

        }
        dismiss(animated: true, completion: nil)
        collectionView.reloadData()

    }
}
