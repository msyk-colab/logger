//
//  ContentView.swift
//  logger WatchKit Extension
//
//  Created by 水谷昌幸 on 2021/02/05.
//

import SwiftUI
import AVFoundation
import WatchConnectivity

var audioRecorder: AVAudioRecorder?
var audioPlayer: AVAudioPlayer?
var dateDAQStarted = Date()
var dateDAQEnded = Date()

struct ContentView: View {
    
    var valueSensingDurations = [1, 10, 30, 60, 120, 240, 480, 720]
    var valueSensingTypes = ["Audio", "Motion", "HeartRate", "Accel and HeartRate", "Acceleration"]
    var valueSensingIntervals = [1.0, 2.0, 5.0, 10, 60, 0.5, 0.1, 0.05, 0.01]
    
    var workoutSession: WorkoutManager
    @State var workoutInProgress = false
    
    @State public var strStatus: String = "status"
    @State private var intSelectedDuration: Int = 0
    @State private var intSelectedInterval: Int = 0
    @State private var intSelectedTypes: Int = 0
    
    
    var body: some View {
        VStack {
            ScrollView{
                Text(self.strStatus)
                if workoutInProgress {
                    Text("Workout session: ON")
                } else {
                    Text("Workout session: OFF")
                }
                Button(action:{
                    if self.valueSensingTypes[self.intSelectedTypes] == "Audio" {
                        self.strStatus = self.startAudioRecording()
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "Motion" {
                        self.strStatus = startMotionSensorUpdates(intervalSeconds: self.valueSensingIntervals[self.intSelectedInterval])
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "HeartRate" {
                        workoutSession.requestAuthorization()
                        workoutSession.startWorkout()
                        workoutInProgress = true
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "Accel and HeartRate" {
                        workoutSession.requestAuthorization()
                        workoutSession.startWorkout()
                        workoutInProgress = true
                        self.strStatus = startAccelerationSensorUpdates(durationMinutes: Double(self.valueSensingDurations[self.intSelectedDuration]))
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "Acceleration" {
                        self.strStatus = startAccelerationSensorUpdates(durationMinutes: Double(self.valueSensingDurations[self.intSelectedDuration]))
                    }
                })
                    {
                    Text("Start DAQ")
                }
                Button(action:{
                    if self.valueSensingTypes[self.intSelectedTypes] == "Audio" {
                        self.strStatus = self.finishAudioRecording()
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "Motion" {
                        self.strStatus = stopMotionSensorUpdates()
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "HeartRate" {
                        workoutSession.endWorkout()
                        workoutInProgress = false
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "Accel and HeartRate" {
                        self.strStatus = stopAccelerationSensorUpdates(intervalSeconds: self.valueSensingIntervals[self.intSelectedInterval])
                        workoutSession.endWorkout()
                        workoutInProgress = false
                    } else if self.valueSensingTypes[self.intSelectedTypes] == "Acceleration" {
                        self.strStatus = stopAccelerationSensorUpdates(intervalSeconds: self.valueSensingIntervals[self.intSelectedInterval])
                    }
                })
                    {
                    Text("Stop DAQ / Retrieve data")
                }
                Button(action:{
                    self.strStatus = self.fileTransfer(fileURL: self.getSensorDataFileURL(), metaData: ["":""])
                })
                    {
                    Text("Send sensor data")
                }
                Picker("DAQ duration [min]", selection: $intSelectedDuration){
                    ForEach(0 ..< valueSensingDurations.count) {
                        Text(String(self.valueSensingDurations[$0]))
                    }
                }.frame(height: 40)
                Picker("Sensing type", selection: $intSelectedTypes){
                    ForEach(0 ..< valueSensingTypes.count) {
                        Text(self.valueSensingTypes[$0])
                    }
                }.frame(height: 40)
                Picker("DAQ interval [s]", selection: $intSelectedInterval){
                    ForEach(0 ..< valueSensingIntervals.count) {
                        Text(String(self.valueSensingIntervals[$0]))
                    }
                }.frame(height: 40)
                /*
                Button(action:{
                    self.strStatus = self.playAudio()
                    //self.strStatus = getAudioFileURLString()
                })
                    {
                    Text("Play audio")
                }
                Button(action:{
                    self.strStatus = self.finishPlayAudio()
                })
                    {
                    Text("Stop audio")
                }
 */
                Button(action:{
                    self.strStatus = self.fileTransfer(fileURL: self.getAudioFileURL(), metaData: ["":""])
                })
                    {
                    Text("Send audio file")
                }
            }
        }
    }
    

    
    func getAudioFileURL() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let audioURL = docsDirect.appendingPathComponent("recodringW.m4a")
        //let audioURL = docsDirect.appendingPathComponent(getDateTimeString()+".m4a")
        return audioURL
    }
    
    func getSensorDataFileURL() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let fileURL = docsDirect.appendingPathComponent("SensorData.csv")
        return fileURL
    }
    
    func startAudioRecording()-> String{
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            let settingsDictionary = [
                AVFormatIDKey:Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            try audioSession.setActive(true)
            audioRecorder = try AVAudioRecorder(url:getAudioFileURL(),settings: settingsDictionary)
            audioRecorder!.record()
            return "REC audio in progress"
        }
        catch {
            return "REC audio error"
        }
    }
    
    func finishAudioRecording()->String{
        audioRecorder?.stop()
        return "Finished."
    }
    
    func playAudio()->String{
        let url = getAudioFileURL()
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            audioPlayer = sound
            sound.prepareToPlay()
            sound.play()
            return "Play audio started."
        }
        catch {
            return "Play audio error."
        }
    }
    
    func finishPlayAudio()->String{
        audioPlayer?.stop()
        return "Play audio finished."
    }
    
    func fileTransfer(fileURL: URL, metaData: [String:String])->String{
        WCSession.default.transferFile(fileURL, metadata: metaData)
        return "File transfer initiated."
    }
    
    // Convert the seconds into seconds, minutes, hours.
    func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    // Convert the seconds, minutes, hours into a string.
    func elapsedTimeString(elapsed: (h: Int, m: Int, s: Int)) -> String {
        return String(format: "%d:%02d:%02d", elapsed.h, elapsed.m, elapsed.s)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(workoutSession: WorkoutManager())
            ContentView(workoutSession: WorkoutManager())
        }
    }
}


