//
//  DynamicTestVC.swift
//  PullRefreshTest
//
//  Created by ficow on 2017/11/28.
//  Copyright © 2017年 ficow. All rights reserved.
//

import UIKit

class DynamicTestVC: UIViewController {
    
    var myTV: UITableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.grouped)
    
    let FootRefreshBottomInset:CGFloat = 24
    let DefaultCellCount = 20
    var cellCount = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "DynamicTest"
        view.backgroundColor = UIColor.white
        setupTV()
    }
    func setupTV(){
        
        view.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        
        myTV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(myTV)
        NSLayoutConstraint.activate([
            myTV.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            myTV.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myTV.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            myTV.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        myTV.backgroundColor = UIColor.white
        myTV.register(UITableViewCell.self, forCellReuseIdentifier: CellID)
        myTV.delegate = self
        myTV.dataSource = self
        
        myTV.setupRefreshHeaderWithBlock { [weak self] in
            self?.refresh()
        }
        myTV.setupRefreshFooterWithBlock { [weak self] in
            self?.loadmore()
        }
    }
    func refresh(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
            self.myTV.endHeaderRefreshing()
        }
    }
    func loadmore(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
            self.cellCount += self.DefaultCellCount
            self.myTV.reloadData()
            self.myTV.endFooterRefreshing()
        }
    }
}

extension DynamicTestVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID)!
        cell.textLabel?.text = "dynamic \(indexPath.row)"
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let stvc = SystemTableViewController()
        self.navigationController?.pushViewController(stvc, animated: true)
    }
}

