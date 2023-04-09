import Foundation

protocol ImageListPresenterProtocol {
    var controller: ImageListViewControllerProtocol? { get set }
    
    func loadNextPhotos()
    func didLoadNextPhotos()
    
    func getPhotoBy(index: Int) -> Photo
    func countPhotos() -> Int
    
    func changeLikeOnPhoto(for cell: ImageListCell, with indexPath: IndexPath)
}

final class ImageListPresenter: ImageListPresenterProtocol {
    
    private let imageListService = ImageListService.shared
    
    private var photos = Array<Photo>()
    
    weak var controller: ImageListViewControllerProtocol?
    
    func loadNextPhotos() {
        imageListService.fetchPhotosNextPage()
    }
    
    func didLoadNextPhotos() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        
        if oldCount != newCount {
            photos = imageListService.photos
            controller?.updateTableViewAnimated(indexes: oldCount..<newCount)
        }
    }
    
    func getPhotoBy(index: Int) -> Photo {
        return photos[index]
    }
    
    func countPhotos() -> Int {
        return photos.count
    }
    
    func changeLikeOnPhoto(for cell: ImageListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoID: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(_):
                self.photos = self.imageListService.photos
                let changedPhoto = self.photos[indexPath.row]
                cell.putLikeOnPhoto(isLiked: changedPhoto.isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
                self.controller?.presentNetworkErrorAlert()
            }
        }
    }
}
