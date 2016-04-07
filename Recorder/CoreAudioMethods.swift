//
//  CoreAudioMethods.swift
//  Recorder
//
//  Created by Connor Reid on 14/03/2016.
//  Copyright © 2016 Connor Reid. All rights reserved.
//

import AudioToolbox
import AVFoundation

let kNumberRecordBuffers = 3

// MARK: Utility functions
func checkError(error: OSStatus, operation: String) {
    guard error != noErr else {
        return
    }
    
    var char = Int(error.bigEndian)
    var result: String = ""
    var err: OSStatus = error.bigEndian
    
    func takesAMutableVoidPointer(x: UnsafeMutablePointer<OSStatus>){
        var returnString = ""
        var bytePointer = UnsafePointer<UInt8>(x)
        
        returnString.append(Character(UnicodeScalar(bytePointer.memory)))
        
        for _ in 0...2 {
            bytePointer = bytePointer.successor()
            returnString.append(Character(UnicodeScalar(bytePointer.memory)))
        }
        
        print("Error: \(operation) (\(returnString)) or \(error)")
        
        exit(1)
    }
    takesAMutableVoidPointer(&err)
    
}

func MyDefaultGetInputDeviceSampleRate(inout outSampleRate: Double) {
    
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    
    outSampleRate = session.sampleRate
    
}

func MyCopyEncoderCookieToFile(queue: AudioQueueRef, file:  AudioFileID){
    
}

func MyComputeRecordBufferSize(desc: UnsafePointer<AudioStreamBasicDescription>, queue: AudioQueueRef, seconds: Double) -> UInt32{
    var size: UInt32 = 0
    
    var packets, frames: Int
    let asbd: AudioStreamBasicDescription = desc.memory
    var error: OSStatus
    
    frames = Int(ceil(seconds * Double(asbd.mBytesPerFrame)))
    
    
    if (asbd.mBytesPerFrame > 0){
        print("mBytesPerFrame set")
        size = UInt32(frames) * asbd.mBytesPerFrame * 500
    }else{
        print("mBytesPerFrame not set")
        var maxPacketSize: UInt32 = 0
        if (asbd.mBytesPerPacket > 0){
            //  Const Packet Size
            maxPacketSize = asbd.mBytesPerPacket
        }else{
            //  Get the largest possible packet size
            var propertySize: UInt32 = UInt32(sizeof(maxPacketSize.dynamicType))
            error = AudioQueueGetProperty(queue, kAudioConverterPropertyMaximumOutputPacketSize, &maxPacketSize, &propertySize)
            checkError(error, operation: "AudioQueueGetProperty failed.  Couldn't get Max Output Packet Size")
        }
        if (asbd.mFramesPerPacket > 0){
            packets = frames / Int(asbd.mFramesPerPacket)
        }else{
            //  Worst case scenario:  1 Frame in a Packet
            packets = frames
        }
        //  Sanity Check
        if (packets == 0){
            packets = 1 // mono
        }
        size = UInt32(packets) * maxPacketSize
        print("Num Packets:  " + String(packets))
    }
    return size
}

//MARK:  Record Callback Function

/*

inUserData
The custom data you’ve specified in the inUserData parameter of the AudioQueueNewInput function. Typically, this includes format and state information for the audio queue.
inAQ
The recording audio queue that invoked the callback.
inBuffer
An audio queue buffer, newly filled by the recording audio queue, containing the new audio data your callback needs to write.
inStartTime
The sample time for the start of the audio queue buffer. This parameter is not used in basic recording.
inNumberPacketDescriptions
The number of packets of audio data sent to the callback in the inBuffer parameter. When recording in a constant bit rate (CBR) format, the audio queue sets this parameter to NULL.
inPacketDescs
For compressed formats that require packet descriptions, the set of packet descriptions produced by the encoder for audio data in the inBuffer parameter. When recording in a CBR format, the audio queue sets this parameter to NULL
*/

var flag = true
func MyAudioQueueInputCallback(inUserData: UnsafeMutablePointer<Void>, inAQ: AudioQueueRef, inBuffer: AudioQueueBufferRef, inStartTime: UnsafePointer<AudioTimeStamp>, var inNumberPacketDesc: UInt32, inPacketDesc: UnsafePointer<AudioStreamPacketDescription>){
    
    var error: OSStatus
    
    MyRecorder.bufferRef = inBuffer
    //print("callback: \(inBuffer)")
    
    if (inNumberPacketDesc > 0){
        
        error = AudioFileWritePackets(MyRecorder.recordFile, false, inBuffer.memory.mAudioDataByteSize, inPacketDesc, MyRecorder.recordPacket, &inNumberPacketDesc, inBuffer.memory.mAudioData)
        checkError(error, operation: "AudioFileWritePackets Failed ")
        
        // Increment the packet index 
        MyRecorder.recordPacket += Int64(inNumberPacketDesc)    // inNumberPacketDesc now holds the number of packets written
        
        if (MyRecorder.running){
            error = AudioQueueEnqueueBuffer(inAQ, inBuffer, inNumberPacketDesc, inPacketDesc)
            checkError(error, operation: "AudioQueueEnqueueBuffer Failed ")
            
            /*var level: Float32 = 0
            var levelSize = UInt32(sizeof(level.dynamicType))
            error = AudioQueueGetProperty(inAQ, kAudioQueueProperty_CurrentLevelMeter, &level, &levelSize)
            checkError(error, operation: "AudioQueueGetProperty Failed...  Get help!")
            
            MyRecorder.meterLevel = level*/
        }
    }
}

func extractPackets(fftBufferRef: AudioQueueBufferRef) -> [Float]{
    var samplePointer = UnsafePointer <Int16>(fftBufferRef.memory.mAudioData)
    var normalizedSamples: [Float] = []
    
    var count = 0
    let numInts = Int(fftBufferRef.memory.mAudioDataBytesCapacity) / sizeof(Int16)
    for _ in 0..<numInts {

        normalizedSamples.append(Float(samplePointer.memory)/Float(32767))  // Add normalized sample
        
        MyRecorder.fftBuffer[count] = Double(samplePointer.memory)/Double(32767)  //make a fraction of MAX_INT
        samplePointer = samplePointer.successor()           //increment pointer by 2 bytes (Int16)

        count = count + 1
    }
    normalizedSamples = fft(normalizedSamples)  // return fft
    
    for x in 0..<normalizedSamples.count{
        normalizedSamples[x] = (log2(normalizedSamples[x]) + 20)/20     // set in dB
    }
    
    return normalizedSamples
}

//MARK:  Main

func main(){
    
    //MARK:  Setup Format
    var recorder = MyRecorder()
    var recordFormat = AudioStreamBasicDescription()
    recordFormat.mFormatID = kAudioFormatLinearPCM       // Codec  //kAudioFormatMPEG4AAC //kAudioFormatLinearPCM
    recordFormat.mChannelsPerFrame = 1                  // Mono
    recordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
    recordFormat.mBitsPerChannel = UInt32(8 * sizeof(Int16))
    recordFormat.mBytesPerPacket = UInt32(sizeof(Int16))
    recordFormat.mFramesPerPacket = 1
    recordFormat.mBytesPerFrame = recordFormat.mBytesPerPacket
    
    MyDefaultGetInputDeviceSampleRate(&recordFormat.mSampleRate)
    MyRecorder.sampleRate = Int(recordFormat.mSampleRate)
    
    //  Set Up FFT  Buffer
    fillFrequencies()       //  Utility Functions
    
    print("Record Format Now:  \(recordFormat)")
    
    var error: OSStatus
    //var propSize: UInt32 = UInt32(sizeof(recordFormat.dynamicType))
    
    /*error = AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
        0,
        nil,
        &propSize,
        &recordFormat)
    checkError(error, operation: "kAudioFormatProperty_FormatInfo Failed error: ") */
    
    //print("Record Format Then:  \(recordFormat)")
    //print(recordFormat)
    //MARK:  Setup Queue
    
    error = AudioQueueNewInput(&recordFormat,
        MyAudioQueueInputCallback,
        &recorder,
        nil,
        nil,
        0,
        &MyRecorder.queue)
    
    checkError(error, operation: "AudioQueueNewInput failed, error:  ")
    
    //var size: UInt32 = UInt32(sizeofValue(recordFormat));
    
    //error = AudioQueueGetProperty(MyRecorder.queue, kAudioConverterCurrentOutputStreamDescription, &recordFormat, &size)  // Retrieve codec desc for ASBD
    //checkError(error, operation: "Could not get Audio Queue Property, error:  ")
    
    //var value: UInt32 = 1
    //let valueSize = UInt32(sizeof(value.dynamicType))
    
    //error = AudioQueueSetProperty(MyRecorder.queue, kAudioQueueProperty_EnableLevelMetering, &value, valueSize)
    
    //checkError(error, operation: "AudioQueueSetProperty kAudioQueueProperty_EnableLevelMetering failed")
    
    //MARK:  Setup File
    let fileName = "newOutput.wav"
    
    let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] + "/\(fileName)"
    
    //let path = NSFileManager.defaultManager().currentDirectoryPath + "/\(fileName)"
    let fileURL: CFURLRef = NSURL.fileURLWithPath(documentPath)
    
    error = AudioFileCreateWithURL(fileURL, kAudioFileWAVEType, &recordFormat, AudioFileFlags.EraseFile, &MyRecorder.recordFile)
    
    checkError(error, operation: "Error in AudioFileCreateWithUrl:  ")
    
    MyCopyEncoderCookieToFile(MyRecorder.queue, file: MyRecorder.recordFile) //Copy Magic Cookie
    
    //MARK:  Other Setup
    //let bufferByteSize: UInt32 = MyComputeRecordBufferSize(&recordFormat, queue: MyRecorder.queue, seconds: 0.5)
    let bufferByteSize = UInt32(MyRecorder.kDefaultBufferSize)
    print("Buffer Byte Size:  \(bufferByteSize)")
    var pBufferFlag = true
    //  Allocate and Enqueue buffers
    for _ in 0..<kNumberRecordBuffers {
        var buffer = AudioQueueBufferRef()
        
        error = AudioQueueAllocateBufferWithPacketDescriptions(MyRecorder.queue, bufferByteSize,bufferByteSize,&buffer)
        //error = AudioQueueAllocateBuffer(MyRecorder.queue, bufferByteSize, &buffer)
        checkError(error, operation: "AudioQueueAllocateBuffer failed ")
        
        if (pBufferFlag){
            pBufferFlag = false
            print(buffer.memory)
        }
        
        error = AudioQueueEnqueueBuffer(MyRecorder.queue, buffer, 0, nil)
        checkError(error, operation: "AudioQueueEnqueueBuffer failed ")
    }
    
    //MARK:  Start Queue
    MyRecorder.running = true
    
    error = AudioQueueStart(MyRecorder.queue, nil)
    checkError(error, operation: "AudioQueueStart Failed ")
    
    print("file:  " + String(fileURL))
    
    //print("Record Format End:  \(recordFormat)")
    
    print("Recorder Running")
    
}

func stopRecording(){
    //MARK:  Stop Queue and Cleanup
    
    print("*  Recording Done  *")
    
    var error : OSStatus
    
    MyRecorder.running = false
    error = AudioQueueStop(MyRecorder.queue, true)
    
    checkError(error, operation: "AudioQueueStop Failed  ")
    
    MyCopyEncoderCookieToFile(MyRecorder.queue, file: MyRecorder.recordFile)
    
    AudioQueueDispose(MyRecorder.queue, true)
    AudioFileClose(MyRecorder.recordFile)
}