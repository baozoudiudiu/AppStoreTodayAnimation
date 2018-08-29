//
//  NextViewController.swift
//  AppStoreListTest
//
//  Created by 罗泰 on 2018/8/24.
//  Copyright © 2018年 chenwang. All rights reserved.
//

import UIKit

var context1: Int = 1
var context2: Int = 2

class NextViewController: UIViewController
{
    //MARK: - 属性
    let test: InteractiveAnimator = InteractiveAnimator.init()
    var interaction: Bool = false
    let bgView: UIView
    let contentView = UIView.init(frame: CGRect.zero)
    
    lazy var listView: UITableView = {
        let view = UITableView.init(frame: self.view.bounds, style: .plain)
        view.delegate = self
        view.dataSource = self
        view.tableFooterView = UIView.init()
        view.contentInset = UIEdgeInsets.init(top: self.topView.frame.height, left: 0, bottom: 0, right: 0)
        view.scrollIndicatorInsets = UIEdgeInsets.init(top: self.topView.frame.height, left: 0, bottom: 0, right: 0)
        view.backgroundColor = UIColor.white
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }else {
            self.view.translatesAutoresizingMaskIntoConstraints = false
        }
        return view
    }()
    
    lazy var topView: UIImageView = {
        let frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 400)
        let view = UIImageView.init(frame: frame)
        view.backgroundColor = self.topViewColor
        view.contentMode = .scaleAspectFill
//        view.autoresizingMask = [.flexibleWidth]
        view.image = UIImage.init(named: self.imgName ?? "")
        self.contentView.addSubview(view)
        return view
    }()
    
    let topViewColor: UIColor
    var imgName: String?
    var panGes: UIPanGestureRecognizer?
    
    lazy var backButton: UIButton = {
        let button =  UIButton(type: .custom)
        let size = CGSize.init(width: 26, height: 26)
        button.frame = CGRect.init(x: self.view.bounds.width - size.width - 24, y: 30, width: size.width, height: size.height)
        button.setBackgroundImage(UIImage.init(named: "btn_close"), for: .normal)
        self.contentView.addSubview(button)
        button.autoresizingMask = [.flexibleLeftMargin]
        return button
    }()
    
    //MARK: - 生命周期
    init(color: UIColor, bgView: UIView) {
        self.topViewColor = color
        self.bgView = bgView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.topViewColor = UIColor.white
        self.bgView = UIView.init()
        super.init(coder: aDecoder)
    }
    
    deinit {
        self.listView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func loadData() {
        self.listView.reloadData()
        self.listView.contentOffset = CGPoint.init(x: 0, y: -400)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//MARK: - 界面视图
extension NextViewController
{
    fileprivate func configureUI() {
        self.view.addSubview(self.bgView)
        self.view.backgroundColor = UIColor.white
        
        self.contentView.frame = self.view.bounds
        self.view.addSubview(self.contentView)
        self.contentView.autoresizingMask = [.flexibleWidth]
        
        self.contentView.addSubview(self.listView)
        self.contentView.bringSubview(toFront: self.topView)
        self.contentView.bringSubview(toFront: self.backButton)
        self.backButton.addTarget(self,
                                  action: #selector(backButtonClick(_:)),
                                  for: .touchUpInside)
        self.listView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: nil)
        
        let pan = UIPanGestureRecognizer.init(target: self,
                                              action: #selector(panAction(_:)))
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
        self.view.isUserInteractionEnabled = true
        self.panGes = pan
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let value = change?[NSKeyValueChangeKey.newKey] as? CGPoint
        if let contentOffset = value {
            if contentOffset.y <= -400 {
                self.topView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 400)
            }else {
                var rect = self.topView.frame
                rect.origin.y = -contentOffset.y - 400
                self.topView.frame = rect
            }
        }
    }
}

// MARK: - 业务逻辑
extension NextViewController {
    @objc fileprivate func backButtonClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func panAction(_ pan: UIPanGestureRecognizer) {
       
        if self.listView.contentOffset.y <= -400
        {
            let present: CGFloat = self.getPresentWith(gesture: pan)
            if present == 0
            {
                return
            }
            switch pan.state
            {
            case .began:()
            case .changed:()
                let scale = 1 - 0.2 * present
                let corner = 8.0 * present
                if present < 0.9
                {
                    self.contentView.transform = CGAffineTransform.init(scaleX: scale, y: scale)
                    self.contentView.layer.cornerRadius = corner
                }
                else
                {
                    self.contentView.transform = CGAffineTransform.identity
                    self.contentView.layer.cornerRadius = 0
                    self.dismiss(animated: true, completion: nil)
                }
            case .ended:
                ///手势结束,关闭标记为false
                self.interaction = false
                if present >= 0.9
                {
                    self.contentView.transform = CGAffineTransform.identity
                    self.contentView.layer.cornerRadius = 0
                    self.dismiss(animated: true, completion: nil)
                }
                else
                {
                    self.contentView.transform = CGAffineTransform.identity
                }
                self.listView.isScrollEnabled = true
            default:
                self.contentView.transform = CGAffineTransform.identity
                self.listView.isScrollEnabled = true
            }
        }else {
            self.listView.isScrollEnabled = true
        }
    }
    
    ///计算手势百分比,用来更新动画的进度
    private func getPresentWith(gesture: UIPanGestureRecognizer) -> CGFloat{
        
        var present: CGFloat = 0
        
        let point = gesture.translation(in: self.view)
        
        let height = self.view.frame.size.height  * 0.26
        
        let y = point.y
        
        self.listView.isScrollEnabled = y<=0
        
        if y > 0
        {
            let final_y = y > 0 ? y : (y * -1)
            present = final_y / height
        }
        return present
    }
}

extension NextViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension NextViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        if cell == nil
        {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cellId")
        }
        cell?.textLabel?.text = String.init(format: "%ld", indexPath.row)
        return cell!
    }
}
