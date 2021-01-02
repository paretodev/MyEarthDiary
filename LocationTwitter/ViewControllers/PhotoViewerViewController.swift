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
    var imageName : String!
    
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
    
    @IBAction func deleteThisPhoto(){
        
        let alertController = makeAlert(withTitle:
                                            "delete this photo".localized(), withContents: "would you really delete this photo?".localized())
        let alertAction = UIAlertAction( title: "yes", style: .default ){_ in
            self.delegate.deleteThisPhoto( self.imageName )
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    
    }
}
