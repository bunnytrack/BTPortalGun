//=============================================================================
// PortableArea.
//=============================================================================
class PortableArea expands Keypoint;

var() bool bInitiallyActive;

function Trigger( actor Other, pawn EventInstigator )
{
	local PortalBlue Portal;
	
	bInitiallyActive = !bInitiallyActive;

	if(!bInitiallyActive){
		foreach AllActors(class'PortalBlue', Portal){
			if(IsPointInArea(Portal.Location)){
				Portal.RemovePortal(Big, Destroy);
			}
		}
	}
}

Simulated Function bool IsPointInArea(Vector Point){

	local Vector CylinderToPoint, Horizontal, Vertical;

	CylinderToPoint = Point - Location;
	Horizontal = CylinderToPoint;
	Horizontal.Z = 0;

	return (VSize(Horizontal) < CollisionRadius && Abs(Point.Z - Location.Z) < CollisionHeight);
}

defaultproperties
{
     bInitiallyActive=True
     bStatic=False
     bNoDelete=True
     Texture=Texture'BTPortalGunV2_1.Icons.PortableArea'
     DrawScale=0.400000
     CollisionRadius=128.000000
     CollisionHeight=128.000000
     bCollideActors=True
}
