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
    private static let SAMPLES = 100
    private static let MAX_REFLECTIONS = 50

    private var camera: Camera
    public var buffer: Buffer
    private let scene: Scene

//    typealias Scene = [Hitable]
    private static let scene: Scene = [
        Sphere(center: Point(0, 0, -1), radius: 0.5, material: Lambertian(albedo: Color(0.8, 0.3, 0.3))),
        Sphere(center: Point(0, -100.5, -1), radius: 100, material: Lambertian(albedo: Color(0.8, 0.8, 0))),
        Sphere(center: Point(1, 0, -1), radius: 0.5, material: Metal(albedo: Color(0.8, 0.6, 0.2), fuzziness: 1)),
        Sphere(center: Point(-1, 0, -1), radius: 0.5, material: Metal(albedo: Color(0.8, 0.8, 0.8), fuzziness: 0.3)),
    ]

    typealias Color = SIMD3<Float>

    init(size: CGSize) {
        self.buffer = Buffer(size: size)

        let location = Point(15, 2, 4)
        let lookingAt = Point(0, 0, 0)

        self.camera = Camera(
            location: location,
            lookingAt: lookingAt,
            aspectRatio: Float(size.width / size.height),
            fieldOfView: 20,
            aperture: 2,
            focusDistance: (location - lookingAt).length
        )

        self.scene = Scene.random()
    }

    func run() {
        for rowIndex in 0..<self.buffer.size.height {
            let y = rowIndex

            for columnIndex in 0..<self.buffer.size.width {
                let x = columnIndex

                DispatchQueue.global(qos: .utility).async {
                    let samples = (0..<Self.SAMPLES).map { sampleIndex -> Color in
                        let u = (Float(x) + self.randomFloat()) / Float(self.buffer.size.width)
                        let v = (Float(y) + self.randomFloat()) / Float(self.buffer.size.height)

                        return self.color(of: self.camera.ray(u, v))
                    }

                    self.buffer.rows[rowIndex][columnIndex] = (samples.reduce(Color.black, +) / Float(samples.count)).pixel
                }
            }
        }
    }

    private func randomFloat() -> Float {
        return Float(drand48())
    }

    private func color(of ray: Camera.Ray, reflections: UInt = 0) -> Color {
        if let hit = self.scene.hit(by: ray, within: 0.001..<Float.greatestFiniteMagnitude) {
            if reflections < Self.MAX_REFLECTIONS {
                if let reflection = hit.material.scatter(ray, hit: hit) {
                    return reflection.attenuation * color(of: reflection.ray, reflections: reflections + 1)
                }
            }

            return Color.black
        }

        let unitDirection = ray.direction.unit
        let t = 0.5 * (unitDirection.y + 1)
        return (1 - t) * Color.white + t * Color.sky
    }
}

extension Raytracer.Color {
    static let red = Self(1, 0, 0)
    static let white = Self(1, 1, 1)
    static let black = Self(0, 0, 0)
    static let blue = Self(0, 0, 1)
    static let sky = Self(0.5, 0.7, 1)

    var pixel: Buffer.Pixel {
        return Buffer.Pixel(self.squareRoot() * 0xff)
    }
}
