import UIKit

protocol ImageListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImageListCell)
}

final class ImageListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImageListCell"
    
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    weak var delegate: ImageListCellDelegate?
    
    @IBAction private func didTapLikeButton() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImage.kf.cancelDownloadTask()
    }
    
    func putLikeOnPhoto(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "Like On Button") : UIImage(named: "Like Off Button")
        likeButton.setImage(likeImage, for: .normal)
    }
}
