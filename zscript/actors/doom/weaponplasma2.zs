// --------------------------------------------------------------------------
//
// Plasma rifle
//
// --------------------------------------------------------------------------

class PlasmaRifleFun : PlasmaRifle replaces PlasmaRifle
{
	Default
	{
		Weapon.SelectionOrder 100;
		Weapon.AmmoUse1 1;
		Weapon.AmmoUse2 10;
		Weapon.AmmoGive 40;
		Weapon.AmmoType1 "Cell";
		Weapon.AmmoType2 "Cell";
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
		PLSG A 6 A_FirePlasmaFun(1);
		PLSG A 6 A_FirePlasmaFun(0);
		PLSG B 4 A_ReFire;
		Goto Ready;
	AltFire:
		PLSG A 20 A_FireIce;		
		PLSG B 14;
		PLSG B 8 A_ReFire;
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

	action void A_FirePlasmaFun(int ammoUse)
	{
		if (player == null)
		{
			return;
		}
		Weapon weap = player.ReadyWeapon;
		if (ammoUse > 0 && weap != null && invoker == weap && stateinfo != null && stateinfo.mStateType == STATE_Psprite)
		{
			if (!weap.DepleteAmmo (weap.bAltFire, true, ammoUse))
				return;
			
			State flash = weap.FindState('Flash');
			if (flash != null)
			{
				player.SetSafeFlash(weap, flash, random[FirePlasma](0, 1));
			}
			
		}
		
		// Save values temporarily
		double SavedPlayerAngle = angle;
		double SavedPlayerPitch = pitch;
		
		int numShots = random[PlasmaFun](4, 12);
		for (int i = 0; i < numShots; i++) // Spawn some random number of plasma balls
		{
			angle = SavedPlayerAngle + Random2[PlasmaFun]() * (4.0 / 256);
			pitch = SavedPlayerPitch + Random2[PlasmaFun]() * (3.0 / 256);
			
			SpawnPlayerMissile ("PlasmaBallFun");
			
			// Restore saved values
			angle = SavedPlayerAngle;
			pitch = SavedPlayerPitch;
		}
		
		A_StartSound ("weapons/plasmaf", CHAN_WEAPON);
	}
	
	action void A_FireIce()
	{
		if (player == null)
		{
			return;
		}
		Weapon weap = player.ReadyWeapon;
		if (weap != null && invoker == weap && stateinfo != null && stateinfo.mStateType == STATE_Psprite)
		{
			if (!weap.DepleteAmmo (weap.bAltFire, true, 1))
				return;
			
			State flash = weap.FindState('Flash');
			if (flash != null)
			{
				player.SetSafeFlash(weap, flash, random[FirePlasma](0, 1));
			}
			
		}
		
		SpawnPlayerMissile ("IceBall",noautoaim:true);
	}
}


class PlasmaBallFun : FastProjectile
{
	Default
	{
		Radius 13;
		Height 8;
		Speed 100;
		Damage 4;
		Scale 0.5;
		Projectile;
		+RANDOMIZE
		+ZDOOMTRANS
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "";
		DeathSound "weapons/plasmax";
		Obituary "$OB_MPPLASMARIFLE";
	}
	States
	{
	Spawn:
		PLSS AB 6 Bright;
		Loop;
	Death:
		PLSE BCDE 2 Bright;
		Stop;
	}
}


class IceBall : Actor
{
	Default
	{
		Radius 15;
		Height 8;
		Speed 12;
		Damage 15;
		Scale 4.0;
		Translation "192:207=168:183";
		Projectile;
		+RANDOMIZE
		+ZDOOMTRANS
		+RIPPER
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "";
		DeathSound "weapons/plasmax";
		Obituary "$OB_MPPLASMARIFLE";
	}
	States
	{
	Spawn:
		PLSS AAAAAABBBBBB 1 Bright A_LaunchIce;		
		Loop;
	Death:
		PLSE BCDE 2 Bright;
		Stop;
	}
	
	action void A_LaunchIce()	
	{
		special1++;
		if (special1 % 2 > 0) // > random[LaunchIce](0,2))
			return;
			
		double angdiff[3] = { -5.625, 5.625, 0 };
		int launched = 0;
		int numBalls = 4;
		for (int i = 0; i < numBalls; i++) {
			double aimAngle = angle + i * 360.0 / numBalls;
			
			//Actor ball = SpawnMissileAngleZ(Pos.Z,"IceBallShard",angle + angleOffset,sin(7.6*(angle+angleOffset))/2.0,target);
			//Actor ball = target.SpawnPlayerMissile("IceBallShard",angle:angle+angleOffset,pos.X-target.pos.X,pos.Y-target.pos.Y,pos.Z-target.pos.Z);
			int j = 2;
			double pitch;
			double fireAngle = aimAngle;
			FTranslatedLineTarget ft;
			do
			{
				fireAngle = aimAngle + angdiff[j];				
				pitch = AimLineAttack(fireAngle, 4096, ft, 20);
				
			} while (!ft.linetarget && --j >= 0);

			if (!ft.linetarget)
			{
				fireAngle = aimAngle;
				pitch = 0.;
			}
			
			Actor ball = SpawnMissileAngleZ(Pos.Z,"IceBallShard",fireAngle,sin(11.6*(fireAngle))/1.5,target);
			
			if (ball != null) {
				ball.Vel3DFromAngle(ball.Speed,fireAngle,pitch);
				launched++;
			}
		}
		
		if (launched > 0)
			A_StartSound ("weapons/plasmaf");
			
		angle += 4.0;

		// slowly shink the into nonexistence
		if (self.Scale.X < 1) {
			SetStateLabel("Death");
			bMissile = false;
		} else {
			A_SetScale(self.Scale.X * 0.97);
			A_SetSpeed(self.Speed * 0.95);
		}
	}
}

class IceBallShard : PlasmaBall {
	Default
	{
		Scale 0.7;
		Speed 18;
		Damage 10;
		Translation "192:207=248:252";		
		SeeSound "";
	}

	States
	{
	Spawn:
		PLSS AB 6 Bright A_ShardThink;
		Loop;
	Death:
		PLSE BCDE 2 Bright;
		Stop;
	}

	action void A_ShardThink() {
		// slowly shink the into nonexistence
		if (self.Scale.X < 0.2) {
			SetStateLabel("Death");
			bMissile = false;
		} else {
			A_SetScale(self.Scale.X * 0.85);
			A_SetSpeed(self.Speed * 0.7);
		}
	}
}