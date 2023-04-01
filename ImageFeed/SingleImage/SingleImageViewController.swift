import UIKit

final class SingleImageViewController: UIViewController {
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    var imageLink: String! {
        didSet {
            guard isViewLoaded else {
                return
            }
            downloadImage()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        downloadImage()
    }
    
    func downloadImage() {
        guard let imageURL = URL(string: imageLink) else {
            return
        }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                UIBlockingProgressHUD.dismiss()
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
                self.presentNetworkErrorAlert()
            }
        }
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        let controller = UIActivityViewController(
            activityItems: [imageView.image as Any],
            applicationActivities: nil
        )
        present(controller, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        view.layoutIfNeeded()
        
        let visibleAreaSize = scrollView.bounds.size
        let widthScale = visibleAreaSize.width / image.size.width
        let heightScale = visibleAreaSize.height / image.size.height
        let scale = min(maxZoomScale, max(minZoomScale, max(widthScale, heightScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        let offsetX = (newContentSize.width - visibleAreaSize.width) / 2
        let offsetY = (newContentSize.height - visibleAreaSize.height) / 2
        
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
    }
    
    private func presentNetworkErrorAlert() { // TODO: Move method to AlertPresenter
        let controller = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(
            title: "Отменить",
            style: .cancel
        ) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.didTapBackButton()
        }
        let retry = UIAlertAction(
            title: "Повторить",
            style: .default
        ) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.downloadImage()
        }
        controller.addAction(cancel)
        controller.addAction(retry)
        controller.preferredAction = retry
        
        present(controller, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        view.layoutIfNeeded()
        
        let visibleAreaSize = scrollView.bounds.size
        let newContentSize = scrollView.contentSize
        
        let insetX = max((visibleAreaSize.width - newContentSize.width) / 2, 0)
        let insetY = max((visibleAreaSize.height - newContentSize.height) / 2, 0)
        
        scrollView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: 0, right: 0)
    }
}
