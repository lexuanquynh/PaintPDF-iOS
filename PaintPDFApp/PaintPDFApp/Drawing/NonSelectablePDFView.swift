//
//  NonSelectablePDFView.swift
//  PaintPDFApp
//
//  Created by Le Xuan Quynh on 27/03/2023.
//

import UIKit
import PDFKit

class NonSelectablePDFView: PDFView {
    
    // Disable selection
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer is UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false
        }
        
        super.addGestureRecognizer(gestureRecognizer)
    }
}
