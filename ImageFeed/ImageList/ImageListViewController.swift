import UIKit

class ImageListViewController: UIViewController {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imageListService = ImageListService.shared
    
    private var imageListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    @IBOutlet private var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImageListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.updateTableViewAnimated()
            }
        
        imageListService.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let controller = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            controller.image = UIImage(named: "Photo Placeholder")
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        
        if oldCount != newCount {
            photos = imageListService.photos
            
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { index in
                    IndexPath(row: index, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    private func configCell(for cell: ImageListCell, with indexPath: IndexPath) {
        guard let photoURL = URL(string: photos[indexPath.row].thumbSizeLink) else {
            return
        }
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "Like On Button") : UIImage(named: "Like Off Button")
        
        cell.photoImage.kf.setImage(
            with: photoURL,
            placeholder: UIImage(named: "Photo Placeholder")
        ) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.dateLabel.text = dateFormatter.string(from: Date())
    }
}

extension ImageListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        
        if indexPath.row == lastRowIndex {
            imageListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
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
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let photoSize = photos[indexPath.row].size
        
        let cellWidth = tableView.bounds.width - insets.left - insets.right
        let scale = cellWidth / photoSize.width
        let cellHeight = scale * photoSize.height + insets.top + insets.bottom
        
        return cellHeight
    }
}
