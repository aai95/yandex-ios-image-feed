import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileViewLayout()
    }
    
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
        vStack.addArrangedSubview(createLabel(text: "Екатерина Новикова", color: .ypWhite, font: .boldSystemFont(ofSize: 23)))
        vStack.addArrangedSubview(createLabel(text: "@ekaterina_nov", color: .ypGray, font: .systemFont(ofSize: 13)))
        vStack.addArrangedSubview(createLabel(text: "Hello, world!", color: .ypWhite, font: .systemFont(ofSize: 13)))
        
        return vStack
    }
    
    private func createHorizontalStack() -> UIStackView {
        let hStack = UIStackView()
        
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        
        hStack.addArrangedSubview(createProfileImage())
        hStack.addArrangedSubview(createLogoutButton())
        
        return hStack
    }
    
    private func createProfileImage() -> UIImageView {
        let image = UIImageView(image: UIImage(named: "Profile Image"))
        
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 70),
            image.heightAnchor.constraint(equalTo: image.widthAnchor, multiplier: 1),
        ])
        return image
    }
    
    private func createLogoutButton() -> UIButton {
        let button = UIButton(type: .custom)
        
        button.setImage(UIImage(named: "Logout Button"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        return button
    }
    
    private func createLabel(text: String, color: UIColor, font: UIFont) -> UILabel {
        let label = UILabel()
        
        label.text = text
        label.textColor = color
        label.font = font
        
        return label
    }
}
