//
//  DetailsViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 14.01.18.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit
import SwiftPhotoGallery

class DetailsViewController: UIViewController, UIGestureRecognizerDelegate,
    SwiftPhotoGalleryDelegate, SwiftPhotoGalleryDataSource,
    UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var hasDrownLabel: UIView!
    @IBOutlet weak var hasDrownView: UIView!
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
    
    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        dismiss(animated: true, completion: nil)
    }
    

    
    
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
        timeLabel.text = String.init(format: "%d минут", level!.duration)
        
        hasDrownLabel.layer.cornerRadius = 4
        hasDrownView.isHidden = self.level!.rating == 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 15 * 4) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return level!.tutorials.count
    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        return UIImage.init(named: level!.tutorials[forIndex])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.item
        
        let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        gallery.backgroundColor = UIColor.white
        gallery.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
        gallery.currentPageIndicatorTintColor = UIColor(red: 0.0, green: 0.66, blue: 0.875, alpha: 1.0)
        gallery.hidePageControl = false
        gallery.modalPresentationStyle = .custom
        
        present(gallery, animated: true, completion: { () -> Void in
            gallery.currentPage = self.index
        })
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
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
