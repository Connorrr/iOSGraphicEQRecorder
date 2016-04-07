//
//  ViewController.swift
//  Recorder
//
//  Created by Connor Reid on 9/03/2016.
//  Copyright © 2016 Connor Reid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK:  View variables
    var levelTimer: NSTimer!        //  Timer for updating the meter level
    var drawTimer: CADisplayLink!
    let numBinViews = 100
    
    @IBOutlet weak var meter: UILabel!
    @IBOutlet weak var fftView: FFTView!
    
    @IBAction func stopRecordingButton(sender: UIButton) {
        
        drawTimer.invalidate()
        stopRecording()
        meter.text = String(MyRecorder.largestSample)
        print("largest sampleis: \(MyRecorder.largestSample)")
        
    }
    var count = 0
    func setFftView(){
        if (MyRecorder.bufferRef != nil){
            if (MyRecorder.running){
                count += 1
                //  Calculate fft values
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                    //print("timer: \(MyRecorder.bufferRef)")
                    let rawPackets: [Float] = extractPackets(MyRecorder.bufferRef)
                    let binHeights: [CGFloat] = downsampleFFT(self.numBinViews, inputArray: rawPackets)
                    // Get them bayyybbees on za screen
                    dispatch_async(dispatch_get_main_queue()){
                        self.fftView.setBinHeights(binHeights)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let flr = 20/11
        print("floor(20/11) = \(flr)")
        // Do any additional setup after loading the view, typically from a nib.
        main()
        fftView.addSubBinViews(UIColor.orangeColor(), numBins: numBinViews) //  Set visible Bins
        //levelTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.setFftView), userInfo: nil, repeats: true)
        drawTimer = CADisplayLink(target: self, selector: #selector(ViewController.setFftView))
        drawTimer.frameInterval = 1
        drawTimer.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

