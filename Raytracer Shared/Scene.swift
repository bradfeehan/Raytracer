//
//  Scene.swift
//  Raytracer
//
//  Created by Brad Feehan on 29/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import Foundation

typealias Scene = [Hitable]

extension Scene: Hitable {
    func hit(by ray: Camera.Ray, within range: Range<Float>) -> Hit? {
        var closest = range.upperBound
        var maybeHit: Hit?

        self.forEach { hitable in
            if let hit = hitable.hit(by: ray, within: range.lowerBound..<closest) {
                closest = hit.distance
                maybeHit = hit
            }
        }

        return maybeHit
    }
}

extension Scene {
    static func random() -> Self {
        var list: [Hitable] = []

        list.append(Sphere(center: Point(0, -1000, 0), radius: 1000, material: Lambertian(albedo: Raytracer.Color(0.5, 0.5, 0.5))))

        for a in -11..<11 {
            for b in -11..<11 {
                let material = drand48()
                let center = Point(Float(a) + 0.9 * Float(drand48()), 0.2, Float(b) + 0.9 * Float(drand48()))

                if (center - Point(4, 0.2, 0)).length > 0.9 {
                    if material < 0.8 {
                        list.append(
                            Sphere(
                                center: center,
                                radius: 0.2,
                                material: Lambertian(
                                    albedo: Raytracer.Color(Float(drand48() * drand48()), Float(drand48() * drand48()), Float(drand48() * drand48()))
                                )
                            )
                        )
                    } else if material < 0.95 {
                        list.append(
                            Sphere(
                                center: center,
                                radius: 0.2,
                                material: Metal(
                                    albedo: Raytracer.Color(0.5 * Float(1 + drand48()), 0.5 * Float(1 + drand48()), 0.5 * Float(1 + drand48())),
                                    fuzziness: 0.5 * Float(drand48())
                                )
                            )
                        )
                    } else {
                        list.append(Sphere(center: center, radius: 0.2, material: Dielectric(refractiveIndex: 1.5)))
                    }
                }
            }
        }

        list.append(Sphere(center: Point(0, 1, 0), radius: 1, material: Dielectric(refractiveIndex: 1.5)))
        list.append(Sphere(center: Point(-4, 1, 0), radius: 1, material: Lambertian(albedo: Raytracer.Color(0.4, 0.2, 0.1))))
        list.append(Sphere(center: Point(4, 1, 0), radius: 1, material: Metal(albedo: Raytracer.Color(0.7, 0.6, 0.5), fuzziness: 0.0)))

        return Self(list)
    }
}
