//
//  Camera.swift
//  Raytracer
//
//  Created by Brad Feehan on 29/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

struct Camera {
    private static let ORIGIN = Point(0, 0, 0)
    private static let ZOOM: Float = 0.3

    private let horizontal: Direction
    private let vertical: Direction

    private let lowerLeftCorner: Point
    private let location: Point

    init(size: Buffer.Size, location: Point = Self.ORIGIN, zoom: Float = Self.ZOOM) {
        self.location = location

        let width = Float(size.width)
        let height = Float(size.height)

        self.horizontal = Direction(width / height / zoom, 0, 0)
        self.vertical = Direction(0, 1.0 / zoom, 0)
        self.lowerLeftCorner = Point(self.horizontal.x, self.vertical.y, 2) * -0.5
    }

    func ray(_ u: Float, _ v: Float) -> Ray {
        return Ray(origin: self.location, direction: self.lowerLeftCorner + u * self.horizontal + v * self.vertical)
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
