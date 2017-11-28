//
//  ViewController.swift
//  PullRefreshTest
//
//  Created by ficow on 2017/11/25.
//  Copyright © 2017年 ficow. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var myTV: UITableView!
    let headRefresh:UIRefreshControl = UIRefreshControl.init()
    let footRefresh:FSFootRefresh = FSFootRefresh.init()
    
    let FootRefreshBottomInset:CGFloat = 24
    let DefaultCellCount = 20
    var cellCount = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "PullRefreshTest"
        setupTV()
        setupRefreshControl()
    }
    func setupTV(){
        
        myTV.register(UITableViewCell.self, forCellReuseIdentifier: CellID)
    }
    func setupRefreshControl(){
        myTV.translatesAutoresizingMaskIntoConstraints = false
        headRefresh.translatesAutoresizingMaskIntoConstraints = false
        myTV.addSubview(headRefresh)
        
        footRefresh.translatesAutoresizingMaskIntoConstraints = false
        myTV.addSubview(footRefresh)
        myTV.sendSubview(toBack: footRefresh)
        NSLayoutConstraint.activate([
            footRefresh.bottomAnchor.constraint(equalTo: myTV.layoutMarginsGuide.bottomAnchor),
            footRefresh.centerXAnchor.constraint(equalTo: myTV.layoutMarginsGuide.centerXAnchor),
            footRefresh.heightAnchor.constraint(equalToConstant: 44),
            footRefresh.widthAnchor.constraint(equalToConstant: self.view.frame.width)
            ])
    }
    func beginRefreshing(){
        
        headRefresh.beginRefreshing()
    }
    func endRefreshing(){
        cellCount = DefaultCellCount
        headRefresh.endRefreshing()
        myTV.reloadData()
    }
    func beginLoadingMore(){
        footRefresh.beginRefreshing()
        let inset = myTV.contentInset
        myTV.contentInset = UIEdgeInsetsMake(inset.top, inset.left, inset.bottom + FootRefreshBottomInset, inset.right)
    }
    func endLoadingMore(){
        cellCount += DefaultCellCount
        footRefresh.endRefreshing()
        let inset = myTV.contentInset
        myTV.reloadData()
        myTV.contentInset = UIEdgeInsetsMake(inset.top, inset.left, inset.bottom - FootRefreshBottomInset, inset.right)
    }
}

let CellID:String = "cell"

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID)!
        cell.textLabel?.text = "static \(indexPath.row)"
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < 10{
            let vc = DynamicTestVC()
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        let stvc = SystemTableViewController()
        self.navigationController?.pushViewController(stvc, animated: true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y > scrollView.contentSize.height - scrollView.frame.height + 4{
            if !footRefresh.isRefreshing{
                beginLoadingMore()
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if headRefresh.isRefreshing{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                self.endRefreshing()
            })
        }
        if footRefresh.isRefreshing{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                self.endLoadingMore()
            })
        }
    }
}

