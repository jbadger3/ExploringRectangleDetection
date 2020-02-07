//
//  WindowController.swift
//  ExploringRectangleDetection
//
//  Created by Jonathan Badger on 2/3/20.
//  Copyright © 2020 Jonathan Badger. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        if let window = window {
            window.delegate = self
        }
    }
}

extension WindowController: NSWindowDelegate {
    func windowWillStartLiveResize(_ notification: Notification) {
        if let window = window,
            let viewController = window.contentViewController as? ViewController {
            viewController.clearRectangles()
        }
    }
    func windowDidEndLiveResize(_ notification: Notification) {
        if let window = window,
            let viewController = window.contentViewController as? ViewController {
            viewController.addRectangleOutlinesToInputImage()
        }
    }
}


