//
//  DetailViewController.swift
//  EarthquakeShelter
//
//  Created by D7703_18 on 2018. 11. 12..
//  Copyright © 2018년 201550057. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UITableViewController, MKMapViewDelegate {
    @IBOutlet weak var lblAddr: UILabel!
    @IBOutlet weak var lbldetailAddr: UILabel!
    @IBOutlet weak var lblCapcity: UILabel!
    @IBOutlet var detailmap: MKMapView!
    
    var selectedForDetail: BusanData?
    var test: String?
   
    @IBAction func navi(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = selectedForDetail?.title
        let subtitle = selectedForDetail?.subtitle
        let capcity = selectedForDetail?.capcity
        let coordinate = selectedForDetail?.coordinate
        
        lblAddr.text = title
        lbldetailAddr.text = subtitle
        lblCapcity.text = capcity
      
    }
}

