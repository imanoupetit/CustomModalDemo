
import UIKit

/* Sources:
 - https://developer.apple.com/library/ios/samplecode/LookInside/Introduction/Intro.html#//apple_ref/doc/uid/TP40014643
 - https://developer.apple.com/library/content/samplecode/CustomTransitions/Introduction/Intro.html#//apple_ref/doc/uid/TP40015158
 */

class PanTransitionController: UIPercentDrivenInteractiveTransition {
    
    private var transitionContext: UIViewControllerContextTransitioning?
    private let gestureRecognizer: UIPanGestureRecognizer
    private let targetEdge: UIRectEdge

    private override init() {
        fatalError("init() has not been implemented")
    }
    
    init(gestureRecognizer: UIPanGestureRecognizer, edgeForDragging targetEdge: UIRectEdge) {
        // Early escape if edges is of type `All` or `None`
        // gestureRecognizer should be a subset of [.top, .bottom, .left, .right] but not an exact copy (definition of strict subset)
        assert(targetEdge.isStrictSubset(of: [.top, .bottom, .left, .right]), "edgeForDragging must be one of UIRectEdge.top, .bottom, .left or .right.")

        self.gestureRecognizer = gestureRecognizer
        self.targetEdge = targetEdge

        super.init()

        gestureRecognizer.addTarget(self, action: #selector(updateTransition))
    }

    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)

        // Save the transitionContext for later
        self.transitionContext = transitionContext
    }
    
    // MARK: - Custom methods


    @objc
    private func updateTransition(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            // The Began state is handled by the view controllers. In response to the gesture recognizer transitioning to this state, they will trigger the presentation or dismissal
            break
        case .changed:
            // We have been dragging! Update the transition context accordingly
            update(percentForGesture(gestureRecognizer))
        case .ended:
            // Dragging has finished. Complete or cancel, depending on how far we've dragged
            percentForGesture(gestureRecognizer) >= 0.5 ? finish() : cancel()
        default:
            // Something happened. cancel the transition
            cancel()
        }
    }

    /**
     Returns the offset of the pan gesture recognizer from the edge of the screen as a percentage of the transition container view's width or height. This is the percent completed for the interactive transition.
     */
    private func percentForGesture(_ gesture: UIPanGestureRecognizer) -> CGFloat {
        guard let view = gesture.view else { return 0 }

        // Return an appropriate percentage from gesture's translationInView
        let translation = gesture.translation(in: view)

        switch targetEdge {
        case .top:
            return (1 - translation.y) / view.bounds.height
        case .bottom:
            return translation.y / view.bounds.height
        case .left:
            return (1 - translation.x) / view.bounds.width
        case .right:
            return translation.x / view.bounds.width
        default:
            return 0
        }
    }
    
}
