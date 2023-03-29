//
//  EditorColorPickerViewController.swift
//  PaintPDFApp
//
//  Created by Le Xuan Quynh on 27/03/2023.
//

import UIKit

protocol EditorColorPickerViewControllerDelegate: AnyObject {
    func onColorSelected(color: UIColor)
}

class EditorColorPickerViewController: UIViewController {
    // delegate
    weak var delegate: EditorColorPickerViewControllerDelegate?

    // lazy var imageView
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "colors"))
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.center = self.view.center
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }

    private func setupUI() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        // add image view show color with image "colors"
        self.view.addSubview(imageView)
        // get color when touch inside image view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)

        // add close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        closeButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 200)
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        self.view.addSubview(closeButton)
    }

    // onClose
    @objc func onClose() {
        self.dismiss(animated: true, completion: nil)
    }
    // onTap to get color
    @objc func onTap(sender: UITapGestureRecognizer) {
        let point = sender.location(in: imageView)
        // convert point to pixel position
        let pixelX = point.x * imageView.image!.size.width / imageView.frame.width
        let pixelY = point.y * imageView.image!.size.height / imageView.frame.height
        let point1 = CGPoint(x: pixelX, y: pixelY)
        let color = imageView.image?.getPixelColor(pos: point1)
        // call delegate
        self.delegate?.onColorSelected(color: color ?? .black)
        self.dismiss(animated: true, completion: nil)
    }
}

// UIImage extension
extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
