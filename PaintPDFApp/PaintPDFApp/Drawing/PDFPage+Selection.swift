//
//  PDFPage+Selection.swift
//  PaintPDFApp
//
//  Created by Le Xuan Quynh on 28/03/2023.
//

import UIKit
import PDFKit

extension PDFPage {
    func annotationWithHitTest(at: CGPoint) -> PDFAnnotation? {
           let annotations = self.annotations
            for annotation in annotations {
                if annotation.bounds.contains(at) {
                    return annotation
                }
            }
            return nil
    }
}
