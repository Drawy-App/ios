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
        UITableViewDataSource, UINavigationControllerDelegate
{
    
    var previews: [Int: [UIImage]] = [:]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Levels.sharedInstance.stages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Levels.sharedInstance.stages[section + 1]!.levels.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "stageHeader") as! MoreCaptionTableViewCell
        header.captionLabel.text = NSLocalizedString("STAGE_NAME", comment: "Stage name").uppercased() +
            " \(section + 1)"
        let stage = Levels.sharedInstance.stages[section + 1]!
        header.contentView.layer.opacity = stage.isUnlocked ? 1 : 0.5
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "levelCell") as! LevelsTableViewCell
        
        let stage = Levels.sharedInstance.stages[indexPath.section + 1]!
        let level = stage.levels[indexPath.row]
        cell.level = level
        cell.previewView.image = previews[indexPath.section + 1]![indexPath.row]
        cell.indexPath = indexPath
        cell.tableView = tableView
        
        cell.cellView.layer.opacity = stage.isUnlocked ? 1 : 0.5
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "showDetails" {
            let destVC = segue.destination as! DetailsViewController
            let indexPath = self.LevelsList.indexPathForSelectedRow!
            destVC.level = Levels.sharedInstance
                .stages[indexPath.section + 1]!.levels[indexPath.row]
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
        LevelsList.backgroundView = nil
        LevelsList.backgroundColor = .clear
        LevelsList.contentInset = .init(top: 20, left: 0, bottom: 0, right: 0)
        
        print("total stars", Levels.sharedInstance.totalStars)
        for stage in Levels.sharedInstance.stages {
            previews[stage.key] = stage.value.levels.map {level in
                UIImage.init(named: level.preview)!
            }
            print("stage", stage.value.number, stage.value.isUnlocked)
        }
        
        // Do any additional setup after loading the view.
//        self.navigationController!.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.LevelsList.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Analytics.sharedInstance.navigate("main", params: [
            "levels": [
                "done": Levels.sharedInstance.data.filter {level in level.rating > 0}
                    .map { $0.name },
                "undone": Levels.sharedInstance.data.filter {level in level.rating == 0}
                    .map { $0.name }
            ],
            "levels_count": [
                "done": Levels.sharedInstance.data.filter {level in level.rating > 0}.count,
                "undone": Levels.sharedInstance.data.filter {level in level.rating == 0}.count
            ]
            ]
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
