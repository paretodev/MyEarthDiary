//
//  SceneDelegate.swift
//  LocationTwitter
//
//  Created by 한석희 on 12/12/20.
//

import UIKit
import CoreData

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // MARK:- Ins Vars
    var window: UIWindow?
//    lazy var managedObjectContext = persistentContainer.viewContext
    // MARK:- Scene Delegate
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        let tabController = window!.rootViewController as! UITabBarController
//        if let tabViewControllers = tabController.viewControllers{
//            let navController = tabViewControllers[0] as! UINavigationController
//            let navController2 = tabViewControllers[1] as! UINavigationController
//            let controller = navController.viewControllers[0] as! CurrentLocationViewController
//            controller.managedObjectContext = self.managedObjectContext
//            print( type(of: navController2.viewControllers[0] ) )
//            let controller2 = navController2.viewControllers[0] as! VisitedLocationsViewController
//            controller2.managedObjectContext = self.managedObjectContext
//        }
//        //
//        listenForCoreDataSaveFailureNotification()
        
    }
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        // Save changes in the application's managed object context when the application transitions to the background.
//        self.saveContext()
    }
    
//    // MARK: - Core Data stack
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "LocationTwitter")
//        container.loadPersistentStores( completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)") // 앱 배포시에 삭제하기 -> 에러 핸들링
//            }
//        })
//        return container
//    }()

    // MARK: - Core Data Saving support
//    func saveContext () {
//        let context = managedObjectContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
    
        //MARK: - Listen For "Core Data Save Error" Notification
//    func listenForCoreDataSaveFailureNotification( ){
//        NotificationCenter.default.addObserver(
//            forName: dataSaveFailedNotification,
//            object: nil,
//            queue: OperationQueue.main
//            ){ _ in
//                let alert = UIAlertController(title: "내부 에러", message: "데이터 저중 중 에러가 발생했습니다.", preferredStyle: .alert)
//            //
//                let action = UIAlertAction(title: "확인", style: .default){ _ in
//                    let exception = NSException(
//                        name: .internalInconsistencyException, // exception을 만드는 측이 지정할 수 있다 !!
//                        reason: "Fatal Core Data Error",
//                        userInfo: nil
//                    )
//                exception.raise()
//            }
//            //
//        alert.addAction(action)
//        let tabBarController = self.window?.rootViewController
//            tabBarController?.present(alert, animated: true, completion: nil) // present new alert
//        }
//    }
    
    // end of scene deleage
}

