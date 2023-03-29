//
//  PDFAnnotationWithPath.swift
//  PaintPDFApp
//
//  Created by Le Xuan Quynh on 28/03/2023.
//

import UIKit
import PDFKit
import Foundation

extension PDFAnnotation {
    
    func contains(point: CGPoint) -> Bool {
        var hitPath: CGPath?
        
        if let path = paths?.first {
            hitPath = path.cgPath.copy(strokingWithWidth: 10.0, lineCap: .round, lineJoin: .round, miterLimit: 0)
        }
        
        return hitPath?.contains(point) ?? false
    }
}
