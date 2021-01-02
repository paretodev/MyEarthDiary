//
//  PhotoViewerViewController.swift
//  LocationTwitter
//
//  Created by 한석희 on 12/20/20.
//

import UIKit

protocol  PhotoViewerViewControllerDelegate {
    func deleteThisPhoto( _ photoName : String )
}

class PhotoViewerViewController: UIViewController {
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var image : UIImage!
    var photoName : String!
    var delegate : PhotoViewerViewControllerDelegate!
    var imageName : String! // delivered
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // resized before display
        if photoName.isEmpty {
            locationNameLabel.text = "장소 이름이 입력되지 않았어요👀".localized()
        }else{
            locationNameLabel.text =  "@ <\(photoName!)>"
        }
        //
        deleteButton.title = "삭제".localized()
        //
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // MARK: - Configure Image View
        photoImageView.layer.cornerRadius = 8
        photoImageView.layer.masksToBounds = true
        photoImageView.image = image.resized(withBounds: photoImageView.bounds.size)
    }
    
    @IBAction func cancel(){
        self.navigationController?.popViewController(animated: true)
    }
    //MARK:-When User Taps Delete for the photo
    @IBAction func deleteThisPhoto(){
        //MARK:-Controller
        let alertController = UIAlertController(title: "Asking For Confirm".localized(), message: "Do you confirm deleting this photo?".localized(), preferredStyle: .alert)
        //MARK:-Action1
        var alertAction = UIAlertAction( title: "yes".localized(), style: .default ){ [weak self]_ in
            if let weakSelf = self {
                weakSelf.delegate.deleteThisPhoto(weakSelf.imageName)
            }
        }
        alertController.addAction(alertAction)
        //MARK:-Action2
        alertAction = UIAlertAction( title: "cancel".localized(), style: .default ){ [weak alertController ] _ in
            if let controller = alertController {
                controller.removeFromParent()
            }
        }
        alertController.addAction(alertAction)
        //MARK:-present it
        present(alertController, animated: true, completion: nil)
        //
    }
}
