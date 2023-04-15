import UIKit

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let imageListController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "ImageListViewController") as? ImageListViewController
        else {
            preconditionFailure("Failed to cast UIViewController as ImageListViewController")
        }
        imageListController.configure(presenter: ImageListPresenter())
        
        let profileController = ProfileViewController()
        profileController.configure(presenter: ProfilePresenter())
        profileController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "Profile Tab"),
            selectedImage: nil
        )
        self.viewControllers = [imageListController, profileController]
    }
}
