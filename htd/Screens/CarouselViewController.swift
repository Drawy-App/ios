//
//  CarouselViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 03.02.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit

class CarouselViewController: UIViewController,
    UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    @IBOutlet weak var pagesLabel: UILabel!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var pagesView: UIView!
    var dragGesture: UIPanGestureRecognizer?
    var pageViewController: UIPageViewController?
    var images: [UIImage] = []
    var pageNumber: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        pageViewController = UIPageViewController.init(
            transitionStyle: .scroll, navigationOrientation: .horizontal,
            options: nil
        )
        self.addChildViewController(pageViewController!)
        pageViewController!.view.frame = .init(
            origin: .init(x: 0, y: 0),
            size: pagesView.frame.size
        )
        self.pagesView.addSubview(pageViewController!.view)
        pageViewController!.dataSource = self
        pageViewController!.delegate = self
        pageViewController!.setViewControllers([
            getViewForPage(self.pageNumber)
        ], direction: .forward, animated: false, completion: nil)
        
        crossButton.addTarget(self, action: #selector(self.exitAnimated), for: .touchUpInside)
        self.initDrag()
        self.setPageNumber()
    }
    
    func initDrag() {
        dragGesture = UIPanGestureRecognizer.init(target: self, action: #selector(dragStarted))
        self.pagesView.addGestureRecognizer(dragGesture!)
    }
    
    @objc func dragStarted(_ sender:UIPanGestureRecognizer) {
        let tr = sender.translation(in: pagesView)
        let velocity = sender.velocity(in: pagesView)
        
        self.view.bounds = .init(
            origin: .init(x: 0, y: 0 - tr.y),
            size: self.view.bounds.size
        )
        let opacityNumber = 1 - abs(tr.y) / pagesView.bounds.height
        self.view.layer.opacity = Float(opacityNumber)
        if sender.state == .ended {
            if opacityNumber < 0.7 || abs(velocity.y) > self.pagesView.bounds.height {
                scrollHide(tr.y > 0, onCompleted: {
                    self.exit()
                })
            } else {
                scrollBack()
            }
        }
    }
    
    func scrollHide(_ down: Bool, onCompleted: (() -> Void)?) {
        let yPosition = down ? 0 - UIScreen.main.bounds.height : UIScreen.main.bounds.height
        UIView.animate(withDuration: 0.2, animations: {
            self.view.bounds = .init(
                origin: .init(x: 0, y: yPosition),
                size: self.view.bounds.size
            )
            self.view.layer.opacity = 0
        }, completion: {completed in
            if onCompleted != nil {
                onCompleted!()
            }
        })
    }
    
    func scrollBack() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.bounds = .init(
                origin: .zero,
                size: self.view.bounds.size
            )
            self.view.layer.opacity = 1
        })
    }
    
    func getViewForPage(_ pageNumber: Int) -> CarouselPageViewController {
        let page = self.storyboard!.instantiateViewController(withIdentifier: "CarouselPage") as! CarouselPageViewController
        page.pageNumber = pageNumber
        page.totalPages = self.images.count
        page.image = self.images[pageNumber]
        return page
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! CarouselPageViewController
        if vc.pageNumber + 1 >= self.images.count {
            return nil
        }
        self.pageNumber += 1
        return self.getViewForPage(self.pageNumber)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! CarouselPageViewController
        if vc.pageNumber <= 0 {
            return nil
        }
        self.pageNumber -= 1
        return self.getViewForPage(self.pageNumber)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.setPageNumber()
    }
    
    func setPageNumber() {
        self.pagesLabel.text = String.init(
            format: NSLocalizedString("GALLERY_STEPS", comment: "Page numbers in gallery"),
            self.pageNumber + 1, self.images.count
        )
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func exit() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func exitAnimated() {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
