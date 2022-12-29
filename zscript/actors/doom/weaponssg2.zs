// --------------------------------------------------------------------------
//
// Super Shotgun
//
// --------------------------------------------------------------------------

class SuperShotgunFun : SuperShotgun replaces SuperShotgun 
{
	Default
	{
		Weapon.SelectionOrder 400;
		Weapon.AmmoUse 2;
		Weapon.AmmoGive 8;
		Weapon.AmmoType "Shell";
		Weapon.SlotNumber 3;
		Inventory.PickupMessage "$GOTSHOTGUN2";
		Obituary "$OB_MPSSHOTGUN";
		Tag "$TAG_SUPERSHOTGUN";
	}
	States
	{
	Ready:
		SHT2 A 1 A_WeaponReady;
		Loop;
	Deselect:
		SHT2 A 1 A_Lower;
		Loop;
	Select:
		SHT2 A 1 A_Raise;
		Loop;
	Fire:
		SHT2 A 3;
		SHT2 A 4 A_FireShotgun2Fun;
		SHT2 B 6;
		SHT2 C 6 A_CheckReload;
		SHT2 D 3 A_OpenShotgun2;
		SHT2 E 3;
		SHT2 F 3 A_LoadShotgun2;
		SHT2 G 3;
		SHT2 H 6 A_CloseShotgun2;
		SHT2 A 5 A_ReFire;
		Goto Ready;
	// unused states
		SHT2 B 7;
		SHT2 A 3;
		Goto Deselect;
	Flash:
		SHT2 I 4 Bright A_Light1;
		SHT2 J 3 Bright A_Light2;
		Goto LightDone;
	Spawn:
		SGN2 A -1;
		Stop;
	}

	action void A_FireShotgun2Fun()
	{
		if (player == null)
		{
			return;
		}

		A_StartSound ("weapons/sshotf", CHAN_WEAPON);
		Weapon weap = player.ReadyWeapon;
		if (weap != null && invoker == weap && stateinfo != null && stateinfo.mStateType == STATE_Psprite)
		{
			if (!weap.DepleteAmmo (weap.bAltFire, true, 2))
				return;
			
			player.SetPsprite(PSP_FLASH, weap.FindState('Flash'), true);
		}
		player.mo.PlayAttacking2 ();

		double pitch = BulletSlope ();
			
		for (int i = 0 ; i < 200 ; i++)
		{
			int damage = 8 * random[FireSG2](1, 3);
			double ang = angle + Random2[FireSG2]() * (35.5 / 256);

			// Doom adjusts the bullet slope by shifting a random number [-255,255]
			// left 5 places. At 2048 units away, this means the vertical position
			// of the shot can deviate as much as 255 units from nominal. So using
			// some simple trigonometry, that means the vertical angle of the shot
			// can deviate by as many as ~7.097 degrees.

			LineAttack (ang, PLAYERMISSILERANGE, pitch + Random2[FireSG2]() * (7.097 / 256), damage, 'Hitscan', "BulletPuff");
		}
	}


	action void A_OpenShotgun2() 
	{ 
		A_StartSound("weapons/sshoto", CHAN_WEAPON); 
	}
	
	action void A_LoadShotgun2() 
	{ 
		A_StartSound("weapons/sshotl", CHAN_WEAPON); 
	}
	
	action void A_CloseShotgun2() 
	{ 
		A_StartSound("weapons/sshotc", CHAN_WEAPON);
		A_Refire();
	}
}
