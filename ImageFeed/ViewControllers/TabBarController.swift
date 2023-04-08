import UIKit

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imageListViewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "ImageListViewController")
        
        let profileViewController = ProfileViewController()
        
        profileViewController.presenter = ProfileViewPresenter()
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "Profile Tab"),
            selectedImage: nil
        )
        self.viewControllers = [imageListViewController, profileViewController]
    }
}
