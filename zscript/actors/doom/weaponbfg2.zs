// --------------------------------------------------------------------------
//
// BFG 9000
//
// --------------------------------------------------------------------------

class BFG11000 : BFG9000 replaces BFG9000
{
	Default
	{
		Height 20;
		Weapon.SelectionOrder 2800;
		Weapon.SlotNumber 7;
		Weapon.AmmoType2 "Cell";
		Weapon.AmmoUse1 30;
		Weapon.AmmoUse2 30;
	}
	States
	{
	Ready:
		BFGG A 1 A_WeaponReady;
		Loop;
	Deselect:
		BFGG A 1 A_Lower;
		Loop;
	Select:
		BFGG A 1 A_Raise;
		Loop;
	Fire:
		BFGG A 10 A_BFGsound;
		BFGG B 10 A_GunFlash;
		BFGG B 14 A_FireBFG;
		BFGG B 5 A_ReFire;
		Goto Ready;
	AltFire:
		BFGG A 4 A_BFGsound;
		BFGG B 4 A_GunFlash;
		BFGG B 20 A_FireAltBFG;
		BFGG B 1 A_ReFire;
		Goto Ready;
	Flash:
		BFGF A 11 Bright A_Light1;
		BFGF B 6 Bright A_Light2;
		Goto LightDone;
	Spawn:
		BFUG A -1;
		Stop;
	OldFire:
		BFGG A 10 A_BFGsound;
		BFGG BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 1 A_FireOldBFG;
		BFGG B 0 A_Light0;
		BFGG B 20 A_ReFire;
		Goto Ready;
	}
	
	action void A_FireAltBFG() {
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
				player.SetSafeFlash(weap, flash, random[FireAltBFG](0, 1));
			}
			
		}
		
		SpawnPlayerMissile ("BFGBallBig",noautoaim:true);
	}
}

class BFGBallBig : BFGBall replaces BFGBall
{	
	Default
	{	
		Speed 20;
		Damage 150;
		MeleeRange 16;
		ExplosionDamage 2048;	
		Projectile;
		Translation 2;
		Scale 2;
		+RIPPER
		+FORCERADIUSDMG
	}
	
	States
	{
	Spawn:
		BFS1 AB 4 Bright A_BFGBallBigThink;
		Loop;
	Death:
		BFE1 AB 4 Bright;
		BFE1 C 6 Bright A_BFGBallBigExplode;
		BFE1 DEF 4 Bright;
		Stop;
	}
	
	action void A_BFGBallBigThink()
	{
		int thinkTime = 4;		
		// can't modify ExplosionRadius so instead we use MeleeRange to keep track of our expanding explosion radius
		if (self.MeleeRange < 1536)
		{
			self.MeleeRange += int(self.Speed * (thinkTime)) / 1.41;
		}
		
		int particles = self.MeleeRange * self.MeleeRange / 20;
		if (particles > 512){
			particles = 512;
		}
		
		for (int i = 0; i < particles; i++) 
		{			
			double maxVel = MeleeRange;
			double scale = 100.;
			Vector3 vec = (random[BFG](-maxVel,maxVel)/scale + vel.X,
				random[BFG](-maxVel,maxVel)/scale + vel.Y,
				random[BFG](-maxVel/10.,maxVel/10.)/scale + vel.Z);
			
			
			double yaw = Random2[FireBFG]() * (360. / 256);
			Vector2 v2 = AngleToVector(yaw,MeleeRange);
			double size = Random[BFG](5,20);
			double zoff = random[BFG](-2000,2000)/MeleeRange;
			
			A_SpawnParticle(color(255,0,255,0),lifetime:thinkTime,size:size,xoff:v2.X,yoff:v2.Y,zoff:zoff,velx:vec.X,vely:vec.Y,velz:vec.Z,fadestepf:0);
		}
	}
	
	action void A_BFGBallBigExplode()
	{
		A_Explode(damage:ExplosionDamage, distance:MeleeRange,flags:0);
	}
}

class BFGBall2 : BFGBall replaces BFGBall
{
	Default
	{		
		Speed 35;
		Damage 400;
		Projectile;	
	}
	States
	{
	Spawn:
		BFS1 AB 4 Bright;
		Loop;
	Death:
		BFE1 AB 4 Bright;
		BFE1 C 6 Bright A_BFGRailSpray("BFGExtra",80,30,90,64*64,64);
		BFE1 DEF 4 Bright;
		Stop;
	}
	
	action void A_BFGRailSpray(class<Actor> spraytype = "BFGExtra", int numrays = 40, int damagecnt = 15, double ang = 90, double distance = 16*64, double vrange = 32, int defdamage = 0, int flags = 0)
	{
		int damage;
		FTranslatedLineTarget t;

		// validate parameters
		if (spraytype == null) spraytype = "BFGExtra";
		if (numrays <= 0) numrays = 40;
		if (damagecnt <= 0) damagecnt = 15;
		if (ang == 0) ang = 90.;
		if (distance <= 0) distance = 16 * 64;
		if (vrange == 0) vrange = 32.;

		// [RH] Don't crash if no target
		if (!target) return;

		// [XA] Set the originator of the rays to the projectile (self) if
		//      the new flag is set, else set it to the player (target)
		Actor originator = (flags & BFGF_MISSILEORIGIN) ? Actor(self) : target;

		double origangle = originator.angle;
		
		// offset angles from its attack ang
		for (int i = 0; i < numrays; i++)
		{
			originator.angle = origangle - ang / 2 + ang / numrays*i;
			
			double pitchoffset = originator.AimLineAttack(originator.angle, distance, t, vrange);
			double angleoffset = 0;

			if (t.linetarget != null)
			{
				Actor spray = Spawn(spraytype, t.linetarget.pos + (0, 0, t.linetarget.Height / 4), ALLOW_REPLACE);
				originator.angle = t.angleFromSource;
			}

			
			if (defdamage == 0)
			{
				damage = 0;
				for (int j = 0; j < damagecnt; ++j)
					damage += Random[BFGSpray](2, 8);
			}
			else
			{
				// if this is used, damagecnt will be ignored
				damage = defdamage;
			}

			// Why do a simple hitscan when you can fire a penetrating rail?
			FRailParams p;
			p.damage = damage;
			p.offset_xy = 0;
			p.offset_z = 0;
			p.color1 = -1;
			p.color2 = 0;
			p.maxdiff = 0;
			p.flags = 1;
			p.puff = spraytype;
			p.angleoffset = 0;
			p.pitchoffset = pitchoffset - originator.pitch;
			p.distance = distance;
			p.duration = 0;
			p.sparsity = 5;
			p.drift = 0;
			//p.spawnclass = "null";
			p.SpiralOffset = 270;
			p.limit = 0;
			originator.RailAttack(p);
			
		}
		originator.angle = origangle;
	}
}