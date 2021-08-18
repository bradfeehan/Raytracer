//
//  Material.swift
//  Raytracer
//
//  Created by Brad Feehan on 29/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import simd

struct ScatteredRay {
    let ray: Camera.Ray
    let attenuation: Raytracer.Color
}

protocol Material {
    func scatter(_ ray: Camera.Ray, hit: Hit) -> ScatteredRay?
}

extension Material {
    func reflect(vector: Direction, normal: Direction) -> Direction {
        return vector - 2 * dot(vector, normal) * normal
    }

    func refract(vector: Direction, normal: Direction, niOverNt: Float) -> Direction? {
        let uv = vector.unit
        let dt = dot(uv, normal)
        let discriminant = 1 - niOverNt * niOverNt * (1 - dt * dt)
        guard discriminant > 0 else { return nil }
        return niOverNt * (uv - normal * dt) - normal * discriminant.squareRoot()
    }
}

struct Lambertian: Material {
    let albedo: Raytracer.Color

    func scatter(_ ray: Camera.Ray, hit: Hit) -> ScatteredRay? {
        let target: Direction = hit.point + hit.normal + Direction.randomInUnitSphere()
        let scatteredRay = Camera.Ray(origin: hit.point, direction: (target - hit.point))
        return ScatteredRay(ray: scatteredRay, attenuation: self.albedo)
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

    func scatter(_ ray: Camera.Ray, hit: Hit) -> ScatteredRay? {
        let reflectedDirection = self.reflect(vector: ray.direction.unit, normal: hit.normal)
        let fuzzyDirection = reflectedDirection + normalizedFuzziness * Direction.randomInUnitSphere()
        let scatteredRay = Camera.Ray(origin: hit.point, direction: fuzzyDirection)

        guard dot(scatteredRay.direction, hit.normal) > 0 else { return nil }

        return ScatteredRay(ray: scatteredRay, attenuation: self.albedo)
    }
}

struct Dielectric: Material {
    static let ATTENUATION = Raytracer.Color.white

    let refractiveIndex: Float

    func scatter(_ ray: Camera.Ray, hit: Hit) -> ScatteredRay? {
        let outwardNormal: Direction
        let niOverNt: Float
        let cosine: Float

        let reflected = self.reflect(vector: ray.direction, normal: hit.normal)

        if dot(ray.direction, hit.normal) > 0 {
            outwardNormal = -hit.normal
            niOverNt = self.refractiveIndex
            cosine = self.refractiveIndex * dot(ray.direction, hit.normal) / ray.direction.length
        } else {
            outwardNormal = hit.normal
            niOverNt = 1 / self.refractiveIndex
            cosine = -dot(ray.direction, hit.normal) / ray.direction.length
        }

        if let refracted = self.refract(vector: ray.direction, normal: outwardNormal, niOverNt: niOverNt) {
            let reflectionProbability = schlick(cosine, refractiveIndex)
            if Float(drand48()) > reflectionProbability {
                return ScatteredRay(ray: Camera.Ray(origin: hit.point, direction: refracted), attenuation: Self.ATTENUATION)
            }
        }

        return ScatteredRay(ray: Camera.Ray(origin: hit.point, direction: reflected), attenuation: Self.ATTENUATION)
    }

    private func schlick(_ cosine: Float, _ refractiveIndex: Float) -> Float {
        let r0 = pow((1 - refractiveIndex) / (1 + refractiveIndex), 2)
        return r0 + (1 - r0) * pow(1 - cosine, 5)
    }
}
