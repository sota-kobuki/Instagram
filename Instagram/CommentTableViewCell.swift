//
//  CommentTableViewCell.swift
//  Instagram
//
//  Created by 小吹　創大 on 2024/09/09.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commenterNameLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCommentData(comment: (String, String)) {
        self.commentTextLabel.text = comment.0
        self.commenterNameLabel.text = comment.1
    }
    
}
