// Created by Crowbar 0.74

$modelname "8z/lvs/sdkfz234puma.mdl"

$bodygroup "body"
{
	studio "puma.smd"
}

$surfaceprop "metalvehicle"
$contents "solid"

$cdmaterials "models\8z\lvs\sdkfz234puma\"

$illumposition 48.524 -0.147 63.691

$texturegroup "skinfamilies"
{
	{ "props_sdkfz234_puma_color" }
	{ "props_sdkfz234_puma_color_green" }
}

$attachment "muzzle_turret" "gun" 0.00 100.00 2.40 rotate 0 90 -90
$attachment "muzzle_mg" "gun" -1.50 18.00 11.00 rotate 0 90 -90

$attachment "smoke_left" "turret" -8.00 24.00 24.00 rotate -120 0 0
$attachment "smoke_right" "turret" -8.00 -24.00 24.00 rotate -120 0 0

$attachment "viewport_driver" "body" -4.00 50.00 50.00 rotate -90 -0 0
$attachment "viewport_gunner" "turret" -15 -17 10 rotate -90 0 0
$attachment "viewport_commander" "turret" -15.00 11.00 12.00 rotate -90 0 0


$poseparameter "turret_pitch" -10 10 loop 0
$poseparameter "turret_yaw" 0 360 loop 360

$sequence "idle" {
	"anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}
$animation neutral "anims/idle.smd" frames 0 0

$weightlist "weights_turret_pitch" { "gun" 1 }
$weightlist "weights_turret_yaw" { "turret" 1 }

$animation "turret_pitch1" "anims\poses.smd" {
	frame 5 5
	subtract neutral 0
	weightlist "weights_turret_pitch"
}
$animation "turret_pitch2" "anims\poses.smd" {
	frame 6 6
	weightlist "weights_turret_pitch"
	subtract neutral 0
}
$sequence "turret_pitch" {
	"turret_pitch1"
	"turret_pitch2"
	autoplay
	blend "turret_pitch" -10 10
	blendwidth 2
	fadein 0.2
	fadeout 0.2
	delta
}

$animation "turret_yaw1" "anims\poses.smd" {
	frame 0 0
	weightlist "weights_turret_yaw"
	subtract neutral 0
}
$animation "turret_yaw2" "anims\poses.smd" {
	frame 1 1
	weightlist "weights_turret_yaw"
	subtract neutral 0
}
$animation "turret_yaw3" "anims\poses.smd" {
	frame 2 2
	weightlist "weights_turret_yaw"
	subtract neutral 0
}
$animation "turret_yaw4" "anims\poses.smd" {
	frame 3 3
	weightlist "weights_turret_yaw"
	subtract neutral 0
}
$animation "turret_yaw5" "anims\poses.smd" {
	frame 4 4
	weightlist "weights_turret_yaw"
	subtract neutral 0
}
$sequence "turret_yaw" {
	"turret_yaw1"
	"turret_yaw2"
	"turret_yaw3"
	"turret_yaw4"
	"turret_yaw5"
	autoplay
	delta
	blend "turret_yaw" 0 360
	blendwidth 5
	fadein 0.2
	fadeout 0.2
}

$collisionmodel "phys.smd"
{
	$mass 1000
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone ""
	$concave
}
