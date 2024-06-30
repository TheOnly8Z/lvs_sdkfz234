// Created by Crowbar 0.74

$modelname "8z/lvs/sdkfz234puma_wheel.mdl"

$bodygroup "body"
{
	studio "puma_wheel.smd"
}

$surfaceprop "rubbertire"

$contents "solid"

$cdmaterials "models\8z\lvs\sdkfz234puma\"

$texturegroup "skinfamilies"
{
	{ "props_sdkfz234_puma_color" }
	{ "props_sdkfz234_puma_color_green" }
}

$sequence "idle" {
	"sdkfz234puma_wheel_anims\idle.smd"
	activity "ACT_IDLE" -1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}
$collisionmodel "puma_wheel.smd"
{
	$mass 75
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone ""
}
