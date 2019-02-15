//
//  MapViewController.swift
//  20190210-DarrylReed-NYCSchools
//
//  Created by DLR on 2/10/19.
//  Copyright © 2019 DLR. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

// Storing JSON detail keys for easy reference in a custom model object
struct MapKeys {
    let dbn = "dbn"
    let schoolName = "school_name"
    let primaryAddress = "primaryAddressLine1"
    let latitude = "latitude"
    let longitude = "longitude"
    let location = "location"
    let city = "city"
    let stateCode = "stateCode"
    let zip = "zip"
    let schoolEmail = "schoolEmail"
    let grades = "grades2018"
    let website = "website"
    let phoneNumber = "phoneNumber"
    let faxNumber = "faxNumber"
}

enum TravelModes: Int {
    case driving
    case walking
    case bicycling
}

class MyAnnotation: NSObject,MKAnnotation {
    
    var title : String?
    var subTit : String?
    var coordinate : CLLocationCoordinate2D
    
    init(title:String,coordinate : CLLocationCoordinate2D,subtitle:String){
        
        self.title = title;
        self.coordinate = coordinate;
        self.subTit = subtitle;
        
    }
}

class MapViewController: UIViewController,  CLLocationManagerDelegate, MKMapViewDelegate {
    
    static var isFavorite = false
    
    static var schoolName: String = ""
    static var image: UIImage?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locateButtonContainer: UIView!
        
    var alertView: UIAlertController!

    var schoolViewController : ViewController?
    var isDirectoryView = false
    var isSchoolView = false
    
    var schoolDict = [String: String]()
    var schoolMapStructArr = [SchoolDOEDataStruct]()
    
    var detailString = String()
    var categoryTxt: UILabel!
    
    var manager = CLLocationManager()
    
    var travelMode = TravelModes.driving
    
    var distance = 0.0
    
    var counter = 0
    var allLocations = [MKPointAnnotation]()
    
    var annotation: MKAnnotation!
//    var annotations = [Location]()
//    var filteredAnnotations = [Location]()
    
    var url = ""
    var titleName = ""
    var titleURL = ""
    var polylineRoute = CLLocation()
    var coordinate1 = CLLocation()
    var coordinate2 = CLLocation()
    let locationManager = CLLocationManager()
    var currentRoute = MKPolyline()
    var tempRoute = MKPolyline()
    
    private let reuseIdentifier = "MyIdentifier"
    
    let userDefaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadSchoolData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewChanges()
        
        // Core Location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        locateButtonContainer.layer.cornerRadius = locateButtonContainer.frame.size.width / 2
        locateButtonContainer.clipsToBounds = true
        locateButtonContainer.layer.borderWidth = 1
        
        self.setupLocateButton()
        
//        let annotations = getMapAnnotations()
//        mapView.addAnnotations(annotations)
        
        let latitude:CLLocationDegrees = 76.0100
        let longitude:CLLocationDegrees = 25.3620
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        // Second Location lat and long
        let latitudeSec:CLLocationDegrees = 75.0100
        let longitudeSec:CLLocationDegrees = 24.3620
        
        let locationSec:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitudeSec, longitudeSec)
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        let myAn1 = MyAnnotation(title: "Office", coordinate: location, subtitle: "My Office")
        let myAn2 = MyAnnotation(title: "Office 1", coordinate: locationSec, subtitle: "My Office 1")
        
        mapView.addAnnotation(myAn1)
        mapView.addAnnotation(myAn2)
        
        for location in allLocations {
            let loc = MKPointAnnotation()
//            loc.title = cityNames[counter]
            loc.subtitle = String(counter + 1)
            loc.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                    longitude: location.coordinate.longitude);
            allLocations.append(loc)
            counter += 1
        }
        // show annotations
        mapView.addAnnotations(allLocations as [MKAnnotation])
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - Functions
    
    // Making API call to get school addesss & additional info
    func loadSchoolData() {
        // Construct url in a specific nmanner
        guard let schoolUrl = URL(string: "https://data.cityofnewyork.us/resource/97mf-9njv.json") else {
            alertView.message = "Could not convert https://data.cityofnewyork.us/resource/97mf-9njv.json to URL"
            self.present(self.alertView, animated: true, completion: nil)
            return
        }
        // Making the API call to fetch data from the internet
        let schoolTask = URLSession.shared.dataTask(with: schoolUrl) { (data, resp, err) in
            guard let dataResp = data,
                err == nil else {
                    self.alertView.message = err?.localizedDescription ?? "Error receiving data"
                    self.present(self.alertView, animated: true, completion: nil)
                    return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: dataResp, options: [])
                guard let jsonDict = json as? [[String: String]] else {
                    self.alertView.message = "Could not convert json to [String: String]"
                    self.present(self.alertView, animated: true, completion: nil)
                    return
                }
                // Initial storing of [dbns: school location & additional info.]
                for i in 0..<jsonDict.count {
                    self.schoolDict[jsonDict[i][MapKeys().dbn]!] = jsonDict[i][MapKeys().schoolName]!
                }
                // Creating custom school struct for easy data access
                for i in 0..<jsonDict.count {
                    let schoolLOC = jsonDict[i][MapKeys().dbn]!
                    if self.schoolDict[schoolLOC] != nil {
                        var schoolMapStruct = SchoolDOEDataStruct()
                        schoolMapStruct.dbn = schoolLOC
                        schoolMapStruct.schoolName = self.schoolDict[schoolLOC] ?? nil
                        schoolMapStruct.primaryAddressLine1 = jsonDict[i][MapKeys().primaryAddress] ?? nil
                        schoolMapStruct.latitude = jsonDict[i][MapKeys().latitude] ?? nil
                        schoolMapStruct.longitude = jsonDict[i][MapKeys().longitude] ?? nil
                        schoolMapStruct.grades2018 = jsonDict[i][MapKeys().grades] ?? nil
                        schoolMapStruct.website = jsonDict[i][MapKeys().website] ?? nil
                        schoolMapStruct.zip = jsonDict[i][MapKeys().longitude] ?? nil
                        schoolMapStruct.schoolEmail = jsonDict[i][MapKeys().schoolEmail] ?? nil
                        schoolMapStruct.website = jsonDict[i][MapKeys().website] ?? nil
                        self.schoolMapStructArr.append(schoolMapStruct)
                    }
                }
                // Updates to UI are on the main thread
                DispatchQueue.main.async {
                }
            } catch let parsingErr {
                self.alertView.message = parsingErr.localizedDescription
                self.present(self.alertView, animated: true, completion: nil)
            }
            // Convert data from Json into string format
            let dataAsString = String (bytes: dataResp, encoding: .utf8)
            // Print out the string format
            print(dataAsString as Any)
        }
        // Fire off the URLSession
        schoolTask.resume()
    }
    
    func viewChanges() {
        if(isDirectoryView) {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(1.0)
            UIView.setAnimationTransition(.flipFromLeft, for: (self.view)!, cache: true)
            UIView.commitAnimations()
        } else {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(1.0)
            UIView.setAnimationTransition(.flipFromLeft, for: (self.view)!, cache: true)
        }
        self.isDirectoryView = self.isSchoolView ? false : true
    }
    
    private func setupLocateButton() {
        let locateButton = MKUserTrackingButton(mapView: self.mapView)
        locateButton.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        locateButton.frame = self.locateButtonContainer.bounds
        
        self.locateButtonContainer.addSubview(locateButton)
        self.locateButtonContainer.layer.borderColor = UIColor(red:0.20, green:0.19, blue:0.30, alpha:1.0).cgColor // UIColor(white: 0.2, alpha: 0.2).cgColor
        self.locateButtonContainer.backgroundColor = UIColor(hue: 0.13, saturation: 0.03, brightness: 0.97, alpha: 1.0)
        self.locateButtonContainer.layer.borderWidth = 1
        self.locateButtonContainer.layer.cornerRadius = 8
        self.locateButtonContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.locateButtonContainer.layer.shadowRadius = 2
        self.locateButtonContainer.layer.shadowOpacity = 0.5
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print(error.localizedDescription)
    }
    
    func calcDistance(sourceLat: Double, sourceLong: Double, destLat: Double, destLong: Double) {
        coordinate1 = CLLocation(latitude: sourceLat, longitude: sourceLong)
        coordinate2 = CLLocation(latitude: destLat, longitude: destLong)
        distance = (coordinate1.distance(from: coordinate2) / 1600).rounded()
        print(distance)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.purple
        renderer.lineWidth = 5.0
        return renderer
    }
    
    func addPinToMapView(title: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let _ = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = CLLocation(latitude: latitude, longitude: longitude)
//        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        titleName = (view.annotation?.title ?? "")!
        titleURL = (view.annotation?.subtitle ?? "")!

        if control == view.rightCalloutAccessoryView {
            distance = (coordinate1.distance(from: coordinate2) / 1600).rounded()
            print("\(distance)%.01/1000fkm")
            print(String(format:" %.01fmi", distance))
            print("\(distance)%.1/100fmi")
        }
    }

    //MARK: - Zoom to region
    
//    func zoomToRegion() {
//        let latitude = Double(MapViewController.latitude) ?? nil
//        let longitude = Double(MapViewController.longitude) ?? nil
//        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
//        let span = MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
//        let region = MKCoordinateRegion(center: coordinate, span: span)
//        self.mapView.setRegion(region, animated: true)
//    }

    //MARK:- Annotations
    
//    func findAnnotations(from: [Location]) -> [CLLocation] {
//        for item in from {
//            let lat = item.latitude
//            let long = item.longitude
//            let annotation = Location(latitude: lat, longitude: long)
//            annotation.title = item.title
//            annotation.subtitle = item.subtitle
//            annotations.append(annotation)
//        }
//        return annotations
//    }
    
//    func getSingleAnnotation() -> [CLLocation] {
//        var annotations:Array = [CLLocation]()
//
//        let schoolDict = locations?["schoolLOC"] as! [AnyObject]
//
//        for item in schoolDict {
//            let obj = schoolMapStructArr()
//            obj.dbn = (item["dbn"] as? String ?? "")
//            obj.schoolName = (item["schoolName"] as? String ?? "")
//            obj.primaryAddress = (item["primaryAddress"] as? String ?? "")
//            obj.longitude = (item["longitude"] as? String ?? "")
//            obj.latitude = (item["latitude"] as? String ?? "")
//            obj.city = (item["city"] as? String ?? "")
//            obj.url = (item["link"] as? String ?? "")
//            obj.grades = (item["grades"] as? String ?? "")
//        }
//
//        let lat = Double(MapViewController.latitude) ?? nil
//        let long = Double(MapViewController.longitude) ?? nil
//        let annotation = Location(latitude: lat!, longitude: long!)
//        annotation.title = MapViewController.detailInfoObj.name
//        annotation.subtitle = MapViewController.detailInfoObj.url
//        annotations.append(annotation)
//        return annotations
//    }
    
//    func getMapAnnotations() -> [Location] {
//        var annotations:Array = [Location]() // 0 elements
//
//        var locations: NSDictionary?
//        let schoolDict = locations?["schoolLOC"] as! [AnyObject]
//
//        for item in schoolDict {
//            let obj = schoolMapStructArr()
//            obj.dbn = (item["dbn"] as? String ?? "")
//            obj.schoolName = (item["schoolName"] as? String ?? "")
//            obj.primaryAddress = (item["primaryAddress"] as? String ?? "")
//            obj.longitude = (item["longitude"] as? String ?? "")
//            obj.latitude = (item["latitude"] as? String ?? "")
//            obj.city = (item["city"] as? String ?? "")
//            obj.url = (item["link"] as? String ?? "")
//            obj.grades = (item["grades"] as? String ?? "")
//
//            let latitude = Double(MapViewController.latitude) ?? nil
//            let longitude = Double(MapViewController.longitude) ?? nil
//
//            if latitude != nil && longitude != nil {
//                let annotation = Location(latitude: latitude!, longitude: longitude!)
//                annotation.title = ((item as AnyObject).value(forKey: "schoolName") as? String)
//                annotation.subtitle = ((item as AnyObject).value(forKey: "primaryAddress")  as? String)
//                annotation.link = ((item as AnyObject).value(forKey: "link") as! String)
//                annotations.append(annotation)
//            }
//        }
//        return annotations
//    }

    // Calculate the distance from user's location to NYC High School
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .none
//        formatter.groupingSeparator = ","
//
//        let _ = formatter.string(for: distance)
//        print(String(describing: distance))
//
//        if let source_lat = locationManager.location?.coordinate.latitude,
//            let source_long = locationManager.location?.coordinate.longitude,
//            let dest_lat = view.annotation?.coordinate.latitude,
//            let destLong = view.annotation?.coordinate.longitude {
//
//            calcDistance(sourceLat: source_lat, sourceLong: source_long, destLat: dest_lat, destLong: destLong)
//        }
//
//        calcDistance(sourceLat: (locationManager.location?.coordinate.latitude)!, sourceLong: (locationManager.location?.coordinate.longitude)!, destLat: (view.annotation?.coordinate.latitude)!, destLong: (view.annotation?.coordinate.longitude)!)
//    }
}

// Extension to convert distance into meters for proximity or directions (pending User permission is granted)
extension CLLocationCoordinate2D {
    func distanceInMetersFrom(otherCoord : CLLocationCoordinate2D) -> CLLocationDistance {
        let sourceCoordinates = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let destinationCoordinates = CLLocation(latitude: latitude, longitude: longitude)
        return sourceCoordinates.distance(from: destinationCoordinates)
    }
}
