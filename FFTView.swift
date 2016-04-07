//
//  FFTView.swift
//  Recorder
//
//  Created by Connor Reid on 1/04/2016.
//  Copyright © 2016 Connor Reid. All rights reserved.
//

import UIKit

class FFTView: UIStackView {
    
    //MARK:  Variables
    var bins: [UIView] = []                             //  View for each freq range
    var heightConstraints: [NSLayoutConstraint] = []    //  Array of Height constraints for each bin
    
    // MARK:  Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     This function Adds the views for each frequency division
     color:  Color of each bin
     numBins:  How many divs are displayed
    */
    func addSubBinViews(colour: UIColor, numBins: Int){
        
        for x in 0...numBins-1{
            bins.append(UIView())
            bins[x].backgroundColor = colour
            bins[x].translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(bins[x])
            heightConstraints.append(NSLayoutConstraint(item: bins[x], attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.0, constant: self.frame.height))
            
            if (x == 0){
                NSLayoutConstraint.activateConstraints([
                    heightConstraints[x],
                    NSLayoutConstraint(item: bins[x], attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0/CGFloat(numBins), constant: 0),
                    NSLayoutConstraint(item: bins[x], attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0),
                    NSLayoutConstraint(item: bins[x], attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
                    ])
            }else{
                NSLayoutConstraint.activateConstraints([
                    heightConstraints[x],
                    NSLayoutConstraint(item: bins[x], attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0/CGFloat(numBins), constant: 0),
                    NSLayoutConstraint(item: bins[x], attribute: .Left, relatedBy: .Equal, toItem: bins[x-1], attribute: .Right, multiplier: 1.0, constant: 0),
                    NSLayoutConstraint(item: bins[x], attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
                ])
            }
        }
        print("Number of Bins = \(bins.count)")
        print("Number of Constraints = \(heightConstraints.count)")

    }
    
    /*
    This function sets the height modifier constraint for each bin
    */
    func setBinHeights(binHeights: [CGFloat]){
        // Loop through each Bin
        for x in 0..<binHeights.count{
            //print(binHeights[x])
            // Update Height Constraint for each Bin
            if(binHeights[x] < 0 || binHeights[x].isNaN || binHeights[x].isInfinite){
                heightConstraints[x].constant = 0.0
            }else{
                heightConstraints[x].constant = self.frame.height * binHeights[x]
            }
        }
    }

}
