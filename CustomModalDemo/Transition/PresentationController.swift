
/* Sources:
 - https://developer.apple.com/library/ios/samplecode/LookInside/Introduction/Intro.html#//apple_ref/doc/uid/TP40014643
 - https://developer.apple.com/library/content/samplecode/CustomTransitions/Introduction/Intro.html#//apple_ref/doc/uid/TP40015158
 */


import UIKit

class PresentationController: UIPresentationController {
    
    private let dimmingView = UIView()
    private let targetEdge: UIRectEdge

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, targetEdge: UIRectEdge) {
        self.targetEdge = targetEdge

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        // Set dimming view transparency
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        // Add a tap gesture recognizer for dimming view in order to dismiss the panel view controller
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedViewController))
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
        
        // Add pan gesture that will dismiss the panel view controller
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(interactivelyDismissPresentedViewController))
        dimmingView.addGestureRecognizer(panGestureRecognizer)

        // Add screen edge pan gesture that will dismiss panel view controller
        let screenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(interactivelyDismissPresentedViewController))
        var dismissalTargetEgde: UIRectEdge {
            switch targetEdge {
            case .top: return .bottom
            case .bottom: return .top
            case .left: return .right
            case .right: return .left
            default: fatalError()
            }
        }
        screenEdgePanGestureRecognizer.edges = dismissalTargetEgde
        dimmingView.addGestureRecognizer(screenEdgePanGestureRecognizer)
    }
    
    // MARK: - User interaction
    
    /**
     Selector linked to tapGestureRecognizer that will proceed a non-interactive dismiss of the view controller
     */
    @objc
    private func dismissPresentedViewController(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // Before to dismiss the presented view controller, we have to reset the transition delagate properties
            guard let transitionDelegate = presentedViewController.transitioningDelegate as? TransitionDelegate else { return }
            transitionDelegate.gestureRecognizer = nil
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }

    /**
     Selector linked to screenEdgePanGestureRecognizer & panGestureRecognizer that will proceed a interactive dismiss of the view controller
     */
    @objc
    private func interactivelyDismissPresentedViewController(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            // Before to dismiss the presented view controller, we have to reset the transition delagate properties
            guard let transitionDelegate = presentedViewController.transitioningDelegate as? TransitionDelegate else { return }
            transitionDelegate.gestureRecognizer = sender
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    // The frame rectangle to assign to the presented view at the end of the animations.
    override var frameOfPresentedViewInContainerView: CGRect {
        // return a controller that has the appropriate width and has a lateral right origin
        guard let containerBounds = containerView?.bounds else { fatalError() }
        
        let presentedViewSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        let presentedViewOrigin: CGPoint
        switch targetEdge {
        case .top:
            presentedViewOrigin = CGPoint(x: 0, y: 0)
        case .bottom:
            presentedViewOrigin = CGPoint(x: 0, y: containerBounds.size.height - presentedViewSize.height)
        case .left:
            presentedViewOrigin = CGPoint(x: 0, y: 0)
        case .right:
            presentedViewOrigin = CGPoint(x: containerBounds.size.width - presentedViewSize.width, y: 0)
        default:
            fatalError()
        }

        return CGRect(origin: presentedViewOrigin, size: presentedViewSize)
    }
    
    override func containerViewWillLayoutSubviews() {
        // Before layout, make sure our dimmingView and presentedView have the correct frame
        // called when collectionTraits change
        dimmingView.frame = containerView!.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        switch targetEdge {
        case .top, .bottom:
            return CGSize(width: parentSize.width, height: parentSize.height / 2)
        case .left, .right:
            return CGSize(width: parentSize.width / 2, height: parentSize.height)
        default:
            fatalError()
        }
    }

    // Notifies an interested controller that the preferred content size of one of its children changed.
//    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
//        super.preferredContentSizeDidChange(forChildContentContainer: container)
//    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        dimmingView.alpha = 0.0
        containerView?.addSubview(dimmingView)
        
        let transition: (UIViewControllerTransitionCoordinatorContext) -> Void = { _ in self.dimmingView.alpha = 1.0 }
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: transition, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        let transition: (UIViewControllerTransitionCoordinatorContext) -> Void = { _ in self.dimmingView.alpha = 0.0 }
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: transition, completion: nil)
    }
    
}
