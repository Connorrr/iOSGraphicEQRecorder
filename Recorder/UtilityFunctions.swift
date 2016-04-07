//
//  UtilityFunctions.swift
//  Recorder
//
//  Created by Connor Reid on 30/03/2016.
//  Copyright © 2016 Connor Reid. All rights reserved.
//

import UIKit

/**
Fills a reference array for the fft buffer.
 First element will be 0Hz or the DC Component
 Second element will be the lowest samplable frequency (half the sampling frequency)
 All remaining elements will be inciments of the second element
*/
func fillFrequencies(){
    //print("frequencies")
    MyRecorder.binFrequencies[0] = 0.0
    //print(MyRecorder.binFrequencies[0])
    let sampleWavelength: Double = 1/Double(MyRecorder.sampleRate)
    let lowestSampleableWavelength: Double = sampleWavelength * Double(MyRecorder.kDefaultBufferSize/sizeof(Int16))
    let div: Double = 1/(lowestSampleableWavelength)
    //  Therefore
    MyRecorder.binFrequencies[1] = Double(div)
    //print(MyRecorder.binFrequencies[1])
    for x in 2...MyRecorder.binFrequencies.count-1{
        MyRecorder.binFrequencies[x] = MyRecorder.binFrequencies[x-1] + MyRecorder.binFrequencies[1]
        //print(MyRecorder.binFrequencies[x])
    }
    //print("")
}

/*
 Down samples the fftArray
*/
func downsampleFFT(numBins: Int, inputArray: [Float]) -> [CGFloat]{
    
    var outArray: [CGFloat] = []
    let halfCount = inputArray.count/2   // value used to ignore fft mirroring
    let samplesPerBin: Int = halfCount/numBins      // for 23, real = 11.13, int = 11
    //print("Samples per bin:  \(samplesPerBin)")
    var count = 0
    var total: Float = 0.0
    
    //  Loop through all frequencies
    for x in 0..<halfCount{
        count += 1
        //  Get mean value for bins groups of size samplesPerBin
        total = total + inputArray[x]
        if (count >= samplesPerBin){    //  Used to check for overflow (remainders after division)
            if (outArray.count < numBins-1){
                outArray.append(CGFloat(total/Float(samplesPerBin)))        //  Get mean value
                total = 0.0
                count = 0
            }
        }
    }
    if (count != 0){    //  Add overflow
        outArray.append(CGFloat(total/Float(count)))  //  Add last value if half count is not divisible by samplesPerBin
    }
    return outArray
}

//  Generic Function to print arrays
func printArray(inArray: [CGFloat], title: String){
    print("")
    print(title)
    for x in 0..<inArray.count{
        print(inArray[x])
    }
}
