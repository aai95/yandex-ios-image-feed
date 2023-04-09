import UIKit

protocol ImageListCellDelegate: AnyObject {
    func imageListCellDidTapLike(on cell: ImageListCell)
}

final class ImageListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImageListCell"
    
    @IBOutlet private var photoImage: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!
    
    private lazy var dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    weak var delegate: ImageListCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImage.kf.cancelDownloadTask()
    }
    
    func configure(photo: Photo) {
        guard let photoURL = URL(string: photo.thumbSizeLink) else {
            return
        }
        let likeImage = photo.isLiked ? UIImage(named: "Like On Button") : UIImage(named: "Like Off Button")
        
        photoImage.kf.setImage(with: photoURL, placeholder: UIImage(named: "Photo Placeholder"))
        likeButton.setImage(likeImage, for: .normal)
        dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
    }
    
    func putLikeOnPhoto(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "Like On Button") : UIImage(named: "Like Off Button")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    @IBAction private func didTapLikeButton() {
        delegate?.imageListCellDidTapLike(on: self)
    }
}
