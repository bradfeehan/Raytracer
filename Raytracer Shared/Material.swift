//
//  Material.swift
//  Raytracer
//
//  Created by Brad Feehan on 29/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import simd

struct Reflection {
    let ray: Camera.Ray
    let attenuation: Raytracer.Color
}

protocol Material {
    func scatter(_ ray: Camera.Ray, hit: Hit) -> Reflection?
}

struct Lambertian: Material {
    let albedo: Raytracer.Color

    func scatter(_ ray: Camera.Ray, hit: Hit) -> Reflection? {
        let target: Direction = hit.point + hit.normal + Direction.randomInUnitSphere()
        let scatteredRay = Camera.Ray(origin: hit.point, direction: (target - hit.point))
        return Reflection(ray: scatteredRay, attenuation: self.albedo)
    }
}

struct Metal: Material {
    let albedo: Raytracer.Color
    let fuzziness: Float

    private var normalizedFuzziness: Float {
        if fuzziness < 0 { return 0 }
        if fuzziness > 1 { return 1 }
        return fuzziness
    }

    func scatter(_ ray: Camera.Ray, hit: Hit) -> Reflection? {
        let reflectedDirection = self.reflect(vector: ray.direction.unit, normal: hit.normal)
        let fuzzyDirection = reflectedDirection + normalizedFuzziness * Direction.randomInUnitSphere()
        let scatteredRay = Camera.Ray(origin: hit.point, direction: fuzzyDirection)

        guard dot(scatteredRay.direction, hit.normal) > 0 else { return nil }

        return Reflection(ray: scatteredRay, attenuation: self.albedo)
    }

    private func reflect(vector: Direction, normal: Direction) -> Direction {
        return vector - 2 * dot(vector, normal) * normal
    }
}
