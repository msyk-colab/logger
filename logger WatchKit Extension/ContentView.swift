//
//  ContentView.swift
//  logger WatchKit Extension
//
//  Created by 水谷昌幸 on 2021/02/05.
//

import SwiftUI
import AVFoundation
import WatchConnectivity

import HealthKit
import Combine


var audioRecorder: AVAudioRecorder?
var audioPlayer: AVAudioPlayer?
var dateDAQStarted = Date()
var dateDAQEnded = Date()
var one = Date()
var two = Date()
var three = Date()
var four = Date()
var five = Date()
var six = Date()
var seven = Date()
var eight = Date()
var nine = Date()
var ten = Date()
var eleven = Date()
var twelve = Date()
var a = Date()
var b = Date()

struct ContentView: View {
    /*
    // Get the business logic from the environment.
    @EnvironmentObject var workoutSession: WorkoutManager
    
    // This view will show an overlay when we don't have a workout in progress.
    @State var workoutInProgress = false
 */
    /*
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession!
     //@ObservedObject var sensor = MotionSensor()
     //@ObservedObject var connector = PhoneConnector()
      
 */
    
    @State public var strStatus: String = "status"

    //Motion
    var valueSensingIntervals = [60,10,5.0,2.0,1.0,0.5,0.1,0.05,0.01]
    @State private var intSelectedInterval: Int = 0
    
    //Acceleration(recordAccelerometer)
    var valueSensingDurations = [1, 2, 5, 10, 12, 30, 60, 120, 240, 480, 720]
    @State private var intSelectedDuration: Int = 0
    
    //workout
    var workoutSession: WorkoutManager
    @State var workoutInProgress = false
    
    //取得データ選択
    var valueSensingTypes = ["Audio", "Motion", "HeartRate", "Accel and HeartRate", "Acceleration", "Motion and HeartRate"]
    //var Choises = ["Audio","Motion","HeartRate","Acceleration","Accel & HeartRate"]
    //何個目か
    @State private var intSelectedTypes: Int = 0
    //必要？
    //@State private var strChoise: String = "MotionData"
    
    
    
    var body: some View {
        VStack {
            ScrollView{
                Group{
                    Text(self.strStatus)
                    Text(ManagerStatus)
                    if workoutInProgress {
                        Text("Workout session: ON")
                    } else {
                        Text("Workout session: OFF")
                        
                    }
                    
                }
                Group{
                    Text("Sensing type")
                    Picker("Sensing type", selection: $intSelectedTypes){
                        ForEach(0 ..< valueSensingTypes.count) {
                            Text(self.valueSensingTypes[$0])
                        }
                    }.frame(height: 40)
                    Text("CoreMotion interval[s]")
                    Picker("DAQ interval [s]", selection: $intSelectedInterval){
                        ForEach(0 ..< valueSensingIntervals.count) {
                            Text(String(self.valueSensingIntervals[$0]))
                        }
                    }.frame(height: 40)
                    Text("Acceleration(recordAccelerometer) duration[min]")
                    Picker("DAQ duration [min]", selection: $intSelectedDuration){
                        ForEach(0 ..< valueSensingDurations.count) {
                            Text(String(self.valueSensingDurations[$0]))
                        }
                    }.frame(height: 40)
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
                    else if self.valueSensingTypes[self.intSelectedTypes] == "Motion and HeartRate"{
                        workoutSession.requestAuthorization()
                        workoutSession.startWorkout()
                        workoutInProgress = true
                        self.strStatus = startMotionSensorUpdates(intervalSeconds: self.valueSensingIntervals[self.intSelectedInterval])
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
                    else if self.valueSensingTypes[self.intSelectedTypes] == "Motion and HeartRate" {
                        self.strStatus = stopMotionSensorUpdates()
                        workoutSession.endWorkout()
                        workoutInProgress = false
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
                
                Button(action:{
                    self.strStatus = start(durationMinutes: Double(self.valueSensingDurations[self.intSelectedDuration]))
                })
                    {
                    Text("start")
                }
                
                Button(action:{
                    self.strStatus = getsend(intervalSeconds: self.valueSensingIntervals[self.intSelectedInterval])
                })
                    {
                    Text("getsend")
                }
                
                Button(action:{
                    self.strStatus = self.fileTransfer(fileURL: self.getSensorDataFileURL(), metaData: ["":""])
                })
                    {
                    Text("send")
                }
                Button(action:{
                    self.strStatus = de(intervalSeconds: self.valueSensingIntervals[self.intSelectedInterval])
                })
                    {
                    Text("de")
                }
               /*
                Button(action:{
                    self.strStatus = get(intervalSeconds: self.valueSensingIntervals[self.intSelectedInterval])
                })
                    {
                    Text("debug")
                }
                */
                
            }
        }
    }
    

    //Audio
    
    func getAudioFileURL() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let audioURL = docsDirect.appendingPathComponent("recodringW.m4a")
        //let audioURL = docsDirect.appendingPathComponent(getDateTimeString()+".m4a")
        return audioURL
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
    
    //3
    func fileTransfer(fileURL: URL, metaData: [String:String])->String{
        WCSession.default.transferFile(fileURL, metadata: metaData)
        return "File transfer initiated."
    }
    
    
    func getSensorDataFileURL() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let fileURL = docsDirect.appendingPathComponent("SensorData.csv")
        return fileURL
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


