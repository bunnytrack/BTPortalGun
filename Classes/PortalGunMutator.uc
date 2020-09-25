//=============================================================================
// PortalGunMutator.
//=============================================================================
class PortalGunMutator expands Mutator Config(BTPortalGun);

var enum EPortableAreaConfiguration
{
	NoPortableAreas,
	OnlyPortableAreas,
	OnlyUnportableAreas,
	PortableAndUnportableAreas
} PortableAreaConfiguration;

struct PlayerInfo {
	var Pawn Player;
	var ZoneInfo PreviousZone;
};
var PlayerInfo PI[32];

var() bool bNoFallDamage, bOnlyOwnerCanUsePortals, bGiveWeapon, bRemoveOtherWeapons;
var config bool NoFallDamage, OnlyOwnerCanUsePortals, GiveWeapon, RemoveOtherWeapons;

var bool bInitialized;

Function PreBeginPlay(){
	local Mutator M;
	local bool bFoundExistingMutator;

	if (bInitialized) return;
	bInitialized = true;

	for (M = Level.Game.BaseMutator; M != None; M = M.NextMutator){
    	if (GetItemName(string(M.class)) == GetItemName(string(Self.class))){
        	if (M != Self){ 
        	    M.Destroy();
				bFoundExistingMutator = true;
        	}
      	}
    }

	if(!bFoundExistingMutator){
		bNoFallDamage = NoFallDamage;
		bOnlyOwnerCanUsePortals = OnlyOwnerCanUsePortals;
		bGiveWeapon = GiveWeapon;
		bRemoveOtherWeapons = RemoveOtherWeapons;
	}

    Self.NextMutator = Level.Game.BaseMutator.NextMutator; // Make a place in the List
    Level.Game.BaseMutator.NextMutator = self; // place it 1st after BaseMutator
	Level.Game.RegisterDamageMutator(self);

	SaveConfig();

	FindPortableAreas();
}

function AddMutator(Mutator M){
	if (M == Self){
		return; // Don't add us.
  	}
  	super.AddMutator(M);  // keep the chain unbroken
}

Function FindPortableAreas(){
	local PortableArea PA;
	local int numPortableAreas, numUnportableAreas;

	foreach AllActors(class'PortableArea', PA){
		if(PA.IsA('UnportableArea')){
			numUnportableAreas++;
		} else{
			numPortableAreas++;
		}
	}	

	if(numPortableAreas == 0 && numUnportableAreas == 0){
		PortableAreaConfiguration = NoPortableAreas;
	} else if(numPortableAreas > 0 && numUnportableAreas == 0){
		PortableAreaConfiguration = OnlyPortableAreas;
	} else if(numPortableAreas == 0 && numUnportableAreas > 0){
		PortableAreaConfiguration = OnlyUnportableAreas;
	} else {
		PortableAreaConfiguration = PortableAndUnportableAreas;
	}
}

function ModifyPlayer (Pawn Other) 
{
  	GiveWeaponTo(Other);
  	Super.ModifyPlayer(Other);
}

function GiveWeaponTo (Pawn P) {
  	local Inventory Inv;
  	local Weapon w;

  	if (bGiveWeapon) {
    	Inv = P.FindInventoryType(class'PortalGun');
    	if (Inv == None) {
      		w = Spawn(class'PortalGun');
      		if (w == None) {
         		Log(Self$".GiveWeaponsTo("$P.getHumanName()$") Warning! Failed to spawn PortalGun!");
      		} else {
         		w.Instigator = P;
         		w.BecomeItem();
         		P.AddInventory(w);
         		w.GiveAmmo(P);
         		w.SetSwitchPriority(P);
         		w.WeaponSet(P);
      		}
    	}
  	}
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if ( bRemoveOtherWeapons && Other.IsA('Weapon') && !Other.IsA('PortalGun'))
	{
		return false;
	}

	if ( bRemoveOtherWeapons && Other.IsA('Ammo') )
	{
		return false;
	}

	bSuperRelevant = 0;
	return true;
}

function ScoreKill(Pawn Killer, Pawn Other)
{
	local int Index;

	if ( NextMutator != None )
		NextMutator.ScoreKill(Killer, Other);
	
	Index = GetPlayerIndex(Other);
	PI[Index].PreviousZone = None;	
	BroadcastPawnChangedZones(Other, None);
}

function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, 
						out Vector Momentum, name DamageType)
{
	if(bNoFallDamage && DamageType == 'Fell'){
		ActualDamage = 0;
	}

	if ( NextDamageMutator != None )
		NextDamageMutator.MutatorTakeDamage( ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType );
}

Function Tick(float DeltaTime){
	local Pawn P;
	local int Index;
	
	for(P=Level.PawnList; P!=None; P=P.NextPawn ){
		if(P.Health <= 0 || (PlayerPawn(P) != None && (PlayerPawn(P).PlayerReplicationInfo.bWaitingPlayer || PlayerPawn(P).PlayerReplicationInfo.bIsSpectator))) continue;

		Index = GetPlayerIndex(P);
		if(P.Region.Zone != PI[Index].PreviousZone){
			// zone change
			PI[Index].PreviousZone = P.Region.Zone;
			BroadcastPawnChangedZones(P, P.Region.Zone);
		}	
	}
}

function BroadcastPawnChangedZones(Pawn P, ZoneInfo Z){
	local PortalRoomTrigger PRT;

	foreach AllActors(class'PortalRoomTrigger',PRT){
		PRT.PawnChangedZones(P, Z);
	}
}

// Find or create an entry in the Player struct array
function int GetPlayerIndex(Pawn P)
{
	local int i, firstemptyslot;

	firstemptyslot = -1;
	for(i=0;i<ArrayCount(PI);i++)
	{
		if(PI[i].Player == P)
			break;
		else if(PI[i].Player == none && firstemptyslot == -1)
			FirstEmptyslot = i;
	}
	if( i == ArrayCount(PI) )
	{
		i = FirstEmptySlot;
		PI[i].Player = P;
		PI[i].PreviousZone = None;
	}
	return i;
}

defaultproperties
{
     bNoFallDamage=True
     bOnlyOwnerCanUsePortals=True
     bGiveWeapon=True
     bRemoveOtherWeapons=True
     NoFallDamage=True
     OnlyOwnerCanUsePortals=True
     GiveWeapon=True
     Texture=Texture'BTPortalGunV2_1.Icons.PortalGunMutator'
     DrawScale=0.400000
}
