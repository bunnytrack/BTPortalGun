class PortalBlue_Impact expands Effects;

var int MaxSparks;
var class<PortalBlue_Spark> Spark;

Simulated Function Spawned()
{
	local int NumSparks;
	local int x;

	if (Instigator != None)
		MakeNoise(0.3);

	NumSparks = FMax(Rand(MaxSparks), 8);
	for (x = 0; x < NumSparks; x++) 
		Spawn(Spark,,, Location + 8 * Vector(Rotation), Rotation);

	Destroy();
}

defaultproperties
{
     MaxSparks=16
}
