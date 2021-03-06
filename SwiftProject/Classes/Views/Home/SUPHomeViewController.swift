//
//  SUPHomeViewController.swift
//  SwiftProject
//
//  Created by NShunJian on 2018/7/2.
//  Copyright © 2018年 superMan. All rights reserved.
//

import UIKit
import MJRefresh
//  重用标记
private let HomeTableViewCellIdentifier = "HomeTableViewCellIdentifier"

class SUPHomeViewController: SUPVisitorViewControlle {
    
    /*
     这里就是 MVVM中  view|controller 引用 viewModel  private lazy var statusListViewModel: SUPStatusListViewModel = SUPStatusListViewModel()
     */
    
    //  使用懒加载方式创建所需要的ViewModel
    private lazy var statusListViewModel: SUPStatusListViewModel = SUPStatusListViewModel()
    //  系统的下拉刷新控件
    private lazy var refreshCtr: UIRefreshControl = {
        
        let ctr = UIRefreshControl()
        ctr.addTarget(self, action: #selector(SUPHomeViewController.pullDownRefresh), for: .valueChanged)
        return ctr
    }()
    //  风火轮
    private lazy var pullUpView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        view.color = UIColor.red
        return view
    }()
    private lazy var tipLabel : UILabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        //        tableView.translatesAutoresizingMaskIntoConstraints = false
       
        if isLogin {
            //  设置tableview相关操作
            setupHeaderView()
            setupFooterView()
            setupTableView()
            //  登陆成功
            loadData(isPullup: false)
        } else {
            visitorView?.updateVisitorViewInfo(message: nil, imageName: nil)
            
        }
       
         //设置提示的Label
        setupTipLabel()
    }
    
    //  设置tableView相关操作
    private func setupTableView() {
        //  注册cell
        tableView.register(SUPStatusTableViewCell.self, forCellReuseIdentifier: HomeTableViewCellIdentifier)
        //  设置行高
        //  自动计算行高
        //  根据contentView的最大y值作为cell的高度
        tableView.rowHeight = UITableViewAutomaticDimension
        //  预估高度 ,  如果不显示cell那么高度就是预估的高度,让其滚动起来,当显示cell的时候在去计算
        tableView.estimatedRowHeight = 200
        //  去掉分割线
        tableView.separatorStyle = .none
        /*
         //  添加上拉刷新控件
         tableView.tableFooterView = pullUpView
         //  指定大小
         pullUpView.sizeToFit()
         //  添加系统下拉刷新的方式1
         //        self.refreshControl = refreshCtr
         //  添加系统下拉刷的方式2
         tableView.addSubview(refreshCtr)
         */
        
    }
    
    //  加载微博数据
    private func loadData(isPullup : Bool) {
        
        statusListViewModel.loadData(isPullup: isPullup) { (isSuccess, message) -> () in
            //这个配合系统使用的
            //   self.endRefreshing()
            
            let time: TimeInterval = 1.0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                //code
                
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
                // self.tableView.mj_footer.endRefreshingWithNoMoreData()
                // 显示提示的Label
                if isPullup == false {
                     //  开启tip动画
                    self.showTipLabel(message: message)
                }
//                self.showTipLabel(message: message)
            }
            if isSuccess {
                //  数据请求成功重写刷新数据
                self.tableView.reloadData()
                
            } else {
                SUPLog("数据请求异常")
            }
        }
    }
    
    /// 显示提示的Label
    private func showTipLabel(message : String) {
        //  判断视图如果显示表示正在执行动画,让其直接返回不执行下面的代码
        if tipLabel.isHidden == false {
            return
        }
        
        // 1.设置tipLabel的属性
        tipLabel.isHidden = false
        tipLabel.text = message
        
//        // 6.动画
        let duration = 0.75;
//        //label.alpha = 0.0;
        UIView.animate(withDuration: duration, animations: {
            self.tipLabel.transform = CGAffineTransform(translationX: 0, y: self.tipLabel.frame.size.height)
        }) { (_) in  // 向下移动完毕
            //延迟delay秒后，再执行动画
             let delay = 1.0;
            UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                 // 恢复到原来的位置
                self.tipLabel.transform = CGAffineTransform.identity;
                //label.alpha = 0.0;
            }, completion: { (_) in
                // 删除控件
//                self.tipLabel.removeFromSuperview();
                self.tipLabel.isHidden = true
            })
        }

    }
    
    
    private func setupTipLabel() {
        // 1.将tipLabel添加父控件中
       
        // 2.设置tipLabel的frame
//        tipLabel.frame = CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: 32)
            tipLabel.frame = CGRect(x: 0, y: (navigationController?.navigationBar.frame.maxY)! - 32, width: UIScreen.main.bounds.width, height: 32)
        // 3.设置tipLabel的属性
        tipLabel.backgroundColor = UIColor.orange
        tipLabel.textColor = UIColor.white
        tipLabel.font = UIFont.systemFont(ofSize: 14)
        tipLabel.textAlignment = .center
        tipLabel.isHidden = true
//        navigationController?.navigationBar.insertSubview(tipLabel, at: 0)
        navigationController?.view.insertSubview(tipLabel, belowSubview: (navigationController?.navigationBar)!)
    }
}

extension SUPHomeViewController {
    //使用 MJRefresh
    private func setupHeaderView() {
        // 1.创建headerView
        let header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(SUPHomeViewController.loadNewStatuses))
        // 2.设置header的属性
        header?.setTitle("下拉刷新", for: .idle)
        header?.setTitle("释放更新", for: .pulling)
        header?.setTitle("加载中...", for: .refreshing)
        
        // 3.设置tableView的header
        
        tableView.mj_header = header
        
        
        // 4.进入刷新状态
        tableView.mj_header.beginRefreshing()
    }
    
    private func setupFooterView() {
        
        //        tableView.mj_footer = MJRefreshAutoFooter.init(refreshingTarget: self, refreshingAction: #selector(SUPHomeViewController.loadMoreStatuses))
        
        let footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(SUPHomeViewController.loadMoreStatuses))
        
        footer?.setTitle("上拉刷新", for: .idle)
        footer?.setTitle("释放更新", for: .pulling)
        footer?.setTitle("加载中...", for: .refreshing)
        
        tableView.mj_footer = footer
        
    }
    
}

extension SUPHomeViewController {
    /// 加载最新的数据
    @objc private func loadNewStatuses() {
        
        loadData(isPullup: false)
    }
    
    /// 加载最新的数据
    @objc private func loadMoreStatuses() {
        
        loadData(isPullup: true)
    }
    
    
    //  结束刷新的方法
    private func endRefreshing() {
        //  停止菊花转
        pullUpView.stopAnimating()
        //  结束系统下拉刷新的状态
        refreshCtr.endRefreshing()
        //  结束自定义下拉刷新的状态
        //        pullDownView.endRefreshing()
        
    }
    @objc private func pullDownRefresh() {
        
        
        //  加载下拉刷新的数据
        //        //  延时两秒回调
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(),{ () -> Void in
        //            self.refreshCtr.endRefreshing()
        //        })
        
        //        loadData()
        
        
        
    }
}

//  MARK: - UITableViewDataSource 数据源代理
extension SUPHomeViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusListViewModel.statusList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCellIdentifier, for: indexPath) as! SUPStatusTableViewCell
        
        /*
         这里就是 MVVM中  viewModel 绑定数据 给 view|controller
         */
        //  给cell绑定数据
        cell.statusViewModel = statusListViewModel.statusList[indexPath.row]
        
        // 取消选中颜色
        cell.selectionStyle = .none
        return cell
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == statusListViewModel.statusList.count - 1 && !pullUpView.isAnimating {
            SUPLog("已经是最后一天微博数据了")
            
            
            /*这是使用系统的 */
            
            //  开启风火轮
            //            pullUpView.startAnimating()
            //            //  加载更多数据
            //            loadData()
        }
    }
}




