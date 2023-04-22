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
    let interstitialAdLoader = InterstitialAdLoader(adId: "e91a5b08633294b9")

    @IBOutlet var appTitleTap: UITapGestureRecognizer!
    @IBOutlet weak var LevelsList: UITableView!
    @IBOutlet weak var appTitleLable: UILabel!
    @IBOutlet weak var appSubTitleLable: UILabel!
    var isProMode: Bool {
        return Purchase.sharedInstance.proMode
    }

    var showAd: Bool {
        get {
            return !isProMode
        }
    }
    
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
        
        Colorize.sharedInstance.addColor(toView: self.view)
    }
    
    func addColor(toView view: UIView) {
        let color = UIColor.init(patternImage: UIImage.init(named: "pattern1")!)
        let newView = UIView.init(frame: self.view.frame)
        newView.backgroundColor = color
        newView.layer.opacity = 0.15
        view.layer.insertSublayer(newView.layer, at: 0)
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
            return section
        }
        if section < firstUnlocked! {
            return section
        }
        if section > firstUnlocked! {
            return section - 1
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
        let levelsCount = Levels.sharedInstance.stages[stageIndex]!.levels.count

        if (section > 0 && showAd) {
            return levelsCount + 1
        }
        return levelsCount
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if getStageIndex(section) == nil {
            return section == 1 ? 80 : 220
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
            header.maxStars = maxStars
            header.neededStars = neededStars
            header.section = section
            header.navigationController = self.navigationController
            header.onTap = {self.performSegue(withIdentifier: "showPaywall", sender: nil)}
            header.update()
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
        let stageIndex = getStageIndex(indexPath.section)!
        let stage = Levels.sharedInstance.stages[stageIndex]!
        if (indexPath.row >= stage.levels.count) {
            let height: CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 90 : 50
            return height
        }
        return 130
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        let stageIndex = getStageIndex(indexPath.section)!
        
        let stage = Levels.sharedInstance.stages[stageIndex]!
        if (indexPath.row >= stage.levels.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "adCell", for: indexPath) as! AdViewCell
            return cell
        }
        let level = stage.levels[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "levelCell") as! LevelsTableViewCell
        cell.level = level
        cell.previewView.image = Levels.sharedInstance.stages[stageIndex]!.levels[indexPath.row].preview
        cell.indexPath = indexPath
        cell.tableView = tableView
        
        cell.cellView.layer.opacity = stage.isUnlocked ? 1 : 0.5
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stageIndex = getStageIndex(indexPath.section)!
        let stage = Levels.sharedInstance.stages[stageIndex]!
        if stage.number == 0 {
            performSegue(withIdentifier: "firstPicture", sender: self)
        } else if stage.isUnlocked {
            if (showAd) {
                interstitialAdLoader.maybeShowAdWith {
                    self.performSegue(withIdentifier: "showDetails", sender: self)
                }
            } else {
                performSegue(withIdentifier: "showDetails", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = self.LevelsList.indexPathForSelectedRow else {
            return
        }
        
        
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
        self.LevelsList.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: false)
    }
    
    @objc func animatedScrollUp() {
        self.LevelsList.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
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
            ],
            "stages_count": [
                "unlocked": Levels.sharedInstance.stages.filter {stage in stage.value.isUnlocked}.count,
                "locked": Levels.sharedInstance.stages.filter {stage in !stage.value.isUnlocked}.count
            ],
            "stars_collected": Levels.sharedInstance.totalStars
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
