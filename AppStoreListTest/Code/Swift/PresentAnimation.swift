//
//  PresentAnimation.swift
//  AppStoreListTest
//
//  Created by 罗泰 on 2018/8/24.
//  Copyright © 2018年 chenwang. All rights reserved.
//

import UIKit

class PresentAnimationDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    weak var cell: UITableViewCell?
    var cellFrame: CGRect = CGRect.zero
    var presentingVC: NextViewController?
    func animationWith(presented: UIViewController, presenting: UIViewController, cell: UITableViewCell, cellFrame: CGRect, complete: ((Bool)-> Void)?) {
        self.cell = cell
        self.cellFrame = cellFrame
        presenting.transitioningDelegate = self
        self.presentingVC = presenting as? NextViewController
        presented.present(presenting, animated: true) {
            complete?(true)
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimation.init(presentType: .presenting, cell: self.cell!, cellFrame: self.cellFrame)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimation.init(presentType: .presented, cell: self.cell!, cellFrame: self.cellFrame)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return self.presentingVC!.test
        return nil
        
    }
}

class PresentAnimation: NSObject {
    
    enum PresentAnimationType {
        case presented, presenting
    }
    
    weak var cell: UITableViewCell!
    
    //MARK: - 属性
    let presentType: PresentAnimationType
    let cellFrame: CGRect
    //MARK: - 构造方法
    init(presentType: PresentAnimationType, cell: UITableViewCell, cellFrame: CGRect) {
        self.presentType = presentType
        self.cellFrame = cellFrame
        self.cell = cell
        super.init()
    }
}

//MARK: - 转场动画代理
extension PresentAnimation: UIViewControllerAnimatedTransitioning {
    
    var timeInterval: TimeInterval {
        return 1
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return timeInterval
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch self.presentType {
        case .presenting:
            self.presenting(transitionContext)
        case .presented:
            self.presented(transitionContext)
        }
    }
    
    fileprivate func presenting(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as? ViewController
        let toVC = transitionContext.viewController(forKey: .to) as? NextViewController
        
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        guard fromVC != nil, toVC != nil else {
            return
        }
        
        guard fromView != nil, toView != nil else {
            return
        }
        let animationView = transitionContext.containerView
        
        // 2.添加toView
        animationView.addSubview(toView!)
        
        // 3.toView动画前frame
        let rect = fromVC!.listView.convert(self.cell.frame, to: fromView!)
        toVC!.contentView.frame = rect
        toVC!.contentView.layer.cornerRadius = 8.0
        toVC!.contentView.layer.masksToBounds = true
        
        // 4.开始动画
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [], animations: {
            self.cell.contentView.isHidden = true
            animationView.layoutIfNeeded()
            toVC!.contentView.frame = CGRect.init(x: 30, y: 60, width: fromView!.frame.width - 60, height: fromView!.frame.height - 120)
        }) { (finish) in
            UIView.animate(withDuration: self.timeInterval - 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [.curveLinear], animations: {
                animationView.layoutIfNeeded()
                toVC!.contentView.frame = fromView!.frame
                toVC!.contentView.layer.cornerRadius = 0.0
                toVC!.contentView.layer.masksToBounds = true
            }, completion: { (finish) in
                self.cell.contentView.isHidden = false
                if finish && !transitionContext.transitionWasCancelled
                {
                    transitionContext.completeTransition(true)
                }
                else
                {
                    toView!.removeFromSuperview()
                    fromView!.isHidden = false
                    transitionContext.completeTransition(false)
                }
            })
        }
    }
    
    fileprivate func presented(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as? NextViewController
        let toVC = transitionContext.viewController(forKey: .to) as? ViewController
        
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        guard fromVC != nil, toVC != nil else {
            return
        }
        
        guard fromView != nil, toView != nil else {
            return
        }
        
        let animationView = transitionContext.containerView
        toView?.frame = animationView.convert(fromView!.frame, from: fromView!.superview!)
        animationView.addSubview(toView!)
        animationView.bringSubview(toFront: fromView!)
//
////        // 3.toView动画前frame
        let rect = self.cellFrame
        self.cell.alpha = 0.0
        fromVC!.bgView.alpha = 0.0
        fromView?.backgroundColor = UIColor.clear
        UIView.animate(withDuration: self.timeInterval - 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [.curveLinear], animations: {
            animationView.layoutIfNeeded()
            fromVC!.contentView.layer.cornerRadius = 8.0
            fromVC!.contentView.layer.masksToBounds = true
            fromVC!.backButton.alpha = 0.0
            fromVC!.contentView.frame = rect
            fromVC!.topView.frame = CGRect.init(x: 0, y: 0, width: rect.width, height: rect.height)
            fromVC!.topView.layer.cornerRadius = 8.0
            fromVC!.topView.layer.masksToBounds = true
            fromVC?.listView.alpha = 0.0
        }, completion: { (finish) in
            if finish && !transitionContext.transitionWasCancelled
            {
                transitionContext.completeTransition(true)
            }
            else
            {
                toView!.removeFromSuperview()
                fromView!.isHidden = false
                transitionContext.completeTransition(false)
            }
            self.cell.alpha = 1.0
        })
    }
    
}

class InteractiveAnimator: UIPercentDrivenInteractiveTransition {
    
}
