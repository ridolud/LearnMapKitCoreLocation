//
//  ViewController.swift
//  LearnCoreLocation
//
//  Created by Faridho Luedfi on 26/06/19.
//  Copyright © 2019 learnCoreLocation. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationBtn: UIButton!
    
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 2300
    
    var currentLocation = CLLocation() {
        didSet{
            currentLocationAnnootation.coordinate = currentLocation.coordinate
        }
    }
    let currentLocationAnnootation = MKPointAnnotation()
    var currentLocationAnnotationView = MKAnnotationView()
    let carImg = #imageLiteral(resourceName: "car-3")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLocationBtn.layer.cornerRadius = 10
        currentLocationBtn.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        currentLocationBtn.layer.shadowColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        currentLocationBtn.layer.shadowOffset = CGSize(width: 0, height: 8)
        currentLocationBtn.layer.shadowOpacity = 0.4
        currentLocationBtn.layer.shadowRadius = 8
        determinateCurretLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        centerMapOnLocation(true)
    }
    
    func determinateCurretLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        centerMapOnLocation()
        mapView.addAnnotation(currentLocationAnnootation)
    }
    
    // tracking location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue: CLLocation = locationManager.location else { return }
        // print("locations = \(locationValue.coordinate.latitude) , \(locationValue.coordinate.longitude)")
        currentLocation = locationValue
        let newImg = UIImage()
        currentLocationAnnotationView.image = newImg.rotateImage(image: carImg, angle: CGFloat(locationValue.course), flipVertical: 0, flipHorizontal: 0)
        print(currentLocation.course)
    }
    

    @IBAction func changeLocation(_ sender: UIButton) {
        centerMapOnLocation(true)
    }
    
    // When telling the map what to display, giving a latitude and longitude is enough to center the map,
    // but you must also specify the rectangular region to display, to get a correct zoom level.
    func centerMapOnLocation(_ animate: Bool = false) {
        guard let locationValue: CLLocation = locationManager.location else { return }
        
        let coordinateRegion = MKCoordinateRegion(center: locationValue.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: animate)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {return nil}
        
        let annotationIndentifier = "yellowCar"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIndentifier)
        
        currentLocationAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIndentifier)
        currentLocationAnnotationView.canShowCallout = true
        
        currentLocationAnnotationView.image = #imageLiteral(resourceName: "car-3")
        return currentLocationAnnotationView
    }
}

extension UIImage {
    func rotateImage(image:UIImage, angle:CGFloat, flipVertical:CGFloat, flipHorizontal:CGFloat) -> UIImage? {
        let ciImage = CIImage(image: image)
        
        let filter = CIFilter(name: "CIAffineTransform")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setDefaults()
        
        let newAngle = angle * CGFloat(-1)
        
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, CGFloat(newAngle), 0, 0, 1)
        transform = CATransform3DRotate(transform, CGFloat(Double(flipVertical) * .pi), 0, 1, 0)
        transform = CATransform3DRotate(transform, CGFloat(Double(flipHorizontal) * .pi), 1, 0, 0)
        
        let affineTransform = CATransform3DGetAffineTransform(transform)
        
        filter?.setValue(NSValue(cgAffineTransform: affineTransform), forKey: "inputTransform")
        
        let contex = CIContext(options: [CIContextOption.useSoftwareRenderer:true])
        
        let outputImage = filter?.outputImage
        let cgImage = contex.createCGImage(outputImage!, from: (outputImage?.extent)!)
        
        let result = UIImage(cgImage: cgImage!)
        return result
    }
}
