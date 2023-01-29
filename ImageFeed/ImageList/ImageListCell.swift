import UIKit

final class ImageListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImageListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
}
