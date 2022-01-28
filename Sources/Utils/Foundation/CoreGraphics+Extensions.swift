import CoreGraphics

extension CGPoint {
    public func distance(to point: CGPoint) -> CGFloat {
        sqrt(squaredDistance(to: point))
    }
    
    public func squaredDistance(to point: CGPoint) -> CGFloat {
        (x - point.x) * (x - point.x) + (y - point.y) * (y - point.y)
    }
}

extension CGRect {
    public init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }
}


extension Array where Element == CGPoint {
    public var centroid: CGPoint {
        CGPoint(x: reduce(CGFloat(0), { $0 + $1.x }) / CGFloat(count),
                y: reduce(CGFloat(0), { $0 + $1.y }) / CGFloat(count))
    }
}

extension CGRect {
    public func extended(by ratio: CGFloat) -> CGRect {
        insetBy(dx: -width * ratio, dy: -height * ratio)
    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin.x)
        hasher.combine(origin.y)
        hasher.combine(size.width)
        hasher.combine(size.height)
    }
}

