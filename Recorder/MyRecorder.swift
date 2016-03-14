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
public class MyRecorder {
    static var recordFile: AudioFileID = nil
    static var recordPacket: Int64 = 0
    static var running: Bool = false
    static var queue: AudioQueueRef = nil
}