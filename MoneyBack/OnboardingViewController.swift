//
//  OnboardingViewController.swift
//  MoneyBack
//
//  Created by Alexandre Vescera on 04/12/2018.
//  Copyright © 2018 Alexandre Vescera. All rights reserved.
//

import UIKit

class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    enum PageViews: String {
        case firstPV
        case secondPV
        case thirdPV
    }
    
    var skipBtn: UIButton!
    
    fileprivate lazy var orderedViewController: [UIViewController] = {
        return [self.getViewController(withIdentifier: PageViews.firstPV.rawValue),
                self.getViewController(withIdentifier: PageViews.secondPV.rawValue),
                self.getViewController(withIdentifier: PageViews.thirdPV.rawValue)]
    }()
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        return (storyboard?.instantiateViewController(withIdentifier: identifier))!
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewController.index(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        enableSkipBtn(enabling: false)
        guard previousIndex >= 0 else { return nil }
        guard orderedViewController.count > previousIndex else { return nil }
        return orderedViewController[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewController.index(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < orderedViewController.count else { return nil }
        guard orderedViewController.count > nextIndex else { return nil }
        if nextIndex == orderedViewController.count - 1 {
            enableSkipBtn(enabling: true)
        }
        return orderedViewController[nextIndex]
    }
    
    func presentationCount(for: UIPageViewController) -> Int {
        return orderedViewController.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        if let firstVC = orderedViewController.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Private Functions
    func enableSkipBtn(enabling: Bool) {
        skipBtn.isEnabled = enabling
        skipBtn.isHidden = !enabling
    }
    
}

