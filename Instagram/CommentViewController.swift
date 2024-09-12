//
//  CommentViewController.swift
//  Instagram


import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol CommentViewControllerDelegate: AnyObject {
    func didPostComment() // 変更点: デリゲートメソッドの追加
}

class CommentViewController: UIViewController {

    @IBOutlet weak var commentTextField: UITextField!
    var postId: String?
    weak var delegate: CommentViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func handlePostCommentButton(_ sender: UIButton) {
        guard let commentText = commentTextField.text, !commentText.isEmpty else {
            print("DEBUG_PRINT: コメントテキストが空です。")
            return
        }
        guard let postId = postId else {
            print("DEBUG_PRINT: postIdがnilです。")
            return
        }
        guard let myId = Auth.auth().currentUser?.uid else {
            print("DEBUG_PRINT: ユーザーがログインしていません。")
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
            self.delegate?.didPostComment()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
