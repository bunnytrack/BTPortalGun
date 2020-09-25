//=============================================================================
// UnportableArea.
//=============================================================================
class UnportableArea expands PortableArea;

function Trigger( actor Other, pawn EventInstigator )
{
	local PortalBlue Portal;

	bInitiallyActive = !bInitiallyActive;

	if(bInitiallyActive){
		foreach AllActors(class'PortalBlue', Portal){
			if(IsPointInArea(Portal.Location)){
				Portal.RemovePortal(Big, Destroy);
			}
		}
	}
}

defaultproperties
{
     Texture=Texture'BTPortalGunV2_1.Icons.UnportableArea'
}
