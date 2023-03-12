import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private let profileImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "Profile Image"))
        
        image.widthAnchor.constraint(equalToConstant: 70).isActive = true
        image.heightAnchor.constraint(equalTo: image.widthAnchor).isActive = true
        
        return image
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setImage(UIImage(named: "Logout Button"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhite
        label.font = .boldSystemFont(ofSize: 23)
        
        return label
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        
        label.text = "@ekaterina_nov"
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 13)
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Hello, world!"
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 13)
        
        return label
    }()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfileViewLayout()
        updateProfileDetails()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.updateProfileImage()
            }
        
        updateProfileImage()
    }
    
    // MARK: - Private functions
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            return
        }
        nameLabel.text = profile.name
        loginLabel.text = profile.login
        descriptionLabel.text = profile.bio
    }
    
    private func updateProfileImage() {
        if let link = profileImageService.profileImageLink,
           let url = URL(string: link)
        {
            profileImage.kf.setImage(
                with: url,
                options: [.processor(RoundCornerImageProcessor(cornerRadius: 35))]
            )
        }
    }
    
    // MARK: - Private layout functions
    
    private func setupProfileViewLayout() {
        let mainStack = createVerticalStack()
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
    
    private func createVerticalStack() -> UIStackView {
        let vStack = UIStackView()
        
        vStack.axis = .vertical
        vStack.spacing = 8
        
        vStack.addArrangedSubview(createHorizontalStack())
        vStack.addArrangedSubview(nameLabel)
        vStack.addArrangedSubview(loginLabel)
        vStack.addArrangedSubview(descriptionLabel)
        
        return vStack
    }
    
    private func createHorizontalStack() -> UIStackView {
        let hStack = UIStackView()
        
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        
        hStack.addArrangedSubview(profileImage)
        hStack.addArrangedSubview(logoutButton)
        
        return hStack
    }
}
