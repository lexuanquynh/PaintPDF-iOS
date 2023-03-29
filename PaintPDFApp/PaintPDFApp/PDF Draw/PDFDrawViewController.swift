//
//  PDFDrawViewController.swift
//  PaintPDFApp
//
//  Created by Le Xuan Quynh on 27/03/2023.
//

import UIKit
import PDFKit

class PDFDrawViewController: UIViewController, EditorColorPickerViewControllerDelegate {
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var thumbnailView: PDFThumbnailView!
    @IBOutlet weak var thumbnailViewContainer: UIView!
    
    private var shouldUpdatePDFScrollPosition = true
    private let pdfDrawer = PDFDrawer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupPDFView()
    }
    
    private func setupUI() {
        sizeSlider.minimumValue = 1
        sizeSlider.maximumValue = 100
        sizeLabel.text = "\(Int(sizeSlider.value))"
    }
    
    private func setupPDFView() {
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
        pdfView.backgroundColor = view.backgroundColor!
        
        thumbnailView.pdfView = pdfView
        thumbnailView.thumbnailSize = CGSize(width: 100, height: 100)
        thumbnailView.layoutMode = .vertical
        thumbnailView.backgroundColor = thumbnailViewContainer.backgroundColor
        
        navigationController?.isToolbarHidden = false
        
        let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()
        pdfView.addGestureRecognizer(pdfDrawingGestureRecognizer)
        pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
        pdfDrawer.pdfView = pdfView
        
        // for test
        readLocalPDF()
    }

    private func readLocalPDF() {
        // read pdf from local with name "pdfdemo"
        if let path = Bundle.main.url(forResource: "pdfdemo", withExtension: "pdf") {
            if let document = PDFDocument(url: path) {
                pdfView.document = document
            }
        }
    }
        
    @IBAction func changeDrawingTool(sender: UIBarButtonItem) {
        toolbarItems?.forEach({ item in
            item.style = .plain
        })
        
        sender.style = .done
        let drawingTool = DrawingTool(rawValue: sender.tag)!
        // load default size if drawing tool is pen, pencil, highlighter
        if drawingTool == .pen ||
            drawingTool == .pencil ||
            drawingTool == .highlighter ||
            drawingTool == .icon ||
            drawingTool == .eraser {
            sizeSlider.value = pdfDrawer.getWith()
            // update to label
            sizeLabel.text = "\(Int(sizeSlider.value))"
            pdfDrawer.drawingTool = drawingTool
        } else if drawingTool == .undo {
            pdfDrawer.undo()
        } else if drawingTool == .redo {
            pdfDrawer.redo()
        }

    }
    
    @IBAction func onSizeChanged(_ sender: UISlider) {
        sizeLabel.text = "\(Int(sender.value))"
        pdfDrawer.setWith(width: Float(sizeSlider.value))
    }
    
    @IBAction func onColorSelected(_ sender: UIButton) {
        // show EditorColorPickerViewController
        let editorColorPickerViewController = EditorColorPickerViewController()
        editorColorPickerViewController.modalPresentationStyle = .overCurrentContext
        editorColorPickerViewController.modalTransitionStyle = .crossDissolve
        editorColorPickerViewController.delegate = self
        self.present(editorColorPickerViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func onChangeTopTool(_ sender: UIBarButtonItem) {       
        // convert tag to TopTool
        guard let topTool = TopTool(rawValue: sender.tag) else { return }
        switch topTool {
        case .importPDF:
            self.importPDF()
        case .exportPDF:
            self.exportPDF(sender)
        }
    }
    
    enum TopTool: Int {
        case importPDF = 9
        case exportPDF = 10
    }

    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldUpdatePDFScrollPosition {
            fixPDFViewScrollPosition()
        }
        
    }
    
    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    private func fixPDFViewScrollPosition() {
        if let page = pdfView.document?.page(at: 0) {
            pdfView.go(to: PDFDestination(page: page, at: CGPoint(x: 0, y: page.bounds(for: pdfView.displayBox).size.height)))
        }
    }
    
    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldUpdatePDFScrollPosition = false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        pdfView.autoScales = true // This call is required to fix PDF document scale, seems to be bug inside PDFKit
    }
    
    private func importPDF() {
        // show document picker
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }

    private func exportPDF(_ sender: UIBarButtonItem) {
        // export pdf for sharing
        let pdfData = pdfView.document?.dataRepresentation()
        let activityViewController = UIActivityViewController(activityItems: [pdfData!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        self.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: EditorColorPickerViewControllerDelegate
extension PDFDrawViewController {
    func onColorSelected(color: UIColor) {
        // set color for colorButton
        colorButton.backgroundColor = color
        pdfDrawer.color = color
    }
}

// MARK: UIDocumentPickerDelegate
extension PDFDrawViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        // load pdf from url
        let document = PDFDocument(url: url)
        pdfView.document = document
        
    }
}
