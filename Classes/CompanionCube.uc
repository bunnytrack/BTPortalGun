class CompanionCube extends Decoration;

#exec MESH IMPORT MESH=CompanionCube ANIVFILE=MODELS\PortalCube_a.3d DATAFILE=MODELS\PortalCube_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=CompanionCube X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=CompanionCube SEQ=All				STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=CompanionCube SEQ=CompanionCube	STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=CompanionCube MESH=CompanionCube
#exec MESHMAP SCALE MESHMAP=CompanionCube X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=CompanionCube NUM=1 TEXTURE=PortalCube_Heart

var 	float 		LastZ;
var		string		BumpName;

Auto State Animate
{
	Function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
	{
		Instigator = InstigatedBy;

		if(Physics == PHYS_Falling)
		{
		    Momentum.Z = 2000;
		    Velocity = Momentum * 0.012;
        }
		else
		{
            SetPhysics(PHYS_Falling);
		    Momentum.Z = 1000;
		    Velocity = Momentum * 0.032;
        }
	}
}

Singular Function ZoneChange(ZoneInfo NewZone)
{
	local float SplashSize;
	local Actor Splash;
	local float Ratio;

	if(NewZone.bWaterZone)
	{
		if(!Region.Zone.bWaterZone)
		{
			if(LastZ > 0 && Abs(Velocity.Z) > LastZ)
			{
				Ratio = 2 - (1 / (Abs(Velocity.Z) / LastZ));
				Buoyancy = FMin(15, Buoyancy * Ratio);
				LastZ = Abs(Velocity.Z) * Ratio;
			}
			else
				LastZ = Abs(Velocity.Z);			

			if(Velocity.Z < -200 && NewZone.EntrySound != None)
				PlaySound(NewZone.EntrySound, SLOT_Interact, SplashSize);

			if(Abs(Velocity.Z) > 32 && NewZone.EntryActor != None)
			{
				SplashSize = FClamp(0.0001 * Mass * (250 - 0.5 * FMax(-600,Velocity.Z)), 1.0, 3.0);
				Splash = Spawn(NewZone.EntryActor); 
				if (Splash != None)
					Splash.DrawScale = SplashSize;
			}
		}
	}
	else if(Region.Zone.bWaterZone)
	{
		bBobbing = true;
		Buoyancy = FMax(Mass, 0.8 * Buoyancy);
	}
}

Function Bump(Actor Other)
{
	local Vector BumpBoost;
	local Vector NewSpeed;
	local float SpeedDiff;
	local int Damage;

	if( Other.IsA('Pawn') || Other.IsA('Decoration') )
	{
		if( VSize(Velocity) > VSize(Other.Velocity) )
		{
			SpeedDiff = Vsize(Velocity - Other.Velocity);
			if (SpeedDiff > 616)
			{
				BumpBoost = Velocity * 75;

				if(BumpBoost.Z >= 0)
					BumpBoost.Z = BumpBoost.Z * 0.75;
				else
					BumpBoost.Z = BumpBoost.Z * 0.5;

				if( BumpName == String(Other.Name) )
					Damage = 0;
				else
					Damage = int( (SpeedDiff - 600) / 16 );

				Other.TakeDamage(Damage, Instigator, Other.Location, BumpBoost, 'Decapitated');
				BumpName = String(Other.name);
				SetTimer(0.2, false);
			}
		}
		else if(Pawn(Other) != None)
		{
			if(bPushable)
			{
				bBobbing = false;
				NewSpeed = Other.Velocity;
				if(NewSpeed.Z <= 24)
					NewSpeed.Z = 24;
				Velocity = NewSpeed;

				if (!bPushSoundPlaying)
					PlaySound(PushSound, SLOT_Misc, 0.25);
				bPushSoundPlaying = true;
				SetPhysics(PHYS_Falling);
				SetTimer(0.3, false);
				Instigator = Pawn(Other);
			}
		}
	}
}

Function Timer()
{
	if(bPushSoundPlaying)
		bPushSoundPlaying = false;
	if(BumpName != "")
		BumpName = "";

	PlaySound(EndPushSound, SLOT_Misc, 0.0);
}

defaultproperties
{
     bPushable=True
     PushSound=Sound'UnrealShare.General.ObjectPush'
     EndPushSound=Sound'UnrealShare.General.Endpush'
     bStatic=False
     LODBias=16.000000
     DrawType=DT_Mesh
     Mesh=LodMesh'BTPortalGunV2_1.CompanionCube'
     DrawScale=1.666000
     CollisionRadius=29.000000
     CollisionHeight=26.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     Mass=10.000000
     Buoyancy=15.000000
     NetPriority=3.000000
}
