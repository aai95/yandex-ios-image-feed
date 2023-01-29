import UIKit

@IBDesignable
class VerticalGradientView: UIView {
    
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    func updateView() {
        guard let layer = self.layer as? CAGradientLayer else {
            print("Failed to cast CALayer as CAGradientLayer")
            return
        }
        
        layer.colors = [firstColor, secondColor].map {$0.cgColor}
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint (x: 0.5, y: 1)
    }
}
