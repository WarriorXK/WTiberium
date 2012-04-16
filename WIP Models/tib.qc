$modelname "tiberium\medium_tiberium_reactor.mdl"
$cdmaterials "models\"
$surfaceprop "Metal"
$body studio "med_pwr_r.smd"
$texturegroup skinfamilies
{
	{ "metal3.vtf",	"metal4.vtf" }
	{ "metal3_gdi.vtf", "metal4.vtf" }
	{ "metal3_nod.vtf", "metal4.vtf" }
	{ "metal3_gdi.vtf", "metal4_gdi.vtf" }
	{ "metal3_nod.vtf", "metal4_nod.vtf" }
	{ "metal3.vtf",	"metal4_gdi.vtf" }
	{ "metal3.vtf",	"metal4_nod.vtf" }
}
$keyvalues  { prop_data { "base" "Metal.Large"  } } 
$sequence idle "med_pwr_r" fps 1.00
$collisionmodel "med_pwr_p.smd" {

	$concave
	$mass 500.0
	$inertia 1.00
	$damping 0.00
	$rotdamping 0.00
}


