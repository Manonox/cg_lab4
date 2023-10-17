local transform = {}


function transform.apply(vec, mat)
    return Vec2(mat * Vec3(vec, 1))
end


function transform.translate(vec)
    return Mat3({
        1, 0, vec.x,
        0, 1, vec.y,
        0, 0, 1,
    })
end


local sin, cos = math.sin, math.cos
function transform.rotate(theta, pivot)
    if pivot then
        local translationMatrix = transform.translate(-pivot)
        local negTranslationMatrix = transform.translate(pivot)
        return negTranslationMatrix * transform.rotate(theta) * translationMatrix
    end

    return Mat3({
        cos(theta), -sin(theta), 0,
        sin(theta),  cos(theta), 0,
        0, 0, 1,
    })
end


function transform.scale(vec, pivot)
    if pivot then
        local translationMatrix = transform.translate(-pivot)
        local negTranslationMatrix = transform.translate(pivot)
        return negTranslationMatrix * transform.scale(vec) * translationMatrix
    end

    return Mat3({
        vec.x, 0, 0,
        0, vec.y, 0,
        0, 0, 1,
    })
end


return transform
