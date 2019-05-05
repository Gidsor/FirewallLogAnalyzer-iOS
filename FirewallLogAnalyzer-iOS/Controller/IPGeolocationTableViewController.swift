//
//  IPGeolocationTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 04/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit
import MapKit

class IPGeolocationTableViewController: UITableViewController {
    @IBOutlet weak var ipTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var hostnameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var continentCodeLabel: UILabel!
    @IBOutlet weak var continentNameLabel: UILabel!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var regionCodeLabel: UILabel!
    @IBOutlet weak var regionNameLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var geonameIdLabel: UILabel!
    @IBOutlet weak var capitalLabel: UILabel!
    @IBOutlet weak var countryFlagLabel: UILabel!
    @IBOutlet weak var callingCodeLabel: UILabel!
    
    private var initCompleation: ((String) -> ())?
    private var ip: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        setupKeyboard()
        if let ip = ip {
            initCompleation?(ip)
        }
    }
    
    func setupKeyboard() {
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        ipTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        view.endEditing(true)
    }
    
    func search(ip: String) {
        guard let ipTextField = ipTextField else {
            self.ip = ip
            initCompleation = search(ip:)
            return
        }
        ipTextField.text = ip
        search(ip)
    }
    
    @IBAction func search(_ sender: Any) {
        guard let ip = ipTextField.text else { return }
        self.view.endEditing(true)
        NetworkManager.shared.getLocation(ip: ip) { (status, ipGeoLocation) in
            guard let ipGeoLocation = ipGeoLocation else { return }
            self.ipLabel.text = ipGeoLocation.ip
            self.hostnameLabel.text = ipGeoLocation.hostname
            self.typeLabel.text = ipGeoLocation.type
            self.continentCodeLabel.text = ipGeoLocation.continentCode
            self.continentNameLabel.text = ipGeoLocation.continentName
            self.countryCodeLabel.text = ipGeoLocation.countryCode
            self.countryNameLabel.text = ipGeoLocation.countryName
            self.regionCodeLabel.text = ipGeoLocation.regionCode
            self.regionNameLabel.text = ipGeoLocation.regionName
            self.cityLabel.text = ipGeoLocation.city
            self.zipLabel.text = ipGeoLocation.zip
            if let latitude = ipGeoLocation.latitude {
                self.latitudeLabel.text = "\(latitude)"
            }
            if let longitude = ipGeoLocation.longitude {
                self.longitudeLabel.text = "\(longitude)"
            }
            if let geonameId = ipGeoLocation.geonameId {
                self.geonameIdLabel.text = "\(geonameId)"
            }
            self.capitalLabel.text = ipGeoLocation.capital
            self.countryFlagLabel.text = ipGeoLocation.countryFlagEmoji
            self.callingCodeLabel.text = ipGeoLocation.callingCode
            
            if let latitude = ipGeoLocation.latitude, let longitude = ipGeoLocation.longitude {
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                self.mapView.addAnnotation(annotation)
                self.mapView.setCenter(location, animated: true)
                let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
}
