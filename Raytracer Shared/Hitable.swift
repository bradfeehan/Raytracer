//
//  Hitable.swift
//  Raytracer
//
//  Created by Brad Feehan on 29/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import simd

struct Hit {
    let distance: Float
    let point: Point
    let normal: Direction
    let material: Material
}

protocol Hitable {
    func hit(by ray: Camera.Ray, within range: Range<Float>) -> Hit?
}

struct Sphere: Hitable {
    let center: Point, radius: Float
    let material: Material

    func hit(by ray: Camera.Ray, within range: Range<Float>) -> Hit? {
        let originToCenter = ray.origin - self.center
        let a = dot(ray.direction, ray.direction)
        let b = 2 * dot(originToCenter, ray.direction)
        let c = dot(originToCenter, originToCenter) - pow(self.radius, 2)
        let discriminant = b * b - 4 * a * c

        if discriminant <= 0 { return nil }

        let t1 = (-b - discriminant.squareRoot()) / (2 * a)

        if range.contains(t1) {
            let point = ray.point(atParameter: t1)
            return hit(at: point, distance: t1)
        }

        let t2 = (-b + discriminant.squareRoot()) / (2 * a)

        if range.contains(t2) {
            let point = ray.point(atParameter: t2)
            return hit(at: point, distance: t2)
        }

        return nil
    }

    private func hit(at point: Point, distance: Float) -> Hit {
        return Hit(
            distance: distance,
            point: point,
            normal: (point - self.center).unit,
            material: self.material
        )
    }
}
