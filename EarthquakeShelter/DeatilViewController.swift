//
//  DetailViewController.swift
//  EarthquakeShelter
//
//  Created by D7703_18 on 2018. 11. 12..
//  Copyright © 2018년 201550057. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UITableViewController,MKMapViewDelegate {
    
    var segue = UIStoryboardSegue(identifier: "", source: UIViewController(), destination: UIViewController())
    
    var selected = BusanData.init(title: "", subtitle: "", coordinate: CLLocationCoordinate2DMake(0, 0))
    
    @IBOutlet weak var lblAddr: UILabel!
    @IBOutlet weak var lblCapacity: UILabel!
    @IBOutlet weak var mvOne: MKMapView!
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let barButton = UIBarButtonItem()
        barButton.title = "Your Title"
        self.navigationItem.backBarButtonItem = barButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mvOne.addAnnotation(selected)
        mvOne.showAnnotations([selected], animated: false)
        mvOne.selectAnnotation(selected, animated: false)
        title = selected.title
        lblAddr.text = selected.subtitle
       
    }
}
