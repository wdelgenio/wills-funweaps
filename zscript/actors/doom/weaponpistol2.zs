// --------------------------------------------------------------------------
//
// Pistol 
//
// --------------------------------------------------------------------------

class Pistol2 : Pistol replaces Pistol
{
	Default
	{
		Weapon.SelectionOrder 1900;
		Weapon.AmmoUse1 2;
		Weapon.AmmoUse2 5;
		Weapon.AmmoGive 20;
		Weapon.AmmoType1 "Clip";
		Weapon.AmmoType2 "Clip";
		Weapon.SlotNumber 2;		
		Obituary "$OB_MPPISTOL";
		+WEAPON.WIMPY_WEAPON
		Inventory.Pickupmessage "$PICKUP_PISTOL_DROPPED";
		Tag "$TAG_PISTOL";
	}
	States
	{
	Ready:
		PISG A 1 A_WeaponReady;
		Loop;
	Deselect:
		PISG A 1 A_Lower;
		Loop;
	Select:
		PISG A 1 A_Raise;
		Loop;
	Fire:
		PISG A 1;
		PISG B 4 A_FirePistol2(650);
		PISG C 20;
		PISG B 18;
		PISG B 1 A_ReFire;
		Goto Ready;
	AltFire:
		PISG A 1;
		PISG B 4 A_FirePistol2(500,1,0.05);
		PISG C 20;
		PISG B 18;
		PISG B 1 A_ReFire;
		Goto Ready;
	Flash:
		PISF A 4 Bright A_Light1;
		Goto LightDone;
	AltFlash:
		PISF A 1 Bright A_Light1;
		Goto LightDone;
 	Spawn:
		PIST A -1;
		Stop;
	}

	//===========================================================================
	action void A_FirePistol2(int damage, int ammoUse = 1, double lifeSteal = 0.)
	{
		if (player != null)
		{
			Weapon weap = player.ReadyWeapon;
			if (weap != null && invoker == weap && stateinfo != null && stateinfo.mStateType == STATE_Psprite && ammoUse > 0)
			{
				if (!weap.DepleteAmmo (weap.bAltFire, true, ammoUse))
					return;

				player.SetPsprite(PSP_FLASH, weap.FindState('Flash'), true);
			}
			player.mo.PlayAttacking2 ();
		}
		
		int damage = damage * random[GunShot](1, 3);
		A_StartSound ("weapons/pistol", CHAN_WEAPON);
		
		FTranslatedLineTarget t;
		Actor puff;
		int actualdamage;
		[puff, actualdamage] = LineAttack(angle, PLAYERMISSILERANGE, BulletSlope(), damage, 'Hitscan',  "BulletPuff", 0, t);
		if (t.linetarget && !t.linetarget.bDontDrain && lifeSteal > 0)
		{			
			GiveBody (int(actualdamage * lifeSteal));
		}

	}
}