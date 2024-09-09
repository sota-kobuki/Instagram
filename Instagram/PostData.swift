//
//  PostData.swift
//  Instagram
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class PostData: NSObject {
    var id = ""
    var name = ""
    var caption = ""
    var date = ""
    var likes: [String] = []
    var isLiked: Bool = false
    var comments: [(String, String)] = []
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        
        let postDic = document.data()
        
        if let name = postDic["name"] as? String {
            self.name = name
        }
        
        if let caption = postDic["caption"] as? String {
            self.caption = caption
        }
        if let timestamp = postDic["date"] as? Timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            self.date = formatter.string(from: timestamp.dateValue())
        }
        
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        
        if let myid = Auth.auth().currentUser?.uid {
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }
        }
    }
    
    func fetchComments(completion: @escaping () -> Void) {
        let commentsCollection = Firestore.firestore().collection(Const.PostPath).document(self.id).collection("comments")
        commentsCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("DEBUG_PRINT: コメントの取得が失敗しました。 \(error)")
                return
            }
            self.comments = querySnapshot?.documents.compactMap { commentDoc -> (String, String)? in
                let commentData = commentDoc.data()
                guard let commentText = commentData["commentText"] as? String,
                      let commenterId = commentData["commenterId"] as? String else {
                    return nil
                }
                var commenterName = "Unknown"
                Firestore.firestore().collection("users").document(commenterId).getDocument { (userDoc, error) in
                    if let error = error {
                        print("DEBUG_PRINT: ユーザー名の取得が失敗しました。 \(error)")
                        return
                    }
                    if let userDic = userDoc?.data(),
                       let userName = userDic["name"] as? String {
                        commenterName = userName
                    }
                    self.comments.append((commentText, commenterName))
                    completion() // Fetchが完了したことを通知
                }
                return nil // 一旦nilを返しておく
            } ?? []
        }
    }
    
    override var description: String {
        return "PostData: name=\(name); caption=\(caption); date=\(date); likes=\(likes.count); id=\(id);"
    }
    
}
