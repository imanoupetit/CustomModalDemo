
import UIKit

class PanelViewController: UIViewController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 5
        view.layer.cornerRadius = 18
        
        // Add screen edge pan gesture that will dismiss the settings view controller
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dismissInteractivelyViewController))
        view.addGestureRecognizer(panGestureRecognizer)

        // We want both tableView's vertical drag gesture and panGestureRecognizer to work wisely together thanks to UIGestureRecognizerDelegate
        //panGestureRecognizer.delegate = self
    }

    // MARK: - Gestures
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        UIRectEdge.all
    }

    /*
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // If y velocity is greater than x velocity, we want the tableView's drag gesture, otherwise, we wand our dismissal horizontal pan gesture to proceed
        // !!! It seems that this implementation is no more required with Xcode 8 / Swift 3 as both gestures work wisely one with the other
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = gestureRecognizer.velocity(in: view)
        return abs(velocity.x) >= abs(velocity.y)
    }
    */
    
    // MARK: - User interaction

    @objc
    private func dismissInteractivelyViewController(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            // Before to dismiss the presented view controller, we have to reset the transition delagate properties
            guard let transitionDelegate = transitioningDelegate as? TransitionDelegate else { return }
            transitionDelegate.gestureRecognizer = sender
            dismiss(animated: true, completion: nil)
        }
    }

}
