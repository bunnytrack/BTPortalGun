//=============================================================================
// ActorKillTrigger.
//=============================================================================
class ActorKillTrigger expands Triggers;

var() name ActorTags[16];

function Trigger( actor Other, pawn EventInstigator )
{
	local Actor A;
	local int i;

	for(i=0;i<ArrayCount(ActorTags);i++){
		if(ActorTags[i] == '') continue;

		foreach AllActors( class 'Actor', A, ActorTags[i])
			A.Destroy();
	}
}

defaultproperties
{
     Texture=Texture'BTPortalGunV2_1.Icons.ActorKillTrigger'
     DrawScale=0.400000
     bCollideActors=False
}
