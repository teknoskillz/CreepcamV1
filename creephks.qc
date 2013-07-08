void(entity killer, entity victim) CC_PlayerKilledPlayer = 
{
	local entity cam;
	local entity l;
	if (killer == victim)
	{
		return;
	}
	cam = victim.clink;
	if (cam)
	{
		if ((cam.style & FIRST_GUY_KILLED) == 0)
		{
			cam.style = cam.style | FIRST_GUY_KILLED;
			cam.autoswitch = killer;
			if (cam.state == 0 || cam.movetarget != killer)
			{
				traceline(victim.filmpos, killer.filmpos, 1, world);
				if (trace_fraction == 1)
				{
					cam.movetarget = killer;
					cam.state = FL_SWIM;
					CC_StartCamTransition(cam);
				}
			}
			if (cam.nextthink < time)
			{
				cam.think = CC_AutoSwitchCamThink;
				cam.nextthink = time + AUTOSWITCH_DELAY;
			}
		}
	}
	l = playerlist;
	while (l)
	{
		cam = l.clink;
		if (cam)
		{
			if (cam.state > 0 && cam.movetarget == victim)
			{
				cam.style = cam.style | SECOND_GUY_KILLED;
				if (cam.nextthink < time)
				{
					cam.think = CC_AutoSwitchCamThink;
					cam.nextthink = time + AUTOSWITCH_DELAY;
				}
			}
		}
		l = l.tless;
	}
};

void(entity deadguy) CC_DeadGuyRespawning = 
{
	local entity cam;
	local entity l;
	cam = deadguy.clink;
	if (cam)
	{
		if (cam.style & FIRST_GUY_KILLED)
		{
			cam.style = cam.style | VIEW_FIXED_POINT;
			cam.dest = deadguy.filmpos;
		}
	}
	l = playerlist;
	while (l)
	{
		cam = l.clink;
		if (cam)
		{
			if (cam.style & SECOND_GUY_KILLED && cam.movetarget == deadguy)
			{
				cam.style = cam.style - SECOND_GUY_KILLED;
				cam.state = 0;
				CC_StartCamTransition(cam);
				if (!(cam.autoswitch))
				{
					cam.autoswitch = deadguy;
					cam.style = cam.style | FIND_DIFFERENT_GUY;
				}
			}
		}
		l = l.tless;
	}
};

float() CC_ClientConnect = 
{
	self.creepflags = 0;
	self.spam_time = 0;
//SJB
   self.ready = FALSE;
	CC_SendAliases(self);
   if (self.netname == "camera" || matchmode == 2 || matchmode == 3)
	{
      parm9 = CF_STAYASCAM;
      bprint("spectator ");
      bprint(self.netname);
      bprint(" entered the game\n");
      return 1;
	}
//SJB
   else
      numplayers = numplayers + 1;
return 0;
};

void() CC_ClientDisconnect = 
{
	if (self.camtype > 0)
	{
		c_count = c_count - 1;
	}
//SJB
   else
      numplayers = numplayers - 1;

	CC_StopCamOrPlayer(self);
};

float() CC_PlayerPostThink = 
{
	local vector d;
   local entity e;
   local string tempstring;

//SJB check to make sure players are not teamswapping in teamplay mode
   if(self.classname == "player" && teamplay > 0)
   {
      if(matchmode == 1 && !self.ready)
         self.oldteam = self.team;
      if((matchmode == 1 || matchmode == 2) && self.team != self.oldteam)
         CC_SetPlayerNotReady();
      if(matchmode == 3 && self.team != self.oldteam)
      {
//SJB a hack I know
         e = find(world,classname,"countdown_timer");
         T_Damage(self,e,e,50000);
         bprint(self.netname);
         bprint(" has defected from ");
         tempstring = find_pants(self.oldteam);
         bprint(tempstring);
         bprint(" team to ");
         tempstring = find_pants(self.team);
         bprint(tempstring);
         bprint(" team\n");
         self.oldteam = self.team; //now they are in a new team
         if(self.frags > 0)
            self.frags = 0;
      }
   }

	if (self.camtype == 0)
	{
		return 1;
	}

//SJB added lines to copy player status bar across to camera
   if(self.classname == "camera")
   {
      if(self.owner)
      {
         if(self.owner.health > 0)
            self.health = self.owner.health;
         else
            self.health = 1;
         self.weapon = self.owner.weapon;
//         self.weaponmodel = self.owner.weaponmodel;
         self.currentammo = self.owner.currentammo;
         self.ammo_shells = self.owner.ammo_shells;
         self.ammo_nails = self.owner.ammo_nails;
         self.ammo_rockets = self.owner.ammo_rockets;
         self.ammo_cells = self.owner.ammo_cells;
         self.items = self.owner.items;
         self.armortype = self.owner.armortype;
         self.armorvalue = self.owner.armorvalue;
      }
      else
      {
         self.health = 100;
         self.weapon = IT_AXE;
         self.currentammo = 0;
         self.ammo_shells = 0;
         self.ammo_nails = 0;
         self.ammo_rockets = 0;
         self.ammo_cells = 0;
         self.items = 0;
         self.armortype = 0;
         self.armorvalue = 0;
      }
   }
	if ((self.creepflags & CF_SENTALIASES) == 0)
	{
		CC_SendAliases(self);
		self.creepflags = self.creepflags | CF_SENTALIASES;
	}
	if (self.camtype < 0)
	{
		if (self.flags & FL_ONGROUND)
		{
			if (self.origin_z - self.oldorigin_z > self.velocity_z * frametime + 1)
			{
				d = self.origin - self.oldorigin;
				d_z = 0;
				if (vlen(d) < 300)
				{
					self.filmlip = self.filmlip - self.origin_z + self.oldorigin_z;
					if (self.filmlip < FILM_LO_LIP)
					{
						self.filmlip = FILM_LO_LIP;
					}
				}
			}
		}
		if (self.filmlip < FILM_HI_LIP)
		{
			self.filmlip = self.filmlip + STAIR_BLEND_RATE * frametime;
			if (self.filmlip > FILM_HI_LIP)
			{
				self.filmlip = FILM_HI_LIP;
			}
		}
		self.filmpos = self.origin;
		self.filmpos_z = self.filmpos_z + self.filmlip;
		traceline(self.filmpos, self.filmpos + PRED_TIME * self.velocity, 1, world);
		self.predpos = trace_endpos - CLIP_TIME * self.velocity;
		CC_PlayerImpulses();
		if (self.deadflag)
		{
			self.impulse = 0;
		}
		return 0;
	}
	self.flags = FL_NOTARGET | FL_CLIENT;
	if (self.button2)
	{
		if ((self.attack_finished & FL_SWIM) == 0)
		{
			self.attack_finished = self.attack_finished | FL_SWIM;
			if (self.owner)
			{
				centerprint(self, self.owner.netname);
			}
		}
	}
	else
	{
		if (self.attack_finished & FL_SWIM)
		{
			self.attack_finished = self.attack_finished - FL_SWIM;
		}
	}
	if (self.button0)
	{
		if ((self.attack_finished & 1) == 0)
		{
			self.attack_finished = self.attack_finished | 1;
			CC_SwitchToNextPlayer();
		}
	}
	else
	{
		if (self.attack_finished & 1)
		{
			self.attack_finished = self.attack_finished - 1;
		}
	}
//SJB check to avoid running camera algorithm during intermission
   if (self.owner != world && !intermission_running)
	{
		if (self.owner.clink == self)
		{
			CC_DoCamAlgorithm(self);
		}
		else
		{
			setorigin(self, self.owner.clink.origin);
			self.v_angle = self.owner.clink.v_angle;
			self.angles = self.owner.clink.angles;
			self.fixangle = 1;
		}
	}
	CC_PlayerImpulses();
	if (self.impulse == 101)
	{
		CC_RequestNotCam();
	}
	if (self.impulse >= 201 && self.impulse < 216)
	{
		CC_SwitchToPlayer(self.impulse - 200);
	}
	if (self.impulse == 56)
	{
		CC_PlayerKilledPlayer(self.movetarget, self.owner);
	}
	self.impulse = 0;
	return 1;
};

float() CC_PutClientInServer = 
{
	if (parm9 & CF_DECODEFLAGS)
	{
		self.creepflags = floor((parm9 - CF_DECODEFLAGS) / CF_DECODESHIFT);
		parm9 = parm9 - CF_DECODEFLAGS - self.creepflags * CF_DECODESHIFT;
	}
	if ((self.creepflags & CF_SENTMOTD) == 0)
	{
		if ((parm9 & CF_STAYASCAM) == 0)
		{
         if(matchmode == 1)
            CC_LongMessage(self, 0.6, "ÄiMeÂ’XŸ Creepcam v1.1 beta5\n\nby €äâ‚mandrake\nmatch stats by ÐhaÎÔ’Í €DB\n\nBased on Creepcam v1.0\n\nType ãòååðãáí at the console\nfor more information.\n\npre-match setup mode.");
         else
            CC_LongMessage(self, 0.6, "ÄiMeÂ’XŸ Creepcam v1.1 beta5\n\nby €äâ‚mandrake\nmatch stats by ÐhaÎÔ’Í €DB\n\nBased on Creepcam v1.0\n\nType ãòååðãáí at the console\nfor more information.");
		}
		self.creepflags = self.creepflags | CF_SENTMOTD;
	}
	if (parm9 & CF_STAYASCAM)
	{
		parm9 = parm9 - CF_STAYASCAM;
		if (CC_RequestNoCrapCam())
		{
			return 1;
		}
	}
	if (self.camtype == 0)
	{
		CC_ChangeToPlayer(self);
	}
	self.camtype = CONTENT_SOLID;
	return 0;
};

void() CC_WorldSpawn = 
{
   local entity e;

	blinkstate = 0;
	c_count = 0;
	playerlist = world;
	freecamlist = world;
	CC_SpawnBlinker();
//SJB always turn autoaim off, set 40fps server speed, and check samelevel
   cvar_set("sv_aim","1");
   cvar_set("sys_ticrate","0.025");
   if(cvar("samelevel") == 2) matchmode = 1;
//SJB precache soundfx used in countdowns etc
   precache_sound("buttons/switch02.wav");
   precache_sound("doors/runetry.wav");
   precache_sound("misc/medkey.wav");
   precache_sound("shambler/sdeath.wav");
   precache_sound("knight/kdeath.wav");

//SJB spawn an entity to display intro messages
   if(matchmode)
   {
      e = spawn();
      e.classname = "intro_message";
      e.think = intro_message;
      e.nextthink = time + 2;
   }
};

