//
//  CGSize+aspectFit+aspectFill.swift
//  ExploringRectangleDetection
//
//  Created by Jonathan Badger on 2/6/20.
//  Copyright © 2020 Jonathan Badger. All rights reserved.
//

import Foundation

extension CGSize {
    static func aspectFit(aspectRatio : CGSize, boundingSize: CGSize) -> (size: CGSize, xOffset: CGFloat, yOffset: CGFloat)  {
        let mW = boundingSize.width / aspectRatio.width;
        let mH = boundingSize.height / aspectRatio.height;
        var fittedWidth = boundingSize.width
        var fittedHeight = boundingSize.height
        var xOffset = CGFloat(0.0)
        var yOffset = CGFloat(0.0)
        
        if( mH < mW ) {
            fittedWidth = boundingSize.height / aspectRatio.height * aspectRatio.width;
            xOffset = abs(boundingSize.width - fittedWidth)/2
            
        }
        else if( mW < mH ) {
            fittedHeight = boundingSize.width / aspectRatio.width * aspectRatio.height;
            yOffset = abs(boundingSize.height - fittedHeight)/2
            
        }
        let size = CGSize(width: fittedWidth, height: fittedHeight)
        
        return (size, xOffset, yOffset)
    }
    
    static func aspectFill(aspectRatio :CGSize, minimumSize: CGSize) -> CGSize {
        let mW = minimumSize.width / aspectRatio.width;
        let mH = minimumSize.height / aspectRatio.height;
        var minWidth = minimumSize.width
        var minHeight = minimumSize.height
        if( mH > mW ) {
            minWidth = minimumSize.height / aspectRatio.height * aspectRatio.width;
        }
        else if( mW > mH ) {
            minHeight = minimumSize.width / aspectRatio.width * aspectRatio.height;
        }
        
        return CGSize(width: minWidth, height: minHeight)
    }
}
