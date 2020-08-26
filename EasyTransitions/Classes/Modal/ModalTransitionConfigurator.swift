//
//  ModalTransitionConfigurator.swift
//  EasyTransitions
//
//  Created by Marcos Griselli on 07/04/2018.
//

import UIKit

/*
 
 动画实现UIViewControllerAnimatedTransitioning 协议
 
 */

@available(iOS 10.0, *)
final class ModalTransitionConfigurator: NSObject, UIViewControllerAnimatedTransitioning {

    private let transitionAnimator: ModalTransitionAnimator

    public init(transitionAnimator: ModalTransitionAnimator) {
        self.transitionAnimator = transitionAnimator
    }
    
    //动画时长
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionAnimator.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionAnimator(using: transitionContext).startAnimation()
    }
    
     private func transitionAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        
        let containerView = transitionContext.containerView
        let isPresenting = (toViewController.presentingViewController === fromViewController)

        let modalView: UIView
        if transitionContext.responds(to: #selector(UIViewControllerContextTransitioning.view(forKey:))) {
            let key: UITransitionContextViewKey = isPresenting ? .to : .from
            modalView = transitionContext.view(forKey: key)!
        } else {
            modalView = isPresenting ? toViewController.view : fromViewController.view
        }

        transitionAnimator.layout(presenting: isPresenting, modalView: modalView, in: containerView)
        
        let duration = transitionDuration(using: transitionContext)
        
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.8)
        animator.addAnimations {
            self.transitionAnimator.animate(presenting: isPresenting,
                                            modalView: modalView, in: containerView)
        }

        //动画结束
        animator.addCompletion { position in
            switch position {
            case .end:
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                if isPresenting {
                    self.transitionAnimator.onPresented?()
                } else {
                    self.transitionAnimator.onDismissed?()
                }
            default:
                self.transitionAnimator.animate(presenting: !isPresenting,
                                                modalView: modalView,
                                                in: containerView)
                transitionContext.completeTransition(false)
            }
        }
        animator.isUserInteractionEnabled = true
        
        return animator
    }
    
    //动画中断
    public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return transitionAnimator(using: transitionContext)
    }
}
