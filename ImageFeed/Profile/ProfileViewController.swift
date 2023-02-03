import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet private var avatarImage: UIImageView!
    @IBOutlet private var logoutButton: UIButton!
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var loginLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    
    @IBAction private func didTapLogoutButton() {}
}
