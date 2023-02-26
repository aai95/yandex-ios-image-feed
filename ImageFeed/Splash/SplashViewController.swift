import UIKit

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if OAuth2Service.shared.authToken == nil {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        } else {
            switchToTabBarController()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard let navigationController = segue.destination as? UINavigationController,
                  let authController = navigationController.viewControllers[0] as? AuthViewController
            else {
                fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
            }
            authController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                break
            }
        }
    }
}
