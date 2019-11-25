
/* Sources:
 - https://developer.apple.com/library/ios/samplecode/LookInside/Introduction/Intro.html#//apple_ref/doc/uid/TP40014643
 - https://developer.apple.com/library/content/samplecode/CustomTransitions/Introduction/Intro.html#//apple_ref/doc/uid/TP40015158
 */

import UIKit

class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    let targetEdge: UIRectEdge
    var gestureRecognizer: UIPanGestureRecognizer?

    init(targetEdge: UIRectEdge) {
        self.targetEdge = targetEdge
        super.init()
    }
    
    // Only needed if a subclass of UIPresentationController is implemented
    // We want this here in order to have a dimming view around our presented view controller
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting, targetEdge: targetEdge)
    }
    
    // Only needed if a subclass of UIViewControllerAnimatedTransitioning is implemented; otherwise, return nil (default)
    // We want this here in order to have a custom animation or an interactive animation (with gesture)
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionAnimator(edgeForDragging: targetEdge)
    }

    // The system calls this method on the presented view controller's transitioningDelegate to retrieve the animator object used for animating the dismissal of the presented view controller.
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var dismissalTargetEdge: UIRectEdge {
            switch targetEdge {
            case .top: return .bottom
            case .bottom: return .top
            case .left: return .right
            case .right: return .left
            default: fatalError()
            }
        }
        return TransitionAnimator(edgeForDragging: dismissalTargetEdge)
    }
    
    // If a `UIViewControllerAnimatedTransitioning` was returned from `animationControllerForPresentedController(_:, presentingController:, sourceController:)`, the system calls this method to retrieve the interaction controller for the presentation transition. Your implementation is expected to return an object that conforms to the UIViewControllerInteractiveTransitioning protocol, or nil if the transition should not be interactive.
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // You must not return an interaction controller from this method unless the transition is to be be interactive.
        // Note: we only deal with UIScreenEdgePanGestureRecognizer for presentation
        guard let screenEdgePanGestureRecognizer = gestureRecognizer as? UIScreenEdgePanGestureRecognizer else { return nil }
        return EdgeTransitionController(gestureRecognizer: screenEdgePanGestureRecognizer)
    }
    
    // If a `UIViewControllerAnimatedTransitioning` was returned from `animationControllerForDismissedController(_:), the system calls this method to retrieve the interaction controller for the dismissal transition.  Your implementation is expected to return an object that conforms to the UIViewControllerInteractiveTransitioning protocol, or nil if the transition should not be interactive.
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // You must not return an interaction controller from this method unless the transition is to be be interactive.
        // Note: we deal with UIPanGestureRecognizer and UIScreenEdgePanGestureRecognizer (subclass of UIPanGestureRecognizer) for dismissal
        switch gestureRecognizer {
        case let edgeGestureRecognizer as UIScreenEdgePanGestureRecognizer:
            // No need to pass a targetEdge as we can use gestureRecognizer's edges property
            return EdgeTransitionController(gestureRecognizer: edgeGestureRecognizer)
        case let panGestureRecognizer?:
            return PanTransitionController(gestureRecognizer: panGestureRecognizer, edgeForDragging: targetEdge)
        default:
            return nil
        }
    }
    
}
