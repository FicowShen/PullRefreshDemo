//
//  FSRefresh.swift
//  PullRefreshTest
//
//  Created by ficow on 2017/11/28.
//  Copyright © 2017年 ficow. All rights reserved.
//

import UIKit

var FSRefreshHeaderKey:UInt8 = 0
var FSRefreshHeaderBlockKey:UInt8 = 0
var FSRefreshFooterKey:UInt8 = 0
var FSRefreshFooterBlockKey:UInt8 = 0
let FSRefreshFooterBottomInset:CGFloat = 24
var FSRefreshFooterObserverKey:UInt8 = 0

extension UIScrollView{
    
    /// 刷新Header，重新加载
    var refreshHeader:UIRefreshControl?{
        return objc_getAssociatedObject(self, &FSRefreshHeaderKey) as? UIRefreshControl
    }
    /// 刷新Footer，加载更多
    var refreshFooter:FSFootRefresh?{
        return objc_getAssociatedObject(self, &FSRefreshFooterKey) as? FSFootRefresh
    }
    
    // MARK: - Setup Header
    /// 设置刷新Header
    ///
    /// - Parameter block: 刷新开始时的回调
    func setupRefreshHeaderWithBlock(_ block:(() -> Void)?){
        
        // 移除旧的
        if let header = refreshHeader{
            header.removeFromSuperview()
        }
        // 添加RefreshControl
        let refreshControl = UIRefreshControl.init()
        self.addSubview(refreshControl)
        objc_setAssociatedObject(self, &FSRefreshHeaderKey, refreshControl, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        // 监测RefreshControl状态
        refreshControl.addTarget(self, action: #selector(headerRefreshStateChanged), for: UIControlEvents.valueChanged)
        
        // 添加Block
        objc_setAssociatedObject(self, &FSRefreshHeaderBlockKey, block, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    @objc func headerRefreshStateChanged(){
        if let header = refreshHeader{
            if let block = objc_getAssociatedObject(self, &FSRefreshHeaderBlockKey) as? (() -> Void)
                ,header.isRefreshing{
                block()
            }
        }
    }
    /// 停止Header刷新
    func endHeaderRefreshing(){
        refreshHeader?.endRefreshing()
    }
    // MARK: - Setup Footer
    func setupRefreshFooterWithBlock(_ block:(() -> Void)?){
        // 移除旧的
        if let footer = refreshFooter{
            footer.removeFromSuperview()
        }
        // 添加RefreshControl
        let footer = FSFootRefresh.init()
        // 添加约束布局
        footer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(footer)
        NSLayoutConstraint.activate([
            footer.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
            footer.centerXAnchor.constraint(equalTo: self.layoutMarginsGuide.centerXAnchor),
            footer.heightAnchor.constraint(equalToConstant: 44),
            footer.widthAnchor.constraint(equalToConstant: self.frame.width)
            ])
        objc_setAssociatedObject(self, &FSRefreshFooterKey, footer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        // 监测RefreshControl状态
        footer.addTarget(self, action: #selector(footerRefreshStateChanged), for: UIControlEvents.valueChanged)
        // 添加Block
        objc_setAssociatedObject(self, &FSRefreshFooterBlockKey, block, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        // 监测ScrollView是否滑动到底部
        let observer = self.observe(\.contentOffset) { (scrollView, dict) in
            let y = scrollView.contentOffset.y
            let bottom = scrollView.contentSize.height - scrollView.frame.height + 2
            if y > bottom{
                self.beginFooterRefreshing()
            }
        }
        objc_setAssociatedObject(self, &FSRefreshFooterObserverKey, observer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    /// Footer状态改变，执行Footer刷新对应的Block
    @objc func footerRefreshStateChanged(){
        
        if let footer = refreshFooter{
            if let block = objc_getAssociatedObject(self, &FSRefreshFooterBlockKey) as? (() -> Void)
                ,footer.isRefreshing{
                block()
            }
        }
    }
    /// 开始Footer刷新
    private func beginFooterRefreshing(){
        
        if let footer = refreshFooter,footer.isRefreshing{
            return
        }
        refreshFooter?.beginRefreshing()
        let inset = self.contentInset
        self.contentInset = UIEdgeInsetsMake(inset.top, inset.left, inset.bottom + FSRefreshFooterBottomInset, inset.right)
    }
    /// 停止Footer刷新
    func endFooterRefreshing(){
        
        if let footer = refreshFooter,footer.isRefreshing{
            footer.endRefreshing()
            let inset = self.contentInset
            self.contentInset = UIEdgeInsetsMake(inset.top, inset.left, inset.bottom - FSRefreshFooterBottomInset, inset.right)
        }
    }
}

/// 底部刷新控件
class FSFootRefresh: UIControl {
    
    var isRefreshing:Bool = false
    private let indicator:UIActivityIndicatorView = UIActivityIndicatorView.init()
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    private func setup(){
        indicator.activityIndicatorViewStyle = .gray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ])
        indicator.hidesWhenStopped = true
    }
    func beginRefreshing(){
        if !isRefreshing{
            isRefreshing = true
            indicator.startAnimating()
            self.sendActions(for: UIControlEvents.valueChanged)
        }
    }
    func endRefreshing(){
        if isRefreshing{
            indicator.stopAnimating()
            isRefreshing = false
            self.sendActions(for: UIControlEvents.valueChanged)
        }
    }
}
