import UIKit
import MapKit
import CoreData
import CoreLocation

class MapViewController: UIViewController, MKLocalSearchCompleterDelegate, UITableViewDelegate, UITableViewDataSource  {
    
    //MARK:-UI Controls
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var mapViewContentView: UIView!
    @IBOutlet weak var autoCompleteTableView: UITableView!
    @IBOutlet weak var addressSearchBar: UISearchBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    //MARK:- Ins Vars
  var locations = [Location]()
  var zoomOutLevel : Int?
  private var mapChangedFromUserInteraction = false
  var searchCompleter : MKLocalSearchCompleter?
  var managedObjectContext: NSManagedObjectContext! {
    didSet {
      NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main) { _ in
        if self.isViewLoaded {
          self.updateLocations() // configure according to NS Fetch Results Controller
        }
      }
    }
  }
    var currentAutoCompletionResults :  [MKLocalSearchCompletion]
    = []
    //MARK:- Vars for temp and map move focusing &  annotations
    var currentSearchedMapItem : MKMapItem?
    var currentSearchedLocatoin : CLLocationCoordinate2D?
    var currentSearchedAnnotation : SearchedLocation?
    var updatedMapViewCenter : CLLocationCoordinate2D?
    var currentCenterPlacemark : CLPlacemark?
    lazy var geoCoder = {
        return CLGeocoder()
    }()
    var currentCenterAnnotation : CurrentCenterLocation?
    var tillNowMapAddedCenterAnnotations : [CurrentCenterLocation] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    // MARK: - Always Specify Context Instance
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let objContext = appDelegate.managedObjectContext
    self.managedObjectContext = objContext
    updateLocations()
    if !locations.isEmpty {
      showLocations()
    }
    //
    self.addressSearchBar.delegate = self
    self.addressSearchBar.placeholder = "주소로 이동하기".localized()
    //
    self.searchCompleter =  MKLocalSearchCompleter()
    self.searchCompleter!.delegate = self
    self.searchCompleter!.region = self.mapView.region
    //MARK:- AutoCompleteTable Configs
    view.bringSubviewToFront(self.autoCompleteTableView)
    view.bringSubviewToFront(self.toolBar)
    //
    autoCompleteTableView.delegate = self
    //
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideSearchOptionsTable))
    gestureRecognizer.cancelsTouchesInView = false
    mapView.addGestureRecognizer(gestureRecognizer)
    //
    autoCompleteTableView.isHidden = true
    autoCompleteTableView.layer.cornerRadius = 5
    //
  }
    
    override func viewDidAppear(_ animated: Bool) {
        let constraint1 = NSLayoutConstraint(item: self.autoCompleteTableView, attribute: .leading, relatedBy: .equal, toItem: self.addressSearchBar, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let constraint2 = NSLayoutConstraint(item: self.autoCompleteTableView, attribute: .trailing, relatedBy: .equal, toItem: self.addressSearchBar, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        self.mapViewContentView.addConstraints( [constraint1, constraint2] )
    }
    
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //
    if segue.identifier == "EditLocation" {
      let controller = segue.destination as! LocationDetailViewController
      controller.managedObjectContext = managedObjectContext
      let button = sender as! UIButton
      let location = locations[button.tag]
      controller.locationToEdit = location
    }
    else if segue.identifier == "AddLocation" {
        let controller = segue.destination as! LocationDetailViewController
        controller.location = currentSearchedMapItem!.placemark.location
        controller.placemark = currentSearchedMapItem!.placemark
        controller.coordinate = currentSearchedMapItem!.placemark.coordinate
        controller.managedObjectContext = self.managedObjectContext
    }
    else if segue.identifier == "AddFromCurrentCenter"{
        
        let controller = segue.destination as! LocationDetailViewController
        controller.location = currentCenterPlacemark!.location
        controller.placemark = currentCenterPlacemark!
        controller.coordinate = currentCenterPlacemark!.location!.coordinate
        controller.managedObjectContext = self.managedObjectContext
        
    }
  }

  // MARK: - Actions
  @IBAction func showUser() {
    let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    mapView.setRegion(mapView.regionThatFits(region), animated: true)
  }

  @IBAction func showLocations() {
    let theRegion = region(for: locations)
    mapView.setRegion(theRegion, animated: true)
  }

  // MARK: - Helper methods
  func updateLocations() {
    mapView.removeAnnotations(locations)
    // MARK: - Fetch Again
    let entity = Location.entity()
    let fetchRequest = NSFetchRequest<Location>()
    fetchRequest.entity = entity
    locations = try! managedObjectContext.fetch(fetchRequest)
    mapView.addAnnotations(locations)
    //
  }

  func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
    let region: MKCoordinateRegion

    switch annotations.count {
    case 0:
      region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)

    case 1:
      let annotation = annotations[annotations.count - 1]
      region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)

    default:
      var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
      var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)

      for annotation in annotations {
        topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
        topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude)
        bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
        bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
      }

      let center = CLLocationCoordinate2D(
        latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
        longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)

      let extraSpace = 1.1
      let span = MKCoordinateSpan(latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace, longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)

      region = MKCoordinateRegion(center: center, span: span)
    }

    return mapView.regionThatFits(region)
  }

  @objc func showLocationDetails(_ sender: UIButton) {
    performSegue(withIdentifier: "EditLocation", sender: sender)
  }
    
    //
    @objc func performSegueForRecentSearch(){
        performSegue(withIdentifier: "AddLocation", sender: nil)
    }
    //
    @objc func performSegueForCenterUpdate(){
        performSegue(withIdentifier: "AddFromCurrentCenter", sender: nil)
    }
    //
}

//MARK: - Mapview Delegating for making MK Annotation View <- MK Annotation
extension MapViewController: MKMapViewDelegate {
    
    // 1). main
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation is Location else {
        
        //MARK:- Location 출신의 Annotation이 아닐 경우
        if annotation is SearchedLocation {
            let identifier = "SearchedLocation"
            var searchedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            //없었을 경우
            if searchedAnnotationView == nil {
                let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinView.isEnabled = true
                pinView.canShowCallout = true
                let rightButton = UIButton(type: .contactAdd )
                rightButton.tintColor = UIColor(named: "tblue")
                rightButton.addTarget(
                    self,
                    action: #selector( performSegueForRecentSearch ), // perform segue
                    for: .touchUpInside
                )
                pinView.rightCalloutAccessoryView = rightButton
                searchedAnnotationView = pinView
            }
            if let searchedAnnotationView = searchedAnnotationView {
                    // MARK: - 주석 내용 넣기
                    searchedAnnotationView.annotation = annotation
                ( searchedAnnotationView as! MKPinAnnotationView ).pinTintColor = UIColor(named:"tblue")
                }
            return searchedAnnotationView
        }
        
        //
        else if annotation is CurrentCenterLocation {
            let identifier = "CurrentCenterLocation"
            var centerAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            //없었을 경우
            if centerAnnotationView == nil {
                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.isEnabled = true
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "tag")!
                let rightButton = UIButton(type: .contactAdd )
                rightButton.tintColor = UIColor(named: "tblue")
                rightButton.addTarget(
                    self,
                    action: #selector( performSegueForCenterUpdate ), // perform segue
                    for: .touchUpInside
                )
                annotationView.rightCalloutAccessoryView = rightButton
                centerAnnotationView = annotationView
            }
            if let centerAnnotationView = centerAnnotationView {
                    // MARK: - 주석 내용 넣기
                    centerAnnotationView.annotation = annotation
                }
            return centerAnnotationView
        }
        
        //
        return nil
    }
    
    //MARK: - Making Annotation From Another 2 VC.
    let identifier = "Location"
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
    // 새로운 핀 뷰 만들기
    if annotationView == nil {
        
        let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        pinView.isEnabled = true
        pinView.canShowCallout = true
        let rightButton = UIButton(type: .detailDisclosure)
        rightButton.addTarget(
            self,
            action: #selector( showLocationDetails(_:) ), //
            for: .touchUpInside
        )
        pinView.rightCalloutAccessoryView = rightButton
        annotationView = pinView
        //
        annotationView!.contentMode = .scaleAspectFill
        annotationView!.tintColor = UIColor.systemBlue
        //
    }
    // MARK: - 재활용하거나 만들어진 핀뷰 커스텀화
    if let annotationView = annotationView {
        // MARK: - 주석 내용 넣기
        annotationView.annotation = annotation
        let button = annotationView.rightCalloutAccessoryView as! UIButton
        if let index = locations.firstIndex( of: annotation as! Location ) {
            button.tag = index
        }
        //MARK: - Configure Image, set 45 * 45 and Put into AnnotationView <- init with 45 * 45 size
        var photoID : String
        if (annotation as! Location).locationPhotos.isEmpty {
            photoID = "noImage"
        }else{
            photoID = (annotation as! Location).locationPhotos[0]
        }
        if photoID == "noImage" {
            annotationView.image = UIImage(named: "noImage")?.resized(withBounds: CGSize(width: 45, height: 45) )
        }else{
            let fileName = "image-\(photoID).jpg"
            let newDirectory = applicationDocumentsDirectory.appendingPathComponent(fileName, isDirectory: false)
            do {
                let data = try Data(contentsOf: newDirectory)
                annotationView.image = UIImage( data: data )!.resized(withBounds: CGSize(width: 45, height: 45))
                annotationView.backgroundColor = UIColor.black
            } catch  {
//                print("There was no such image : \(newDirectory.absoluteString)")
                fatalError("\(error.localizedDescription)")
            }
        }
        //
        formatAnnotation(annotationView, for: self.mapView)
    }
    
    //MARK: - Return MK Annotation View
    return annotationView
  }
    
    // MARK: - Configure AnnotationView According to : 1/ZoomOutLevel
    func formatAnnotation(_ annotationView : MKAnnotationView, for map: MKMapView){
        if var zoomOutLevel = self.zoomOutLevel {
            //MARK:- Configure Image Size According To User's Zoom Out level.
            switch zoomOutLevel {
                case let a where a > 5:
                    zoomOutLevel = 2
                case let a where a <= 5 :
                    zoomOutLevel = 1
                default :
                    break
            }
            let scale =  1.15 * ( 1 / CGFloat(zoomOutLevel) )
            annotationView.transform = CGAffineTransform( scaleX: CGFloat(scale), y: CGFloat(scale) )
        }
    }
    
    // MARK: - Calculate Zoom Out Level & If pinch out or in detected Configure Annotations Accordinly
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        mapView.removeAnnotations( tillNowMapAddedCenterAnnotations )
        tillNowMapAddedCenterAnnotations = [] //MARK:- Reset
        
        self.updatedMapViewCenter = self.mapView.centerCoordinate
        //
        let zoomWidth = mapView.visibleMapRect.size.width
        self.zoomOutLevel = Int( log2(zoomWidth) ) - 7
//        print("mapview zoom out level now : \(self.zoomOutLevel!)")
        // MARK : - If pinch zoom in/out is finished
        if (mapChangedFromUserInteraction) {
//            print("User just finished zooming in/out.")
            self.mapView.removeAnnotations(locations)
            self.mapView.addAnnotations(locations)
        }
        //
        let nowLat = self.mapView.centerCoordinate.latitude
        let nowLong = self.mapView.centerCoordinate.longitude
        //
        //MARK: - find placemark for coordinate - background thread schedule
        DispatchQueue.global().async {
            //
            let stdLat = nowLat
            let stdLong = nowLong
            //
            self.geoCoder.reverseGeocodeLocation(  CLLocation(latitude: nowLat, longitude: nowLong) ){ placemarks, error in
                if let error = error {
                    return
                }
                if let placemarks = placemarks {
                    let responsePlacemark = placemarks.last!
                    DispatchQueue.main.async {
                        if ( self.updatedMapViewCenter!.longitude == stdLong && self.updatedMapViewCenter!.latitude == stdLat) {
                            self.currentCenterPlacemark = responsePlacemark
                            let currentCenterLocation = CurrentCenterLocation()
                            currentCenterLocation.coordinate = responsePlacemark.location!.coordinate
                            currentCenterLocation.title = "여기에 블로그 작성 📷".localized()
                            var addressString = string(from: responsePlacemark )
                            if addressString.isEmpty { addressString = "미등록 주소".localized()}
                            currentCenterLocation.subtitle = addressString
                            self.mapView.addAnnotation( currentCenterLocation )
                            self.tillNowMapAddedCenterAnnotations.append( currentCenterLocation )
                        }
                    }
                }
        }

        
        //
    }
    }
    
    
    //
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
    }
    //
    
    // MARK:- Helper Methods
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( ( recognizer.state == UIGestureRecognizer.State.began || recognizer.state == UIGestureRecognizer.State.ended ) ) {
                    return true
                }
            }
        }
        return false
    }
    
    func setRegion(on coordinate : CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3200, longitudinalMeters: 3200)
        mapView.setRegion(region, animated: true)
    }
    
    //
    // MARK: - mapview tapped -> if tableview is visible -> invisible
    @objc func hideSearchOptionsTable(_ gestureRecognizer: UIGestureRecognizer) {
        if autoCompleteTableView.isHidden == false {
            autoCompleteTableView.isHidden = true
        }
        if addressSearchBar.isFirstResponder == true{
            addressSearchBar.resignFirstResponder()
        }
    }
    
    // MARK: - End of Extension mapview
}

extension MapViewController : UISearchBarDelegate {
    //
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchBar.text!.isEmpty else{ return }
        //MARK:- Make Request And Get Auto Completed Location Objs
        self.searchCompleter!.queryFragment = searchBar.text!
        self.currentAutoCompletionResults =  self.searchCompleter!.results
        //MARK: - Display the text of auto completed results into table view
        self.autoCompleteTableView.isHidden = false
        self.autoCompleteTableView.reloadData()
    }
    //
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard !searchBar.text!.isEmpty else{ return }
        //MARK:- Make Request And Get Auto Completed Location Objs
        self.searchCompleter!.queryFragment = searchBar.text!
        self.currentAutoCompletionResults =  self.searchCompleter!.results
        //MARK: - Display the text of auto completed results into table view
        self.autoCompleteTableView.isHidden = false
        self.autoCompleteTableView.reloadData()
    }
    
    //
}


extension MapViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteCell")!
        let result = self.currentAutoCompletionResults[indexPath.row]
        //
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        //
        return cell
        //
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print( self.currentAutoCompletionResults.count )
        return self.currentAutoCompletionResults.count
    }
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedResult = currentAutoCompletionResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: selectedResult)
        searchRequest.region = mapView.region
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let response = response else {
                return
            }
            //
            print("there are \(response.mapItems.count) results for clicked location.")
            //
            guard !response.mapItems.isEmpty else {
                print("not a valid address")
                return
            }
            //
            let targetLocationMapItem = response.mapItems[0]
            //
            self.currentSearchedMapItem = targetLocationMapItem
            self.currentSearchedLocatoin = targetLocationMapItem.placemark.coordinate
            //
            self.addressSearchBar.text = targetLocationMapItem.name ?? ""
            tableView.isHidden = true
            
           //MARK:- Make a new SearchedAnnotation Object and add annotation
            if let originalSearchedAnnotation = self.currentSearchedAnnotation{
                self.mapView.removeAnnotation(originalSearchedAnnotation)
            }
            let searchAnnoation = SearchedLocation()
            searchAnnoation.coordinate = targetLocationMapItem.placemark.coordinate
            searchAnnoation.title = targetLocationMapItem.name
            searchAnnoation.subtitle = string(from: targetLocationMapItem.placemark)
            self.currentSearchedAnnotation = searchAnnoation
            //
            self.mapView.addAnnotation(searchAnnoation)
            //
            self.setRegion(on: targetLocationMapItem.placemark.coordinate )
            //
        }
    }
}

