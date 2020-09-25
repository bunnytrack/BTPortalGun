//=============================================================================
// PortalDestroyerTrigger.
//=============================================================================
class PortalDestroyerTrigger expands Triggers;

// When triggered.
function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn P;
  	local Inventory Inv;
  	local PortalGun PG;
	
	P = Pawn(Other);
	if(P == None) return;

	Inv = P.FindInventoryType(class'PortalGun');

	if(Inv == None) return;

	PG = PortalGun(Inv);
	PG.DestroyPortals();
}

defaultproperties
{
     Texture=Texture'BTPortalGunV2_1.Icons.PortalDestroyerTrigger'
     DrawScale=0.400000
     bCollideActors=False
}
