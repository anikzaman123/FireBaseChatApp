//
//  myMapScreen.swift
//  FireBaseChatApp
//
//  Created by Anik Zaman on 7/11/17.
//  Copyright © 2017 Anik Zaman. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class myMapScreen: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var myView: UIView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.showCurrentLocationOnMap()
        self.locationManager.stopUpdatingLocation()
    }
    
    
    

    func showCurrentLocationOnMap() {
        
        let camera = GMSCameraPosition.camera(withLatitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!, zoom: 14)
        
        let mapView = GMSMapView.map(withFrame: CGRect(x:0, y: 0, width:self.myView.frame.size.width, height:self.myView.frame.size.height), camera: camera)
        
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        
        let marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = "Current Location"
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.map = mapView
        self.myView.addSubview(mapView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
