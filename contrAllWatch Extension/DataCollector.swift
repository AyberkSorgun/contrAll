//
//  Variables.swift
//  contrAllWatch Extension
//
//  Created by Aybüke Buket Akgül on 16.03.2019.
//  Copyright © 2019 contrAll. All rights reserved.
//

import Foundation
import WatchConnectivity
import CoreMotion
import CoreML
import WatchKit

class DataCollector: NSObject{
    
    var typeOfGesture: Int = -1
    var isSessionActive = false
    var timer : Timer?
    var timerCount = 20
    let session : WCSession? = WCSession.isSupported() ? WCSession.default : nil
    let interval = 0.1
    let queue = OperationQueue()
    var accelerometerData = ""
    var accelerometerX : [Double] = []
    var accelerometerY : [Double] = []
    var accelerometerZ : [Double] = []
    let motionManager = CMMotionManager()
    let precision = 1000.0
    var isPlaying = false
    

    override init(){
        super.init()
        setSession()
    }
    
    deinit{
        deinitTimer()
    }
    @objc func  initilizer(){}
    func setTimer(){
        if self.timer != nil {
            self.timer!.invalidate()
        }
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(initilizer), userInfo: nil, repeats: true)
    }
    func setSession(){
        session?.delegate = self
        session?.activate()
    }
    
    func deinitTimer() {
        if timer != nil {
            timer!.invalidate()
        }
        timer = nil
    }
    
    func startReceivingData(label: WKInterfaceLabel){
        setTimer()
        timerCount = 20
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        motionManager.deviceMotionUpdateInterval = interval
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            if deviceMotion != nil {
                let userAcceleration = deviceMotion!.userAcceleration
                self.accelerometerData = "\(round(self.precision * userAcceleration.x) / self.precision),\(round(self.precision * userAcceleration.y) / self.precision),\(round(self.precision * userAcceleration.z) / self.precision)"
                self.accelerometerX.append(round(self.precision * userAcceleration.x))
                self.accelerometerY.append(round(self.precision * userAcceleration.y))
                self.accelerometerZ.append(round(self.precision * userAcceleration.z))
            }
            self.timerCount -= 1
            label.setText(String(self.timerCount))
            if (self.timerCount == 0){
                self.timer!.invalidate()
                self.stopReceivingData()
                self.predict()
                var gestureType = "None"
                if(self.typeOfGesture == 1){
                    gestureType = "Next Song"
                    self.isPlaying = true
                }else if (self.typeOfGesture == 2){
                    gestureType = "Previous Song"
                    self.isPlaying = true
                }else if (self.typeOfGesture == 3){
                    gestureType = "Volume Up"
                }else if (self.typeOfGesture == 4){
                    gestureType = "Volume Down"
                }else if (self.typeOfGesture == 5){
                    gestureType =  self.isPlaying ? "Paused" : "Playing"
                    self.isPlaying = !self.isPlaying
                }
                self.sendMessageToAudioPlayer()
                label.setText("\(gestureType)")
                self.typeOfGesture = 6
            }
        }
    }
    
    func sendMessageToAudioPlayer() {
        if (WCSession.default.isReachable) {
            let message = ["gesture": self.typeOfGesture]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("error: \(error)")
            })
        }
    }

    func stopReceivingData(){
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    
}

extension DataCollector: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated && session.isReachable {
            print("Session is activated and it's reachable")
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            print("Session reachability did changed and it's reachable")
        }else{
            print("Session reachability did changed and it's NOT reachable")
        }
    }
}


extension DataCollector {
    func predict(){
        let input = preprocessing()
        let model = cukubix()
        let options = MLPredictionOptions()
        options.usesCPUOnly = true
        let input_data = cukubixInput(gestures: input)
        do{
            let prediction = try model.prediction(input: input_data)
            let gestureNum = getGestureType(prediction.gestureType)
            typeOfGesture = gestureNum
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func preprocessing() -> MLMultiArray{
        guard let input_data = try? MLMultiArray(shape:[1,1,60], dataType: .double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        while(accelerometerX.count < 20) {
            accelerometerX.append(0.0)
            accelerometerY.append(0.0)
            accelerometerZ.append(0.0)
        }
        for index in 0...19 {
            input_data[index] = accelerometerX[index] as NSNumber
            input_data[index+20] = accelerometerY[index] as NSNumber
            input_data[index+40] = accelerometerZ[index] as NSNumber
        }
        self.accelerometerX = []
        self.accelerometerY = []
        self.accelerometerZ = []
        return input_data
    }
    
    func getGestureType(_ result : MLMultiArray) -> Int {
        var index:Int = 0
        var max = 0.0
        for i in 0...4{
            if(result[i].doubleValue > max){
                max = result[i].doubleValue
                index = i
            }
        }
       
        return index+1
    }
    
}
