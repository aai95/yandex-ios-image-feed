import UIKit

final class SplashViewController: UIViewController {
    
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeSplashViewLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2Service.authToken {
            fetchProfile(token)
        } else {
            switchToAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func makeSplashViewLayout() {
        let image = UIImageView(image: UIImage(named: "Launch Screen Logo"))
        
        view.addSubview(image)
        view.backgroundColor = UIColor.ypBlack
        
        image.translatesAutoresizingMaskIntoConstraints = false
        
        image.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func switchToAuthViewController() {
        let viewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "AuthViewController")
        
        guard let authController = viewController as? AuthViewController else {
            fatalError("Failed to cast UIViewController as AuthViewController")
        }
        authController.delegate = self
        present(authController, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            UIBlockingProgressHUD.show()
            self.fetchOAuthToken(code)
        }
    }
}

private extension SplashViewController {
    
    func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let token):
                self.fetchProfile(token)
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
                self.presentNetworkErrorAlert()
            }
        }
    }
    
    func fetchProfile(_ token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let profile):
                self.profileImageService.fetchProfileImageLink(token, for: profile.username) { _ in }
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarViewController()
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
                self.presentNetworkErrorAlert()
            }
        }
    }
    
    func switchToTabBarViewController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("There is no UIWindow in UIApplication")
        }
        let viewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = viewController
    }
    
    func presentNetworkErrorAlert() {
        let controller = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "Ок",
            style: .default
        )
        controller.addAction(action)
        present(controller, animated: true)
    }
}
