// --------------------------------------------------------------------------
//
// Fist 
//
// --------------------------------------------------------------------------

class FistResurrector : Fist replaces Fist
{
	Default
	{
		Weapon.SelectionOrder 3700;
		Weapon.Kickback 100;
		Weapon.SlotNumber 1;
		Weapon.AmmoType2 "Cell";
		Weapon.AmmoUse2 20;
		Translation 1;
		Obituary "$OB_MPFIST";
		Tag "$TAG_FIST";
		+WEAPON.WIMPY_WEAPON
		+WEAPON.MELEEWEAPON
		+WEAPON.NOAUTOSWITCHTO
	}
	States
	{
	Ready:
		PUNG A 1 A_WeaponReady;
		Loop;
	Deselect:
		PUNG A 1 A_Lower;
		Loop;
	Select:
		PUNG A 1 A_Raise;
		Loop;
	Rise:
		PUNG C 1;
		Goto Ready;
	Fire:
		PUNG B 3;
		PUNG C 3 A_LongPunch;
		PUNG D 4;
		PUNG C 2;
		PUNG B 2 A_ReFire;
		Goto Ready;
	AltFire:
		PUNG B 2 A_StartSound("vile/active",CHAN_BODY,0,0.75);
		PUNG C 2;
		PUNG B 2;
		PUNG C 2;
		PUNG B 2;
		PUNG C 2;
		PUNG D 2;
		PUNG C 3;
		PUNG D 3;
		PUNG C 3;
		PUNG D 15 A_PunchRevive;
		PUNG C 2;
		PUNG B 2;
		PUNG C 2;
		PUNG B 1 A_ReFire;
		Goto Ready;
	}
	
	action void A_PunchRevive()
	{
		if (player == null)
			return;

		int raised = 0;
		BlockThingsIterator it = BlockThingsIterator.Create(player.mo,MeleeRange);
		while (it.Next() && raised == 0)
		{
			let targ = it.thing;
			if (targ != null && 
				targ.bCORPSE && 
				targ.health <= 0 &&
				player.mo.CanResurrect(targ,false))
			{
				
				State raisestate = targ.FindState("raise");
				if (raisestate)
				{
					let info = targ.Default;
					targ.A_SetSize(info.radius,info.height,true);
					
					targ.A_StartSound("vile/raise");
					targ.Revive();
					targ.CopyFriendliness(player.mo,false);
					targ.SetState(raisestate);
					raised++;

					Weapon weap = player.ReadyWeapon;
					if (weap != null && !weap.bDehAmmo && invoker == weap && stateinfo != null && stateinfo.mStateType == STATE_Psprite)
					{
						if (!weap.DepleteAmmo (weap.bAltFire))
						return;
					}
				}
			}
		}
	}

	// Try to punch, but if there's nothing to punch, try to revive a corpse
	action void A_LongPunch()
	{
		FTranslatedLineTarget t;

		if (player != null)
		{
			Weapon weap = player.ReadyWeapon;
			if (weap != null && !weap.bDehAmmo && invoker == weap && stateinfo != null && stateinfo.mStateType == STATE_Psprite)
			{
				if (!weap.DepleteAmmo (weap.bAltFire))
					return;
			}
		}

		int damage = random[Punch](8, 20) << 1;

		if (FindInventory("PowerStrength"))
			damage *= 30;

		double range = 2*(MeleeRange + MELEEDELTA); //give some extra range		
	
		A_CustomPunch(damage,false,CPF_USEAMMO,"BulletPuff",range,0.1,0,"ArmorBonus","*fist");	
	}

}