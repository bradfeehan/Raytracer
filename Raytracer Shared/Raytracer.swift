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
    private var camera: Camera
    public var buffer: Buffer

    typealias Scene = [Hitable]
    private static let scene: Scene = [
        Sphere(center: Point(0, 0, -1), radius: 0.5),
        Sphere(center: Point(0, -100.5, -1), radius: 100),
    ]

    init(size: CGSize) {
        self.buffer = Buffer(size: size)
        self.camera = Camera(size: self.buffer.size)
    }

    func run() {
        for rowIndex in 0..<buffer.size.height {
            let y = rowIndex
            let v = Float(y) / Float(buffer.size.height)

            for columnIndex in 0..<buffer.size.width {
                let x = columnIndex
                let u = Float(x) / Float(buffer.size.width)

                self.buffer.rows[rowIndex][columnIndex] = self.color(of: self.camera.ray(u, v))
            }
        }
    }

    private func color(of ray: Camera.Ray) -> Buffer.Pixel {
        if let hit = Self.scene.hit(by: ray, within: 0.0..<Float.greatestFiniteMagnitude) {
            let rgb = 0.5 * (hit.normal + 1)
            return Buffer.Pixel(rgb * 0xff)
        }

        let unitDirection = ray.direction.unit
        let t = 0.5 * (unitDirection.y + 1)
        return (1 - t) * Buffer.Pixel.white + t * Buffer.Pixel.sky
    }
}

