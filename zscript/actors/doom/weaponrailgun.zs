// --------------------------------------------------------------------------
//
// Railgun
//
// --------------------------------------------------------------------------

class RailgunFun : Shotgun replaces Shotgun
{
	Default
	{
		Weapon.SelectionOrder 1300;
		Weapon.AmmoUse1 3;
		Weapon.AmmoUse2 2;		
		Weapon.Kickback 500;
		Weapon.AmmoGive1 20;
		Weapon.AmmoGive2 4;
		Weapon.AmmoType1 "Cell";
		Weapon.AmmoType2 "Shell";
		Weapon.SlotNumber 3;
		Inventory.PickupMessage "$GOTSHOTGUN";
		Obituary "$OB_MPSHOTGUN";
		Tag "$TAG_SHOTGUN";
		+ALWAYSPUFF;
	}
	States
	{
	Ready:
		RLGG A 1 A_WeaponReady;
		Loop;
	Deselect:
		RLGG A 1 A_Lower;
		Loop;
	Select:
		RLGG A 1 A_Raise;
		Loop;
	Fire:
		RLGG E 8 A_FireRailgunFun;
		RLGG F 3;
		RLGG G 3;
		RLGG H 3;
		RLGG I 3;
		RLGG J 3;
		RLGG K 3;
		RLGG L 3;
		RLGG A 3;
		RLGG M 2 A_ReFire;
		goto Ready;
	AltFire:
		RLGG A 3;
		RLGG A 6 A_FireRailgunAlt;
		RLGG BC 4;
		RLGG D 3;
		RLGG CB 4;
		RLGG A 3;
		RLGG A 5 A_ReFire;
		Goto Ready;
	Flash:
		TNT1 A 5 bright A_Light1;
		TNT1 A 5 bright A_Light2;
		TNT1 A 0 bright A_Light0;
		Goto LightDone;
	Spawn:
		RAIL A -1;
		Stop;
	}

	action void A_FireRailgunFun()
	{
		if (player == null)
		{
			return;
		}

		A_StartSound ("weapons/rbeam", CHAN_WEAPON);
		Weapon weap = player.ReadyWeapon;
		if (weap != null && invoker == weap && stateinfo != null && stateinfo.mStateType == STATE_Psprite)
		{
			if (!weap.DepleteAmmo (weap.bAltFire, true, 1))
				return;
			
			player.SetPsprite(PSP_FLASH, weap.FindState('Flash'), true);
		}
		player.mo.PlayAttacking2 ();
		
		A_RailAttack(1000,0,false,0,0,0,0,"RailgunPuff2");
	}
	
	action void A_FireRailgunAlt()
	{
		if (player == null)
		{
			return;
		}

		A_StartSound ("weapons/shotgf", CHAN_WEAPON);
		Weapon weap = player.ReadyWeapon;
		if (weap != null && invoker == weap && stateinfo != null && stateinfo.mStateType == STATE_Psprite)
		{
			if (!weap.DepleteAmmo (weap.bAltFire, true, 1))
				return;
			
			player.SetPsprite(PSP_FLASH, weap.FindState('Flash'), true);
		}
		player.mo.PlayAttacking2 ();

		double pitch = BulletSlope ();
				
		for (int i = 0; i < 12; i++)
		{
			double spread = 14;
			A_RailAttack(100,0,false,-1,0,0,0,"BulletPuff",spread,0,0,0,2.0,2.0,"none",0,270,5);
		}
		
	}

}

class ShotgunFun : DoomWeapon {
}

class RailgunPuff2 : BulletPuff
{
	Default
	{
		+PIERCEARMOR;
		+ALWAYSPUFF;		
	}
	States
	{
	Spawn:
		BAL2 C 1 Bright {
			A_RadiusThrust(1000,128,RTF_AFFECTSOURCE | RTF_NOIMPACTDAMAGE );
			A_RadiusThrust(200,64,RTF_AFFECTSOURCE | RTF_NOIMPACTDAMAGE | RTF_THRUSTZ );			
		}
		BAL2 D 4;
		BAL2 E 4;
	Death:
	Extreme:
	Melee:
		TNT1 A 1 {
			A_RadiusThrust(1000,64,RTF_AFFECTSOURCE | RTF_NOIMPACTDAMAGE );
			A_RadiusThrust(200,64,RTF_AFFECTSOURCE | RTF_NOIMPACTDAMAGE | RTF_THRUSTZ );			
		}		
		stop;
	}
}