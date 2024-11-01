//%attributes = {"preemptive":"capable"}
//This Property has been chosen: Run in a preemptive process if possible
C_LONGINT:C283($thermoID; $process2call; $window2call; $nbOfSlices)

$process2call:=$1
$window2call:=$2
$what2Do:=$3
$obj_Parameters:=$4

DEMO_Statistics($process2call; $window2call; $what2Do; $obj_Parameters)

