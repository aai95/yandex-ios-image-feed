import Foundation

final class ImageListService {
    
    static let shared = ImageListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImageListProviderDidChange")
    
    private let storage = OAuth2TokenStorage.shared
    private let session = URLSession.shared
    private let perPage = 10
    
    private (set) var photos: [Photo] = []
    
    private var currentTask: URLSessionTask?
    private var lastLoadedPage: Int?
    
    private init() {}
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread, "This code must be executed on the main thread")
        
        guard currentTask == nil else {
            return
        }
        guard let token = storage.authToken else {
            return
        }
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        let request = makePhotosRequest(with: token, for: nextPage)
        
        let task = session.decodeTask(from: request) { [weak self] (result: Result<[PhotoBody], Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let bodies):
                assert(Thread.isMainThread, "This code must be executed on the main thread")
                
                self.photos.append(contentsOf: self.convertPhotos(from: bodies))
                self.currentTask = nil
                self.lastLoadedPage = nextPage
                
                NotificationCenter.default.post(
                    name: ImageListService.didChangeNotification,
                    object: self,
                    userInfo: ["Photos": self.photos as Any]
                )
            case .failure(_):
                break
            }
        }
        
        currentTask = task
        task.resume()
    }
    
    private func makePhotosRequest(with token: String, for page: Int) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/photos"
            + "?page=\(page)"
            + "&per_page=\(perPage)"
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func convertPhotos(from bodies: [PhotoBody]) -> [Photo] {
        var photos = [Photo]()
        
        for body in bodies {
            let photo = Photo(
                id: body.id,
                createdAt: ISO8601DateFormatter().date(from: body.createdAt),
                size: CGSize(width: body.width, height: body.height),
                isLiked: body.likedByUser,
                description: body.description,
                fullSizeLink: body.urls.full,
                thumbSizeLink: body.urls.thumb
            )
            photos.append(photo)
        }
        return photos
    }
}

extension ImageListService {
    
    struct Photo {
        let id: String
        let createdAt: Date?
        let size: CGSize
        let isLiked: Bool
        let description: String?
        let fullSizeLink: String
        let thumbSizeLink: String
    }
    
    private struct PhotoBody: Decodable {
        let id: String
        let createdAt: String
        let width: Int
        let height: Int
        let likedByUser: Bool
        let description: String?
        let urls: URLsBody
        
        enum CodingKeys: String, CodingKey {
            case id
            case createdAt = "created_at"
            case width
            case height
            case likedByUser = "liked_by_user"
            case description
            case urls
        }
    }
    
    private struct URLsBody: Decodable {
        let full: String
        let thumb: String
        
        enum CodingKeys: String, CodingKey {
            case full
            case thumb
        }
    }
}
