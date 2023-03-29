//
//  LazyPaintViewController.swift
//  PaintPDFApp
//
//  Created by Le Xuan Quynh on 29/03/2023.
//

import UIKit
import LazyPDFKit

class LazyPaintViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    private func openLazyPDF() {
        let phrase = "" // Document password (for unlocking most encrypted PDF files)

        let pdfs = Bundle.main.paths(forResourcesOfType: "pdf", inDirectory: nil)

        let filePath = pdfs.first
        assert(filePath != nil) // Path to first PDF file

        let document = LazyPDFDocument(filePath: filePath, password: phrase)

        if document != nil { // Must have a valid LazyPDFDocument object in order to proceed with things
            guard let lazyPDFViewController = LazyPDFViewController(lazyPDFDocument: document) else {
                return
            }
            lazyPDFViewController.delegate = self
            lazyPDFViewController.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(lazyPDFViewController, animated: true)
        } else { // Log an error so that we know that something went wrong
            
        }
    }
    
    @IBAction func onOpenPDF(_ sender: Any) {
        openLazyPDF()
    }
    
}


extension LazyPaintViewController: LazyPDFViewControllerDelegate {
    
}
