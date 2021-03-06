//
//  ViewController.swift
//  EarthquakeShelter
//
//  Created by D7703_18 on 2018. 11. 5..
//  Copyright © 2018년 201550057. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

let location = CLLocationCoordinate2D(latitude: 35.180100, longitude: 129.081017)
let span = MKCoordinateSpan(latitudeDelta: 0.0027, longitudeDelta: 0.0027)
let region = MKCoordinateRegion(center: location, span: span)

class ViewController: UIViewController, XMLParserDelegate,CLLocationManagerDelegate  {
    
    @IBOutlet var scZoom: UISegmentedControl!
    @IBOutlet var myMapView: MKMapView!
    
     let locationManager = CLLocationManager()
     var manualZoom = false
    var annotation: BusanData?
    var annotations: Array = [BusanData]()
    
    var selected: BusanData?
    
    var item: [String:String] = [:]
    var items: [[String:String]] = []
    var currentElement = ""
    
    var address: String?
    var lat: String?
    var long: String?
    var name: String?
    var capcity : String?
    var loc: String?
    var dLat: Double?
    var dLong: Double?
   
    func sortAnnotations() {
        if let userLocation = locationManager.location {
            annotations.sort { (a, b) -> Bool in
                let locationA = CLLocation.init(
                    latitude: a.coordinate.latitude, longitude: a.coordinate.longitude)
                let locationB = CLLocation.init(
                    latitude: b.coordinate.latitude, longitude: b.coordinate.longitude)
                let distanceA = userLocation.distance(from: locationA)
                let distenceB = userLocation.distance(from: locationB)
                return distanceA < distenceB
            }
        }
    }
    
    var currentZoomLevel = CLLocationDistance(100)
    func setZoomLevel(_ meters: CLLocationDistance, center: CLLocationCoordinate2D?) {
        var useCurrentZoom = false
        if meters < 0 { return }
        if meters == 0 {
            useCurrentZoom = true
        } else {
            currentZoomLevel = meters
        }
        let center = center ?? myMapView.region.center
        var viewRegion = MKCoordinateRegionMakeWithDistance(center, meters, meters)
        if useCurrentZoom {
            viewRegion = MKCoordinateRegionMakeWithDistance(center, currentZoomLevel, currentZoomLevel)
        }
        let adjustedRegion = myMapView.regionThatFits(viewRegion)
        myMapView.setRegion(adjustedRegion, animated: true)
    }
    
    @IBAction func scZoomchanged(_ sender: UISegmentedControl) {
        let selected = sender.selectedSegmentIndex
        switch selected {
        case 0:
            print("500 selected")
            sortAnnotations()
            let selected = annotations[0]
            myMapView.selectAnnotation(selected, animated: true)
            setZoomLevel(1000, center:selected.coordinate)
        case 1:
            print("1km selected")
            sortAnnotations()
            let selected = annotations[0]
            myMapView.selectAnnotation(selected, animated: true)
            setZoomLevel(2000, center:selected.coordinate)
        case 2:
            print("2km selected")
            sortAnnotations()
            let selected = annotations[0]
            myMapView.selectAnnotation(selected, animated: true)
            setZoomLevel(5000, center:selected.coordinate)
        case 3:
            print("fullscreen selected")
            self.viewDidLoad()
//            manualZoom = false
//            let userLocation = myMapView.userLocation
//            let region = MKCoordinateRegionMakeWithDistance((userLocation.location?.coordinate)!, 5000, 5000)
//            myMapView.setRegion(region, animated: true)
//            print("\(1*selected)km selected")
//            setZoomLevel(CLLocationDistance(200 * selected), center: nil)
        default:
            break
        }
       
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.myMapView.showsUserLocation = true
        
        if let path = Bundle.main.url(forResource: "Shelter", withExtension: "xml"){
            if let myParser = XMLParser(contentsOf: path) {
                myParser.delegate = self
                if myParser.parse() {
                    print("파싱 성공")
                } else {
                    print("파싱 실패")
                }
            } else {
                print("파싱 오류1")
            }
        } else {
            print("XML 파일 없음")
        }
        
        myMapView.delegate = self
        
        // 초기맵 설정
        zoomToRegion()
        
        for item in items {
            lat = item["ycord"]
            long = item["xcord"]
            name = item["vt_acmdfclty_nm"]
            loc = item["dtl_adres"]
            capcity = item["fclty_ar"]
            dLat = Double(lat!)
            dLong = Double(long!)
            annotation = BusanData(title: name!, subtitle: loc!, capcity: capcity!, coordinate: CLLocationCoordinate2D(latitude: dLat!, longitude: dLong!))
            annotations.append(annotation!)
        }
        myMapView.showAnnotations(annotations, animated: true)
        myMapView.addAnnotations(annotations)
        
    }
    
    func zoomToRegion() {
        let location = CLLocationCoordinate2D(latitude: 35.180100, longitude: 129.081017)
        let span = MKCoordinateSpan(latitudeDelta: 0.0027, longitudeDelta: 0.0027)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
    }
    
    // XMLParser Delegete 메소드
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        // 현재 위치는 pin 모양 바꾸기 제외
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        if annotation.isKind(of: BusanData.self) {
            var annotationView = myMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.animatesDrop = true
            } else {
                annotationView?.annotation = annotation
            }
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
            return annotationView
        }
        return nil
    }
    
    // XML 파서가 시작 테그를 만나면 호출됨
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }
    
    // XML 파서가 종료 테그를 만나면 호출됨
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "row" {
            items.append(item)
        }
    }
    
    // 현재 테그에 담겨있는 문자열 전달
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        // 공백제거
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        // 공백체크 후 데이터 뽑기
        if !data.isEmpty {
            item[currentElement] = data
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.latitude)
        let region = MKCoordinateRegion(center: center, span:MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        self.myMapView.setRegion(region, animated: true)
        self.locationManager.startUpdatingLocation()
    }
}

extension ViewController : MKMapViewDelegate
{
    func myMapView(_ myMapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? BusanData {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = myMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        let location = view.annotation as! BusanData
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
//        location.mapItem().openInMaps(launchOptions: launchOptions)
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        selected = view.annotation as? BusanData
        if control == view.rightCalloutAccessoryView {
            self.performSegue(withIdentifier: "showDetail", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.selectedForDetail = self.selected
        }
    }
}
