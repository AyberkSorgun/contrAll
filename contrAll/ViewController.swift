//
//  ViewController.swift
//  contrAll
//
//  Created by Ayberk Sorgun on 2.03.2019.
//  Copyright © 2019 contrAll. All rights reserved.
//

import UIKit
import WatchConnectivity
import AVFoundation


class ViewController: UIViewController {
    
    @IBOutlet var song_duration: UILabel!
    @IBOutlet var current_time: UILabel!
    @IBOutlet var time_slider: UISlider!
    @IBOutlet var volume_slider: UISlider!{
        didSet{
        }
    }
    @IBOutlet var play_pause_button: UIButton!
    @IBOutlet var song_name: UILabel!
    
    let song_array: [String] = ["1","2","3","4","5","6","7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19"]
    let song_type: String = "mp3"
    var count: Int = 0
    let song_count: Int = 19
    var session: WCSession?
    var gestureType: Int = 6
    var session_timer: Timer?
    var song_timer: Timer?
    var audioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setSession()
        setAudioPlayer()
    }
    
    @IBAction func Play(_ sender: Any) {
        play()
    }
    
    @IBAction func restart(_ sender: Any) {
        restart()
    }
    
    @IBAction func nextSong(_ sender: Any) {
        next()
    }
    
    
    @IBAction func prevSong(_ sender: Any) {
        prev()
    }
    
    @IBAction func volumeUp(_ sender: Any) {
        volumeUp()
    }
    
    @IBAction func volumeDown(_ sender: Any) {
        volumeDown()
    }
    
    @IBAction func timeSliderChanged(_ sender: Any) {
        audioPlayer.pause()
        audioPlayer.currentTime = TimeInterval(time_slider.value)
        audioPlayer.prepareToPlay()
        time_slider.maximumValue = Float (audioPlayer.duration)
        audioPlayer.play()
    }
    
    @IBAction func volumeSliderChanged(_ sender: UISlider) {
        let val = Float(sender.value)
        audioPlayer.setVolume(val, fadeDuration: 0.1)
    }
    
    
}
// setups
extension ViewController{
    
    func setSession() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            print("hi i got session")
            session_timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        }else{
            print("Session is not supported in phone application")
        }
    }
    
    @objc func update(){
        // control if the value is changed, if changed, then do the audio player thing
        if self.gestureType != 6 {
            print("aha gesture type değişmiş")
            print("New gesture is \(self.gestureType)")
            let nameOfGesture = self.nameOfGesture()
            print("Gesture Name: \(nameOfGesture)")
            self.gestureType = 6
        }
    }
    
    private func nameOfGesture() -> String {
        var nameOfGesture = "None"
        if(self.gestureType == 1){
            nameOfGesture = "Right"
            next()
        }else if (self.gestureType == 2){
            nameOfGesture = "Left"
            prev()
        }else if (self.gestureType == 3){
            nameOfGesture = "Up"
            volumeUp()
        }else if (self.gestureType == 4){
            nameOfGesture = "Down"
            volumeDown()
        }else if (self.gestureType == 5){
            nameOfGesture = "Circle"
            play()
        }else if (self.gestureType == 6){
            nameOfGesture = "Not a gesture"
        }
        return nameOfGesture
    }
    
    func setAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "1", ofType: "mp3")!) )
            song_timer = Timer.scheduledTimer(timeInterval: 1.0, target : self, selector : #selector(updateTimeSlider), userInfo : nil,repeats: true)
            audioPlayer.prepareToPlay()
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])
                try AVAudioSession.sharedInstance().setActive(true)
            }
            catch {
                print(error)
            }
        }
        catch {
            print(error)
        }
        audioPlayer.setVolume(0.5, fadeDuration: 0)
        time_slider.setValue(0, animated: true)
        song_name.text = "Track 01"
        //volume_slider.isHidden = true
    }
    
    @objc func updateTimeSlider () {
        time_slider.value = Float(audioPlayer.currentTime)
        if Int(time_slider.value) == Int(audioPlayer.duration) {
            next()
        }
        let current_time_song = time_slider.value
        var optionalZero = ""
        if Int(Int(current_time_song) % 60) < 10 {
            optionalZero = "0"
        }
        var time = "\(Int(current_time_song / 60)):\(optionalZero)\(Int(Int(current_time_song) % 60))"
        current_time.text = time
        optionalZero = ""
        if Int(Int(audioPlayer.duration) % 60) < 10 {
            optionalZero = "0"
        }
        
        time = "\(Int(audioPlayer.duration / 60)):\(optionalZero)\(Int(Int(audioPlayer.duration) % 60))"
        song_duration.text = time
    }
    
}

extension ViewController: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session Did Become Inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Session Did Deactive")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("just ios session")
    }
    
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any]) {
        handleSession(session,
                      didReceiveMessage: message)
    }
    
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        handleSession(session,
                      didReceiveMessage: message,
                      replyHandler: replyHandler)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleSession(session, didReceiveMessage: applicationContext, replyHandler: nil)
    }
    //Helper Method
    func handleSession(_ session: WCSession,
                       didReceiveMessage message: [String : Any],
                       replyHandler: (([String : Any]) -> Void)? = nil) {
        print("bura ios")
        print("didReceiveMessage")
        print("I got \(message)")
        self.gestureType = message["gesture"] as! Int
    }
    
}


// Control Functions
extension ViewController {
    
    func play () {
        time_slider.maximumValue = Float (audioPlayer.duration)
        if audioPlayer.isPlaying {
            play_pause_button.setImage(UIImage(named: "play-button.png"), for: .normal)
            audioPlayer.pause()
            
        }else{
            play_pause_button.setImage(UIImage(named: "pause.png"), for: .normal)
            audioPlayer.play()
        }
    }
    
    func restart() {
        if audioPlayer.isPlaying {
            audioPlayer.currentTime = 0
            time_slider.maximumValue = Float(audioPlayer.duration)
            audioPlayer.play()
        }
        else {
            time_slider.maximumValue = Float(audioPlayer.duration)
            audioPlayer.play()
            play_pause_button.setTitle("Pause", for: .normal)
        }
        song_name.text = String(song_array[count])
    }
    
    func next() {
        count = (count + 1) % song_count
        let vol = audioPlayer.volume
        let song = song_array[count]
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: song, ofType: "mp3")!) )
            play_pause_button.setImage(UIImage(named: "pause.png"), for: .normal)
            time_slider.maximumValue = Float (audioPlayer.duration)
            audioPlayer.prepareToPlay()
            time_slider.maximumValue = Float (audioPlayer.duration)
            volume_slider.setValue(vol, animated: true)
            audioPlayer.setVolume(vol, fadeDuration: 0.1)
            audioPlayer.play()
            song_name.text = count < 9 ? "Track 0\(song)" : "Track \(song)"
        }
        catch {
            print(error)
        }
    }
    
    func prev() {
        count = (count - 1 + 19) % song_count
        let song = song_array[count]
        let vol = audioPlayer.volume
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: song, ofType: "mp3")!) )
            play_pause_button.setImage(UIImage(named: "pause.png"), for: .normal)
            time_slider.maximumValue = Float (audioPlayer.duration)
            audioPlayer.prepareToPlay()
            time_slider.maximumValue = Float (audioPlayer.duration)
            volume_slider.setValue(vol, animated: true)
            audioPlayer.setVolume(vol, fadeDuration: 0.1)
            audioPlayer.play()
            song_name.text = count < 9 ? "Track 0\(song)" : "Track \(song)"
        }
        catch {
            print(error)
        }
    }
    
    func volumeUp(){
        print("Volume Up: Current Vol: \(audioPlayer.volume)")
        var vol:Float = round(10*audioPlayer.volume+2)/10
        print("New vol: \(vol)")
        if vol > 1 {
            vol = 1
        }
        audioPlayer.setVolume(vol, fadeDuration: 0.1)
        volume_slider.setValue(vol, animated: true)
    }
    
    func volumeDown(){
        print("Volume Up: Current Vol: \(audioPlayer.volume)")
        var vol:Float = round(10*audioPlayer.volume-2)/10
        print("New vol: \(vol)")
        if vol < 0 {
            vol = 0
        }
        audioPlayer.setVolume(vol, fadeDuration: 0.1)
        volume_slider.setValue(vol, animated: true)
    }
}
