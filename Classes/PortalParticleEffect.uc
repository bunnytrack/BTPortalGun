//=============================================================================
// PortalParticleEffect.
//=============================================================================
class PortalParticleEffect expands TranslocOutEffect;

var Actor Target;

Replication
{
	Reliable if ( Role == ROLE_Authority )
		Target;
}

auto state Explode
{
	simulated function Tick(float DeltaTime)
	{
		if ( Level.NetMode == NM_DedicatedServer )
		{
			Disable('Tick');
			return;
		}
		ScaleGlow = Lifespan/Default.Lifespan;

		DrawScale = 0.08 + 0.105 * (Scaleglow);	
		LightBrightness = (ScaleGlow) * 210.0;
		if ( LifeSpan < 0.8 && Target != None)
			Velocity += Normal((Target.Location - Vector(Target.Rotation)*25) - Location) * 1800 * DeltaTime;
			SetPhysics(PHYS_Projectile);
	}
}

defaultproperties
{
     LifeSpan=1.200000
     LODBias=10.000000
     Texture=Texture'Botpack.Translocator.Tranglow'
     LightType=LT_None
     LightEffect=LE_None
     LightBrightness=0
     LightHue=0
     LightSaturation=0
     LightRadius=0
}
