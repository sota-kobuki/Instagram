//
//  PostTableViewCell.swift
//  Instagram
//

import UIKit
import FirebaseStorageUI

protocol PostTableViewCellDelegate: AnyObject {
    func didTapCommentButton(postId: String)
}



class PostTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postData?.comments.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        if let comment = postData?.comments[indexPath.row] {
            cell.setCommentData(comment: comment) // 変更点: コメントデータの設定
        }
        return cell
    }
    

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentsTableView: UITableView!
    
    
    weak var delegate: PostTableViewCellDelegate?
    private var postData: PostData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentButton.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        let nib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        commentsTableView.register(nib, forCellReuseIdentifier: "CommentCell")
        
    }
    
    func setPostData(_ postData: PostData) {
        self.postData = postData
        // 画像の表示
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImageView.sd_setImage(with: imageRef)

        // キャプションの表示
        self.captionLabel.text = "\(postData.name) : \(postData.caption)"

        // 日時の表示
        self.dateLabel.text = postData.date

        // いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        commentsTableView.reloadData()
    }
    
    @objc private func commentButtonTapped() {
        if let postId = postData?.id {
            delegate?.didTapCommentButton(postId: postId)
        }
    }
}
