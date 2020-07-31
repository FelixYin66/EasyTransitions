//
//  ModalTransitionDelegate.swift
//  EasyTransitions
//
//  Created by Marcos Griselli on 07/04/2018.
//

import Foundation
import UIKit

/*
 
 实现UIViewControllerTransitioningDelegate 协议，转场动画的第一步
 
 */
open class ModalTransitionDelegate: NSObject {

    private var animators = [ModalOperation: ModalTransitionAnimator]()
    private let interactiveController = TransitionInteractiveController()
    private var presentationController: UIPresentationController?
    
    open func wire(viewController: UIViewController,
                   with pan: Pan,
                   navigationAction: @escaping () -> Void,
                   beginWhen: @escaping (() -> Bool) = { return true }) {
        interactiveController.wireTo(viewController: viewController, with: pan)
        interactiveController.navigationAction = navigationAction
        interactiveController.shouldBeginTransition = beginWhen
    }

    //按照key保存Animator
    open func set(animator: ModalTransitionAnimator, for operation: ModalOperation) {
        animators[operation] = animator
    }
    
    //移除Animator
    open func removeAnimator(for operation: ModalOperation) {
        animators.removeValue(forKey: operation)
    }
    
    open func set(presentationController: UIPresentationController?) {
        self.presentationController = presentationController
    }
    
    //配置present 与 dismiss情况下动画 ModalTransitionConfigurator 实现协议UIViewControllerAnimatedTransitioning
    private func configurator(for operation: ModalOperation) -> ModalTransitionConfigurator? {
        guard let animator = animators[operation] else {
            return nil
        }
        return ModalTransitionConfigurator(transitionAnimator: animator)
    }
}

//实现UIViewControllerTransitioningDelegate 代理
extension ModalTransitionDelegate: UIViewControllerTransitioningDelegate {
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return configurator(for: .present)
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return configurator(for: .dismiss)
    }
    
    //交互式动画
    open func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveController.interactionInProgress ? interactiveController : nil
    }
    
    open func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveController.interactionInProgress ? interactiveController : nil
    }
    
    open func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return presentationController
    }
}
