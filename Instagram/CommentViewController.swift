//
//  CommentViewController.swift
//  Instagram


import UIKit
import FirebaseAuth
import FirebaseFirestore

class CommentViewController: UIViewController {

    @IBOutlet weak var commentTextField: UITextField!
    var postId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func handlePostCommentButton(_ sender: UIButton) {
        guard let commentText = commentTextField.text, !commentText.isEmpty else {
            return
        }
        guard let postId = postId else {
            return
        }
        guard let myId = Auth.auth().currentUser?.uid else {
            return
        }

        let comment = [
            "commentText": commentText,
            "commenterId": myId,
            "timestamp": FieldValue.serverTimestamp()
        ] as [String : Any]

        let postRef = Firestore.firestore().collection(Const.PostPath).document(postId)
        postRef.collection("comments").addDocument(data: comment) { error in
            if let error = error {
                print("DEBUG_PRINT: コメントの保存に失敗しました。 \(error)")
                return
            }
            print("DEBUG_PRINT: コメントを保存しました。")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
