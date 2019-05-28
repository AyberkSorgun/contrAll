//
//  InterfaceController.swift
//  contrAllWatch Extension
//
//  Created by Ayberk Sorgun on 2.03.2019.
//  Copyright © 2019 contrAll. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity


class InterfaceController: WKInterfaceController{

    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet weak var startStopButton: WKInterfaceButton!
    let dataCollector = DataCollector()
    
    @IBAction func startStopTapped() {
        print("started")
        dataCollector.startReceivingData(label: self.label)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    deinit {
        print("deinitializing")
        dataCollector.stopReceivingData()
    }

}
