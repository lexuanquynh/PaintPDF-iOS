//
//  DrawingAnnotation.swift
//  PaintPDFApp
//
//  Created by Le Xuan Quynh on 28/03/2023.
//

import Foundation
import PDFKit

class DrawingAnnotation: PDFAnnotation {
    public var path: UIBezierPath!
    // image
    public var image: UIImage?
    
    // A custom init that sets the type to Stamp on default and assigns our Image variable

    init(image: UIImage!, forBounds bounds: CGRect, withProperties properties: [AnyHashable : Any]?) {
        super.init(bounds: bounds, forType: PDFAnnotationSubtype.stamp, withProperties: properties)

        self.image = image
    }

    // init with path: DrawingAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .ink, withProperties: nil)
    override init(bounds: CGRect, forType annotationType: PDFAnnotationSubtype, withProperties properties: [AnyHashable : Any]?) {
        super.init(bounds: bounds, forType: annotationType, withProperties: properties)
        self.path = UIBezierPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        // check drawing type
        if image != nil {
            drawImage(with: box, in: context)
        } else {
            drawPath(with: box, in: context)
        }
    }

    // draw image
    private func drawImage(with box: PDFDisplayBox, in context: CGContext) {
        guard let image = image else { return }
        
        // Get the CGImage of our image
            guard let cgImage = image.cgImage else { return }

            // Draw our CGImage in the context of our PDFAnnotation bounds 100 x 100
        let imageRect = CGRect(x: bounds.minX, y: bounds.minY, width: 100, height: 100)
            context.draw(cgImage, in: imageRect)

        
//        UIGraphicsPushContext(context)
//        context.saveGState()
//
//        context.setShouldAntialias(true)
//
//        let imageRect = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: bounds.height)
//        image.draw(in: imageRect)
//
//        context.restoreGState()
//        UIGraphicsPopContext()
    }

    // draw path
    private func drawPath(with box: PDFDisplayBox, in context: CGContext) {
        let pathCopy = path.copy() as! UIBezierPath
        UIGraphicsPushContext(context)
        context.saveGState()

        context.setShouldAntialias(true)

        color.set()
        pathCopy.lineJoinStyle = .round
        pathCopy.lineCapStyle = .round
        pathCopy.lineWidth = border?.lineWidth ?? 1.0
        pathCopy.stroke()

        context.restoreGState()
        UIGraphicsPopContext()
    }
}
