class PortalBlue_Spark extends Effects;

/*
simulated function PostBeginPlay()
{
	Velocity = (Vector(Rotation) + VRand()) * 125 * FRand();
}
*/

auto state Explode
{
	simulated function ZoneChange( ZoneInfo NewZone )
	{
		if (NewZone.bWaterZone)
			Destroy();
	}

	simulated function Landed( vector HitNormal )
	{
		Destroy();
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Destroy();
	}
}

defaultproperties
{
     Physics=PHYS_Falling
     LifeSpan=2.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'BTPortalGunV2_1.PortalBlueSparkTex'
     DrawScale=0.015000
     bUnlit=True
     bCollideWorld=True
     bBounce=True
     NetPriority=2.000000
}
