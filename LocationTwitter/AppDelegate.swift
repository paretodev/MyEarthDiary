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
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocationTwitter")
        container.loadPersistentStores( completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)") // 앱 배포시에 삭제하기 -> 에러 핸들링
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = managedObjectContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - Core Data Error Observer Deployment
    func listenForCoreDataSaveFailureNotification( ){
        NotificationCenter.default.addObserver(
            forName: dataSaveFailedNotification,
            object: nil,
            queue: OperationQueue.main
        ){ _ in
            let alert = UIAlertController(title: "내부 에러", message: "데이터 저중 중 에러가 발생했습니다.", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default){ _ in
                let exception = NSException(
                    name: .internalInconsistencyException, // exception을 만드는 측이 지정할 수 있다 !!
                    reason: "Fatal Core Data Error",
                    userInfo: nil
                )
                exception.raise()
            }
    alert.addAction(action)
    let tabBarController = self.window?.rootViewController
        tabBarController?.present(alert, animated: true, completion: nil) // present new alert
    }
}
    
    
    // MARK: - Application Delegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 1). Set Defaults for Image Name
        UserDefaults.standard.register(
            defaults: ["photoID" : 0]
        )
        //2). Set Listener For CoreData Error in app's life cycle
        listenForCoreDataSaveFailureNotification()
        return true
    }

    // MARK:- Only on iOS 13.0 or above
        // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    //
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.saveContext()
    }
    //
}

