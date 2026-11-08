// Author: sushiboi
// starship.ks is a boot file that will run this program on start
// designed for booster propulsive landing on KERBIN only
// all heights are in meters unless stated otherwise
// all speed, velocities, and acceleration are in meters per second (squared) unless stated otherwise
PRINT "landing script takeover".
/////////////////////////////////////////////// Initialization
set agloffset to 80.
set entryburnendalt to 40000.
set entryburnendspeed to 600.
set maxaoa to 30.
//set geardeployheight to 90.
set targpos to 0.
set landingpos to 0.
set main_engine to SHIP:PARTSNAMED("SEP.25.BOOSTER.CLUSTER")[0].
print "WAITING FOR SEP".
/////////////////////////////// FUNCTIONS AND CUSTOM EXPRESSIONS /////////////////////////////////

function geodist {
    parameter pos1.
    parameter pos2.
    return (pos1:position - pos2:position):mag.
}

function errorvec {
    parameter impactpos.
    parameter targposs.
    local v1 to impactpos:position - targposs:position.
    local v2 to VECTOREXCLUDE(ship:up:forevector, v1).
    return v2.
}

function vec_to_target {
    parameter targposs.
    local v1 to targposs:position - ship:position.
    local v2 to VECTOREXCLUDE(ship:up:forevector, v1).
    return v2.
}

function horizontalvelocity {
    local v1 to ship:velocity:surface.
    local v2 to VECTOREXCLUDE(ship:up:forevector, v1).
    return v2.
}

function landingspeed {
    parameter speed.
    parameter maxacc.
    parameter shipVerticalSpeed.
    return ((constant:g0) - (speed + shipVerticalSpeed)) / maxacc.
}

function entrydisplacement {
    parameter entryburnendspeedd.
    parameter shipVelocityMag.
    parameter maxacc.
    return abs((entryburnendspeedd^2 - shipVelocityMag^2) / (2 * maxacc)).
}

function getentryburnstartalt {
    parameter entryburnendaltt.
    parameter entryDisplacementValue.
    return entryburnendaltt + entryDisplacementValue.
}

function getsteeringlanding {
    parameter maxaoaa.
    parameter errorvecValue.
    parameter shipVelocitySurface.
    local vec is -shipVelocitySurface - errorvecValue.
    if vAng(vec, -shipVelocitySurface) > maxaoaa {
        set vec to -shipVelocitySurface:normalized - tan(maxaoaa) * errorvecValue:normalized.
    }
    return vec.
}

function getsteeringlanding2 {
    parameter upForeVector.
    parameter maxaoaa.
    parameter errorvecValue.
    local vec is upForeVector * 70 - errorvecValue.
    if vAng(vec, upForeVector) > maxaoaa {
        set vec to upForeVector:normalized - tan(maxaoaa) * errorvecValue:normalized.
    }
    return vec.
}

function getsteeringlanding3 {
    parameter upForeVector.
    parameter shipVelocitySurface.
    parameter maxaoaa.
    local vec is upForeVector * 70 - vxcl(ship:up:forevector, shipVelocitySurface).
    if vAng(vec, upForeVector) > maxaoaa {
        set vec to upForeVector:normalized - tan(maxaoaa) * vxcl(ship:up:forevector, shipVelocitySurface):normalized.
    }
    return vec.
}

function getsteeringlanding4 {
    parameter maxaoaa.
    local vec is (-horizontalvelocity()*0.015+vec_to_target(landingpos)*0.002) + up:forevector.//horizontalvelocity()*0.1 + up:forevector.//vec_to_target(landingpos)
    if vAng(vec, up:forevector) > maxaoaa {
        set vec to tan(maxaoaa) * (-horizontalvelocity()*0.015+vec_to_target(landingpos)*0.002):normalized + up:forevector:normalized.//horizontalvelocity():normalized.//vec_to_target(landingpos)
    }
    return vec.
}

function getsteeringgliding {
    parameter maxaoaa.
    parameter errorvecValue.
    parameter shipVelocitySurface.
    parameter mult.
    local vec is -shipVelocitySurface + mult * errorvecValue.
    if vAng(vec, -shipVelocitySurface) > maxaoaa {
        set vec to -shipVelocitySurface:normalized + tan(maxaoaa) * errorvecValue:normalized.
    }
    return vec.
}

function getlandingthrottle {
    parameter desiredacc.
    parameter maxacc.
    return desiredacc / maxacc.
}

function compheading {
    parameter geo1.
    parameter geo2.
    return arcTan2(geo1:lng - geo2:lng, geo1:lat - geo2:lat).
}

function landingburnalt {
    parameter maxacc.
    parameter shipVelocityMag.
    local landingDisplacement is abs((0^2 - shipVelocityMag^2) / (2 * maxacc)).
    return (0 + landingDisplacement) * 1.
}

function horiznontalacc {
    parameter maxacc.
    return maxacc * sin(vAng(-up:forevector, -ship:velocity:surface)).
}

function landingtime {
    parameter landingburnaltValue.
    parameter agloffsett.
    parameter shipVelocityMag.
    return (landingburnaltValue - agloffsett) / ((shipVelocityMag) / 2).
}

function overshootpos {
    parameter landingtimeValue.
    parameter horiznontalaccValue.
    parameter shipGeoPosition.
    parameter landingposs.
    parameter factor.
    local dist is geodist(shipGeoPosition, landingposs).
    local ovrshtmultiplier is factor*(landingtimeValue * horiznontalaccValue * 1) / dist.
    local x is (ovrshtmultiplier * (landingposs:lat - shipGeoPosition:lat)) + landingposs:lat.
    local y is (ovrshtmultiplier * (landingposs:lng - shipGeoPosition:lng)) + landingposs:lng.
    return latlng(x, y).
}


//////////////////////////////////////////////////////////////////////////////////////////////
unlock all.
sas off.
rcs off.
gear off.
brakes off.
lock throttle to 0.4.


print "Checking if Trajectories mod is installed...".
wait 0.1.
if addons:tr:available {
    print "Trajectories mod is installed, program is allowed to proceed.".
} else {
    print "Trajectories mod is not installed, rebooting...".
    wait 3.
    reboot.
}

print "Program is overriding all guidance systems of booster from this point onwards...".
print "DO NOT TURN ON SAS!!!".


set steeringManager:rollts to 1.5.
set steeringManager:pitchts to 1.
set steeringManager:yawts to 1.
rcs on.
//lock steering to ship:facing:forevector.

wait 0.1.

set landingpos to latlng(-0.0972043516185744, -74.5576786324102). // Target geoposition, KSC launch pad.
set targpos to landingpos.
addons:tr:settarget(landingpos).
lock impactpos to addons:tr:impactpos.
clearscreen.

print "Target coordinates recorded, target has been set on Trajectories mod".
wait 0.1.
print "Target selected, initialization complete, stand by for landing program activation...".
wait 0.1.

//set LaunchHeading to ship:facing:yaw.

/////////////////////////////////////////////// Initialization complete!

/////////////////////////////////////////////// BOOSTBACK
//SET STEERINGMANAGER:SHOWFACINGVECTORS TO TRUE.
set steeringManager:maxstoppingtime to 5.
lock steering to heading(compheading(targpos, impactpos), 0, 180).
lock throttle to 0.5.
lock maxacc to ship:maxthrust/ship:mass + 0.00001.
set navMode to "SURFACE".

until vAng(heading(compheading(targpos, impactpos), 0):forevector, ship:facing:forevector) < 30 {
    print "Executing flip maneuver for boostback/correction burn".
    print "Current guidance error in degrees: " + round(vAng(heading(compheading(targpos, impactpos), 0):forevector, ship:facing:forevector)).
    wait 0.1.
    clearScreen.
}

toggle AG1.
toggle AG1.

set steeringManager:maxstoppingtime to 2.
lock throttle to 1.

when errorvec(impactpos, targpos):mag < 3000 then {
    lock throttle to 0.3.
    when errorvec(impactpos, targpos):mag < 1000 then {
        lock throttle to 0.1.
    }
}
when errorvec(impactpos, targpos):mag < 100000 then {
    LIST ENGINES IN ccc.
    FOR eng IN ccc {
        if eng:name:contains("SEP.25.BOOSTER.CORE") {
            print("Activating vents.").
            eng:activate().
            break.
        }
    }.
}


until errorvec(impactpos, targpos):mag < 200 {
    print "Trajectory error: " + round(errorvec(impactpos, targpos):mag).
    wait 0.01.
    clearScreen.
}

//set perp to -vxcl(ship:up:forevector, ship:facing:rightvector).

lock throttle to 0.
print "Trajectory error (pre-completion): " + round(errorvec(impactpos, targpos):mag).
print "Boostback complete".

// LIST ENGINES IN myVariable.
// FOR eng IN myVariable {
//     if eng:name:contains("SEP.25.BOOSTER.CORE") {
//         print("Activating vents.").
//         eng:activate().
//         break.
//     }
// }.

print "Max Acc:   " + maxacc.

/////////////////////////////////////////////// COAST TO ENTRY BURN
set top_facing to heading(90,0):vector. //tower roll orientation
set aero_top_facing to VECTOREXCLUDE(ship:up:forevector, ship:geoposition:position - landingpos:position):normalized. //descent aero roll
clearscreen.
print "Coasting to entry burn altitude. Stand by...".
set steeringManager:maxstoppingtime to 2.
set maxaoa to 30.
lock errorfactor to 5.
//lock osp to overshootpos(landingtime(landingburnalt(maxacc, ship:velocity:surface:mag), agloffset, ship:velocity:surface:mag), horiznontalacc(maxacc), ship:geoposition, landingpos, 1).
lock steering to lookDirUp(getsteeringgliding(maxaoa, errorvec(impactpos, targpos), ship:velocity:surface, errorfactor), aero_top_facing).  ///osp
//lock steering to lookDirUp(ship:velocity:surface * -1, top_facing).
lock desiredacc to ship:verticalspeed^2/(2*(alt:radar-agloffset)) + constant:g0.
brakes on.

until maxacc > 37 {
    print maxacc.
    wait 0.1.
    clearScreen.
}

LIST ENGINES IN myVariable.
FOR eng IN myVariable {
    if eng:name:contains("SEP.25.BOOSTER.CORE") {
        print("Deactivating vents.").
        eng:shutdown().
        break.
    }
}.

until alt:radar < 60000{//getentryburnstartalt(entryburnendalt, entrydisplacement(entryburnendspeed, ship:velocity:SURFACE:mag, maxacc)) {
    print "Coasting to entry burn altitude. Stand by...".
    print "Entry burn altitude is: " + round(getentryburnstartalt(entryburnendalt, entrydisplacement(entryburnendspeed, ship:velocity:SURFACE:mag, maxacc))).
    print "Guidance AoA for 'getsteeringgliding': " + round(vAng(ship:velocity:surface * -1, getsteeringgliding(maxaoa, errorvec(impactpos, targpos), ship:velocity:surface, 3))).
    print "Error: " + round(errorvec(impactpos, targpos):mag).
    wait 0.5.
    clearScreen.
}

/////////////////////////////////////////////// ENTRY BURN
//set top_facing1 to -vec_to_target(targpos).

/////////////////////////////////////////////// ATMOSPHERIC GLIDING
set steeringManager:maxstoppingtime to 0.8.
set steeringManager:pitchts to 0.5.
set steeringManager:yawts to 0.5.

// set steeringManager:yawpid:ki to 0.
// set steeringManager:pitchpid:ki to 0.
set maxaoa to 30.


SET STEERINGMANAGER:PITCHPID:KD TO 0.3.
SET STEERINGMANAGER:YAWPID:KD TO 0.3.

// when alt:radar < 20000 then {
//     rcs off.
//     lock errorfactor to max(5, 5 * (20000 - alt:radar) / (20000 - 8000)).
// }

when errorvec(impactpos, targpos):mag < 200 then {
    //lock steering to lookDirUp(ship:velocity:surface * -1, aero_top_facing).
    set steeringManager:maxstoppingtime to 0.1.
    set maxaoa to 15.
    rcs off.
    // SET STEERINGMANAGER:PITCHPID:KP TO 3.
    // SET STEERINGMANAGER:YAWPID:KP TO 3.
}

// when errorvec(impactpos, osp):mag < 150 then {
//     //rcs off.
//     lock steering to lookDirUp(ship:velocity:surface * -1, top_facing).
// }

lock true_diplacement to (alt:radar^2 + errorvec(impactpos, ship:geoposition):mag^2)^0.5.

until true_diplacement < landingburnalt(maxacc, ship:velocity:surface:mag) and alt:radar < 4900 {
    print "Landing burn altitude: " + round(landingburnalt(maxacc, ship:velocity:surface:mag)).
    print "True Displacement: " + round(true_diplacement).
    print "Error: " + round(errorvec(impactpos, targpos):mag).
    wait 0.1.
    clearScreen.
    //addons:tr:settarget(osp).
}

//set steeringManager:pitchtorquefactor to 1.//reset

/////////////////////////////////////////////// LANDING BURN
addons:tr:settarget(landingpos).
set maxaoa to 30.
set steeringManager:maxstoppingtime to 0.7.
lock steering to lookDirUp(ship:velocity:surface * -1, aero_top_facing).
lock throttle to 0.8.

set steeringManager:pitchts to 0.8.
set steeringManager:yawts to 0.8.

SET STEERINGMANAGER:PITCHPID:KP TO 2.
SET STEERINGMANAGER:YAWPID:KP TO 2.
SET STEERINGMANAGER:PITCHPID:KD TO 0.8.
SET STEERINGMANAGER:YAWPID:KD TO 0.8.

wait until vAng(ship:facing:forevector, ship:velocity:surface * -1) < 15.

lock desiredacc to min(ship:verticalspeed, 0)^2 / (2 * (alt:radar - agloffset)) + constant:g0.
lock throttle to getlandingthrottle(desiredacc, maxacc) + 1 * sin(vAng(up:forevector, facing:forevector)).
rcs off.

when ship:velocity:surface:mag < 500 then {
    set targpos to landingpos.
    addons:tr:settarget(landingpos).
    lock steering to lookDirUp(getsteeringlanding(maxaoa, errorvec(impactpos, targpos), ship:velocity:surface), top_facing).
}

set camera to false.
set cameraReady to false.

when alt:radar < 1800 then {
    set camera to vessel("Tracking Camera"):connection.

    if camera:isconnected {
        set cameraReady to true.
        camera:sendmessage("ping").
    } else {
        preserve.
    }
}

set valid to true.

set minspeed to 90.

when ship:verticalSpeed > -minspeed then {
    if valid {
        lock throttle to landingspeed(minspeed, maxacc, ship:verticalSpeed).
    }
}

until ship:verticalSpeed > -minspeed {
    print "Landing!!!".
    print "Error: " + round(errorvec(impactpos, targpos):mag).
    print "Throttle input: " + getlandingthrottle(desiredacc, maxacc).
    print "Max AoA: " + maxaoa.
    wait 0.05.
    clearScreen.
    if cameraReady {
        if camera:isconnected {
            camera:sendmessage("ping").
        }
    }

}

set valid to false.
set steeringManager:maxstoppingtime to 0.5.
STEERINGMANAGER:resetpids().

SET STEERINGMANAGER:PITCHPID:KD TO 0.1.
SET STEERINGMANAGER:YAWPID:KD TO 0.1.

set final_steering to 0.

set special to false.

when vAng(up:forevector, -ship:velocity:surface) < 7 or abs(ship:verticalSpeed) < 15 then {
    set special to true.
    rcs on.
	set maxaoa to 8.
    lock steering to lookDirUp(getsteeringlanding2(up:forevector, maxaoa, errorvec(impactpos, targpos)), top_facing).
}

lock vspeed to 0.

lock steering to lookDirUp(getsteeringlanding4(maxaoa), top_facing).//lookDirUp(ship:velocity:surface * -1 + up:forevector*107, top_facing).
    
set last_height to alt:radar.
set start to abs(ship:verticalSpeed)*1.
lock vspeed to start - start * (last_height - alt:radar) / (last_height - 250).
lock throttle to max(landingspeed(vspeed, maxacc, ship:verticalSpeed), 0.3).

when abs(ship:verticalSpeed) < 8 then {
    rcs on.
    lock vspeed to 8.
    set netdecel to maxacc - constant:g0.
    set stopdist to abs(8)^2 / (2 * netdecel).

    when alt:radar - 79 < stopdist then {
        set last_height to alt:radar.
        set start to abs(ship:verticalSpeed).
        lock vspeed to start - start * (last_height - alt:radar) / (last_height - 79).
        lock throttle to 1 * landingspeed(vspeed, maxacc, ship:verticalSpeed).

        when abs(ship:verticalSpeed) < 5 then {
            lock vspeed to 5.
            set netdecel to maxacc - constant:g0.
            set stopdist to abs(5)^2 / (2 * netdecel).

            when alt:radar - 79 < stopdist then {
                set last_height to alt:radar.
                set start to abs(ship:verticalSpeed).
                lock vspeed to start - start * (last_height - alt:radar) / (last_height - 79).
                lock throttle to 1 * landingspeed(vspeed, maxacc, ship:verticalSpeed).

                when abs(ship:verticalSpeed) < 0.5 then {
                    lock vspeed to 0.5.
                    lock throttle to 1 * landingspeed(vspeed, maxacc, ship:verticalSpeed).
                }
            }
        }
    }
}

when abs(ship:verticalSpeed) < 10 and SHIP:ANGULARVEL:MAG * 180 / CONSTANT():PI < 5 then {
    toggle AG1. //switch to center 3 engines
    rcs on.
    set steeringManager:maxstoppingtime to 0.8.
    SET STEERINGMANAGER:PITCHPID:KD TO 2.
    SET STEERINGMANAGER:YAWPID:KD TO 2.
    set steeringManager:pitchts to 2.//1.5
    set steeringManager:yawts to 2.
}

when errorvec(impactpos, targpos):mag < 1 and VECTOREXCLUDE(ship:up:forevector, ship:velocity:surface):mag < 1 then {
    rcs off.
    set steeringManager:pitchts to 4.//1.5
    set steeringManager:yawts to 4.
}

until alt:radar < 90 {
    print "Error: " + round(errorvec(impactpos, targpos):mag).
    print "Target Speed: " + round(vspeed). 
    print "Special Guidance: " + special.
    print "MAX AoA: " + maxaoa.
    wait 0.1.
    clearScreen.
    if cameraReady {
        if camera:isconnected {
            camera:sendmessage("ping").
        }
    }
}

set last_error to round(errorvec(impactpos, targpos):mag).

if final_steering = 0 {
    lock steering to lookDirUp(getsteeringlanding3(up:forevector, 0.7*ship:velocity:surface, maxaoa), ship:facing:topvector).
    rcs off.
} else {
    lock steering to lookDirUp(getsteeringlanding3(up:forevector, 0.7*ship:velocity:surface, maxaoa), ship:facing:topvector).
    rcs off.
}

until ship:verticalspeed > -0.4 {
    print "Error: " + last_error.
    wait 0.1.
    clearScreen.
    if cameraReady {
        if camera:isconnected {
            camera:sendmessage("ping").
        }
    }
}

lock throttle to 0.
unlock steering.
main_engine:SHUTDOWN(). // Tag of the main engine
print("Main Engines have been shut down.").

wait 3.

set final_displacement to vec_to_target(landingpos):mag.

LIST ENGINES IN myVariable.
FOR eng IN myVariable {
    if eng:name:contains("SEP.25.BOOSTER.CORE") {
        print("Activating vents.").
        eng:activate().
        break.
    }
}.

print("Final error is: " + final_displacement).
print("End of script. Disengaging in 5 seconds").

wait 5.

lock throttle to 0.
unlock all.
rcs off.
print("Disengaged.").