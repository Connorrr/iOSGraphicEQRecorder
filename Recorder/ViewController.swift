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
    @IBOutlet weak var meter: UILabel!
    
    @IBAction func stopRecordingButton(sender: UIButton) {
        
        stopRecording()
        
    }
    
    func setMeterLabel(meterText: String){
        
        meter.text = meterText
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setMeterLabel("0.555")
        main()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

