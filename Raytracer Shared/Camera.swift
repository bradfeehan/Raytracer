//
//  Camera.swift
//  Raytracer
//
//  Created by Brad Feehan on 29/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

struct Camera {
    private static let ZOOM: Float = 0.5

    private let horizontal: Direction
    private let vertical: Direction

    private let lowerLeftCorner: Point
    private static let origin = Point(0, 0, 0)

    init(size: Buffer.Size) {
        let width = Float(size.width)
        let height = Float(size.height)

        self.horizontal = Direction(width / height / Self.ZOOM, 0, 0)
        self.vertical = Direction(0, 1.0 / Self.ZOOM, 0)
        self.lowerLeftCorner = Point(self.horizontal.x, self.vertical.y, 2) * -0.5
    }

    func ray(_ u: Float, _ v: Float) -> Ray {
        return Ray(origin: Self.origin, direction: self.lowerLeftCorner + u * self.horizontal + v * self.vertical)
    }

    struct Ray {
        let origin: Point
        let direction: Direction

        enum Intersection {
            case Miss
            case Hit(point: Point, normal: Direction)
        }

        func point(atParameter t: Float) -> Point {
            return origin + t * direction
        }
    }
}
