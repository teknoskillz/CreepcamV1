void () player_pain;

void () player_stand1;

void (vector org, entity death_owner) spawn_tdeath;
float modelindex_eyes /* = 0.000 */;
float modelindex_player /* = 0.000 */;
//SJB moved intermission_running float to globals.qc
float intermission_exittime /* = 0.000 */;

void() info_intermission =
{
};

void() SetChangeParms = 
{
	if (self.health <= 0)
	{
		SetNewParms();
		return;
	}
	self.items = self.items - (self.items & (IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD));
	if (self.health > 100)
	{
		self.health = 100;
	}
	if (self.health < SLOW_TURN_RATE)
	{
		self.health = SLOW_TURN_RATE;
	}
	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;
	if (self.ammo_shells < 25)
	{
		parm4 = 25;
	}
	else
	{
		parm4 = self.ammo_shells;
	}
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
	parm8 = self.weapon;
	parm9 = self.armortype * 100;
	parm9 = parm9 + CF_DECODEFLAGS + CF_DECODESHIFT * (self.creepflags & CF_KEEPBETWEENLEVELS);
	if (self.camtype > 0)
	{
		parm9 = parm9 + CF_STAYASCAM;
	}
};

void() SetNewParms = 
{
   parm1 = IT_SHOTGUN | IT_AXE;
	parm2 = 100;
	parm3 = 0;
	parm4 = 25;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = 1;
	parm9 = 0;
};

void() DecodeLevelParms = 
{
//SJB different starting items depending on matchmode
   if(matchmode == 0)
   {
      if (serverflags)
      {
         if (world.model == "maps/start.bsp")
         {
            SetNewParms();
         }
      }
      self.items = parm1;
      self.health = parm2;
      self.armorvalue = parm3;
      self.ammo_shells = parm4;
      self.ammo_nails = parm5;
      self.ammo_rockets = parm6;
      self.ammo_cells = parm7;
      self.weapon = parm8;
      self.armortype = parm9 * 0.010000;
   }
   if(matchmode == 1)
   {
      self.items = IT_AXE;
      self.health = 100;
      self.armorvalue = 0;
      self.ammo_shells = 0;
      self.ammo_nails = 0;
      self.ammo_rockets = 0;
      self.ammo_cells = 0;
      self.weapon = IT_AXE;
      self.armortype = 0;
   }
   if(matchmode == 2)
   {
      self.items = IT_AXE | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING | IT_ARMOR3;
      self.health = 100;
      self.armorvalue = 200;
      self.ammo_shells = 100;
      self.ammo_nails = 200;
      self.ammo_rockets = 100;
      self.ammo_cells = 100;
      self.weapon = IT_ROCKET_LAUNCHER;
      self.armortype = 0.8;
   }
   if(matchmode == 3)
   {
      self.items = IT_AXE | IT_SHOTGUN;
      self.health = 100;
      self.armorvalue = 0;
      self.ammo_shells = 25;
      self.ammo_nails = 0;
      self.ammo_rockets = 0;
      self.ammo_cells = 0;
      self.weapon = IT_SHOTGUN;
      self.armortype = 0;
   }

};

entity() FindIntermission = 
{
	local entity spot;
	local float cyc;
	spot = find(world, classname, "info_intermission");
	if (spot)
	{
		cyc = random() * MOVETYPE_STEP;
		while (cyc > 1)
		{
			spot = find(spot, classname, "info_intermission");
			if (!spot)
			{
				spot = find(spot, classname, "info_intermission");
			}
			cyc = cyc - 1;
		}
		return spot;
	}
	spot = find(world, classname, "info_player_start");
	if (spot)
	{
		return spot;
	}
	spot = find(world, classname, "testplayerstart");
	if (spot)
	{
		return spot;
	}
	objerror("FindIntermission: no spot");
	
};

string nextmap /* = "" */;

void() GotoNextMap = 
{
	if (cvar("samelevel"))
	{
		changelevel(mapname);
	}
	else
	{
		changelevel(nextmap);
	}
};

void() ExitIntermission = 
{
   if (deathmatch)
	{
			GotoNextMap();
         return;
	}
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;
	if (intermission_running == FL_SWIM)
	{
		if (world.model == "maps/e1m7.bsp")
		{
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, FL_SWIM);
			WriteByte(MSG_ALL, MOVETYPE_WALK);
			if (!cvar("registered"))
			{
				WriteByte(MSG_ALL, SVC_FINALE);
				WriteString(MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!");
			}
			else
			{
				WriteByte(MSG_ALL, SVC_FINALE);
				WriteString(MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!");
			}
			return;
		}
		else
		{
			if (world.model == "maps/e2m6.bsp")
			{
				WriteByte(MSG_ALL, SVC_CDTRACK);
				WriteByte(MSG_ALL, FL_SWIM);
				WriteByte(MSG_ALL, MOVETYPE_WALK);
				WriteByte(MSG_ALL, SVC_FINALE);
				WriteString(MSG_ALL, "The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herself in her frightful\notherworld cathedral.");
				return;
			}
			else
			{
				if (world.model == "maps/e3m6.bsp")
				{
					WriteByte(MSG_ALL, SVC_CDTRACK);
					WriteByte(MSG_ALL, FL_SWIM);
					WriteByte(MSG_ALL, MOVETYPE_WALK);
					WriteByte(MSG_ALL, SVC_FINALE);
					WriteString(MSG_ALL, "The charred viscera of diabolic horrors\nbubble viscously as you seize the Rune\nof Hell Magic. Its heat scorches your\nhand, and its terrible secrets blight\nyour mind. Gathering the shreds of your\ncourage, you shake the devil's shackles\nfrom your soul, and become ever more\nhard and determined to destroy the\nhideous creatures whose mere existence\nthreatens the souls and psyches of all\nthe population of Earth.");
					return;
				}
				else
				{
					if (world.model == "maps/e4m7.bsp")
					{
						WriteByte(MSG_ALL, SVC_CDTRACK);
						WriteByte(MSG_ALL, FL_SWIM);
						WriteByte(MSG_ALL, MOVETYPE_WALK);
						WriteByte(MSG_ALL, SVC_FINALE);
						WriteString(MSG_ALL, "Despite the awful might of the Elder\nWorld, you have achieved the Rune of\nElder Magic, capstone of all types of\narcane wisdom. Beyond good and evil,\nbeyond life and death, the Rune\npulsates, heavy with import. Patient and\npotent, the Elder Being Shub-Niggurath\nweaves her dire plans to clear off all\nlife from the Earth, and bring her own\nfoul offspring to our world! For all the\ndwellers in these nightmare dimensions\nare her descendants! Once all Runes of\nmagic power are united, the energy\nbehind them will blast open the Gateway\nto Shub-Niggurath, and you can travel\nthere to foil the Hell-Mother's plots\nin person.");
						return;
					}
				}
			}
		}
		GotoNextMap();
	}
	if (intermission_running == MOVETYPE_WALK)
	{
		if (!cvar("registered"))
		{
			WriteByte(MSG_ALL, SVC_SELLSCREEN);
			return;
		}
		if ((serverflags & FILM_HI_LIP) == FILM_HI_LIP)
		{
			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString(MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisible forces moving to\nunseal ancient barriers. Shub-Niggurath\nhad hoped to use the Runes Herself to\nclear off the Earth, but now instead,\nyou will use them to enter her home and\nconfront her as an avatar of avenging\nEarth-life. If you defeat her, you will\nbe remembered forever as the savior of\nthe planet. If she conquers, it will be\nas if you had never been born.");
			return;
		}
	}
	GotoNextMap();
};

//SJB intermission think has been completely changed :)
void() IntermissionThink =
{
	if (time < intermission_exittime)
	{
		return;
	}
   if (matchmode && !finale)
	{
      finale = TRUE;
      SpawnMatchOver();
	}
   if(matchmode)
      return;

   if (!(self.button0) && !(self.button1) && !(self.button2))
	{
		return;
	}
   ExitIntermission();
};

void() execute_changelevel = 
{
	local entity pos;
	intermission_running = 1;
	if (deathmatch)
	{
		intermission_exittime = time + 5;
	}
	else
	{
		intermission_exittime = time + 3;
	}
	WriteByte(MSG_ALL, SVC_CDTRACK);
	WriteByte(MSG_ALL, MOVETYPE_WALK);
	WriteByte(MSG_ALL, MOVETYPE_WALK);
	pos = FindIntermission();
	other = find(world, classname, "player");
	while (other != world)
	{
		other.view_ofs = VEC_ORIGIN;
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = 1;
		other.nextthink = time + TRACE_PAUSE;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin(other, pos.origin);
		other = find(other, classname, "player");
	}

//SJB duplicate code for cameras....crude, but it works ;)

   other = find(world, classname, "camera");
	while (other != world)
	{
		other.view_ofs = VEC_ORIGIN;
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = 1;
		other.nextthink = time + TRACE_PAUSE;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin(other, pos.origin);
      other = find(other, classname, "camera");
	}

	WriteByte(MSG_ALL, SVC_INTERMISSION);
};

void() changelevel_touch = 
{
	local entity pos;
	if (other.classname != "player")
	{
		return;
	}
	if (cvar("noexit") == 1 || (cvar("noexit") == FL_SWIM && mapname != "start"))
	{
		T_Damage(other, self, self, 50000);
		return;
	}
	if (coop || deathmatch)
	{
		bprint(other.netname);
		bprint(" exited the level\n");
	}
	nextmap = self.map;
	SUB_UseTargets();
	if (self.spawnflags & 1 && deathmatch == 0)
	{
		GotoNextMap();
		return;
	}
	self.touch = SUB_Null;
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

void() trigger_changelevel = 
{
	if (!(self.map))
	{
		objerror("chagnelevel trigger doesn't have map");
	}
	InitTrigger();
	self.touch = changelevel_touch;
};

void () set_suicide_frame;

void() respawn = 
{
	CC_DeadGuyRespawning(self);
	if (coop)
	{
		CopyToBodyQue(self);
		setspawnparms(self);
		PutClientInServer();
	}
	else
	{
		if (deathmatch)
		{
			CopyToBodyQue(self);
			SetNewParms();
			PutClientInServer();
		}
		else
		{
			localcmd("restart\n");
		}
	}
};

void() ClientKill = 
{
	if (self.camtype > 0)
	{
		return;
	}
	bprint(self.netname);
	bprint(" suicides\n");
	set_suicide_frame();
	self.modelindex = modelindex_player;
//SJB
   if(matchmode != 1 && matchmode != 2)
	{
      	self.frags = self.frags - 2;
//PNT 
		UpdateMatchStats(self,-2, 0, 2, 2); // update match stats (suicides, deaths) add 2 suicides and 2 deaths
	}
	respawn();
	CC_AntiSpamAction(self);
};

// Gives compile error, function not called anywhere, probably intended for future dev.
/*
void(vector v) CheckSpawnPoint = 
{
	return 0;
};

*/

entity() SelectSpawnPoint = 
{
   local entity spot,spots;
	local entity thing;
   local float pcount,totalspots,numspots;
	spot = find(world, classname, "testplayerstart");
	if (spot)
	{
		return spot;
	}
	if (coop)
	{
		lastspawn = find(lastspawn, classname, "info_player_coop");
		if (lastspawn == world)
		{
			lastspawn = find(lastspawn, classname, "info_player_start");
		}
		if (lastspawn != world)
		{
			return lastspawn;
		}
	}
	else
	{
		if (deathmatch)
		{
//SJB allow choosing between standard ordered spawning & QW random respawning
         if(standardspawn == FALSE)
         {
            spots = world;
            spot = find (world, classname, "info_player_deathmatch");       
            while (spot)
            {
               totalspots = totalspots + 1;
         
               thing=findradius(spot.origin, 84);
               pcount=0;               
               while (thing)
               {
                  if (thing.classname == "player")
                     pcount=pcount + 1;                      
                  thing=thing.chain;      
               }
               if (pcount == 0) {
                  spot.goalentity = spots;
                  spots = spot;
                  numspots = numspots + 1;
               }
   
               // Get the next spot in the chain
               spot = find (spot, classname, "info_player_deathmatch");                
            }
            totalspots=totalspots - 1;
            if (!numspots) {
               // ack, they are all full, just pick one at random
         //    bprint (PRINT_HIGH, "Ackk! All spots are full. Selecting random spawn spot\n");
               totalspots = rint((random() * totalspots));
               spot = find (world, classname, "info_player_deathmatch");       
               while (totalspots > 0) {
                  totalspots = totalspots - 1;
                  spot = find (spot, classname, "info_player_deathmatch");
               }
               return spot;
            }
       
         // We now have the number of spots available on the map in numspots
   
            // Generate a random number between 1 and numspots
   
            numspots = numspots - 1;
    
            numspots = rint((random() * numspots ) );
   
            spot = spots;
            while (numspots > 0) {
               spot = spot.goalentity;
               numspots = numspots - 1;
            }
            return spot;
         }
         else
         {
            spot = lastspawn;
            while (1)
            {
               spot = find(spot, classname, "info_player_deathmatch");
               if (spot != world)
               {
                  if (spot == lastspawn)
                  {
                     return lastspawn;
                  }
                  pcount = 0;
                  thing = findradius(spot.origin, FL_MONSTER);
                  while (thing)
                  {
                     if (thing.classname == "player")
                     {
                        pcount = pcount + 1;
                     }
                     thing = thing.chain;
                  }
                  if (pcount == 0)
                  {
                     lastspawn = spot;
                     return spot;
                  }
               }
            }
         }
		}
	}
	if (serverflags)
	{
		spot = find(world, classname, "info_player_start2");
		if (spot)
		{
			return spot;
		}
	}
	spot = find(world, classname, "info_player_start");
	if (!spot)
	{
		error("PutClientInServer: no info_player_start on level");
	}
	return spot;
};

void () PlayerDie;

void() PutClientInServer = 
{
	local entity spot;
	if (CC_PutClientInServer())
	{
      return;
	}
	spot = SelectSpawnPoint();
	self.classname = "player";
	self.health = 100;
   self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	self.max_health = 100;
   self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = FL_SWIM;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;
	DecodeLevelParms();
	W_SetCurrentAmmo();
	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	self.deadflag = DEAD_NO;
	self.pausetime = 0;
	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = 1;
	setmodel(self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;
	setmodel(self, "progs/player.mdl");
	modelindex_player = self.modelindex;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.view_ofs = '0 0 22';
	player_stand1();
	if (deathmatch || coop)
	{
		makevectors(self.angles);
		spawn_tfog(self.origin + v_forward * 20);
	}
	spawn_tdeath(self.origin, self);
};

void() info_player_start = 
{
};

void() info_player_start2 = 
{
};

void() testplayerstart = 
{
};

void() info_player_deathmatch = 
{
};

void() info_player_coop = 
{
};

void() NextLevel = 
{
	local entity o;
	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else
		{
			if (!(serverflags & 1))
			{
				mapname = "e1m1";
				serverflags = serverflags | 1;
			}
			else
			{
				if (!(serverflags & FL_SWIM))
				{
					mapname = "e2m1";
					serverflags = serverflags | FL_SWIM;
				}
				else
				{
					if (!(serverflags & MOVETYPE_STEP))
					{
						mapname = "e3m1";
						serverflags = serverflags | MOVETYPE_STEP;
					}
					else
					{
						if (!(serverflags & FL_CLIENT))
						{
							mapname = "e4m1";
							serverflags = serverflags - MOVETYPE_PUSH;
						}
					}
				}
			}
		}
		o = spawn();
		o.map = mapname;
	}
	else
	{
		o = find(world, classname, "trigger_changelevel");
		if (!o)
		{
			mapname = "start";
			o = spawn();
			o.map = mapname;
		}
	}
	nextmap = o.map;
	gameover = 1;
	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
};

void() CheckRules = 
{
	local float timelimit;
	local float fraglimit;
	if (gameover)
	{
		return;
	}
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	if (timelimit && time >= timelimit)
	{
		NextLevel();
		return;
	}
	if (fraglimit && self.frags >= fraglimit)
	{
		NextLevel();
		return;
	}
};

void() PlayerDeathThink = 
{
	local entity old_self;
	local float forward;
	if (self.flags & FL_ONGROUND)
	{
		forward = vlen(self.velocity);
		forward = forward - 20;
		if (forward <= 0)
		{
			self.velocity = VEC_ORIGIN;
		}
		else
		{
			self.velocity = forward * normalize(self.velocity);
		}
	}
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
		{
			return;
		}
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}
	if (!(self.button2) && !(self.button1) && !(self.button0))
	{
		return;
	}
	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	respawn();
};

void() PlayerJump = 
{
	local vector start;
	local vector end;
	if (self.flags & FL_WATERJUMP)
	{
		return;
	}
	if (self.waterlevel >= FL_SWIM)
	{
		if (self.watertype == CONTENT_WATER)
		{
			self.velocity_z = 100;
		}
		else
		{
			if (self.watertype == CONTENT_SLIME)
			{
				self.velocity_z = 80;
			}
			else
			{
				self.velocity_z = SLOW_TURN_RATE;
			}
		}
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
			if (random() < TRACE_PAUSE)
			{
				sound(self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			}
			else
			{
				sound(self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
			}
		}
		return;
	}
	if (!(self.flags & FL_ONGROUND))
	{
		return;
	}
	if (!(self.flags & FL_JUMPRELEASED))
	{
		return;
	}
	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	self.flags = self.flags - FL_ONGROUND;
	self.button2 = 0;
	sound(self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	self.velocity_z = self.velocity_z + 270;
};

.float dmgtime;

void() WaterMove = 
{
	if (self.movetype == MOVETYPE_NOCLIP)
	{
		return;
	}
	if (self.health < 0)
	{
		return;
	}
	if (self.waterlevel != MOVETYPE_WALK)
	{
		if (self.air_finished < time)
		{
			sound(self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		}
		else
		{
			if (self.air_finished < time + MOVETYPE_FLYMISSILE)
			{
				sound(self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
			}
		}
		self.air_finished = time + 12;
		self.dmg = FL_SWIM;
	}
	else
	{
		if (self.air_finished < time)
		{
			if (self.pain_finished < time)
			{
				self.dmg = self.dmg + FL_SWIM;
				if (self.dmg > FILM_HI_LIP)
				{
					self.dmg = MOVETYPE_BOUNCE;
				}
				T_Damage(self, world, world, self.dmg);
				self.pain_finished = time + 1;
			}
		}
	}
	if (!(self.waterlevel))
	{
		if (self.flags & FL_INWATER)
		{
			sound(self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}
	if (self.watertype == CONTENT_LAVA)
	{
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
			{
				self.dmgtime = time + 1;
			}
			else
			{
				self.dmgtime = time + TRACE_BUFFER;
			}
			T_Damage(self, world, world, MOVETYPE_BOUNCE * self.waterlevel);
		}
	}
	else
	{
		if (self.watertype == CONTENT_SLIME)
		{
			if (self.dmgtime < time && self.radsuit_finished < time)
			{
				self.dmgtime = time + 1;
				T_Damage(self, world, world, MOVETYPE_STEP * self.waterlevel);
			}
		}
	}
	if (!(self.flags & FL_INWATER))
	{
		if (self.watertype == CONTENT_LAVA)
		{
			sound(self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		}
		if (self.watertype == CONTENT_WATER)
		{
			sound(self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		}
		if (self.watertype == CONTENT_SLIME)
		{
			sound(self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);
		}
		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}
	if (!(self.flags & FL_WATERJUMP))
	{
		self.velocity = self.velocity - 0.8 * self.waterlevel * frametime * self.velocity;
	}
};

void() CheckWaterJump = 
{
	local vector start;
	local vector end;
	makevectors(self.angles);
	start = self.origin;
	start_z = start_z + FL_CLIENT;
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward * 24;
	traceline(start, end, 1, self);
	if (trace_fraction < 1)
	{
		start_z = start_z + self.maxs_z - FL_CLIENT;
		end = start + v_forward * 24;
		self.movedir = trace_plane_normal * -50;
		traceline(start, end, 1, self);
		if (trace_fraction == 1)
		{
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + FL_SWIM;
			return;
		}
	}
};

void() PlayerPreThink = 
{
	local float mspeed;
	local float aspeed;
	local float r;
	if (intermission_running)
	{
		IntermissionThink();
		return;
	}
	if (self.camtype >= 0)
	{
		return;
	}
	if (self.view_ofs == VEC_ORIGIN)
	{
		return;
	}
	makevectors(self.v_angle);
	CheckRules();
	WaterMove();
	if (self.waterlevel == FL_SWIM)
	{
		CheckWaterJump();
	}
	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink();
		return;
	}
	if (self.deadflag == DEAD_DYING)
	{
		return;
	}
	if (self.button2)
	{
		PlayerJump();
	}
	else
	{
		self.flags = self.flags | FL_JUMPRELEASED;
	}
	if (time < self.pausetime)
	{
		self.velocity = VEC_ORIGIN;
	}
	if (time > self.attack_finished && self.currentammo == 0 && self.weapon != IT_AXE)
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
	}
};

void() CheckPowerups = 
{
	if (self.health <= 0)
	{
		return;
	}
	if (self.invisible_finished)
	{
		if (self.invisible_sound < time)
		{
			sound(self, CHAN_AUTO, "items/inv3.wav", TRACE_PAUSE, ATTN_IDLE);
			self.invisible_sound = time + (random() * MOVETYPE_WALK + 1);
		}
		if (self.invisible_finished < time + MOVETYPE_WALK)
		{
			if (self.invisible_time == 1)
			{
				sprint(self, "Ring of Shadows magic is fading\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd(self, "bf\n");
			}
		}
		if (self.invisible_finished < time)
		{
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}
	else
	{
		self.modelindex = modelindex_player;
	}
	if (self.invincible_finished)
	{
		if (self.invincible_finished < time + MOVETYPE_WALK)
		{
			if (self.invincible_time == 1)
			{
				sprint(self, "Protection is almost burned out\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd(self, "bf\n");
			}
		}
		if (self.invincible_finished < time)
		{
			self.items = self.items - IT_INVULNERABILITY;
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
		{
			self.effects = self.effects | EF_DIMLIGHT;
		}
		else
		{
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
		}
	}
	if (self.super_damage_finished)
	{
		if (self.super_damage_finished < time + MOVETYPE_WALK)
		{
			if (self.super_time == 1)
			{
				sprint(self, "Quad Damage is wearing off\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}
			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd(self, "bf\n");
			}
		}
		if (self.super_damage_finished < time)
		{
			self.items = self.items - IT_QUAD;
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
		{
			self.effects = self.effects | EF_DIMLIGHT;
		}
		else
		{
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
		}
	}
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;
		if (self.radsuit_finished < time + MOVETYPE_WALK)
		{
			if (self.rad_time == 1)
			{
				sprint(self, "Air supply in Biosuit expiring\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd(self, "bf\n");
			}
		}
		if (self.radsuit_finished < time)
		{
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}
};

void() PlayerPostThink = 
{
	local float mspeed;
	local float aspeed;
	local float r;
	if (CC_PlayerPostThink())
	{
		return;
	}
	if (self.view_ofs == VEC_ORIGIN)
	{
		return;
	}
	if (self.deadflag)
	{
		return;
	}
	W_WeaponFrame();
	if (self.jump_flag < -300 && (self.flags & FL_ONGROUND) && self.health > 0)
	{
		if (self.watertype == CONTENT_WATER)
		{
			sound(self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		}
		else
		{
			if (self.jump_flag < -650)
			{
				T_Damage(self, world, world, MOVETYPE_FLY);
				sound(self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
				self.deathtype = "falling";
			}
			else
			{
				sound(self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
			}
		}
		self.jump_flag = 0;
	}
	if (!(self.flags & FL_ONGROUND))
	{
		self.jump_flag = self.velocity_z;
	}
	CheckPowerups();
};

void() ClientConnect = 
{
	if (CC_ClientConnect())
	{
		return;
	}
	bprint(self.netname);
	bprint(" entered the game\n");
	if (intermission_running)
	{
		ExitIntermission();
	}
};

void() ClientDisconnect = 
{
	CC_ClientDisconnect();
	if (gameover)
	{
		return;
	}
//SJB
   if(self.classname == "player")
   {
      bprint(self.netname);
      bprint(" left the game with ");
      bprint(ftos(self.frags));
      bprint(" frags\n");
      sound(self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
      set_suicide_frame();
      if(matchmode == 2)
         CC_SetAllNotReady();
   }
   else
   {
      bprint("spectator ");
      bprint(self.netname);
      bprint(" left the game\n");
      sound(self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
   }
};

void(entity targ, entity attacker) ClientObituary = 
{
   local float rnum,rnd;
	local string deathstring;
	local string deathstring2;
//SJB avoid "so and so has died" message when countdown timer frags players
   if(attacker.classname == "countdown_timer")
      return;
	rnum = random();
	if (targ.classname == "player")
	{
		if (attacker.classname == "teledeath")
		{
			bprint(targ.netname);
			bprint(" was telefragged by ");
			bprint(attacker.owner.netname);
			bprint("\n");
			attacker.owner.frags = attacker.owner.frags + 1;
// PNT attacker gets a telefrag on target
			UpdateMatchStats(attacker.owner, 1, 1, 0, 0); 	// update match stats (kills) add a kill to attacker
			UpdateMatchStats(targ, 0, 0, 0, 1); 		// update match stats (deaths) add a death to target	
			CC_PlayerKilledPlayer(attacker.owner, targ);
			return;
		}
		if (attacker.classname == "teledeath2")
		{
			bprint("Satan's power deflects ");
			bprint(targ.netname);
			bprint("'s telefrag\n");
			targ.frags = targ.frags - 1;
// PNT attacker has pent and is telefraged
			UpdateMatchStats(targ, -1, 0, 1, 1); 		// update match stats (frags, suicides, deaths) add a death + suicide to player
			CC_PlayerKilledPlayer(targ, attacker.owner);
			return;
		}
		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				attacker.frags = attacker.frags - 1;
// PNT attacker kills himself with a weapon
				UpdateMatchStats(targ, -1, 0, 1, 1); 	// update match stats (frags, suicides, deaths) add a death + suicide to player
				bprint(targ.netname);
				if (targ.weapon == FL_GODMODE && targ.waterlevel > 1)
				{
					bprint(" discharges into the water.\n");
					return;
				}
				if (targ.weapon == IT_GRENADE_LAUNCHER)
				{
					bprint(" tries to put the pin back in\n");
				}
				else
				{
					bprint(" becomes bored with life\n");
				}
				return;
			}
			else
			{
				if (teamplay == FL_SWIM && targ.team > 0 && targ.team == attacker.team)
				{
//SJB modified this function to add more teamplay death messages
               rnd = 1 + floor(rnum * 15);
               if(rnd == 1)
                  deathstring = " mows down a teammate\n";
               else if(rnd == 2)
                  deathstring = " checks his glasses\n";
               else if(rnd == 3)
                  deathstring = " gets a frag for the other team\n";
               else if(rnd == 4)
                  deathstring = " loses another friend\n";
               else if(rnd == 5)
                  deathstring = " needs to work on his accuracy\n";
               else if(rnd == 6)
                  deathstring = " thinks everyone is after him\n";
               else if(rnd == 7)
                  deathstring = " says 'Ooops!'\n";
               else if(rnd == 8)
                  deathstring = " starts making excuses\n";
               else if(rnd == 9)
                  deathstring = " believes everyone is fair game\n";
               else if(rnd == 10)
                  deathstring = " is running out of friends\n";
               else if(rnd == 11)
                  deathstring = " does time in the sin bin\n";
               else if(rnd == 12)
                  deathstring = " is convicted of treason\n";
               else if(rnd == 13)
                  deathstring = " reveals he is colour-blind\n";
               else if(rnd == 14)
                  deathstring = " lets it all go to his head\n";
               else if(rnd == 15)
                  deathstring = " has been overdosing on LSD\n";

					bprint(attacker.netname);
					bprint(deathstring);
					attacker.frags = attacker.frags - 1;
// PNT Attacker frags a team mate with a weapon
					UpdateMatchStats(attacker, -1, 0, 1, 0);	// update match stats (suicides) add a suicide to attacker
					UpdateMatchStats(targ, -1, 0, 0, 1);	// update match stats (deaths) add a death to target
					CC_PlayerKilledPlayer(attacker, targ);
					return;
				}
				else
				{
					attacker.frags = attacker.frags + 1;
// PNT Attacker frags a enemy
					UpdateMatchStats(attacker, 1, 1, 0, 0);	// update match stats (kills) add a kill to attacker
					UpdateMatchStats(targ, 0, 0, 0, 1); 	// update match stats (deaths) add a death to target
					CC_PlayerKilledPlayer(attacker, targ);
					rnum = attacker.weapon;
					if (rnum == IT_AXE)
					{
						deathstring = " was ax-murdered by ";
						deathstring2 = "\n";
					}
					if (rnum == IT_SHOTGUN)
					{
						deathstring = " chewed on ";
						deathstring2 = "'s boomstick\n";
					}
					if (rnum == IT_SUPER_SHOTGUN)
					{
						deathstring = " ate 2 loads of ";
						deathstring2 = "'s buckshot\n";
					}
					if (rnum == IT_NAILGUN)
					{
						deathstring = " was nailed by ";
						deathstring2 = "\n";
					}
					if (rnum == IT_SUPER_NAILGUN)
					{
						deathstring = " was punctured by ";
						deathstring2 = "\n";
					}
					if (rnum == IT_GRENADE_LAUNCHER)
					{
						deathstring = " eats ";
						deathstring2 = "'s pineapple\n";
						if (targ.health < -40)
						{
							deathstring = " was gibbed by ";
							deathstring2 = "'s grenade\n";
						}
					}
					if (rnum == IT_ROCKET_LAUNCHER)
					{
						deathstring = " rides ";
						deathstring2 = "'s rocket\n";
						if (targ.health < -40)
						{
							deathstring = " was gibbed by ";
							deathstring2 = "'s rocket\n";
						}
					}
					if (rnum == IT_LIGHTNING)
					{
						deathstring = " accepts ";
						if (attacker.waterlevel > 1)
						{
							deathstring2 = "'s discharge\n";
						}
						else
						{
							deathstring2 = "'s shaft\n";
						}
					}
					bprint(targ.netname);
					bprint(deathstring);
					bprint(attacker.netname);
					bprint(deathstring2);
				}
			}
			return;
		}
		else
		{
			targ.frags = targ.frags - 1;
// PNT target is killed by something else
			UpdateMatchStats(targ, -1, 0, 1, 1); 	// update match stats (suicides,deaths) add a suicide + death to target
			bprint(targ.netname);
			if (attacker.flags & FL_MONSTER)
			{
				if (attacker.classname == "monster_army")
				{
					bprint(" was shot by a Grunt\n");
				}
				if (attacker.classname == "monster_demon1")
				{
					bprint(" was eviscerated by a Fiend\n");
				}
				if (attacker.classname == "monster_dog")
				{
					bprint(" was mauled by a Rottweiler\n");
				}
				if (attacker.classname == "monster_dragon")
				{
					bprint(" was fried by a Dragon\n");
				}
				if (attacker.classname == "monster_enforcer")
				{
					bprint(" was blasted by an Enforcer\n");
				}
				if (attacker.classname == "monster_fish")
				{
					bprint(" was fed to the Rotfish\n");
				}
				if (attacker.classname == "monster_hell_knight")
				{
					bprint(" was slain by a Death Knight\n");
				}
				if (attacker.classname == "monster_knight")
				{
					bprint(" was slashed by a Knight\n");
				}
				if (attacker.classname == "monster_ogre")
				{
					bprint(" was destroyed by an Ogre\n");
				}
				if (attacker.classname == "monster_oldone")
				{
					bprint(" became one with Shub-Niggurath\n");
				}
				if (attacker.classname == "monster_shalrath")
				{
					bprint(" was exploded by a Vore\n");
				}
				if (attacker.classname == "monster_shambler")
				{
					bprint(" was smashed by a Shambler\n");
				}
				if (attacker.classname == "monster_tarbaby")
				{
					bprint(" was slimed by a Spawn\n");
				}
				if (attacker.classname == "monster_vomit")
				{
					bprint(" was vomited on by a Vomitus\n");
				}
				if (attacker.classname == "monster_wizard")
				{
					bprint(" was scragged by a Scrag\n");
				}
				if (attacker.classname == "monster_zombie")
				{
					bprint(" joins the Zombies\n");
				}
				return;
			}
			if (attacker.classname == "explo_box")
			{
				bprint(" blew up\n");
				return;
			}
			if (attacker.solid == SOLID_BSP && attacker != world)
			{
				bprint(" was squished\n");
				return;
			}
			if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
			{
				bprint(" was spiked\n");
				return;
			}
			if (attacker.classname == "fireball")
			{
				bprint(" ate a lavaball\n");
				return;
			}
			if (attacker.classname == "trigger_changelevel")
			{
				bprint(" tried to leave\n");
				return;
			}
			rnum = targ.watertype;
			if (rnum == CONTENT_WATER)
			{
				if (random() < TRACE_PAUSE)
				{
					bprint(" sleeps with the fishes\n");
				}
				else
				{
					bprint(" sucks it down\n");
				}
				return;
			}
			else
			{
				if (rnum == CONTENT_SLIME)
				{
					if (random() < TRACE_PAUSE)
					{
						bprint(" gulped a load of slime\n");
					}
					else
					{
						bprint(" can't exist on slime alone\n");
					}
					return;
				}
				else
				{
					if (rnum == CONTENT_LAVA)
					{
						if (targ.health < -15)
						{
							bprint(" burst into flames\n");
							return;
						}
						if (random() < TRACE_PAUSE)
						{
							bprint(" turned into hot slag\n");
						}
						else
						{
							bprint(" visits the Volcano God\n");
						}
						return;
					}
				}
			}
			if (targ.deathtype == "falling")
			{
				targ.deathtype = "";
				bprint(" fell to his death\n");
				return;
			}
			bprint(" died\n");
		}
	}
};

