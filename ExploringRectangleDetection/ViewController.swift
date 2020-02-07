//
//  ViewController.swift
//  ExploringRectangleDetection
//
//  Created by Jonathan Badger on 1/31/20.
//  Copyright © 2020 Jonathan Badger. All rights reserved.
//

import Cocoa
import Quartz
import Vision

class ViewController: NSViewController {

    //MARK: - Properties
    var inputImageURL: URL?
    var rectangles: [VNRectangleObservation]?
    var maximumObservations: Int = 1
    var minimumAspectRatio: Float = 0.5
    var maximumAspectRatio: Float = 0.5
    var minimumSize: Float = 0.2
    var quadratureTolerance: Float = 30.0
    var minimumConfidence: Float = 0.0

    //MARK: - Interface Builder Outlets
    @IBOutlet var inputImageView: NSImageView!
    @IBOutlet var showRectanglesSwitch: NSSwitch!
    @IBOutlet weak var maximumObservationsTextField: NSTextField!
    @IBOutlet weak var minimumAspectRatioLabel: NSTextField!
    @IBOutlet weak var maximumAspectRatioLabel: NSTextField!
    @IBOutlet weak var minimumSizeLabel: NSTextField!
    @IBOutlet weak var quadratureToleranceLabel: NSTextField!
    @IBOutlet weak var minimumConfidenceLabel: NSTextField!
    
    @IBOutlet weak var minimumAspectRatioSlider: NSSlider!
    @IBOutlet weak var maximumAspectRatioSlider: NSSlider!
    @IBOutlet weak var minimumSizeSlider: NSSlider!
    @IBOutlet weak var quadratureToleranceSlider: NSSlider!
    @IBOutlet weak var minimumConfidenceSlider: NSSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - User actions
    @IBAction func loadImageButtonPressed(_ sender: Any) {
        guard let window = view.window else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        
        panel.beginSheetModal(for: window) { modalResponse in
            if modalResponse == .OK {
                let selectedURL = panel.urls[0]
                self.inputImageURL = selectedURL
                self.setInputImage()
            }
        }
    }
    
    
    @IBAction func restoreDefaultsButtonPressed(_ sender: Any) {
        restoreDefaultSettings()
    }
    
    @IBAction func maximumObservationsTextField(_ sender: Any) {
        if let slider = sender as? NSTextField {
            if let intValue = Int(slider.stringValue) {
                maximumObservations = intValue
            } else {
                maximumObservations = 0
            }
            createVisionRequest()
        }
    }
    
    @IBAction func minimumAspectRatioSliderChanged(_ sender: Any) {
        if let slider = sender as? NSSlider,
            let sliderVal = slider.value(forKey: "value") as? NSNumber {
            let newFloatVal = sliderVal.floatValue
            minimumAspectRatio = newFloatVal
            
            DispatchQueue.main.async {
                self.minimumAspectRatioLabel.stringValue = String(self.minimumAspectRatio)
                self.createVisionRequest()
            }
        }
    }
    
    @IBAction func maximumAspectRatioSliderChanged(_ sender: Any) {
        if let slider = sender as? NSSlider,
            let sliderVal = slider.value(forKey: "value") as? NSNumber {
            let newFloatVal = sliderVal.floatValue
            maximumAspectRatio = newFloatVal
            
            DispatchQueue.main.async {
                self.maximumAspectRatioLabel.stringValue = String(self.maximumAspectRatio)
                self.createVisionRequest()
            }
        }
    }
    
    @IBAction func minimumSizeSliderChanged(_ sender: Any) {
        if let slider = sender as? NSSlider,
            let sliderVal = slider.value(forKey: "value") as? NSNumber {
            let newFloatVal = sliderVal.floatValue
            minimumSize = newFloatVal
            
            DispatchQueue.main.async {
                self.minimumSizeLabel.stringValue = String(self.minimumSize)
                self.createVisionRequest()
            }
        }
    }
    
    @IBAction func quadratureToleranceSliderChanged(_ sender: Any) {
        if let slider = sender as? NSSlider,
            let sliderVal = slider.value(forKey: "value") as? NSNumber {
            let newFloatVal = sliderVal.floatValue
            quadratureTolerance = newFloatVal
            
            DispatchQueue.main.async {
                self.quadratureToleranceLabel.stringValue = String(self.quadratureTolerance)
                self.createVisionRequest()
            }
        }
    }
    
    @IBAction func minimumConfidenceSliderChanged(_ sender: Any) {
        if let slider = sender as? NSSlider,
            let sliderVal = slider.value(forKey: "value") as? NSNumber {
            let newFloatVal = sliderVal.floatValue
            minimumConfidence = newFloatVal
            
            DispatchQueue.main.async {
                self.minimumConfidenceLabel.stringValue = String(self.minimumConfidence)
                self.createVisionRequest()
            }
        }
    }
    
    @IBAction func showRectanglesSwitchChanged(_ sender: Any) {
        if let showRectanglesSwitch = sender as? NSSwitch {
            if showRectanglesSwitch.state == .on {
                addRectangleOutlinesToInputImage()
            }
            if showRectanglesSwitch.state == .off {
                clearRectangles()
            }
        }
    }
    
    //MARK: - Helper functions
    func setInputImage() {
        if let inputImageURL = inputImageURL {
            if let image = NSImage(contentsOf: inputImageURL) {
                inputImageView.imageScaling = .scaleProportionallyDown
                inputImageView.image = image
                rectangles = nil
                clearRectangles()
                createVisionRequest()
            }
        }
    }
    
    func restoreDefaultSettings() {
        maximumObservations = 1
        minimumAspectRatio = 0.5
        maximumAspectRatio = 0.5
        minimumSize = 0.2
        quadratureTolerance = 30.0
        minimumConfidence = 0.0
        
        DispatchQueue.main.async {
            self.maximumObservationsTextField.stringValue = String(self.maximumObservations)
            self.minimumAspectRatioLabel.stringValue = String(self.minimumAspectRatio)
            self.minimumAspectRatioSlider.setValue(self.minimumAspectRatio, forKey: "value")
            self.maximumAspectRatioLabel.stringValue = String(self.maximumAspectRatio)
            self.maximumAspectRatioSlider.setValue(self.maximumAspectRatio, forKey: "value")
            self.minimumSizeLabel.stringValue = String(self.minimumSize)
            self.minimumSizeSlider.setValue(self.minimumSize, forKey: "value")
            self.quadratureToleranceLabel.stringValue = String(self.quadratureTolerance)
            self.quadratureToleranceSlider.setValue(self.quadratureTolerance, forKey: "value")
            self.minimumConfidenceLabel.stringValue = String(self.minimumConfidence)
            self.minimumConfidenceSlider.setValue(self.minimumConfidence, forKey: "value")
        }
        clearRectangles()
        createVisionRequest()
    }
    
    //Mark: - Rectangle detection
    func createVisionRequest() {
        guard let inputImageURL = inputImageURL else { return }
        rectangles = nil
        clearRectangles()
        
        let requestHandler = VNImageRequestHandler(url: inputImageURL)
        let request = VNDetectRectanglesRequest { request, error in
            self.completedVisionRequest(request, error: error)
        }
        
        if let maximumObservations = Int(maximumObservationsTextField.stringValue) {
            request.maximumObservations = maximumObservations
        } else {
            request.maximumObservations = 0
        }
        request.minimumAspectRatio = minimumAspectRatio
        request.maximumAspectRatio = maximumAspectRatio
        request.minimumSize = minimumSize
        request.quadratureTolerance = quadratureTolerance
        request.minimumConfidence = minimumConfidence
        
        request.usesCPUOnly = false
        
        DispatchQueue.global().async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Error: Rectangle detection failed - vision request failed.")
            }
        }
    }
    
    func completedVisionRequest(_ request: VNRequest?, error: Error?) {
        guard let rectangles = request?.results as? [VNRectangleObservation] else {
            guard let error = error else { return }
            print("Error: Rectangle detection failed with error: \(error.localizedDescription)")
            return
        }
        self.rectangles = rectangles
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.addRectangleOutlinesToInputImage()
        }
        print("Found \(rectangles.count) rectangles")
    }
    
    //MARK: - Rectangle display methods
    func clearRectangles() {
        if let layer = self.inputImageView.layer,
            let sublayers = layer.sublayers{
            for subView in sublayers {
                if subView.name == "rectangle" {
                    subView.removeFromSuperlayer()
                }
            }
        }
    }
    
    func addRectangleOutlinesToInputImage() {
        if showRectanglesSwitch.state == .on {
            if let layer = self.inputImageView.layer,
                let rectangles = self.rectangles {
                self.rectangles = rectangles
                for rectangle in rectangles {
                    let shapeLayer = self.shapeLayerForObservation(rectangle)
                    layer.addSublayer(shapeLayer)
                }
            }
        }
    }
    
    func shapeLayerForObservation(_ rectangle: VNRectangleObservation) -> CAShapeLayer {
        guard let image = inputImageView.image else { return CAShapeLayer() }
        
        let transformProperties = CGSize.aspectFit(aspectRatio: image.size, boundingSize: inputImageView.bounds.size)
        let shapeLayer = CAShapeLayer()
        let frame = frameForRectangle(rectangle, withTransformProperties: transformProperties)
        shapeLayer.frame = frame
        shapeLayer.path = pathForRectangle(rectangle, withTransformProperties: transformProperties, andBoundingBox: shapeLayer.bounds)
        shapeLayer.strokeColor = CGColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        shapeLayer.fillColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        shapeLayer.name = "rectangle"
        return shapeLayer
    }
    
    func frameForRectangle(_ rectangle: VNRectangleObservation, withTransformProperties properties: (size: CGSize, xOffset: CGFloat, yOffset: CGFloat)) -> NSRect {
        // Use aspect fit to determine scaling and X & Y offsets
        let transform = CGAffineTransform.identity
            .translatedBy(x: properties.xOffset, y: properties.yOffset)
            .scaledBy(x: properties.size.width, y: properties.size.height)
            
        // Convert normalized coordinates to display coordinates
        let convertedTopLeft = rectangle.topLeft.applying(transform)
        let convertedTopRight = rectangle.topRight.applying(transform)
        let convertedBottomLeft = rectangle.bottomLeft.applying(transform)
        let convertedBottomRight = rectangle.bottomRight.applying(transform)
        
        // Calculate bounds of bounding box
        let minX = min(convertedTopLeft.x, convertedTopRight.x, convertedBottomLeft.x, convertedBottomRight.x)
        let maxX = max(convertedTopLeft.x, convertedTopRight.x, convertedBottomLeft.x, convertedBottomRight.x)
        let minY = min(convertedTopLeft.y, convertedTopRight.y, convertedBottomLeft.y, convertedBottomRight.y)
        let maxY = max(convertedTopLeft.y, convertedTopRight.y, convertedBottomLeft.y, convertedBottomRight.y)
        let frame = NSRect(x: minX , y: minY, width: maxX - minX, height: maxY - minY)
        return frame
    }
    
    func pathForRectangle(_ rectangle: VNRectangleObservation,withTransformProperties properties: (size: CGSize, xOffset: CGFloat, yOffset: CGFloat),andBoundingBox size: CGRect) -> CGPath {
        //Convert to appropriate scale
        let scaleTransform = CGAffineTransform.identity
            .scaledBy(x: properties.size.width, y: properties.size.height)
            
        // Convert normalized coordinates to adjust for size of bounding box
        let scaledTopLeft = rectangle.topLeft.applying(scaleTransform)
        let scaledTopRight = rectangle.topRight.applying(scaleTransform)
        let scaledBottomLeft = rectangle.bottomLeft.applying(scaleTransform)
        let scaledBottomRight = rectangle.bottomRight.applying(scaleTransform)
        
        // translate to make bottom left corner of bounding box 0, 0
        let minX = min(scaledTopLeft.x, scaledTopRight.x, scaledBottomRight.x, scaledBottomLeft.x)
        let minY = min(scaledTopLeft.y, scaledTopRight.y, scaledBottomRight.y, scaledBottomLeft.y)
        
        let translateTransform = CGAffineTransform.identity
            .translatedBy(x: -minX, y: -minY)
            .scaledBy(x: properties.size.width, y: properties.size.height)
        
        let convertedTopLeft = rectangle.topLeft.applying(translateTransform)
        let convertedTopRight = rectangle.topRight.applying(translateTransform)
        let convertedBottomLeft = rectangle.bottomLeft.applying(translateTransform)
        let convertedBottomRight = rectangle.bottomRight.applying(translateTransform)
        
        let path = CGMutablePath()
        
        path.addLines(between: [convertedTopLeft, convertedTopRight, convertedBottomRight, convertedBottomLeft, convertedTopLeft])
        return path
    }
    
}
