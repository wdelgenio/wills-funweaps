// --------------------------------------------------------------------------
//
// Plasma rifle
//
// --------------------------------------------------------------------------

class PlasmaRifleZap : PlasmaRifle replaces PlasmaRifle
{
	Default
	{
		Weapon.SelectionOrder 100;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 40;
		Weapon.AmmoType "Cell";
		Weapon.SlotNumber 6;
		Inventory.PickupMessage "$GOTPLASMA";
		Tag "$TAG_PLASMARIFLE";
	}
	States
	{
	Ready:
		PLSG A 1 A_WeaponReady;
		Loop;
	Deselect:
		PLSG A 1 A_Lower;
		Loop;
	Select:
		PLSG A 1 A_Raise;
		Loop;
	Fire:
		PLSG A 1 A_FirePlasmaZap(0);
		PLSG A 1 A_FirePlasmaZap(0);
		PLSG A 8 A_FirePlasmaZap(1);
		PLSG B 10 A_ReFire;
		Goto Ready;
	Flash:
		PLSF A 4 Bright A_Light1;
		Goto LightDone;
		PLSF B 4 Bright A_Light1;
		Goto LightDone;
	Spawn:
		PLAS A -1;
		Stop;
	}

	action void A_FirePlasmaZap(int ammoUse)
	{
		if (player == null)
		{
			return;
		}
		Weapon weap = player.ReadyWeapon;
		if (weap != null && invoker == weap && stateinfo != null && stateinfo.mStateType == STATE_Psprite)
		{
			if (!weap.DepleteAmmo (weap.bAltFire, true, ammoUse))
				return;
			
			State flash = weap.FindState('Flash');
			if (flash != null)
			{
				player.SetSafeFlash(weap, flash, random[FirePlasma](0, 1));
			}
			
		}
		
		SpawnPlayerMissile ("PlasmaZap");
	}
}
	
class PlasmaZap : Actor
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 25;
		Damage 5;
		Scale 1.0;
		Projectile;
		+RANDOMIZE
		+HITTRACER
		+ZDOOMTRANS
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "weapons/plasmaf";
		DeathSound "weapons/plasmax";
		Obituary "$OB_MPPLASMARIFLE";
	}
	States
	{
	Spawn:
		PLSS AB 6 Bright;
		Loop;
	Death:
		PLSE A 4 Bright A_PlasmaZapDeath;
		PLSE BCDE 4 Bright;
		Stop;
	}
	
	action void A_PlasmaZapDeath()
	{	
		if (tracer == null)
			return;

		double startAngle = angle - 22.5;
		for (int i = 0; i < 3; i++)
		{
			angle = startAngle + i * 22.5;
			let offset = Vec2Angle(tracer.radius,angle);
			vector3 spawnPos = Vec3Offset(offset.X, offset.Y,0.);			
			let zap = Spawn("PlasmaZap",spawnPos);
			if (zap)
			{
				zap.target = tracer;
				zap.Vel3DFromAngle(Speed, angle, pitch);
			}
		}
	}
}
