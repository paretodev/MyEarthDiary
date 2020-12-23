//
//  LocationCell.swift
//  LocationTwitter
//
//  Created by 한석희 on 12/17/20.
//

import UIKit
import KRWordWrapLabel

class LocationCell: UITableViewCell {
   
    //MARK:- Ins Vars
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    let addressLabel = KRWordWrapLabel()
    
    //MARK:- Initial Set Up
    override func awakeFromNib() {
        super.awakeFromNib()
        //MARK: -  Init Code
        self.addressLabel.lineBreakMode = .byWordWrapping
        self.addressLabel.numberOfLines = 0
        self.addressLabel.textAlignment = .left
        //
        self.locationNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.addressLabel.font = UIFont.systemFont(ofSize: 15)
        //
        contentView.addSubview(addressLabel)
        //
        self.addressLabel.translatesAutoresizingMaskIntoConstraints = false
        //
        let constraint1 = NSLayoutConstraint(item: locationNameLabel!, attribute: .bottom , relatedBy:.equal , toItem: addressLabel , attribute: .top, multiplier: 1.0, constant: -5.0)
        let constraint7 = NSLayoutConstraint(item: self.locationImage!, attribute: .trailing , relatedBy:.equal , toItem: addressLabel , attribute: .leading, multiplier: 1.0, constant: -8.0)
        //
        let constraint3 = NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: addressLabel, attribute: .trailing, multiplier: 1.0, constant: 10.0)
        let constraint6 = NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: locationNameLabel, attribute: .trailing, multiplier: 1.0, constant: 10.0)
        let constraint4 = NSLayoutConstraint(item: addressLabel, attribute: .leading, relatedBy: .equal, toItem: locationNameLabel, attribute: .leading, multiplier: 1.0, constant: 0.0)
        // <-> contentView
        let constraint2 = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: addressLabel, attribute: .bottom, multiplier: 1.0, constant: 8.0)
        let constraint5 =  NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: locationNameLabel, attribute: .top, multiplier: 1.0, constant: -8.0)
        //
        contentView.addConstraints([constraint1,constraint2,constraint3, constraint4, constraint5, constraint6, constraint7])
        locationImage.layer.cornerRadius = locationImage.bounds.width / 2
        locationImage.clipsToBounds = true
    }
    
    //
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //
    func configureCell(for location : Location){
        // MARK: - 1). Set up image
        if  !location.locationPhotos.isEmpty && location.locationPhotos[0] != "noImage"{
            let newDirectory = applicationDocumentsDirectory.appendingPathComponent(
                "image-\( location.locationPhotos[0] ).jpg", isDirectory: false )
            do {
                let data = try Data(contentsOf: newDirectory)
                self.locationImage.image = UIImage( data: data )?.resized(withBounds: locationImage.bounds.size)
            } catch  {
                let exception = NSException(name: NSExceptionName("No Such Data"), reason: "There is no such file \(newDirectory)", userInfo: ["location" : location])
                exception.raise()
            }
        }
        // In Case, the location's photo list is empty
        else{
            self.locationImage.image = UIImage(named: "noImage")!.resized(withBounds: locationImage.bounds.size)
        }
        // MARK: - 2). Set Up Labels
        self.addressLabel.text = string(from: location.placemark!)
        self.locationNameLabel.text = location.name
        //MARK:- End of Configure Cell for a Location
    }
    
    // end of view controllers
}


