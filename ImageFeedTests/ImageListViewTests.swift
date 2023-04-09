import XCTest
@testable import ImageFeed

final class ImageListPresenterSpy: ImageListPresenterProtocol {
    
    var controller: ImageListViewControllerProtocol?
    var isLoadNextPhotosCalled = false
    
    func loadNextPhotos() {
        isLoadNextPhotosCalled = true
    }
    
    func didLoadNextPhotos() {}
    
    func getPhotoBy(index: Int) -> Photo {
        return Photo(
            id: "",
            createdAt: Date(),
            size: CGSize(),
            isLiked: false,
            description: nil,
            fullSizeLink: "",
            thumbSizeLink: ""
        )
    }
    
    func countPhotos() -> Int {
        return 1
    }
    
    func changeLikeOnPhoto(for cell: ImageListCell, with indexPath: IndexPath) {}
}

final class ImageListViewTests: XCTestCase {
    
    func testControllerCallsLoadNextPhotos() {
        // Given
        let imageListPresenterSpy = ImageListPresenterSpy()
        let imageListController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "ImageListViewController") as! ImageListViewController
        
        imageListController.configure(presenter: imageListPresenterSpy)
        
        // When
        _ = imageListController.view
        
        // Then
        XCTAssertTrue(imageListPresenterSpy.isLoadNextPhotosCalled)
    }
    
    func testPresenterHasNoPhotosAfterInit() {
        // Given
        let imageListPresenter = ImageListPresenter()
        
        // When
        let count = imageListPresenter.countPhotos()
        
        // Then
        XCTAssertEqual(count, 0)
    }
}
