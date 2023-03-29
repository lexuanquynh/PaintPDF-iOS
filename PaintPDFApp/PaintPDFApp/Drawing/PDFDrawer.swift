//
//  PDFDrawer.swift
//  PaintPDFApp
//
//  Created by Le Xuan Quynh on 28/03/2023.
//

import Foundation
import PDFKit


enum DrawingTool: Int {
    case pencil = 1
    case pen = 2
    case highlighter = 3
    case icon = 4
    case undo = 5
    case redo = 6
    case eraser = 7
    
    var width: CGFloat {
        let userDefault = UserDefaults.standard
        switch self {
        case .pencil:
            // get from userdefault
            let width = userDefault.float(forKey: "pencilWidth")
            return CGFloat(width)
        case .pen:
            let width = userDefault.float(forKey: "penWidth")
            return CGFloat(width)
        case .highlighter:
            let width = userDefault.float(forKey: "highlighterWidth")
            return CGFloat(width)
        default:
            return 0
        }
    }

    var alpha: CGFloat {
        switch self {
        case .highlighter:
            return 0.3
        default:
            return 1
        }
    }
}


class PDFDrawer {
    weak var pdfView: PDFView!
    private var path: UIBezierPath?
    private var currentAnnotation : DrawingAnnotation?
    private var currentPage: PDFPage?
    var color = UIColor.red // default color is red
    var drawingTool = DrawingTool.pen

    init() {
        // save default value for width
        let userDefault = UserDefaults.standard
        userDefault.set(1, forKey: "pencilWidth")
        userDefault.set(10, forKey: "penWidth")
        userDefault.set(10, forKey: "highlighterWidth")
        userDefault.set(10, forKey: "eraserWidth")
    }

    func setWith(width: Float) {
        let userDefault = UserDefaults.standard
        switch drawingTool {
        case .pencil:
            userDefault.set(width, forKey: "pencilWidth")
        case .pen:
            userDefault.set(width, forKey: "penWidth")
        case .highlighter:
            userDefault.set(width, forKey: "highlighterWidth")
        case .eraser:
            userDefault.set(width, forKey: "eraserWidth")
        default:
            break
        }
    }

    func getWith() -> Float {
        let userDefault = UserDefaults.standard
        switch drawingTool {
        case .pencil:
            return userDefault.float(forKey: "pencilWidth")
        case .pen:
            return userDefault.float(forKey: "penWidth")
        case .highlighter:
            return userDefault.float(forKey: "highlighterWidth")
        case .eraser:
            return userDefault.float(forKey: "eraserWidth")
        default:
            return 0
        }
    }

    // MARK: - Undo and Redo
    func undo() {

    }

    func redo() {

    }
}

extension PDFDrawer: DrawingGestureRecognizerDelegate {
    func gestureRecognizerBegan(_ location: CGPoint) {
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        currentPage = page
        let convertedPoint = pdfView.convert(location, to: currentPage!)
        path = UIBezierPath()
        path?.move(to: convertedPoint)
    }
    
    func gestureRecognizerMoved(_ location: CGPoint) {
        guard let page = currentPage else { return }
        let convertedPoint = pdfView.convert(location, to: page)
              
        if drawingTool == .eraser {
            removeAnnotationAtPoint(point: convertedPoint, page: page)
            return
        }
        
        path?.addLine(to: convertedPoint)
        path?.move(to: convertedPoint)
        drawAnnotation(onPage: page)      
    }
    
    func gestureRecognizerEnded(_ location: CGPoint) {
        guard let page = currentPage else { return }
        let convertedPoint = pdfView.convert(location, to: page)
        
        // Erasing
        if drawingTool == .eraser {
            removeAnnotationAtPoint(point: convertedPoint, page: page)
            return
        }
        
        // Drawing
        guard let _ = currentAnnotation else { return }
        
        path?.addLine(to: convertedPoint)
        path?.move(to: convertedPoint)
        
        // Final annotation
        page.removeAnnotation(currentAnnotation!)
        let finalAnnotation = createFinalAnnotation(path: path!, page: page)
        currentAnnotation = nil
    }
    
    private func createAnnotation(path: UIBezierPath, page: PDFPage) -> DrawingAnnotation {
        let border = PDFBorder()
        border.lineWidth = drawingTool.width
        // check by path or image
        if drawingTool == .icon {
            let image = UIImage(named: "icon")
            let annotation = DrawingAnnotation(image: image, forBounds: path.bounds, withProperties: nil)
            annotation.color = color.withAlphaComponent(drawingTool.alpha)
            annotation.border = border
            return annotation
        } else {
            let annotation = DrawingAnnotation(bounds: path.bounds, forType: .ink, withProperties: nil)
            annotation.color = color.withAlphaComponent(drawingTool.alpha)
            annotation.border = border
            return annotation
        }

//        let annotation = DrawingAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .ink, withProperties: nil)
//        annotation.color = color.withAlphaComponent(drawingTool.alpha)
//        annotation.border = border
//        return annotation
    }
    
    private func drawAnnotation(onPage: PDFPage) {
        guard let path = path else { return }
        
        if currentAnnotation == nil {
            // check by path or image
            if drawingTool == .icon {
                currentAnnotation = createAnnotation(path: path, page: onPage)
                currentAnnotation?.path = path
                forceRedraw(annotation: currentAnnotation!, onPage: onPage)
            } else {
                currentAnnotation = createAnnotation(path: path, page: onPage)
                currentAnnotation?.path = path
                forceRedraw(annotation: currentAnnotation!, onPage: onPage)
            }
//            currentAnnotation = createAnnotation(path: path, page: onPage)
        }
        
//        currentAnnotation?.path = path
//        forceRedraw(annotation: currentAnnotation!, onPage: onPage)
    }
    
    private func createFinalAnnotation(path: UIBezierPath, page: PDFPage) -> PDFAnnotation {
        let border = PDFBorder()
        border.lineWidth = drawingTool.width
        
        let bounds = CGRect(x: path.bounds.origin.x - 5,
                            y: path.bounds.origin.y - 5,
                            width: path.bounds.size.width + 10,
                            height: path.bounds.size.height + 10)
        var signingPathCentered = UIBezierPath()
        signingPathCentered.cgPath = path.cgPath
        signingPathCentered.moveCenter(to: bounds.center)
        
        let annotation = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: nil)
        annotation.color = color.withAlphaComponent(drawingTool.alpha)
        annotation.border = border
        annotation.add(signingPathCentered)
        page.addAnnotation(annotation)
                
        return annotation
    }
    
    private func removeAnnotationAtPoint(point: CGPoint, page: PDFPage) {
        if let selectedAnnotation = page.annotationWithHitTest(at: point) {
            selectedAnnotation.page?.removeAnnotation(selectedAnnotation)
        }
    }
    
    private func forceRedraw(annotation: PDFAnnotation, onPage: PDFPage) {
        onPage.removeAnnotation(annotation)
        onPage.addAnnotation(annotation)
    }
}
