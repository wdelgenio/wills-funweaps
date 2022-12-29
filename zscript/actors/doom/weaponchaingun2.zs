// --------------------------------------------------------------------------
//
// Chaingun
//
// --------------------------------------------------------------------------

class ChaingunFun : Chaingun replaces Chaingun
{
	Default
	{
		Weapon.SelectionOrder 700;
		Weapon.AmmoUse 1;
		Weapon.AmmoUse2 1;
		Weapon.AmmoGive 20;
		Weapon.AmmoType "Clip";
		Weapon.AmmoType2 "Clip";
		Weapon.SlotNumber 4;
		Inventory.PickupMessage "$GOTCHAINGUN";
		Obituary "$OB_MPCHAINGUN";
		Tag "$TAG_CHAINGUN";
	}
	States
	{
	Ready:
		CHGG A 1 A_WeaponReady;
		Loop;
	Deselect:
		CHGG A 1 A_Lower;
		Loop;
	Select:
		CHGG A 1 A_Raise;
		Loop;
	Fire:
		CHGG AB 5 A_FireCGunFun();
		CHGG B 0 A_ReFire;
		Goto Ready;
	AltFire:
		CHGG AB 1 A_FireCGunFun(true);
		CHGG B 0 A_ReFire;
		Goto Ready;
	Flash:
		CHGF A 5 Bright A_Light1;
		Goto LightDone;
		CHGF B 5 Bright A_Light2;
		Goto LightDone;
	Spawn:
		MGUN A -1;
		Stop;
	}

	action void A_FireCGunFun(bool altFire = false)
	{
		if (player == null)
		{
			return;
		}

		Weapon weap = player.ReadyWeapon;
		if (weap != null && invoker == weap && stateinfo != null && stateinfo.mStateType == STATE_Psprite)
		{
			// for altfire, since we're firing so fast, only randomly deplete ammo 25% of the time
			if (!altFire || random[FireAltCg](1,4) == 1) {
				if (!weap.DepleteAmmo (weap.bAltFire, true, 1)) {
					return;
				}
			}

			A_StartSound ("weapons/chngun", CHAN_WEAPON);

			State flash = weap.FindState('Flash');
			if (flash != null)
			{
				// Removed most of the mess that was here in the C++ code because SetSafeFlash already does some thorough validation.
				State atk = weap.FindState('Fire');
				let psp = player.GetPSprite(PSP_WEAPON);
				if (psp) 
				{
					State cur = psp.CurState;
					int theflash = atk == cur? 0:1;
					player.SetSafeFlash(weap, flash, theflash);
				}
			}
		}
		player.mo.PlayAttacking2 ();

		if (altFire) {
			double spread = 5.0;
			int damage = 12 * random[FireSG2](1, 3);
			//action void A_RailAttack(int damage, int spawnofs_xy = 0, bool useammo = true, color color1 = 0, color color2 = 0, int flags = 0, double maxdiff = 0, class<Actor> pufftype = "BulletPuff", double spread_xy = 0, double spread_z = 0, double range = 0, int duration = 0, double sparsity = 1.0, double driftspeed = 1.0, class<Actor> spawnclass = "none", double spawnofs_z = 0, int spiraloffset = 270, int limit = 0)
			A_RailAttack(damage, useammo:false, color1:-1, flags:RGF_SILENT, spread_xy:spread, sparsity:7.0, limit:3);
		} else {
		
			for (int i = 0 ; i < 10 ; i++)
			{
				int damage = 12 * random[FireSG2](1, 3);
				double ang = angle + Random2[FireSG2]() * (3. / 256);

				LineAttack (ang, PLAYERMISSILERANGE, pitch + Random2[FireSG2]() * (3.0 / 256), damage, 'Hitscan', "BulletPuff");
			}

			GunShot (!player.refire, "BulletPuff", BulletSlope ());
		}
	}
}
