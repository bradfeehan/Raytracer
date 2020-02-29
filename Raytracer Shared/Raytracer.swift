//
//  Raytracer.swift
//  Raytracer
//
//  Created by Brad Feehan on 29/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import Foundation
import simd

class Raytracer {
    private static let ZOOM: Float = 0.5

    public var buffer: Buffer

    typealias Scene = [Hitable]
    private static let scene: Scene = [
        Sphere(center: Point(0, 0, -1), radius: 0.5),
        Sphere(center: Point(0, -100.5, -1), radius: 100),
    ]

    private var horizontal, vertical: Direction
    private var lowerLeftCorner: Point

    init(size: CGSize) {
        self.buffer = Buffer(size: size)

        let width = Float(buffer.size.width)
        let height = Float(buffer.size.height)

        self.horizontal = Direction(width / height / Self.ZOOM, 0, 0)
        self.vertical = Direction(0, 1.0 / Self.ZOOM, 0)
        self.lowerLeftCorner = Point(self.horizontal.x, self.vertical.y, 2) * -0.5
    }

    func run() {
        for rowIndex in 0..<buffer.size.height {
            let y = rowIndex
            let v = Float(y) / Float(buffer.size.height)

            for columnIndex in 0..<buffer.size.width {
                let x = columnIndex
                let u = Float(x) / Float(buffer.size.width)

                self.buffer.rows[rowIndex][columnIndex] = self.color(of: self.ray(u, v))
            }
        }
    }

    private func ray(_ u: Float, _ v: Float) -> Ray {
        return Ray(origin: Point.origin, direction: self.lowerLeftCorner + u * self.horizontal + v * self.vertical)
    }

    private func color(of ray: Ray) -> Buffer.Pixel {
        if let hit = Self.scene.hit(by: ray, within: 0.0..<Float.greatestFiniteMagnitude) {
            let rgb = 0.5 * (hit.normal + 1)
            return Buffer.Pixel(rgb * 0xff)
        }

        let unitDirection = ray.direction.unit
        let t = 0.5 * (unitDirection.y + 1)
        return (1 - t) * Buffer.Pixel.white + t * Buffer.Pixel.sky
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

