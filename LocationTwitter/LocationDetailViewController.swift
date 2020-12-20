//
//  LocationDetailViewController.swift
//  LocationTwitter
//
//  Created by 한석희 on 12/12/20.
//

import UIKit
import CoreData
import CoreLocation
import YPImagePicker
import KRWordWrapLabel

class LocationDetailViewController: UITableViewController {
    
    //MARK:- Ins Vars
        // MARK: - Common Ins Vars
    var managedObjectContext : NSManagedObjectContext!
    // MARK: - Related Vars
    var placemark : CLPlacemark!
    var locationPhotos : [String] = [ ]
    var locationCategoryName = ""
    var date : Date?
    var coordinate : CLLocationCoordinate2D!
    
    // MARK: - Internally Created
    var observer : Any!
    var photoURL: URL {
        let nowID = issuePhotoID()
        let filename = "image-\(nowID).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename, isDirectory: false)
    }
    lazy var imagePickerController : YPImagePicker? = {
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 20
        config.library.minNumberOfItems = 1
        let picker = YPImagePicker(configuration: config)
        return picker
    }( )
    // MARK:- Add Location Only Var
    var location : CLLocation? {
        didSet {
            date = location?.timestamp
        }
    }
    // MARK:- Only For Editing Var
    var locationToEdit : Location?
    
        // 2). UI Elements
    @IBOutlet weak var nameOfLocationTextFeild: UITextField!
    @IBOutlet weak var locationCategoryLabel: UILabel!
    @IBOutlet weak var locationGalleryScrollView: UIScrollView!
    @IBOutlet weak var galleryPageControl: UIPageControl!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var twitterTextView: UITextView!
    @IBOutlet weak var galleryCell: UITableViewCell!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addressLabelMotherView: UIView!
    @IBOutlet weak var labelNamedAdress: UILabel!
    var kAddressLabel : KRWordWrapLabel?
    
    //MARK: - Initail Set up
    override func viewDidLoad() {
        print("LocatoinDetailVC view did load executed.")
        super.viewDidLoad()
        
        // MARK: - Edit Only
        if let locationToEdit = locationToEdit {
            nameOfLocationTextFeild.text = locationToEdit.name
            locationCategoryName = locationToEdit.category
            locationCategoryLabel.text = locationToEdit.category
            self.locationPhotos = locationToEdit.locationPhotos
            self.placemark = locationToEdit.placemark
            date = locationToEdit.date // -> 자동 지정된다.
            if locationToEdit.locationTwit != "" {
                twitterTextView.text = locationToEdit.locationTwit
            }
        }
        
        // MARK: - 1). Common
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44 // Something reasonable to help ios render your cells
            // 1). Scroll View's Delegate Regi.
        locationGalleryScrollView.delegate = self
        galleryPageControl.pageIndicatorTintColor = .lightGray
        galleryPageControl.currentPageIndicatorTintColor = .gray
            // 2). Configure Date, Address Labels.
        kAddressLabel = KRWordWrapLabel()
        kAddressLabel!.lineBreakMode = .byWordWrapping
        kAddressLabel!.numberOfLines = 0
        kAddressLabel!.text = string(from: placemark)
            // 3). Add Constraints
        addressLabelMotherView.addSubview(kAddressLabel!)
        kAddressLabel!.translatesAutoresizingMaskIntoConstraints = false
        addressLabelMotherView.translatesAutoresizingMaskIntoConstraints = false
        //
        addressLabelMotherView.addConstraint(
            NSLayoutConstraint(item: addressLabelMotherView!, attribute: .trailing, relatedBy: .equal, toItem: kAddressLabel!, attribute: .trailing, multiplier: 1.0, constant: 10 )
        )
        addressLabelMotherView.addConstraint(
            NSLayoutConstraint(item: addressLabelMotherView!, attribute: .top, relatedBy: .equal, toItem: kAddressLabel!, attribute: .top, multiplier: 1.0, constant: -10.0 )
        )
        addressLabelMotherView.addConstraint(
            NSLayoutConstraint(item: addressLabelMotherView!, attribute: .bottom, relatedBy: .equal, toItem: kAddressLabel!, attribute: .lastBaseline, multiplier: 1.0, constant: +10.0)
        )
        addressLabelMotherView.addConstraint(
            NSLayoutConstraint(item: kAddressLabel!, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: labelNamedAdress, attribute: .right, multiplier: 1.0, constant: +10.0)
        )
            // 4). Label Configuration
        dateLabel.text = {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ko-KR")
            return  formatter.string( from: date! )
        }( )
        //3). Add Location vs. Edit Location Set ups
            // In Case, it is "add location"
                // 1. placeholder image
        
        //MARK: - Only Add
        if locationToEdit == nil {
            locationPhotos.append("noImage")
            placeholderSetting()
        }
        // MARK: - Only Edit
        else{
            if locationToEdit?.locationTwit == "" {
                placeholderSetting()
            }
        }
        // MARK: - Common - Gallery Reload
        configureGalleryScrollView()
        
        //MARK: - Common - TextView Responder Control
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        listenForBackgroundNotification()
        //
    }
    
    //MARK:- Reload
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        configureGalleryScrollView()
    }
    
    // MARK: - TableView Delegation
    
        // 1). Assign Selectable Indexpaths
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if ( indexPath.section == 0 && indexPath.row == 1)  || (indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 2 && indexPath.row == 2) {
            return indexPath
        }
        else{
            return nil
        }
    }
            //2). Cell Selection Actions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        if indexPath.section == 1 && indexPath.row == 0 {
            tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
            presentYPImagePicker()
        }
        //
        else if indexPath.section == 0 && indexPath.row == 1 {
            tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        }
        //
        else if indexPath.section == 2, indexPath.row == 2 {
            twitterTextView.becomeFirstResponder()
        }
        //
    }
        //2). row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
    }
    
    // MARK: - Navigation
        // 1. To Elsewhere
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPicker
            controller.selectedCategoryName = self.locationCategoryName
        }
    }
    
    //MARK: - Action Methods
    
        // 1. Unwind From CategoryPicker
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPicker
        locationCategoryName = controller.selectedCategoryName
        locationCategoryLabel.text = locationCategoryName
    }
        // 2. Done
    @IBAction func done(){
        
        if locationToEdit == nil {
            let location = Location(context: self.managedObjectContext)
            // 스크래치 패드 위에 객체 생성
            location.category = self.locationCategoryName
            location.latitude = self.location!.coordinate.latitude
            location.longitude = self.location!.coordinate.longitude
            location.locationPhotos = self.locationPhotos
            location.date = self.date!
            location.placemark = self.placemark
            location.locationTwit = self.twitterTextView.text
            location.name = nameOfLocationTextFeild.text!
        }
        else if let locationToEdit = locationToEdit {
            //
            locationToEdit.category = self.locationCategoryName
            locationToEdit.locationPhotos = self.locationPhotos
            locationToEdit.locationTwit = self.twitterTextView.text
            locationToEdit.name = self.nameOfLocationTextFeild.text!
            //
        }
        // MARK: - Common - Save Change to Object Context
        do {
            try managedObjectContext.save() // true if succeeds, false if fails, this thread deals with completion handler
            self.navigationController?.popViewController(animated: true)
        } catch  {
            fatalCoreDataError(error)
        }
    }
    
    @IBAction func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Helper Methods
        // 1). placeholder set up
    func placeholderSetting() {
        twitterTextView.delegate = self // txtvReview가 유저가 선언한 outlet
        twitterTextView.text = "이 장소에 대한 트윗을 남겨보세요."
        twitterTextView.textColor = UIColor.lightGray
    }
        //2). configure page control <-> scrollView
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = ( scrollView.contentOffset.x / scrollView.frame.size.width ).rounded()
        self.galleryPageControl.currentPage = Int(pageNumber)
    }
        // 2). Configure Gallery ScrollView <-> locationPhotos
    func configureGalleryScrollView() {
        // 스크롤뷰 초기화
        for subview in locationGalleryScrollView.subviews {
            subview.removeFromSuperview()
            print("begin gallery set up. Removed all the image views. removed view type :  \(type(of: subview))")
        }
        //
        galleryPageControl.numberOfPages = locationPhotos.count
        //
        locationGalleryScrollView.contentSize = CGSize(
            width: ( locationGalleryScrollView.frame.size.width * CGFloat(self.locationPhotos.count) ),
            height: locationGalleryScrollView.frame.size.height
        )
        //
        locationGalleryScrollView.showsHorizontalScrollIndicator = false
        locationGalleryScrollView.showsVerticalScrollIndicator = false
        locationGalleryScrollView.bounces = false
        locationGalleryScrollView.isPagingEnabled = true
        //
        var frame : CGRect = CGRect.zero
        for index in 0..<locationPhotos.count {
            // 1.
            frame.origin.x = locationGalleryScrollView.frame.size.width * CGFloat(index)
            frame.size = locationGalleryScrollView.frame.size
            // 2.
            let  imgView = UIImageView(frame: frame)
            imgView.layer.cornerRadius = 15
            imgView.layer.masksToBounds = true
            imgView.contentMode = .scaleAspectFill
            imgView.backgroundColor = .darkGray
            
            //MARK:- 이미지 로드 방법 에셋 이름, URL(도큐먼트) 모색
            if locationPhotos[index] == "noImage" {
                imgView.image = UIImage( named: locationPhotos[index] )!.resized(withBounds: imgView.bounds.size)
            }
            else{
                let newDirectory = applicationDocumentsDirectory.appendingPathComponent(
                    "image-\( locationPhotos[index] ).jpg", isDirectory: false )
                do {
                    let data = try Data(contentsOf: newDirectory)
                    imgView.image = UIImage( data: data )?.resized(withBounds: imgView.bounds.size)
                } catch  {
                    print("There was no image in the given directory : \(newDirectory.absoluteString)")
                    fatalError()
                }
                //
            }
            // 3.
            locationGalleryScrollView.addSubview(imgView)
            // 4.imgView와 슈퍼뷰인 스크롤뷰 사이의 constraint를 프로그램으로 주기
            imgView.translatesAutoresizingMaskIntoConstraints = false
            locationGalleryScrollView.addConstraint( NSLayoutConstraint(
                                    item: locationGalleryScrollView!,
                                    attribute: .width,
                                    relatedBy: .equal,
                                    toItem: imgView,
                                    attribute: .width,
                                    multiplier: 1.0,
                                    constant: 0 )
            )
                // 높이
            locationGalleryScrollView.addConstraint( NSLayoutConstraint(
                                    item: locationGalleryScrollView!,
                                    attribute: .height,
                                    relatedBy: .equal,
                                    toItem: imgView,
                                    attribute: .height,
                                    multiplier: 1.0,
                                    constant: 0 )
            )
                // 중앙점
            let constraint = NSLayoutConstraint(item: imgView, attribute: .centerX, relatedBy: .equal, toItem: locationGalleryScrollView, attribute: .centerX, multiplier: CGFloat(2*index + 1), constant: 0 )
            locationGalleryScrollView.addConstraint(constraint)
            let constrainty = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: locationGalleryScrollView, attribute: .centerY, multiplier: 1, constant: 0 )
            locationGalleryScrollView.addConstraint(constrainty)
        }
    }
    
    //MARK:- YPImagePicker
    func presentYPImagePicker(){
        // 1). Define Completion Handler
        regeneratePicker()
        //
        imagePickerController!.didFinishPicking { [self, unowned imagePickerController] items, cancelled in
            //
            if cancelled == true {
                imagePickerController!.dismiss(animated: true, completion: nil)
                self.imagePickerController = nil
                return
            }
            //
            for item in items {
                switch item {
                    //1>.
                case .photo(let photo):
                        // 1). result photo.image type check
                    print("the type of photo.image is : ", type(of: photo.image) )
                        // 2). Document url + newID => documents에 저장
                    if let data = photo.image.jpegData(compressionQuality: 0.5) {
                        //
                        do {
                            let url : URL = photoURL
                            try data.write(to: url, options: .atomic)
                            //
                            let string = url.absoluteString
                            let char = string [ string.index( string.endIndex, offsetBy: -5 ) ]
                            locationPhotos.append("\( String(char) )")
                            //
                            print("check photos status : ", locationPhotos)
                        }
                        catch {
                            print("Writing image failed :  \(error)")
                            fatalError()
                        }
                        //
                    }
                    //2>. Just In Case, video function can be added
                case .video(let video):
                    print(video)
                }
            }
            
            // MARK:- Adding : Remove Placeholder Image
            if locationPhotos[0] == "noImage" {
                print( "removed placeholder image" )
                locationPhotos.remove(at: 0)
            }
            //
            self.configureGalleryScrollView()
            imagePickerController!.dismiss(animated: true, completion: nil)
            self.imagePickerController = nil
        }
        
        // 2). Present Image Picker
        present(imagePickerController!, animated: true, completion: nil)
    }
    
    //MARK: - YPImagePicker Regeneration
    func regeneratePicker(){
        if imagePickerController == nil {
                var config = YPImagePickerConfiguration()
                // [Edit configuration here ...]
                config.library.maxNumberOfItems = 20
                config.library.minNumberOfItems = 1
                //
                imagePickerController = YPImagePicker(configuration: config)
        }
    }
    //
}


//MARK:- UITextView Delegation
extension LocationDetailViewController : UITextViewDelegate {
    // TextView Place Holder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    // TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "이 장소에 대한 트윗을 남겨보세요."
            textView.textColor = UIColor.lightGray
        }
    }
    
    // MARK: - Resigner FirstResponder, In Case Of Touching Outside Twit Cell.
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
      let point = gestureRecognizer.location(in: tableView)
      let indexPath = tableView.indexPathForRow(at: point)
      //
        if nameOfLocationTextFeild.isFirstResponder {
            if indexPath != nil, indexPath!.section == 0, indexPath!.row == 0 {
              return
            }
            nameOfLocationTextFeild.resignFirstResponder()
        }
        //
        else if twitterTextView.isFirstResponder{
            if indexPath != nil, indexPath!.section == 2, indexPath!.row == 2 {
              return
            }
            twitterTextView.resignFirstResponder()
        }
    }
    //
    func listenForBackgroundNotification() {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
    }
    //
    @objc func willResignActive(_ notification: Notification) {
        self.twitterTextView.resignFirstResponder()
        self.nameOfLocationTextFeild.resignFirstResponder()
    }
    
    //MARK: - End of VC
}
//
