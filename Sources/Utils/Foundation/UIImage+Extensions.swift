import UIKit.UIImage
import AVFoundation

extension UIImage {
    public func fixedOrientation() -> UIImage {
        guard var cgImage = self.cgImage,
              self.imageOrientation != .up else {
            return self
        }
        
        var transform: CGAffineTransform = .identity

        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }

        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }
        
        autoreleasepool {
            var context: CGContext?
            
            guard
                let colorSpace = cgImage.colorSpace,
                let _context = CGContext(
                    data: nil,
                    width: Int(self.size.width),
                    height: Int(self.size.height),
                    bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
                return
            }
            context = _context
            
            context?.concatenate(transform)

            var drawRect: CGRect = .zero
            switch imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                drawRect.size = CGSize(width: size.height, height: size.width)
            default:
                drawRect.size = CGSize(width: size.width, height: size.height)
            }

            context?.draw(cgImage, in: drawRect)
            
            guard let newCGImage = context?.makeImage() else {
                return
            }
            cgImage = newCGImage
        }
        
        return UIImage(cgImage: cgImage, scale: 1, orientation: .up)
    }

}

struct CropParameters {
    let center: CGPoint
    let dimension: CGFloat
    let angle: CGFloat
    let imageSize: CGSize
}

extension UIImage {
    func cropped(with parameters: CropParameters) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: ceil(parameters.dimension), height: ceil(parameters.dimension)), format: format)
        return renderer.image { context in
            let halfDimension = parameters.dimension / 2.0
            
            context.cgContext.translateBy(x: halfDimension, y: halfDimension)
            context.cgContext.rotate(by: parameters.angle)
            context.cgContext.translateBy(x: -parameters.center.x, y: -parameters.center.y)
            
            draw(at: .zero)
        }
    }
    
    func watermarked(with watermark: UIImage) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { _ in
            draw(at: .zero)
            
            let expectedWidth = size.width * 0.2
            let expectedHeight = watermark.size.height * expectedWidth / watermark.size.width

            watermark.draw(in: CGRect(
                x: size.width - expectedWidth - 16,
                y: size.height - expectedHeight - 16,
                width: expectedWidth,
                height: expectedHeight)
            )
        }
    }
    
    func blured(radius: CGFloat) -> UIImage {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIGaussianBlur")!
        let beginImage = CIImage(image: self)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter.setValue(radius, forKey: kCIInputRadiusKey)
        
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(currentFilter.outputImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        
        let output = cropFilter.outputImage!
        let cgimg = context.createCGImage(output, from: output.extent)!
        let processedImage = UIImage(cgImage: cgimg)
        
        return processedImage
    }
}

extension UIImage {
    public func resize(to newSize: CGSize) -> UIImage? {
        guard newSize != size else { return self }
        
        defer { UIGraphicsEndImageContext() }

        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func resizeAspect(to dimension: CGFloat) -> UIImage? {
        let aspectRatio = size.width / size.height
        let newSize: CGSize
        if aspectRatio > 1 {
            newSize = CGSize(width: dimension, height: ceil(dimension / aspectRatio))
        } else {
            newSize = CGSize(width: ceil(dimension * aspectRatio), height: dimension)
        }
        
        guard newSize != size else { return self }
        
        defer { UIGraphicsEndImageContext() }

        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func cropped(boundingBox: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: boundingBox) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
    
    public func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(self.size.width),
            Int(self.size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess else {
            return nil
        }

        if let pixelBuffer = pixelBuffer {
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            guard let context = CGContext(
                    data: pixelData,
                    width: Int(self.size.width),
                    height: Int(self.size.height),
                    bitsPerComponent: 8,
                    bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                    space: rgbColorSpace,
                    bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
            ) else {
                return nil
            }

            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1.0, y: -1.0)

            UIGraphicsPushContext(context)
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

            return pixelBuffer
        }

        return nil
    }
}

extension UIImage {
    public func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}

extension UIImage {
    public func flipHorizontally() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: self.size.width/2, y: self.size.height/2)
        context.scaleBy(x: -1.0, y: 1.0)
        context.translateBy(x: -self.size.width/2, y: -self.size.height/2)

        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

extension UIImage {
    public func aspectFit(to newSize: CGSize) -> UIImage? {
        guard size.width > newSize.width || size.height > newSize.height else { return self }
        
        let scaledRect = AVMakeRect(aspectRatio: size, insideRect: CGRect(origin: .zero, size: newSize))
        UIGraphicsBeginImageContextWithOptions(scaledRect.size, true, self.scale)
        draw(in: CGRect(x: 0, y: 0, width: scaledRect.width, height: scaledRect.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension CVPixelBuffer {
    /// Deep copy a CVPixelBuffer:
    ///   http://stackoverflow.com/questions/38335365/pulling-data-from-a-cmsamplebuffer-in-order-to-create-a-deep-copy
    public func copy(newSize: CGSize? = nil) -> CVPixelBuffer? {
        precondition(CFGetTypeID(self) == CVPixelBufferGetTypeID(), "copy() cannot be called on a non-CVPixelBuffer")

        var buffer: CVPixelBuffer?

        let options = [
            String(kCVPixelBufferMetalCompatibilityKey): true as CFBoolean,
            String(kCVPixelBufferIOSurfacePropertiesKey): [:] as CFDictionary
        ] as CFDictionary
        
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            newSize.flatMap { Int($0.width) } ?? CVPixelBufferGetWidth(self),
            newSize.flatMap { Int($0.height) } ?? CVPixelBufferGetHeight(self),
            CVPixelBufferGetPixelFormatType(self),
            options,
            &buffer)

        guard let copy = buffer else { return nil }

        CVBufferPropagateAttachments(self as CVBuffer, copy as CVBuffer)
        
        guard newSize == nil else { return copy }

        CVPixelBufferLockBaseAddress(self, .readOnly)
        CVPixelBufferLockBaseAddress(copy, [])
        defer {
            CVPixelBufferUnlockBaseAddress(copy, [])
            CVPixelBufferUnlockBaseAddress(self, .readOnly)
        }

        for plane in 0 ..< CVPixelBufferGetPlaneCount(self) {
            let dest        = CVPixelBufferGetBaseAddressOfPlane(copy, plane)
            let source      = CVPixelBufferGetBaseAddressOfPlane(self, plane)
            let height      = CVPixelBufferGetHeightOfPlane(self, plane)
            let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(self, plane)

            memcpy(dest, source, height * bytesPerRow)
        }

        return copy
    }
}

extension UIImage {
    public func matrix(_ rows: Int, _ columns: Int) -> [UIImage] {
        let y = (size.height / CGFloat(rows)).rounded()
        let x = (size.width / CGFloat(columns)).rounded()
        var images: [UIImage] = []
        images.reserveCapacity(rows * columns)
        guard let cgImage = cgImage else { return [] }
        (0..<rows).forEach { row in
            (0..<columns).forEach { column in
                var width = Int(x)
                var height = Int(y)
                if row == rows-1 && size.height.truncatingRemainder(dividingBy: CGFloat(rows)) != 0 {
                    height = Int(size.height - size.height / CGFloat(rows) * (CGFloat(rows)-1))
                }
                if column == columns-1 && size.width.truncatingRemainder(dividingBy: CGFloat(columns)) != 0 {
                    width = Int(size.width - (size.width / CGFloat(columns) * (CGFloat(columns)-1)))
                }
                if let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: column * Int(x), y:  row * Int(x)), size: CGSize(width: width, height: height))) {
                    images.append(UIImage(cgImage: image, scale: scale, orientation: imageOrientation))
                }
            }
        }
        return images
    }
}

