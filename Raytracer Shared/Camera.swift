//
//  Camera.swift
//  Raytracer
//
//  Created by Brad Feehan on 29/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import Foundation
import simd

struct Camera {
    private static let ORIGIN = Point(0, 0, 0)
    private static let ZOOM: Float = 0.3
    private static let UP = Direction(0, 1, 0)

    private let horizontal: Direction
    private let vertical: Direction

    private let lowerLeftCorner: Point
    private let location: Point

    init(location: Point, lookingAt: Point, upVector: Direction = Self.UP, fieldOfView: Float = 90, aspectRatio: Float) {
        let theta = fieldOfView * Float.pi / 180
        let halfHeight = tan(theta / 2)
        let halfWidth = aspectRatio * halfHeight

        self.location = location

        let w = Direction(location - lookingAt).unit
        let u = Direction(cross(upVector, w)).unit
        let v = Direction(cross(w, u))

        self.lowerLeftCorner = location - halfWidth * u - halfHeight * v - w
        self.horizontal = 2 * halfWidth * u
        self.vertical = 2 * halfHeight * v
    }

    func ray(_ u: Float, _ v: Float) -> Ray {
        let horizontal: Direction = u * self.horizontal
        let vertical: Direction = v * self.vertical
        let offset: Direction = self.lowerLeftCorner - self.location
        let direction: Direction = offset + horizontal + vertical
        return Ray(origin: self.location, direction: direction)
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
