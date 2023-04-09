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
        guard let url = URL(string: photo.thumbSizeLink) else {
            return
        }
        photoImage.kf.setImage(with: url, placeholder: UIImage(named: "Photo Placeholder"))
        putLikeOnPhoto(isLiked: photo.isLiked)
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
