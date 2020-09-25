//=============================================================================
// BTPortalGun Version 2.1
//
// Original mod by OwYeaW
//
// Version 2.1 by VRN|>@tack!< a.k.a. Kaos Richie a.k.a. Richard Nazarian
//
// www.twitch.tv/kaosrichie
//=============================================================================

class BTPortalGun_Instructions expands Actor;

/*
//=============================================================================
New in V2.1:
- Fixed bNoFallDamage not working
- Portals now also trigger UnTouch
- PortableAreas no longer take up a network channel
- Removed invalid surface animation and sound
- Changed some default properties

Fixes:
- Animation Bug when shooting while bringing up weapon

New Features:
- New Portal Textures
- New Portal Effects
- Portals can interact with Triggers (use TT_ClassProximity with class set to PortalBlue)

New Actors:
- Triggers
-- ActorKillTrigger
-- PortalDestroyerTrigger
-- PortalRoomTrigger

- Keypoint
-- BlockPortal
-- PortableArea
--- UnportableArea

- Info.Mutator
-- PortalGunMutator

- Effects.TranslocOutEffect
-- PortalParticleEffect

//=============================================================================
ActorKillTrigger:
+ Name ActorTags[16]

- Trigger it to destroy actors with tags set in [ActorTags] variable.
- Can be used to reset CompanionCubes spawned through ThingFactories. Make sure the ThingFactory itemTag matches one of the ActorKillTrigger's ActorTags.
//=============================================================================
PortalDestroyerTrigger:

- Trigger it to destroy portals owned by the player triggering the trigger.
//=============================================================================
PortalRoomTrigger:
+ bool bDestroyPortalsOnRoomExit
+ bool bUseCompleteTimeout
+ float CompleteTimeout
+ string RoomCompleteMessage
+ string RoomTimeoutMessage
+ Name RoomZoneInfoTags[8]

- Defines a room which can be completed. Room is defined by multiple ZoneInfo tags which you can set in [RoomZoneInfoTags].
- Room will trigger its Event when a player enters the room while empty, or when a player exits the room, making it empty. 
  This can be used to reset the room (for instance, reset CompanionCubes with an ActorKillTrigger).
- Triggering the PortalRoomTrigger will mark the room as complete. 
  An optional message [RoomCompleteMessage] can be displayed to the players inside the room when this happens. 
- If [bUseCompleteTimeout] is set: After [CompleteTimeout] seconds, if the room has not been reset yet due to players exiting the room, the room will automatically 
  reset and display an optional message [RoomTimeoutMessage] to players still inside the room.
- If [bDestroyPortalsOnRoomExit] is set: Players exiting the room will have their portals destroyed.
//=============================================================================
BlockPortal:

- Place in level to block shots from the PortalGun.
//=============================================================================
PortableArea:
+ bInitiallyActive

- Defines an area in the level where portals can be placed. 
- [bInitiallActive] indicates whether the PortableArea has an effect. Can be triggered to toggle active state. Portals inside the area are destroyed when toggled to inactive.
- When no PortableAreas are placed, portals can be placed in the entire level.
//=============================================================================
UnportableArea:
+ bInversePortableAreas

- Defines an area in the level where portals can not be placed.
- [bInitiallActive] indicates whether the UnportableArea has an effect. Can be triggered to toggle active state.
- UnportableAreas have a higher priority than PortableAreas
//=============================================================================
PortalGunMutator:
+ bNoFallDamage
+ bOnlyOwnerCanUsePortals

- When used as a mutator or embedded in the level, players will start with the PortalGun.
- Not necessary to place in the level for the PortalGun to work. But can be done to change the following settings.
- [bNoFallDamage] can be set to toggle immunity to fall damage.
- [bOnlyOwnerCanUsePortals] can be set to toggle the restriction of only the owner being able to use its portals.
//=============================================================================
*/

defaultproperties
{
}
