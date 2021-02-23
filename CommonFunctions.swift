//
//  CommonFunctions.swift
//  logger
//
//  Created by 水谷昌幸 on 2021/02/05.
//

import Foundation
var i = 0
let sensorDataFileName = "SensorData.csv"
//let date = Date()
let tukuru = "10min"+TimeString()+getNumber2(num:i)+".csv"
let okuru = "10min"+TimeString()+getNumber3(num:i)+".csv"

func TimeString() -> String{
    let date = Date()
    let df = DateFormatter()
    df.locale = Locale(identifier: "ja_JP")
    df.dateFormat = "yyyyMMdd_"
    return df.string(from: date)
}
func getNumber2(num: Int) ->String{
    i = i + 1
    return String(i)
}
func getNumber3(num: Int) ->String{
    i = i + 1
    return String(i)
}

func getDateTimeString() -> String{
    let f = DateFormatter()
    f.dateFormat = "yyyy_MMdd_HHmmss_SSS"
    let now = Date()
    return f.string(from: now)
    //return f.string(from: dateDAQStarted)
}

func getNumber(num: Int) ->String{
    i = i + 1
    return String(i)
}

func convertDateTimeString(now: Date) -> String{
    let f = DateFormatter()
    f.dateFormat = "yyyy/MM/dd_HH:mm:ss:SSS"
    return f.string(from: now)
}

func getDateTimeMilisecString() -> String{
    let f = DateFormatter()
    f.dateFormat = "yyyy_MMdd_HHmm_ss_SSS"
    let now = Date()
    return f.string(from: now)
}


