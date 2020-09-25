class PortalGun extends TournamentWeapon;

/*##################################################################################################
## Sounds
##################################################################################################*/
#exec audio import file=Sounds\Portal_AmbientLoop.wav
#exec audio import file=Sounds\Portal_Connected.wav
#exec audio import file=Sounds\Portal_Open.wav
#exec audio import file=Sounds\Portal_Close.wav
#exec audio import file=Sounds\Portal_Close2.wav
#exec audio import file=Sounds\Portal_Enter.wav
#exec audio import file=Sounds\Portal_Exit.wav
#exec audio import file=Sounds\PortalGun_Shoot_Blue.wav
#exec audio import file=Sounds\PortalGun_Shoot_Yellow.wav
#exec audio import file=Sounds\Portal_Invalid_Surface.wav
#exec audio import file=Sounds\Portal_Fail.wav
#exec audio import file=Sounds\PortalGun_Selected.wav

/*##################################################################################################
## Textures
##################################################################################################*/
#exec OBJ LOAD FILE=Textures\BTPortalGunV2Textures.utx PACKAGE=BTPortalGunV2_1
/*##################################################################################################
## Mesh - Portal
##################################################################################################*/
#exec MESH IMPORT MESH=portal ANIVFILE=MODELS\portal_a.3d DATAFILE=MODELS\portal_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=portal X=24 Y=0 Z=0

#exec MESH SEQUENCE MESH=portal SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=portal SEQ=portal STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=portal MESH=portal
#exec MESHMAP SCALE MESHMAP=portal X=0.1 Y=0.1 Z=0.2

/*##################################################################################################
## Mesh - Pickup
##################################################################################################*/
#exec MESH IMPORT MESH=p_PortalGun ANIVFILE=MODELS\w_PortalGun_a.3d DATAFILE=MODELS\w_PortalGun_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=p_PortalGun X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=p_PortalGun SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=p_PortalGun SEQ=W_PORTALGUN STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW			MESHMAP=p_PortalGun MESH=p_PortalGun
#exec MESHMAP SCALE			MESHMAP=p_PortalGun X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE	MESHMAP=p_PortalGun NUM=0  TEXTURE=w_PortalGun

/*##################################################################################################
## Mesh - ThirdPerson
##################################################################################################*/
#exec MESH IMPORT MESH=w_PortalGun ANIVFILE=MODELS\w_PortalGun_a.3d DATAFILE=MODELS\w_PortalGun_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=w_PortalGun X=-80 Y=0 Z=-12 YAW=0 PITCH=8 ROLL=0

#exec MESH SEQUENCE MESH=w_PortalGun SEQ=All    STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=w_PortalGun SEQ=W_PORTALGUN STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW			MESHMAP=w_PortalGun MESH=w_PortalGun
#exec MESHMAP SCALE			MESHMAP=w_PortalGun X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE	MESHMAP=w_PortalGun NUM=0  TEXTURE=w_PortalGun

/*##################################################################################################
## Mesh - FirstPerson
##################################################################################################*/
#exec OBJ LOAD FILE=FILE\PGmesh.u PACKAGE=BTPortalGunV2_1
#exec MESHMAP SETTEXTURE MESHMAP=v_PortalGun NUM=1  TEXTURE=v_PortalGun
#exec MESHMAP SETTEXTURE MESHMAP=v_PortalGun NUM=2  TEXTURE=v_PortalGun_Glass

/*##################################################################################################
##
## Portal Gun Class
##
##################################################################################################*/
var PortalBlue Portal1, Portal2;
var PortalGunMutator PGM;
var bool bPortableEverywhere;

var enum EFireType
{
	Fire,
	AltFire
} FireType;

var enum EAnimType
{
	Fire,
	InvalidSurface,
	PortalReturn
} AnimType;

var enum EPortableAreaConfiguration
{
	NoPortableAreas,
	OnlyPortableAreas,
	OnlyUnportableAreas,
	PortableAndUnportableAreas
} PortableAreaConfiguration;

Replication
{
	Reliable if(Role == ROLE_Authority)
		Portal1, Portal2, PortableAreaConfiguration;
}

/*##################################################################################################
##
## Initialization
##
##################################################################################################*/
Function PreBeginPlay(){
	CheckForPortalGunMutator();
	CheckForPortableAreaConfiguration();
}

Function CheckForPortalGunMutator(){

	foreach AllActors(class'PortalGunMutator', PGM){
		break;
	}

	if(PGM == None){
		PGM = Spawn(class'PortalGunMutator');
	}
}

Function CheckForPortableAreaConfiguration(){
	switch(PGM.PortableAreaConfiguration){
		case NoPortableAreas:
			PortableAreaConfiguration = NoPortableAreas;
			break;
		case OnlyPortableAreas:
			PortableAreaConfiguration = OnlyPortableAreas;
			break;
		case OnlyUnportableAreas:
			PortableAreaConfiguration = OnlyUnportableAreas;
			break;
		case PortableAndUnportableAreas:
			PortableAreaConfiguration = PortableAndUnportableAreas;
			break;
	}
}
/*##################################################################################################
##
## Render Functions
##
##################################################################################################*/
Simulated Event RenderOverlays(Canvas C)
{
	local bool bPlayerOwner;
	local int Hand;
	local Rotator NewRot;

	if(bHideWeapon || (Owner == None))
		return;

	if(PlayerPawn(Owner) != None)
	{
		bPlayerOwner = true;
		Hand = PlayerPawn(Owner).Handedness;
	}
	if((Level.NetMode == NM_Client) && bPlayerOwner && (Hand == 2))
	{
		bHideWeapon = true;
		return;
	}
	if ( !bPlayerOwner || (PlayerPawn(Owner).Player == None) )
		PlayerPawn(Owner).WalkBob = vect(0, 0, 0);

	newRot = Pawn(Owner).ViewRotation;
	SetLocation(Owner.Location + CalcDrawOffset());

	if ( Hand == 0 )
		newRot.Roll = -2 * Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll * Hand;
	setRotation(newRot);
	C.DrawActor(Self, false);
}

/*##################################################################################################
##
## Misc Functions
##
##################################################################################################*/
Function DestroyPortals(){
	if(Portal1 != None){
		Portal1.RemovePortal(Big, Destroy);
	}
	if(Portal2 != None){
		Portal2.RemovePortal(Big, Destroy);
	}
}

/*##################################################################################################
##
## Fire Functions
##
##################################################################################################*/
Function Fire(float value)
{
	bPointing = true;
	bCanClientFire = true;
	Pawn(Owner).PlayRecoil(FiringSpeed);

	if( Owner.Isa('playerpawn') ){
		GotoState('NormalFire');
		ClientFire(Value);
		Traceng(Fire);
	}
}

Function AltFire(float value)
{
	bPointing = true;
	bCanClientFire = true;
	Pawn(Owner).PlayRecoil(FiringSpeed);

	if( Owner.Isa('playerpawn') ){
		GotoState('AltFiring');
		ClientAltFire(Value);
		Traceng(AltFire);
	}
}

Function bool Traceng(EFireType FireType)
{
	local Vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local Actor Other;
	local bool bInvalidShot;

	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;

	AdjustedAim = Pawn(Owner).AdjustAim(1000000, StartTrace, 2.75 * AimError, False, False);
	EndTrace = StartTrace + (10000 * vector(AdjustedAim));

	Other = Pawn(Owner).Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	Owner.MakeNoise(Pawn(Owner).SoundDampening);

	foreach TraceActors(class'Actor', Other, HitLocation, HitNormal, EndTrace, StartTrace){

		if(Other.IsA('BlockPortal')){
			bInvalidShot = true;
			break;
		} else if(Other == Level || Other.IsA('Mover')){
			if(ValidatePortalLocation(StartTrace, HitLocation, AdjustedAim, FireType) )
			{
				if( !CollidingPortal(HitLocation, FireType) )
				{
					ShootPortal(Other, HitLocation, HitNormal, FireType);
				} else{
					bInvalidShot = true;
				}
			} else{
				bInvalidShot = true;
			}
			break;
		}
	}

	if(bInvalidShot){
		Effectz(Hitlocation, Hitnormal, FireType);
	}
	return !bInvalidShot;
}

Function ShootPortal(Actor Other, Vector HitLocation, Vector HitNormal, EFireType FireType)
{
	local rotator PortalRot;
	local vector X, Y, Z;

	if(HitNormal.Z >= 0.99 || HitNormal.Z <= -0.99){
		PortalRot = Owner.Rotation;
		PortalRot.Pitch = HitNormal.Z * 16384;
		PortalRot.Roll += 16384;
	} else{
		PortalRot = rotator(HitNormal);
		PortalRot.Roll += 16384;
	}

	if(FireType == Fire)
	{
		if(Portal1 != None)
		{
			Portal1.RemovePortal(Big, Destroy);
			Portal1 = None;
		}

		Portal1 = Spawn(class'PortalBlue',self,, HitLocation + (8 * HitNormal), PortalRot);
		if(Other.IsA('Mover'))
			Portal1.MoverName = Mover(Other);
	}
	else if(FireType == AltFire)
	{
		if(Portal2 != None)
		{
			Portal2.RemovePortal(Big, Destroy);
			Portal2 = None;
		}

		Portal2 = Spawn(class'PortalYellow',self,, HitLocation + (8 * HitNormal), PortalRot);
		if(Other.IsA('Mover'))
			Portal2.MoverName = Mover(Other);
	}
}

Simulated Function Effectz(Vector HitLocation, Vector HitNormal, EFireType FireType)
{
	local Spark3 Effect;

	if(FireType == Fire)
	{
		SpawnSparks(HitLocation, HitNormal, FireType);
		Effect = Spawn(class'Spark3',,, HitLocation, Rotator(HitNormal));
		Effect.DrawScale = 0.1;
	}
	else if(FireType == AltFire)
	{
		SpawnSparks(HitLocation, HitNormal, FireType);
		Effect = Spawn(class'Spark34',,, HitLocation, Rotator(HitNormal));
		Effect.DrawScale = 0.1;
	}
}

Function SpawnSparks(Vector HitLocation, Vector HitNormal, EFireType FireType)
{
	local PortalBlue_Spark Spark;
	local int NumSparks;
	local int x;

	NumSparks = FMax(Rand(16), 8);
	if(FireType == Fire)
	{
		for (x = 0; x < NumSparks; x++)
		{
			Spark = Spawn(class'PortalBlue_Spark',,, HitLocation + (8 * HitNormal), Rotator(HitNormal));
			Spark.Velocity = (HitLocation + VRand()) * 125 * FRand();
		}
	}
	else if(FireType == AltFire)
	{
		for (x = 0; x < NumSparks; x++)
		{
			Spark = Spawn(class'PortalYellow_Spark',,, HitLocation + (8 * HitNormal), Rotator(HitNormal));
			Spark.Velocity = (HitLocation + VRand()) * 125 * FRand();
		}
	}
}

/*##################################################################################################
##
## Portal Validation Stuff
##
##################################################################################################*/
Simulated Function bool ValidatePortalLocation(Vector StartTrace, Vector EndTrace, Rotator AdjustedAim, EFireType FireType){
	local Vector BlockLocation, BlockNormal;
	local bool bHitPortableArea, bHitUnportableArea;
	local PortableArea PA;

	if(PortableAreaConfiguration == NoPortableAreas) return true;

	foreach TraceActors(class'PortableArea', PA, BlockLocation, BlockNormal, EndTrace, StartTrace)
	{
		if(!PA.IsA('PortableArea') || !PA.bInitiallyActive) continue;

		if(PA.IsPointInArea(EndTrace)){
			if(PA.IsA('UnportableArea')){
				bHitUnportableArea = true;
				break;
			} else{
				bHitPortableArea = true;
				continue;
			}
		}
	}

	return (PortableAreaConfiguration == OnlyUnportableAreas || bHitPortableArea) && !bHitUnportableArea;
}

Simulated Function bool CollidingPortal(Vector PortalLocation, EFireType FireType)
{
	local PortalBlue Bro;

	foreach VisibleCollidingActors(class'PortalBlue', Bro, 78, PortalLocation)
	{
		if( (Bro.Owner == Pawn(Owner) && Bro.IsA('PortalYellow') && FireType == Fire)
		||	(Bro.Owner == Pawn(Owner) && !Bro.IsA('PortalYellow') && FireType == AltFire) )
		{
			Bro.RemovePortal(Spray, Destroy);

			if(FireType == Fire)
			{
				if(Portal1 != None)
				{
					Portal1.RemovePortal(Big, Destroy);
					Portal1 = None;
				}
			}
			else if(FireType == AltFire)
			{
				if(Portal2 != None)
				{
					Portal2.RemovePortal(Big, Destroy);
					Portal2 = None;
				}
			}
			return true;
		}
	}
	return false;
}
/*##################################################################################################
##
## Dumb Stuff
##
##################################################################################################*/
simulated function TweenToStill(){}
/*##################################################################################################
##
## Animation Functions
##
##################################################################################################*/
simulated function PlayFiring()
{
	Owner.PlaySound(Sound'PortalGun_Shoot_Blue', SLOT_None, 16.0);
	LoopAnim( 'Fire', 1.5, 0.05);
	ColoredGlass(Fire);
}

simulated function PlayAltFiring()
{
	Owner.PlaySound(Sound'PortalGun_Shoot_Yellow', SLOT_None, 16.0);
	LoopAnim( 'Fire', 1.5, 0.05);
	ColoredGlass(AltFire);
}

simulated function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		LoopAnim('Idle', 0.3,0.4);
}

Simulated Function ColoredGlass(EFireType FireType)
{
	if(FireType == Fire)
	{
		MultiSkins[2] = Texture'v_portalgun_glass_b';
		SetTimer(0.1, false);
	}
	else if(FireType == AltFire)
	{
		MultiSkins[2] = Texture'v_portalgun_glass_y';
		SetTimer(0.1, false);
	}
}

Simulated Function Timer()
{
	MultiSkins[2] = None;
}
/*##################################################################################################
##
## Default Properties
##
##################################################################################################*/

defaultproperties
{
     bRapidFire=True
     FiringSpeed=2.000000
     SelectSound=Sound'BTPortalGunV2_1.PortalGun_Selected'
     DeathMessage="%o was killed by %k's portals"
     PickupMessage="You got the Portal Gun"
     ItemName="Portal Gun"
     PlayerViewOffset=(X=-6.000000,Z=0.000000)
     PlayerViewMesh=SkeletalMesh'BTPortalGunV2_1.v_PortalGun'
     PickupViewMesh=LodMesh'BTPortalGunV2_1.p_PortalGun'
     PickupViewScale=1.750000
     ThirdPersonMesh=LodMesh'BTPortalGunV2_1.w_PortalGun'
     ThirdPersonScale=1.300000
     StatusIcon=Texture'Botpack.Icons.UseTrans'
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'Botpack.Icons.UseTrans'
     bHidden=True
     LODBias=16.000000
     bEdShouldSnap=True
     Mesh=LodMesh'BTPortalGunV2_1.p_PortalGun'
     DrawScale=1.750000
     bNoSmooth=False
     CollisionRadius=16.000000
     CollisionHeight=8.000000
}
