//=============================================================================
// PortalRoomTrigger.
//=============================================================================
class PortalRoomTrigger expands Triggers;

var() name RoomZoneInfoTags[8]; // Zones which form the room
var() float CompleteTimeout; // time till room automatically resets after being completed
var() bool bUseCompleteTimeout;
var() bool bDestroyPortalsOnRoomExit;
var() string RoomCompleteMessage;
var() string RoomTimeoutMessage;

var Pawn PawnsInRoom[32];
var int PawnCount;
var bool bCompleted;

Function PawnChangedZones(Pawn P, ZoneInfo Zone){
	local int i;
	local bool bAlreadyInRoom, bZoneIsInRoom;
	
	bAlreadyInRoom = GetPawnInRoomIndex(P) != -1;
	
	// check if pawn's new zone is in the room
	if(Zone == None){
		bZoneIsInRoom = false;
	} else{
		for(i=0;i<ArrayCount(RoomZoneInfoTags);i++){
			if(RoomZoneInfoTags[i] == Zone.Tag){
				bZoneIsInRoom = true;
				break;
			}
		}
	}

	// Pawn entered the room
	if(!bAlreadyInRoom && bZoneIsInRoom){
		AddPawnToRoomList(P);
		PawnCount++;
		if(PawnCount == 1){
			ResetPortalRoom();
		}
	}
	
	// Pawn exited the room
	else if(bAlreadyInRoom && !bZoneIsInRoom){
		RemovePawnFromRoomList(P);
		PawnCount--;
		if(PawnCount == 0){
			ResetPortalRoom();
		}
		DestroyPortalsForPawn(P);
	} 
}

function Trigger( Actor Other, Pawn EventInstigator ){
	if(!bCompleted){
		PortalRoomCompleted();
	}
}

function PortalRoomCompleted(){
	bCompleted = true;

	if(RoomCompleteMessage != ""){
		BroadCastMessageToPlayersInRoom(RoomCompleteMessage);
	}

	if(bUseCompleteTimeout);
		SetTimer(CompleteTimeout,false);
}

function Timer(){
	PortalRoomTimeout();
}

function PortalRoomTimeout(){
	if(RoomTimeoutMessage != ""){
		BroadCastMessageToPlayersInRoom(RoomTimeoutMessage);
	}
	ResetPortalRoom();
}

function BroadCastMessageToPlayersInRoom(string Message){
	local int i;

	for(i=0;i<ArrayCount(PawnsInRoom);i++)
	{
		if(PawnsInRoom[i] == None) continue;
		
		PawnsInRoom[i].ClientMessage(Message);		
	}
}

function DestroyPortalsForPawn(Pawn P){
  	local Inventory Inv;
  	local PortalGun PG;
	
	if(P == None) return;

	Inv = P.FindInventoryType(class'PortalGun');

	if(Inv == None) return;

	PG = PortalGun(Inv);
	PG.DestroyPortals();
}

function ResetPortalRoom(){
	local Actor A;

	if(bUseCompleteTimeout);
		SetTimer(0,false);

	bCompleted = false;

	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( self, None );
}

function int GetPawnInRoomIndex(Pawn P){
	local int index, i;

	index = -1;
	for(i=0;i<ArrayCount(PawnsInRoom);i++)
	{
		if(PawnsInRoom[i] == P){
			index = i;
			break;
		}
	}
	return index;
}

function int AddPawnToRoomList(Pawn P)
{
	local int i, firstemptyslot;

	firstemptyslot = -1;
	for(i=0;i<ArrayCount(PawnsInRoom);i++)
	{
		if(PawnsInRoom[i] == P)
			break;
		else if(PawnsInRoom[i] == none && firstemptyslot == -1)
			FirstEmptyslot = i;
	}

	if( i == ArrayCount(PawnsInRoom) )
	{
		i = FirstEmptySlot;
		PawnsInRoom[i] = P;
	}
	return i;
}

Function RemovePawnFromRoomList(Pawn P){
	local int Index;

	Index = GetPawnInRoomIndex(P);
	PawnsInRoom[Index] = none;
}

defaultproperties
{
     CompleteTimeout=20.000000
     bUseCompleteTimeout=True
     bDestroyPortalsOnRoomExit=True
     RoomCompleteMessage="Room completed"
     RoomTimeoutMessage="Room timeout reset"
     Texture=Texture'BTPortalGunV2_1.Icons.PortalRoomTrigger'
     DrawScale=0.400000
     bCollideActors=False
}
