//
//  TabBarController.swift
//
//  OutRun
//  Copyright (C) 2020 Tim Fraedrich <timfraedrich@icloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    static var lastCurrent: TabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        TabBarController.lastCurrent = self
        
        self.tabBar.barTintColor = .backgroundColor
        self.tabBar.isTranslucent = false
        
        // So here the WorkoutListView is defined.
        let listController = WorkoutListViewController()
        let timeline = NavigationController(rootViewController: listController)
        timeline.tabBarItem = UITabBarItem(
            title: LS("TabBar.Timeline"),
            image: .tabbarTimeline,
            selectedImage: .tabbarTimelineFilled
        )
        // Settings view controller is defined, then is encapsulated in a NavigationController, which allows to stack information
        let settingsController = SettingsViewController()
        settingsController.settingsModelClosure = {
            return SettingsModel.custom
        }
        let settings = NavigationController(rootViewController: settingsController)
        let settingsTabBarItem = UITabBarItem(
            title: LS("TabBar.Settings"),
            image: .tabbarSettings,
            selectedImage: .tabbarSettingsFilled
        )
        settings.tabBarItem = settingsTabBarItem
        
        // Next the two view controllers are added
        self.viewControllers = [timeline, settings]

        let bgrdView = UIView()
        bgrdView.backgroundColor = .backgroundColor
        self.tabBar.insertSubview(bgrdView, at: 0)
        bgrdView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0))
        }
        
        self.addDebugGestureRecognizer()
    }
    
    // Deinitializer of the controller. Invoked when the view is destroyed?
    deinit {
        if TabBarController.lastCurrent == self {
            TabBarController.lastCurrent = nil
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let selectionObserver = viewController.findFirstNonTabOrNavigationController() as? TabBarSelectionObserver {
            selectionObserver.willGetSelected()
        }
        if let currentSelectionObserver = tabBarController.selectedViewController?.findFirstNonTabOrNavigationController() as? TabBarSelectionObserver, currentSelectionObserver != viewController {
            currentSelectionObserver.willGetDeselected(newController: viewController)
        }
        return true
    }
    
    @objc private func displayNewWorkoutAlert(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let alert = WorkoutTypeAlert(
                action: { (type) in
                    let controller = NewWorkoutViewController()
                    controller.type = type
                    self.showDetailViewController(controller, sender: self)
                },
                manualAction: {
                    let controller = EditWorkoutController()
                    self.showDetailViewController(NavigationController(rootViewController: controller), sender: self)
                }
            )
            alert.present(on: self)
        }
    }
    
    @objc private func showNewWorkoutController() {
        let controller = NewWorkoutViewController()
        self.showDetailViewController(controller, sender: self)
    }
    
    func addDebugGestureRecognizer() {
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(recognizeDebugGesture(recognizer:)))
        recognizer.numberOfTapsRequired = 10
        recognizer.delaysTouchesBegan = false
        recognizer.delaysTouchesEnded = false
        
        self.tabBar.addGestureRecognizer(recognizer)
        
    }
    
    @objc func recognizeDebugGesture(recognizer: UITapGestureRecognizer) {
        if self.selectedIndex == 2 {
            self.showDetailViewController(NavigationController(rootViewController: DebugController()), sender: self)
        }
    }
    
}
