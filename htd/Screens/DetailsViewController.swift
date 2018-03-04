//
//  DetailsViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 14.01.18.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UIGestureRecognizerDelegate,
    UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var makePhotoLabel: UILabel!
    @IBOutlet weak var hasDrownView: UIView!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var backButtonLabel: UILabel!
    @IBOutlet var makePhotoGesture: UITapGestureRecognizer!
    @IBOutlet weak var photoButton: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previewViewContainer: UIView!
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet var backTapRecognizer: UITapGestureRecognizer!
    
    
    var index: Int = 0
    var level: Level?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        backTapRecognizer.addTarget(self, action: #selector(self.exit))
        previewViewContainer.layer.cornerRadius = 5
        
        photoButton.layer.cornerRadius = 5
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 0, left: 15, bottom: 8, right: 15)
        
        titleLabel.text = level!.title
        previewView.image = UIImage.init(named: level!.preview)
        timeLabel.text = GramCase.getLocalizedString(number: level!.tutorials.count, key: "STEPS")
        
        
        self.makePhotoLabel.text = NSLocalizedString("CHECK_BUTTON", comment: "Make photo")
        self.stepsLabel.text = NSLocalizedString("STEPS_HEADER", comment: "Steps header")
        self.backButtonLabel.text = NSLocalizedString("BACK_BUTTON", comment: "Back button")
        
        for i in 0...(level!.difficulty - 1) {
            addStar(i, full: level!.rating > 0 )
        }
    }
    
    func addStar(_ number: Int, full: Bool) {
        let imageView = UIImageView.init()
        imageView.frame = .init(x: number * (16 + 4), y: 3, width: 16, height: 16)
        self.hasDrownView.addSubview(imageView)
        imageView.image = UIImage.init(named: full ? "star" : "star_empty")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 15 * 4) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    @objc func exit() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return level!.tutorials.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCell", for: indexPath) as! GalleryCollectionViewCell
        cell.imageView.image = UIImage.init(named: level!.tutorials[indexPath.item])
        cell.counterLabel.text = String(indexPath.item + 1)
        
        return cell as UICollectionViewCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makePhoto" {
            let dest = segue.destination as! RecognizerViewController
            dest.level = self.level
        }
        if segue.identifier == "showGallery" {
            let dest = segue.destination as! CarouselViewController
            dest.level = self.level
//            dest.navigationController = self.navigationController
            dest.images = self.level!.tutorials.map {
                UIImage.init(named: $0)!
            }
            dest.pageNumber = self.collectionView.indexPathsForSelectedItems!.first!.item
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Analytics.sharedInstance.navigate("details", params: ["name": self.level!.name])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
