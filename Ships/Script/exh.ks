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
set maxaoa to 20.
//set geardeployheight to 90.
set targpos to 0.
set landingpos to 0.
//set main_engine to SHIP:PARTSNAMED("SEP.25.BOOSTER.CLUSTER")[0].
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

function landingspeed {
    parameter speed.
    parameter maxacc.
    parameter shipVerticalSpeed.
    return ((constant:g0) - (speed + shipVerticalSpeed)) / maxacc.
}

function horizontalvelocity {
    local v1 to ship:velocity:surface.
    local v2 to VECTOREXCLUDE(ship:up:forevector, v1).
    return v2.
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
    local vec is (-horizontalvelocity()*0.1+vec_to_target(landingpos)*0.015) + up:forevector.//horizontalvelocity()*0.1 + up:forevector.//vec_to_target(landingpos)
    if vAng(vec, up:forevector) > maxaoaa {
        set vec to tan(maxaoaa) * (-horizontalvelocity()*0.1+vec_to_target(landingpos)*0.015):normalized + up:forevector:normalized.//horizontalvelocity():normalized.//vec_to_target(landingpos)
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

set landingpos to latlng(-0.122791818628691, -74.5085873032379).//Landing Pad Pos
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
set steeringManager:maxstoppingtime to 1.

set steeringManager:pitchts to 3.
set steeringManager:yawts to 3.

// SET STEERINGMANAGER:PITCHPID:KP TO 2.
// SET STEERINGMANAGER:YAWPID:KP TO 2.
SET STEERINGMANAGER:PITCHPID:KD TO 0.4.
SET STEERINGMANAGER:YAWPID:KD TO 0.4.

lock maxacc to ship:maxthrust/ship:mass + 0.00001.
lock throttle to 1.
lock steering to lookDirUp(getsteeringlanding3(up:forevector, 1*ship:velocity:surface, maxaoa), -vec_to_target(landingpos)).

until ship:verticalspeed > 3 {
    print "Ascending to 1m/s...".
    wait 0.1.
    clearscreen.
}

lock steering to lookDirUp(getsteeringlanding2(up:forevector, maxaoa, errorvec(impactpos, targpos)), -vec_to_target(landingpos)).

until alt:radar > 50 {
    print "Ascending to 50m...".
    wait 0.1.
    clearscreen.
}

/////////////////////////////////////////////// LANDING BURN
addons:tr:settarget(landingpos).
set maxaoa to 30.
lock throttle to max(landingspeed(0, maxacc, ship:verticalSpeed), 0.4).
lock steering to lookDirUp(getsteeringlanding4(maxaoa), ship:facing:topvector).

LIST ENGINES IN ccc.
FOR eng IN ccc {
    if eng:name:contains("SEP.24.SHIP.PROTO.BODY") {
        print("Activating vents.").
        eng:activate().
        break.
    }
}.

until vec_to_target(landingpos):mag < 25 {
    print "Hovering".
    wait 0.1.
    clearscreen.
}

gear on.

lock throttle to landingspeed(4, maxacc, ship:verticalSpeed).

until alt:radar < 15 {
    print "Descending".
    wait 0.1.
    clearscreen.
}

lock throttle to landingspeed(0.3, maxacc, ship:verticalSpeed).

when alt:radar < 10 then {
    lock steering to lookDirUp(up:forevector, ship:facing:topvector).
}



until ship:verticalspeed > -0.1 {
    print "Descending slowly".
    wait 0.1.
    clearscreen.
}

print round(vec_to_target(landingpos):mag, 2).

unlock all.