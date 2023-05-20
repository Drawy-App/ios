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
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var captureButton: UIControl!
    @IBOutlet weak var captureButtonLabel: UILabel!
    @IBOutlet weak var pagesLabel: UILabel!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var pagesView: UIView!
    @IBOutlet weak var bannerView: UIView!
    var level: Level?
    var dragGesture: UIPanGestureRecognizer?
    var pageViewController: UIPageViewController?
    var images: [UIImage] = []
    var pageNumber: Int = 0
    var banner: BannerView?
    let bannerHeight: CGFloat = 130
    let interstitial = InterstitialAdLoader.init(adId: "e91a5b08633294b9")
    
    private func initAd() {
        let heightConstraint = bannerView.constraints.first(where: {c in
            return c.identifier == "bannerHeight"
        })
        heightConstraint?.constant = bannerHeight
        banner = .init(id: "16e1ef1bec51c5fc", with: bannerView, height: bannerHeight)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (Ad.sharedInstance.showAd) {
            initAd()
        }
        
        self.captureButtonLabel.text = NSLocalizedString("CHECK_BUTTON", comment: "Check button")
        self.nextButton.setTitle(NSLocalizedString("NEXT_BUTTON", comment: "Next button"), for: .normal)
        self.captureButton.layer.cornerRadius = 5
        self.captureButton.isHidden = true
        
        
        pageViewController = UIPageViewController.init(
            transitionStyle: .scroll, navigationOrientation: .horizontal,
            options: nil
        )
        self.addChild(pageViewController!)
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
        
        self.nextButton.addTarget(self, action: #selector(self.nextTap), for: .touchUpInside)
        self.captureButton.addTarget(self, action: #selector(self.nextTap), for: .touchUpInside)
        
        setButtonTitle()
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
        if vc.pageNumber >= self.images.count - 1 {
            return nil
        }
        let number = vc.pageNumber + 1
        return self.getViewForPage(number)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! CarouselPageViewController
        if vc.pageNumber <= 0 {
            return nil
        }
        let number = vc.pageNumber - 1
        return self.getViewForPage(number)
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return (pageViewController.viewControllers!.first! as! CarouselPageViewController).pageNumber
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.setPageNumber()
    }
    
    func setPageNumber() {
        let vc = self.pageViewController!.viewControllers!.first! as! CarouselPageViewController
        pageNumber = vc.pageNumber
        self.pagesLabel.text = String.init(
            format: NSLocalizedString("GALLERY_STEPS", comment: "Page numbers in gallery"),
            pageNumber + 1, self.images.count
        )
        
        setButtonTitle()
        
        Analytics.sharedInstance.navigate("carousel_page", params: [
            "name": self.level!.name,
            "page": String(pageNumber),
            "total_pages": String(self.images.count)
        ])
    }
    
    func setButtonTitle() {
        self.nextButton.isHidden = pageNumber + 1 == self.images.count
        self.captureButton.isHidden = !(pageNumber + 1 == self.images.count)
    }
    
    @objc func nextTap() {
        if pageNumber + 1 == self.images.count {
            if (Ad.sharedInstance.showAd) {
                interstitial.maybeShowAdWith {
                    self.verify()
                }
            } else {
                verify()
            }
        } else {
            let nextVC = getViewForPage(pageNumber + 1)
            self.pageViewController?.setViewControllers(
                [nextVC], direction: .forward,
                animated: true, completion: {completed in
                    if completed {
                        self.pageNumber += 1
                        self.setPageNumber()
                    }
                }
            )
        }
    }
    
    func verify() {
        let pv = self.presentingViewController as! UINavigationController
        pv.viewControllers.last!.performSegue(withIdentifier: "makePhoto", sender: self)
        self.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Analytics.sharedInstance.navigate("carousel", params: ["name": self.level!.name])
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makePhotoFromCarousel" {
            let vc = segue.destination as! RecognizerViewController
            vc.level = self.level
        }
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
