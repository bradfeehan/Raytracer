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

    private let lensRadius: Float
    private let u: Direction, v: Direction, w: Direction

    init(
        location: Point,
        lookingAt: Point,
        aspectRatio: Float,
        upVector: Direction = Self.UP,
        fieldOfView: Float = 90,
        aperture: Float,
        focusDistance: Float
    ) {
        self.lensRadius = aperture / 2

        let theta = fieldOfView * Float.pi / 180
        let halfHeight = tan(theta / 2)
        let halfWidth = aspectRatio * halfHeight

        self.location = location

        self.w = Direction(location - lookingAt).unit
        self.u = Direction(cross(upVector, w)).unit
        self.v = Direction(cross(w, u))

        let w = focusDistance * self.w
        let u = halfWidth * focusDistance * self.u
        let v = halfHeight * focusDistance * self.v

        self.lowerLeftCorner = location - u - v - w
        self.horizontal = 2 * u
        self.vertical = 2 * v
    }

    func ray(_ s: Float, _ t: Float) -> Ray {
        let rd = self.lensRadius * Direction.randomInUnitSphere()
        let offset = self.u * rd.x + self.v * rd.y
        let h = s * self.horizontal
        let v = t * self.vertical
        let origin = self.location + offset
        let direction = self.lowerLeftCorner + h + v - origin
        return Ray(origin: origin, direction: direction)
//        let horizontal: Direction = u * self.horizontal
//        let vertical: Direction = v * self.vertical
//        let offset: Direction = self.lowerLeftCorner - self.location
//        let direction: Direction = offset + horizontal + vertical
//        return Ray(origin: self.location, direction: direction)
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
