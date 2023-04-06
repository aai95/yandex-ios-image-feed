import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didPresentAlert(controller: UIAlertController)
}

struct AlertPresenter {
    
    weak private var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate?) {
        self.delegate = delegate
    }
    
    func presentAlert(model: AlertModel) {
        
        let controller = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        for actionModel in model.actions {
            
            let action = UIAlertAction(
                title: actionModel.title,
                style: actionModel.style,
                handler: actionModel.handler
            )
            controller.addAction(action)
            
            if actionModel.isPreferred {
                controller.preferredAction = action
            }
        }
        
        delegate?.didPresentAlert(controller: controller)
    }
}
