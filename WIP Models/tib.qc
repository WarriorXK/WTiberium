$modelname "tiberium\acc_t.mdl"
$cdmaterials "wtiberium\"
$cdmaterials "models\"
$surfaceprop "Metal"
$body studio "acc_t_r.smd"

//$texturegroup skinfamilies
//{
//	{ "metal3.vtf",	"metal4.vtf" }
//	{ "metal3_gdi.vtf", "metal4.vtf" }
//	{ "metal3_nod.vtf", "metal4.vtf" }
//	{ "metal3_gdi.vtf", "metal4_gdi.vtf" }
//	{ "metal3_nod.vtf", "metal4_nod.vtf" }
//	{ "metal3.vtf",	"metal4_gdi.vtf" }
//	{ "metal3.vtf",	"metal4_nod.vtf" }
//}

$keyvalues  { prop_data { "base" "Metal.Large"  } } 

//$attachment "las1" "polymsh" -147.00 401.85 0.00 rotate -0 0 0
//$attachment "las2" "polymsh" 0.00 401.85 -147.00 rotate -0 0 0
//$attachment "las3" "polymsh" 147.00 401.85 0.00 rotate -0 0 0
//$attachment "las4" "polymsh" 0.00 401.85 147.00 rotate -0 0 0
//$attachment "spawn" "polymsh" 0.00 15.50 0.00 rotate -0 0 0
//$attachment "panel" "polymsh" 200.00 0.00 200.00 rotate -45 -140 90
//$attachment "panel" "polymsh" 200.00 0.00 200.00 rotate -50 -0 -90

$sequence idle "acc_t_r" fps 1.00
$collisionmodel "acc_t_p.smd" {

	$concave
	$mass 50.0
	$inertia 1.00
	$damping 0.00
	$rotdamping 0.00
}


