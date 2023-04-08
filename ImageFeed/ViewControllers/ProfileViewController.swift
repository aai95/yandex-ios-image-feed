import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let profileImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "Profile Image"))
        
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 35
        image.widthAnchor.constraint(equalToConstant: 70).isActive = true
        image.heightAnchor.constraint(equalTo: image.widthAnchor).isActive = true
        
        return image
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setImage(UIImage(named: "Logout Button"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        
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
        label.numberOfLines = 0
        
        return label
    }()
    
    private var alertPresenter: AlertPresenter?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    var presenter: ProfileViewPresenterProtocol?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
        
        makeProfileViewLayout()
        subscribeToProfileImageUpdate()
        
        updateProfileData()
        updateProfileImage()
    }
    
    func updateProfileData() {
        guard let profile = presenter?.presentProfile() else {
            return
        }
        nameLabel.text = profile.name
        loginLabel.text = profile.login
        descriptionLabel.text = profile.bio
    }
    
    func updateProfileImage() {
        guard let url = presenter?.presentProfileImageURL() else {
            return
        }
        profileImage.kf.indicatorType = .activity
        (profileImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = .ypWhite
        profileImage.kf.setImage(with: url)
    }
    
    func logoutProfile() {
        presenter?.removeUserDataWhenLogout()
        
        guard let window = UIApplication.shared.windows.first else {
            preconditionFailure("Failed to find UIWindow in UIApplication")
        }
        window.rootViewController = SplashViewController()
    }
    
    @objc private func didTapLogoutButton() {
        let noActionModel = AlertActionModel(
            title: "Нет",
            style: .cancel,
            isPreferred: true
        )
        let yesActionModel = AlertActionModel(
            title: "Да",
            handler: { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.logoutProfile()
            }
        )
        let alertModel = AlertModel(
            title: "Пока-пока!",
            message: "Уверены что хотите выйти?",
            actions: [noActionModel, yesActionModel]
        )
        alertPresenter?.presentAlert(model: alertModel)
    }
    
    private func subscribeToProfileImageUpdate() {
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
    }
}

extension ProfileViewController: AlertPresenterDelegate {
    
    func didPresentAlert(controller: UIAlertController) {
        present(controller, animated: true)
    }
}

private extension ProfileViewController {
    
    func makeProfileViewLayout() {
        let mainStack = createVerticalStack()
        
        view.addSubview(mainStack)
        view.backgroundColor = UIColor.ypBlack
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
    
    func createVerticalStack() -> UIStackView {
        let vStack = UIStackView()
        
        vStack.axis = .vertical
        vStack.spacing = 8
        
        vStack.addArrangedSubview(createHorizontalStack())
        vStack.addArrangedSubview(nameLabel)
        vStack.addArrangedSubview(loginLabel)
        vStack.addArrangedSubview(descriptionLabel)
        
        return vStack
    }
    
    func createHorizontalStack() -> UIStackView {
        let hStack = UIStackView()
        
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        
        hStack.addArrangedSubview(profileImage)
        hStack.addArrangedSubview(logoutButton)
        
        return hStack
    }
}
