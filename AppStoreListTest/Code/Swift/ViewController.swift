//
//  ViewController.swift
//  AppStoreListTest
//
//  Created by 罗泰 on 2018/8/24.
//  Copyright © 2018年 chenwang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //MARK: - 属性
    @IBOutlet var listView: UITableView!
    
    let colors = [UIColor.red,
                  UIColor.orange,
                  UIColor.yellow,
                  UIColor.green,
                  UIColor.blue,
                  UIColor.cyan,
                  UIColor.purple]
    
    let imgNames = ["1.jpg",
                    "2.jpg",
                    "3.jpg",
                    "4.jpg",
                    "5.jpg",
                    "6.jpg",
                    "7.jpg"]
    
    let transitionDelegate = PresentAnimationDelegate.init()
    
    //MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.listView.showsVerticalScrollIndicator = false
        self.listView.tableFooterView = UIView.init()
        self.listView.backgroundColor = self.view.backgroundColor
        self.listView.separatorStyle = .none
        self.listView.register(TableViewCell.classForCoder(), forCellReuseIdentifier: "cellId")
        self.listView.showsVerticalScrollIndicator = false
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        cell.startAnimation()
        return true
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        cell.endAnimation()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)!
        let nextVC = NextViewController.init(color: self.colors[indexPath.section], bgView: self.imageFromView)
        nextVC.imgName = self.imgNames[indexPath.section]
        self.transitionDelegate.animationWith(presented: self,
                                              presenting: nextVC,
                                              cell: tableView.cellForRow(at: indexPath)!, cellFrame: self.view.convert(cell.frame, from: cell.superview!), complete: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.colors.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.selectionStyle = .none
        cell.layer.cornerRadius = 8.0
        cell.layer.masksToBounds = true
        var imgView = cell.contentView.viewWithTag(999) as? UIImageView
        if imgView == nil {
            imgView = UIImageView.init(frame: cell.contentView.bounds)
            imgView?.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(imgView!)
            
            let views = ["imgView" : imgView!]
            var str = "H:|-0-[imgView]-0-|"
            cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: str, options: [], metrics: nil, views: views))
            str = "V:|-0-[imgView]-0-|"
            cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: str, options: [], metrics: nil, views: views))
            
            imgView?.tag = 999
            imgView?.contentMode = .scaleAspectFill
            imgView?.backgroundColor = UIColor.groupTableViewBackground
            
            imgView?.layer.cornerRadius = 8.0
            imgView?.layer.masksToBounds = true
        }
        imgView!.image = UIImage.init(named: self.imgNames[indexPath.section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 380
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    var imageFromView: UIImageView {
        UIGraphicsBeginImageContext(self.view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        self.view.layer.render(in: context!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imgView = UIImageView.init(frame: self.view.bounds)
        imgView.image = img

        let effect = UIBlurEffect.init(style: .light)
        let effectView = UIVisualEffectView.init(effect: effect)
        effectView.frame = imgView.bounds
        imgView.addSubview(effectView)
        
        return imgView
    }
}

