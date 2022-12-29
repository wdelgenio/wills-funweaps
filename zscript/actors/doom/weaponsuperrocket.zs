// --------------------------------------------------------------------------
//
// Rocket launcher
//
// --------------------------------------------------------------------------

class SuperRocketLauncher : RocketLauncher replaces RocketLauncher
{
	Default
	{
		Weapon.SelectionOrder 2500;
		Weapon.AmmoUse 1;
		Weapon.AmmoUse2 1;		
		Weapon.AmmoGive 10;
		Weapon.AmmoType "RocketAmmo";
		Weapon.AmmoType2 "RocketAmmo";
		Weapon.SlotNumber 5;
		+WEAPON.NOAUTOFIRE
		Inventory.PickupMessage "$GOTLAUNCHER";
		Tag "$TAG_ROCKETLAUNCHER";
	}
	States
	{
	Ready:
		MISG A 1 A_WeaponReady;
		Loop;
	Deselect:
		MISG A 1 A_Lower;
		Loop;
	Select:
		MISG A 1 A_Raise;
		Loop;
	Fire:
		MISG B 8 A_GunFlash;
		MISG B 14 A_FireSuperMissile;
		MISG B 5 A_ReFire;
		Goto Ready;
	AltFire:
		MISG B 4 A_GunFlash;
		MISG BBBB 2 A_FireMiniMissile();
		MISG B 2 A_FireMiniMissile(true);
		MISG B 5;
		MISG B 1 A_ReFire;
		Goto Ready;
	Flash:
		MISF A 3 Bright A_Light1;
		MISF B 4 Bright;
		MISF CD 4 Bright A_Light2;
		Goto LightDone;
	Spawn:
		LAUN A -1;
		Stop;
	}

	action void A_FireMiniMissile(bool useAmmo = false)
	{
		if (player == null)
		{
			return;
		}
		Weapon weap = player.ReadyWeapon;
		if (useAmmo && weap != null && invoker == weap && stateinfo != null && stateinfo.mStateType == STATE_Psprite)
		{
			if (!weap.DepleteAmmo (weap.bAltFire, true, 1))
				return;
		}
		
		SpawnPlayerMissile ("MiniRocket");
	}
	
	action void A_FireSuperMissile()
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
		}
		
		int numShots = random[SuperRocket](5, 7);
		
		for (int i = 0; i < numShots; i++) // Spawn some random number of rockets
		{
			// Do an evenly spaced horizontal spread
			double offset = 6 * (2.0 * i / (numShots - 1.0) - 1);
			
			FTranslatedLineTarget t;
			let misl = SpawnPlayerMissile ("SuperRocket",angle+offset,0,0,0,t,false,true);
			if (misl)
			{				
				if (t.linetarget && !t.unlinked) {
					misl.tracer = t.linetarget;
				}
			}			
		}
		A_StartSound ("weapons/rocklf", CHAN_WEAPON);
	}
}

class MiniRocket : FastProjectile
{
	Default
	{
		Radius 6;
		Height 4;
		Speed 120;
		Damage 38;
		ExplosionDamage 80;
		MaxTargetRange 4000;
		Translation 1;
		Projectile;		
		Scale 0.5;
		+RANDOMIZE
		+DEHEXPLOSION
		+ROCKETTRAIL
		+ZDOOMTRANS
		SeeSound "weapons/rocklf";
		DeathSound "weapons/rocklx";
		Obituary "$OB_MPROCKET";
	}
	States
	{
	Spawn:
		MISL A 1 Bright;
		Loop;
	Death:
		MISL B 8 Bright A_Explode;
		MISL C 6 Bright;
		MISL D 4 Bright;
		Stop;
	BrainExplode:
		MISL BC 10 Bright;
		MISL D 10 A_BrainExplode;
		Stop;
	}
}

class SuperRocket : Rocket
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 30;
		Damage 80;
		MaxTargetRange 4000;
		Translation "128:191=208:239";
		Projectile;
		+RANDOMIZE
		+DEHEXPLOSION
		+ROCKETTRAIL
		+ZDOOMTRANS
		+SEEKERMISSILE
		SeeSound "";
		DeathSound "weapons/rocklx";
		Obituary "$OB_MPROCKET";
	}
	States
	{
	Spawn:
		MISL A 1 Bright A_SuperRocketTracer;
		Loop;
	Death:
		MISL B 8 Bright A_Explode;
		MISL C 6 Bright;
		MISL D 4 Bright;
		Stop;
	BrainExplode:
		MISL BC 10 Bright;
		MISL D 10 A_BrainExplode;
		Stop;
	}
	
	// Do a standard tracer homing, but occasionally hunt for a target
	action void A_SuperRocketTracer(double traceang = 19.6875)
	{
		// are we locked on?
		if (self.tracer != null && self.tracer.health > 0 && CanSeek(self.tracer))
		{
			A_Tracer2(traceang);
						
			//A_Tracer2 really does a poor job of adjusting the slope
			// bump up the vel it'll change by to get to the best slope
			double dist;
			double slope;
			Actor dest;

			dest = self.tracer;
			dist = DistanceBySpeed(dest, Speed);			
			
			if (dest.Height >= 56.)
			{
				slope = (dest.pos.z + 40. - pos.z) / dist;
			}
			else
			{
				slope = (dest.pos.z + Height*(2./3) - pos.z) / dist;
			}

			if (slope < Vel.Z)
				Vel.Z -= 8. / 8;
			else
				Vel.Z += 8. / 8;
				
			return;
		}
		
		FTranslatedLineTarget t;
		
		// Try to find a new target
		double pitch = AimLineAttack(angle,self.MaxTargetRange,t);
		if (t.linetarget && !t.unlinked && t.linetarget != self.target) {			
			self.tracer = t.linetarget;
		} else {
			// wander off a bit
			angle += Random2[SRT]() * (8. / 256);
			VelFromAngle();
			self.Vel.Z += Random2[SRT]() * (0.4 / 256);
		}
	}
}