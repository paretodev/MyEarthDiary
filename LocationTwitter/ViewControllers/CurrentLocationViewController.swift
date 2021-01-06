//
//  CurrentLocationViewController.swift
//  LocationTwitter
//
//  Created by 한석희 on 12/12/20.
//

// MARK:- import lbiraries
import UIKit
import MapKit
import CoreLocation
import AudioToolbox
import CoreData

//
class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK:- Ins Vars
        // 1). UI Elements
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeValueLabel: UILabel!
    @IBOutlet weak var LongitudeValueLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var WriteBlogButton: UIButton!
    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet weak var containerView: UIView!
        // 2). View Controller Ins Vars
    var locationManager = CLLocationManager()
    var updatingLocation : Bool = false
    var timer : Timer?
    var lastLocationError : NSError?
    var currentPlacemark : CLPlacemark?
    var performingGeocoding = false
    var indicatorView : UIActivityIndicatorView?
    var indicatorLabel : UILabel?
    var geoCoder = CLGeocoder()
    var soundID: SystemSoundID = 0
    lazy var managedObjectContext : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let objContext = appDelegate.managedObjectContext
        return objContext
    }()
    var location : CLLocation? {
        didSet {
            if let location = location {
                latitudeValueLabel.text = "\(location.coordinate.latitude)"
                LongitudeValueLabel.text = "\(location.coordinate.longitude)"
            }
        }
    }
    var currentLocationState : CurrentLocationState? {
        didSet {
            // Defensive
            if  !( [ CurrentLocationState.unknownTill6 , CurrentLocationState.updatingLoc ].contains(currentLocationState) ){
                self.stopIndicator()
            }
            //
            configureLabel()
            //
            if currentLocationState == CurrentLocationState.completeLoc && performingGeocoding == false{
                let onceConfirmedLocation = location!
                performingGeocoding = true
                geoCoder.reverseGeocodeLocation( onceConfirmedLocation ){ placemarks, error in
                    if let placemarks = placemarks {
                        let responsePlacemark = placemarks.last!
                        if self.currentLocationState == CurrentLocationState.completeLoc {
                            self.currentPlacemark = responsePlacemark
                            self.addressLabel.text = string(from: self.currentPlacemark!)
                            self.WriteBlogButton.isHidden = false
                            self.playSoundEffect()
                        }
                    }
                    else {
                        self.makeAlert( withTitle: "에러".localized(), withContents: "인터넷이 연결되어 있지 않거나, 조회가 되지 않는 주소입니다.".localized() )
                        self.currentLocationState = CurrentLocationState.beforePress
                    }
                    self.performingGeocoding = false
                }
            }
        }
    }
    
    // MARK:- Inital Setups
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSoundEffect("succeed.caf")
        currentLocationState = .beforePress
    }
    
    //MARK:- Action Methods
    @IBAction func getLocation(_ sender: Any) {
        // 위치 미허가
            // 매니저를 통해, 허가 상태를 파악할 수 있음
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
            // 전체 서비스 미허가 또는 이 앱에 대하여 미허가
        if authStatus == .denied || authStatus == .restricted {
            currentLocationState = .locSerDeniedDetected
            makeAlert(withTitle: "위치 서비스 미허용".localized(), withContents:
                        "이 앱을 사용하기 위해서는 위치 서비스 허용이 필요합니다. 기기 전체에 대한 위치 서비스가 허용되어 있는지 확인하고, 이 앱에 대한 위치 서비스를 허용해주세요.".localized())
            return
        }
        // 이미 위치가 잡혔고, 중간에 중단한다면.
        if updatingLocation {
//            print("위치 업데이트 중 유저가 업데이트 중단".localized())
            stopLocationMananger()
            currentLocationState = .completeLoc
        }
        // 다시 버튼 누름
        else {
            location = nil
            currentPlacemark = nil
            startLocationManager()
        }
    }
    
    // MARK:- Location mananger delegate
        // 1). 장소 피드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //
        let newReportedLocation = locations.last!
        if newReportedLocation.timestamp.timeIntervalSinceNow < -5 {
          return
        }
        if newReportedLocation.horizontalAccuracy < 0 {
          return
        }
        //
        if location == nil {
            location = newReportedLocation
            updatingLocation = true // 처음 지정받은 이후 ~ 스탑 전까지 updating location이라고 할 수 있다.
        }
        else {
            if location!.horizontalAccuracy > newReportedLocation.horizontalAccuracy {
                location = newReportedLocation
//                print("정확도 향상 좌표 업데이트!!".localized())
            }
        }
        // 업데이트 된 정확도가 - 타깃 정확도를 넘으면 중단
        if location!.horizontalAccuracy <= locationManager.desiredAccuracy {
//            print("원하던 정확도 달성. 매니저 종료".localized())
            stopLocationMananger()
            currentLocationState = .completeLoc
        }
    }
        // 2). 매니저 에러 메세지
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //
        if (error as NSError).code == CLError.Code.locationUnknown.rawValue{
//            print("trying. but failed for now.")
            if currentLocationState != CurrentLocationState.unknownTill6 {
                currentLocationState = .unknownTill6
            }
            return
        }
        //
        else if (error as NSError).code == CLError.Code.denied.rawValue{
            currentLocationState = .locSerDeniedDetected
            makeAlert(withTitle: "위치 서비스 비활성화".localized(), withContents: "기기의 위치 서비스 또는 이 앱의 위치 서비스 활성화 여부를 확인해주세요.".localized())
            return
        }
    }

    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddLocation" {
            let controller = segue.destination as! LocationDetailViewController
            controller.location = location
            controller.placemark = currentPlacemark
            controller.coordinate=location!.coordinate
            controller.managedObjectContext = self.managedObjectContext
        }
    }

    //MARK:- Helper Method
        // 1). 경고창 모듈
    func makeAlert(withTitle: String, withContents: String){
        let alert = UIAlertController(title: withTitle, message: withContents, preferredStyle: .alert)
        let action = UIAlertAction( title: "확인".localized(), style: .default, handler: nil )
        alert.addAction(action)
        present( alert, animated: true, completion: nil )
    }
        // 2). 장소 페치 타임아웃
    @objc func didTimeOut(){
        if location == nil {
            stopLocationMananger()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            //
            currentLocationState = .unknownToFail
            makeAlert(withTitle: "위치 정보 가져오기 실패".localized(), withContents: "gps, 셀룰러, 와이파이 중 하나를 활성화 해주세요.".localized())
//            print("시스템이 위치를 가져오는 데 실패.".localized())
        }
    }
        // 3).
    func startLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // 위치의 정밀성이 중요할 경우
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        // label config.
        currentLocationState = .updatingLoc
    }
        // 4).
    func stopLocationMananger() {
        // MARK: - Defensive : stop indicatorview if it is running
        self.stopIndicator()
        //
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        //
        updatingLocation = false
        timer?.invalidate()
        //
    }
        // 5).
    func configureLabel() {
        if ![ CurrentLocationState.unknownTill6 , CurrentLocationState.updatingLoc ].contains(currentLocationState) {
            messageLabel.text = currentLocationState!.msgLabelText
        }
        addressLabel.text = currentLocationState!.addressLabelText
        WriteBlogButton.isHidden = currentLocationState!.blogButtonIsHidden
        getLocationButton.setTitle( currentLocationState!.getLocationButtonTitle, for: .normal )
        // detail case handling
        if currentLocationState == CurrentLocationState.unknownTill6 {
            getLocationButton.isHidden = true
        }else{
            getLocationButton.isHidden = false
        }
        // msg label 조절
            // .updatingLoc , .unknownTill6
        if [ CurrentLocationState.unknownTill6 , CurrentLocationState.updatingLoc ].contains(currentLocationState){
            //
            let x = messageLabel.frame.midX
            let y = messageLabel.frame.midY
            //
            let rect = CGRect(
                x : x + 80,
                y:  y - 25,
                width: 50,
                height: 50) // 측면 60포인트에 인디케이터뷰 띄우기
            let rect2 = CGRect(
                x : x - 80,
                y: y - 25,
                width: 160,
                height: 50
            )
            //
            indicatorView = UIActivityIndicatorView(frame: rect)
            indicatorView?.color = UIColor(red: 63.0/255.0, green: 170.0/255.0, blue: 225.0/255.0, alpha: 1.0)
            indicatorView?.startAnimating()
            indicatorLabel = UILabel(frame: rect2)
            indicatorLabel?.textAlignment = .center
            //
            switch currentLocationState {
                case .unknownTill6:
                    indicatorLabel?.text = "나의 위치 잡는 중".localized()
                case .updatingLoc:
                    indicatorLabel?.text = "위치 정확도 향상중".localized()
                default:
                    break
            }
            //
            messageLabel.isHidden = true
            containerView.addSubview(indicatorLabel!)
            containerView.addSubview(indicatorView!)
        }
        else {
            //
            messageLabel.isHidden = false
            if let nowIndicatorView = indicatorView {
                nowIndicatorView.stopAnimating()
                nowIndicatorView.removeFromSuperview()
                indicatorView = nil
            }
            if let label = indicatorLabel {
                label.removeFromSuperview()
                indicatorLabel = nil
            }
        }
    }
    
        //6).
    func loadSoundEffect(_ name: String) {
      if let path = Bundle.main.path(forResource: name, ofType: nil) {
        let fileURL = URL(fileURLWithPath: path, isDirectory: false)
        let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
        if error != kAudioServicesNoError {
//          print("Error code \(error) loading sound: \(path)")
        }
      }
    }
        //7).
    func unloadSoundEffect() {
      AudioServicesDisposeSystemSoundID(soundID)
      soundID = 0
    }
        //8).
    func playSoundEffect() {
      AudioServicesPlaySystemSound(soundID)
    }
    //MARK: - Setter Defend against Indicator view still running
    func stopIndicator(){
        if let nowIndicatorView = indicatorView {
            nowIndicatorView.stopAnimating()
            nowIndicatorView.removeFromSuperview()
            indicatorView = nil
        }
        if let label = indicatorLabel {
            label.removeFromSuperview()
            indicatorLabel = nil
        }
    }
        
    
    //
}

