import UIKit

class ImageListViewController: UIViewController {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let photoNames: [String] = Array(0..<21).map{ "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let controller = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            controller.image = UIImage(named: photoNames[indexPath.row])
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configCell(for cell: ImageListCell, with indexPath: IndexPath) {
        guard let photoImage = UIImage(named: photoNames[indexPath.row]) else {
            return
        }
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "Like On Button") : UIImage(named: "Like Off Button")
        
        cell.photoImage.image = photoImage
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.dateLabel.text = dateFormatter.string(from: Date())
    }
}

extension ImageListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImageListCell else {
            print("Failed to cast UITableViewCell as ImageListCell")
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImageListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photoNames[indexPath.row]) else {
            return 0
        }
        
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let cellWidth = tableView.bounds.width - insets.left - insets.right
        let scale = cellWidth / image.size.width
        let cellHeight = scale * image.size.height + insets.top + insets.bottom
        
        return cellHeight
    }
}
