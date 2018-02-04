//
//  MainScreenViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 13.01.18.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class MainScreenViewController:
        UIViewController, UITableViewDelegate,
        UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return Levels.sharedInstance.data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 10 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "levelCell") as! LevelsTableViewCell
        let data = Levels.sharedInstance.data[indexPath.section]
        cell.level = data
        cell.indexPath = indexPath
        cell.tableView = tableView
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "showDetails" {
            let destVC = segue.destination as! DetailsViewController
            destVC.level = Levels.sharedInstance.data[self.LevelsList.indexPathForSelectedRow!.section]
        }
        
    }

    @IBOutlet weak var LevelsList: UITableView!
    @IBOutlet weak var appTitleLable: UILabel!
    @IBOutlet weak var appSubTitleLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appTitleLable.text = NSLocalizedString("APP_TITLE", comment: "App title")
        self.appSubTitleLable.text = NSLocalizedString("APP_SUBTITLE", comment: "App title")
        LevelsList.delegate = self
        LevelsList.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.LevelsList.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
