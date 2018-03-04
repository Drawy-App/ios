//
//  MainScreenViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 13.01.18.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class MainScreenViewController:
        UIViewController, UITableViewDelegate, UIScrollViewDelegate,
        UITableViewDataSource, UINavigationControllerDelegate
{
    
    var previews: [Int: [UIImage]] = [:]

    @IBOutlet var appTitleTap: UITapGestureRecognizer!
    @IBOutlet weak var LevelsList: UITableView!
    @IBOutlet weak var appTitleLable: UILabel!
    @IBOutlet weak var appSubTitleLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appTitleTap.addTarget(self, action: #selector(self.animatedScrollUp))
        
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
    
    func getStageIndex(_ section: Int) -> Int? {
        var firstUnlocked: Int? = nil
        for stage in Levels.sharedInstance.stages.sorted(by: {a, b in
            return a.key < b.key
        }) {
            if !stage.value.isUnlocked {
                firstUnlocked = stage.key
                break
            }
        }
        if firstUnlocked == nil {
            return section + 1
        }
        if section < firstUnlocked! - 1 {
            return section + 1
        }
        if section > firstUnlocked! - 1 {
            return section
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if Levels.sharedInstance.stages.filter({stage in
            return !stage.value.isUnlocked
        }).count == 0 {
            return Levels.sharedInstance.stages.count
        }
        return Levels.sharedInstance.stages.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let stageIndex = getStageIndex(section) else {
            return 0
        }
        
        return Levels.sharedInstance.stages[stageIndex]!.levels.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if getStageIndex(section) == nil {
            return 160
        }
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let stageIndex = getStageIndex(section) else {
            let header = tableView.dequeueReusableCell(withIdentifier: "moreImagesCell") as! MoreCaptionTableViewCell
            guard let nextStageIndex = getStageIndex(section + 1) else {
                return nil
            }
            let neededStars = Stage.needed[nextStageIndex]! - Levels.sharedInstance.totalStars
            let maxStars = Stage.needed[nextStageIndex]! - Stage.needed[nextStageIndex - 1]!
            let share = Int(100 * Float(maxStars - neededStars) / Float(maxStars))
            if share >= 66 {
                header.threeStars.image = UIImage.init(named: "three_stars_two")!
            } else if share >= 33 {
                header.threeStars.image = UIImage.init(named: "three_stars_one")!
            } else {
                header.threeStars.image = UIImage.init(named: "three_stars_zero")!
            }
            header.captionLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("NEED_MORE_STARS", comment: "Need more stars"),
                neededStars
            )
            
            return header as UIView
        }
        
        let header = tableView.dequeueReusableCell(withIdentifier: "stageHeader") as! MoreCaptionTableViewCell
        header.captionLabel.text = NSLocalizedString("STAGE_NAME", comment: "Stage name").uppercased() +
        " \(stageIndex)"
        let stage = Levels.sharedInstance.stages[stageIndex]!
        header.contentView.layer.opacity = stage.isUnlocked ? 1 : 0.5
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        let cell = tableView.dequeueReusableCell(withIdentifier: "levelCell") as! LevelsTableViewCell
        let stageIndex = getStageIndex(indexPath.section)!
        
        let stage = Levels.sharedInstance.stages[stageIndex]!
        let level = stage.levels[indexPath.row]
        cell.level = level
        cell.previewView.image = previews[stageIndex]![indexPath.row]
        cell.indexPath = indexPath
        cell.tableView = tableView
        
        cell.cellView.layer.opacity = stage.isUnlocked ? 1 : 0.5
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stageIndex = getStageIndex(indexPath.section)!
        let stage = Levels.sharedInstance.stages[stageIndex]!
        if stage.isUnlocked {
            performSegue(withIdentifier: "showDetails", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.LevelsList.indexPathForSelectedRow!
        
        
        if segue.identifier! == "showDetails" {
            guard let stageIndex = getStageIndex(indexPath.section) else {
                return
            }
            
            let destVC = segue.destination as! DetailsViewController
            destVC.level = Levels.sharedInstance
                .stages[stageIndex]!.levels[indexPath.row]
        }
        
    }
    
    @objc func scrollUp() {
        self.LevelsList.scrollToRow(at: .init(row: 0, section: 1), at: .top, animated: false)
    }
    
    @objc func animatedScrollUp() {
        self.LevelsList.scrollToRow(at: .init(row: 0, section: 1), at: .top, animated: true)
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
