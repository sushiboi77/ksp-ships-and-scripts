ship:partsnamed("rotoServo.03")[0]:getmodule("ModuleRoboticRotationServo"):setfield("Target Angle", 90).
wait 0.5.
ship:partsnamed("hinge.01")[0]:getmodule("ModuleRoboticServoHinge"):setfield("Target Angle", -30).
wait 0.5.
ship:partsnamed("rotoServo.03")[0]:getmodule("ModuleRoboticRotationServo"):setfield("Target Angle", 0).
wait 0.5.
ship:partsnamed("hinge.01")[0]:getmodule("ModuleRoboticServoHinge"):setfield("Target Angle", 0).


function wrap180 {
    parameter ang.

    until ang <= 180 {
        set ang to ang - 360.
    }

    until ang >= -180 {
        set ang to ang + 360.
    }

    return ang.
}

function bearingFromVector {
    parameter vec.

    local upVec is ship:up:forevector.
    local flatVec is VECTOREXCLUDE(upVec, vec).

    if flatVec:mag < 0.001 {
        return 0.
    }

    local northVec is VECTOREXCLUDE(upVec, ship:north:forevector):normalized.
    local eastVec is VECTOREXCLUDE(upVec, ship:north:rightvector):normalized.

    local b is arcTan2(VDOT(flatVec:normalized, eastVec), VDOT(flatVec:normalized, northVec)).

    until b >= 0 {
        set b to b + 360.
    }

    until b < 360 {
        set b to b - 360.
    }

    return b.
}


set yawServo to ship:partsnamed("rotoServo.03")[0]:getmodule("ModuleRoboticRotationServo").
set pitchServo to ship:partsnamed("hinge.01")[0]:getmodule("ModuleRoboticServoHinge").


until not true {
    wait until not ship:messages:empty.
    set received to ship:messages:pop.

    if received:hassender {
        set targetVessel to vessel(received:sender:name).

        set relVec to targetVessel:position - ship:position.

        // Camera 0 yaw points out of the contraption belly.
        set cameraZeroVector to -ship:facing:topvector.

        set zeroBearing to bearingFromVector(cameraZeroVector).
        set targetBearing to bearingFromVector(relVec).

        set targetYawAng to wrap180(targetBearing - zeroBearing).

        yawServo:setfield("Target Angle", targetYawAng).

        set horizDist to VECTOREXCLUDE(ship:up:forevector, relVec):mag.
        set vertDist to VDOT(relVec, ship:up:forevector) - 7.

        set targetPitchAng to arcTan2(vertDist, horizDist).

        pitchServo:setfield("Target Angle", -targetPitchAng).

        print "zero: " + round(zeroBearing, 2) + " target: " + round(targetBearing, 2) + " yaw: " + round(targetYawAng, 2) + " pitch: " + round(-targetPitchAng, 2).
    }
}