//
//  PhotoViewerViewController.swift
//  LocationTwitter
//
//  Created by 한석희 on 12/20/20.
//

import UIKit

class PhotoViewerViewController: UIViewController {
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var image : UIImage!
    var photoName : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // resized before display
        if photoName.isEmpty {
            locationNameLabel.text = "장소 이름이 입력되지 않았어요👀".localized()
        }else{
            locationNameLabel.text =  "@ <\(photoName!)>"
        }
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

}
