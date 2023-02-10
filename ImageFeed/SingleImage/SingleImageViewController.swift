import UIKit

final class SingleImageViewController: UIViewController {
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    var image: UIImage! {
        didSet {
            guard isViewLoaded else {
                return
            }
            imageView.image = image
            rescaleAndCenterImageInScrollView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        imageView.image = image
        rescaleAndCenterImageInScrollView()
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        let controller = UIActivityViewController(
            activityItems: [image as Any],
            applicationActivities: nil
        )
        present(controller, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView() {
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
