import UIKit

protocol ImageListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(indexes: Range<Int>)
    func presentNetworkErrorAlert()
}

class ImageListViewController: UIViewController, ImageListViewControllerProtocol {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private var presenter: ImageListViewPresenterProtocol!
    private var alertPresenter: AlertPresenter?
    private var imageListServiceObserver: NSObjectProtocol?
    
    @IBOutlet private var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        subscribeToPhotosUpdate()
        presenter.loadNextPhotos()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let controller = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            controller.imageLink = presenter.getPhotoBy(index: indexPath.row).fullSizeLink
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func configure(presenter: ImageListViewPresenterProtocol) {
        self.presenter = presenter
        self.presenter.controller = self
    }
    
    func updateTableViewAnimated(indexes: Range<Int>) {
        tableView.performBatchUpdates {
            let indexPaths = indexes.map { index in
                IndexPath(row: index, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func presentNetworkErrorAlert() {
        let okActionModel = AlertActionModel(
            title: "OK"
        )
        let alertModel = AlertModel(
            title: "Что-то пошло не так",
            message: "Не удалось выполнить операцию",
            actions: [okActionModel]
        )
        alertPresenter?.presentAlert(model: alertModel)
    }
    
    private func subscribeToPhotosUpdate() {
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImageListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.presenter.didLoadNextPhotos()
            }
    }
}

extension ImageListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        
        if indexPath.row == lastRowIndex {
            presenter.loadNextPhotos()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.countPhotos()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView
            .dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath) as? ImageListCell
        else {
            preconditionFailure("Failed to cast UITableViewCell as ImageListCell")
        }
        imageListCell.delegate = self
        imageListCell.configure(photo: presenter.getPhotoBy(index: indexPath.row))
        return imageListCell
    }
}

extension ImageListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let photoSize = presenter.getPhotoBy(index: indexPath.row).size
        
        let cellWidth = tableView.bounds.width - insets.left - insets.right
        let scale = cellWidth / photoSize.width
        let cellHeight = scale * photoSize.height + insets.top + insets.bottom
        
        return cellHeight
    }
}

extension ImageListViewController: ImageListCellDelegate {
    
    func imageListCellDidTapLike(on cell: ImageListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        presenter?.changeLikeOnPhoto(for: cell, with: indexPath)
    }
}

extension ImageListViewController: AlertPresenterDelegate {
    
    func didPresentAlert(controller: UIAlertController) {
        present(controller, animated: true)
    }
}
