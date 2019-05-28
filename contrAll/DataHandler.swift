//
//  DataHandler.swift
//  contrAll
//
//  Created by Ayberk Sorgun on 20.04.2019.
//  Copyright © 2019 contrAll. All rights reserved.
//

import Foundation
import WatchConnectivity

class DataHandler: NSObject {
    
    var session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

    var gestureType: Int = 6
    
    var timer: Timer?
        
    override init() {
        super.init()
        session?.delegate = self
        session?.activate()
        print("init")
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update(){
        // control if the value is changed, if changed, then do the audio player thing
        if self.gestureType != 6 {
            print("aha gesture type değişmiş")
            print("New gesture is \(self.gestureType)")
            self.gestureType = 6
        }
    }
    
}

extension DataHandler: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session Did Become Inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Session Did Deactive")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("just ios session")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("bura ios")
        print("didReceiveMessage")
        print("I got \(message)")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("bura ios")
        print("didReceiveApplicationContext")
        print("I got \(applicationContext)")
    }

    
}
