//
//  AppDelegate.swift
//  LocationTwitter
//
//  Created by 한석희 on 12/12/20.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    //
    var window: UIWindow?
    lazy var managedObjectContext = persistentContainer.viewContext
    // MARK: - Core Data Stacks Load
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocationTwitter")
        container.loadPersistentStores( completionHandler: { ( _, error) in
            if let error = error as NSError? {
                fatalCoreDataError(error)
            }
        } )
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = managedObjectContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    //MARK: - Core Data Error Observer Deployment -> Alert
    func listenForCoreDataSaveFailureNotification( ){
        //
        NotificationCenter.default.addObserver(
            forName: dataSaveFailedNotification,
            object: nil,
            queue: OperationQueue.main
        )//
        { _ in
            let alert = UIAlertController(title: "내부 에러".localized(), message: "데이터 저장 중 에러가 발생했습니다.".localized(), preferredStyle: .alert)
            let action = UIAlertAction(title: "확인".localized(), style: .default){ _ in
                let exception = NSException(
                    name: .internalInconsistencyException,
                    reason: "Fatal Core Data Error",
                    userInfo: nil
                )
                exception.raise()
            }
            //
    alert.addAction(action)
    let tabBarController = self.window?.rootViewController
        tabBarController?.present(alert, animated: true, completion: nil) // present new alert
    }
        //
}
    
    
    // MARK: - Application Delegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.register(
            defaults: ["photoID" : 0]
        )
        //2). Set Listener For CoreData Error in app's life cycle
        listenForCoreDataSaveFailureNotification()
        self.customizeAppearance()
        return true
    }
    
    // MARK:- Only on iOS 13.0 or above
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    //
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.saveContext()
    }
    //
    func customizeAppearance() {
        let tintColor = UIColor(
            red: 0.246,
            green: 0.666,
            blue: 0.881,
            alpha: 1.0
        )
        UITabBar.appearance().tintColor = tintColor
        UIButton.appearance().tintColor = tintColor
    }
}

