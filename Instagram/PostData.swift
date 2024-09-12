import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class Comment {
    var commentText: String
    var commenterId: String
    var commenterName: String
    
    init(commentText: String, commenterId: String, commenterName: String) {
        self.commentText = commentText
        self.commenterId = commenterId
        self.commenterName = commenterName
    }
}

class PostData: NSObject {
    var id = ""
    var name = ""
    var caption = ""
    var date = ""
    var likes: [String] = []
    var isLiked: Bool = false
    var comments: [Comment] = []
    
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
            if self.likes.contains(myid) {
                self.isLiked = true
            }
        }
    }
    
    func fetchComments(completion: @escaping () -> Void) {
        let commentsCollection = Firestore.firestore().collection(Const.PostPath).document(self.id).collection("comments")
        commentsCollection.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("DEBUG_PRINT: コメントの取得が失敗しました。 \(error)")
                return
            }
            self.comments = []
            if let querySnapshot = querySnapshot {
                var commentCount = querySnapshot.documents.count
                for commentDoc in querySnapshot.documents {
                    let commentData = commentDoc.data()
                    guard let commentText = commentData["commentText"] as? String,
                          let commenterId = commentData["commenterId"] as? String else {
                        commentCount -= 1
                        continue
                    }
                    Firestore.firestore().collection("users").document(commenterId).getDocument { (userDoc, error) in
                        if let error = error {
                            print("DEBUG_PRINT: ユーザー名の取得が失敗しました。 \(error)")
                            commentCount -= 1
                            if commentCount == 0 {
                                completion() // ユーザー名取得処理が全て完了したら通知
                            }
                            return
                        }
                        var commenterName = "Unknown"
                        if let userDic = userDoc?.data(),
                           let userName = userDic["name"] as? String {
                            commenterName = userName
                        }
                        let newComment = Comment(commentText: commentText, commenterId: commenterId, commenterName: commenterName)
                        self.comments.append(newComment)
                        commentCount -= 1
                        if commentCount == 0 {
                            DispatchQueue.main.async {
                                completion() // ユーザー名取得処理が全て完了したら通知
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion() // コメントがない場合も通知
                }
            }
        }
    }
    
    override var description: String {
        return "PostData: name=\(name); caption=\(caption); date=\(date); likes=\(likes.count); id=\(id);"
    }
}
