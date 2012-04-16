$modelname "tiberium\factory.mdl"
$cdmaterials "wtiberium\"
$cdmaterials "models\"
$surfaceprop "Metal"
$body studio "factory2_r.smd"
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
$attachment "las1" "polymsh" -145.00 390.00 0.00 rotate -0 0 0
$attachment "las2" "polymsh" 0.00 390.00 -145.00 rotate -0 0 0
$attachment "las3" "polymsh" 145.00 390.00 0.00 rotate -0 0 0
$attachment "las4" "polymsh" 0.00 390.00 145.00 rotate -0 0 0
$attachment "panel" "polymsh" 200.00 0.00 200.00 rotate 45 0 0
$attachment "spawn" "polymsh" 0.00 48.00 0.00 rotate -0 0 0
$sequence idle "factory2_r" fps 1.00
$collisionmodel "factory2_p.smd" {

	$concave
	$mass 1000.0
	$inertia 1.00
	$damping 0.00
	$rotdamping 0.00
}


