//
//  MyRecorder.swift
//  Recorder
//
//  Created by Connor Reid on 11/03/2016.
//  Copyright © 2016 Connor Reid. All rights reserved.
//

import Foundation
import AudioToolbox

//MARK:  User Data Struct / Class
struct MyRecorder {
    static let kDefaultBufferSize = 1024            //  @  44.1KHz ~ 22.7ms Latency
    static var sampleRate = 44100                   //  Standard Sampling Rate
    static var recordFile: AudioFileID = nil
    static var recordPacket: Int64 = 0
    static var running: Bool = false
    static var queue: AudioQueueRef = nil
    static var bufferRef: AudioQueueBufferRef = nil
    static var meterLevel: Float32 = 0.00
    static var dBBuffer = [Double](count:kDefaultBufferSize/sizeof(Int16), repeatedValue: 0.0)
    static var fftBuffer = [Double](count:kDefaultBufferSize/sizeof(Int16), repeatedValue: 0.0)
    static var binFrequencies = [Double](count:kDefaultBufferSize/sizeof(Int16), repeatedValue: 0.0)
    static var divisor: Double = 100.0                      //  Used to scale the fft view
    static var largestSample: Double = 0.0
}