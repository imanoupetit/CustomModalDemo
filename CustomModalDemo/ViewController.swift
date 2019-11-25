//
//  ViewController.swift
//  RightPanel
//
//  Created by Imanou Petit on 12/01/2017.
//  Copyright © 2017 Imanou Petit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Delegate for custom transition
    lazy var transitionDelegate: TransitionDelegate = TransitionDelegate(targetEdge: .bottom)

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true

        let button = UIButton(type: .system)
        button.setTitle("present", for: .normal)
        button.addTarget(self, action: #selector(presentPanelViewController), for: .touchUpInside)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        let gestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(presentInteractivelyPanelViewController))
        gestureRecognizer.edges = transitionDelegate.targetEdge
        view.addGestureRecognizer(gestureRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        performSegue(withIdentifier: "ShowPanel", sender: nil)
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        UIRectEdge.all
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - User interaction

    @objc
    private func presentPanelViewController(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowPanel", sender: sender)
    }

    @objc
    private func presentInteractivelyPanelViewController(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .began {
            performSegue(withIdentifier: "ShowPanel", sender: sender)
        }
    }

    // If you know you don’t need to return nil, the return type can be non-optional.
    // If you return nil from the method, UIKit falls back to calling the init(coder:) method to create the view controller
    @IBSegueAction
    func showPanelViewController(coder: NSCoder, sender: Any?, segueIdentifier: String?) -> PanelViewController? {
        if segueIdentifier == "ShowPanel" {
            transitionDelegate.gestureRecognizer = sender as? UIScreenEdgePanGestureRecognizer
            let panelViewController = PanelViewController(coder: coder)
            panelViewController?.transitioningDelegate = transitionDelegate
            panelViewController?.modalPresentationStyle = .custom
            return panelViewController
        }
        return nil
    }

    // MARK: - Navigation
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowPanel2" {
//            transitionDelegate.gestureRecognizer = sender as? UIScreenEdgePanGestureRecognizer
//            let panelViewController = segue.destination as! PanelViewController
//            panelViewController.transitioningDelegate = transitionDelegate
//            panelViewController.modalPresentationStyle = .custom
//        }
//    }

}
