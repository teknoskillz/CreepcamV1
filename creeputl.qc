void(entity e) CC_AntiSpamAction = 
{
	local string s;
	if (time - e.spam_time > SPAM_TIMEINTERVAL)
	{
		e.spam_time = time;
		e.spam_count = 1;
	}
	else
	{
		e.spam_count = e.spam_count + 1;
		if (e.spam_count >= SPAM_ACTIONLIMIT)
		{
			bprint("Too much spamming from ");
			bprint(e.netname);
			bprint("\n");
			stuffcmd(e, "\ndisconnect\n");
		}
	}
};

void(entity e) CC_SendAliases = 
{
	stuffcmd(e, "alias creepcam \"impulse 120\"\n");
	stuffcmd(e, "alias my-specs \"impulse 150\"\n");
	stuffcmd(e, "alias all-specs \"impulse 151\"\n");
	stuffcmd(e, "alias spectate \"impulse 100\"\n");
	stuffcmd(e, "alias join \"impulse 101\"\n");
	stuffcmd(e, "alias show-rec \"impulse 121\"\n");
	stuffcmd(e, "alias autoswitch \"impulse 122\"\n");
//SJB more aliases for new commands
   stuffcmd(e, "alias respawn \"impulse 102\"\n");
   stuffcmd(e, "alias ready \"impulse 105\"\n");
   stuffcmd(e, "alias notready \"impulse 106\"\n");
   stuffcmd(e, "alias noquad \"impulse 107\"\n");
   stuffcmd(e, "alias nopent \"impulse 108\"\n");
   stuffcmd(e, "alias noring \"impulse 109\"\n");
   stuffcmd(e, "alias matchmode \"impulse 119\"\n");
};

void(entity e) CC_WriteHelpInfo = 
{
   sprint(e, "ç Creepcam command summary:\nÛÂ„Ù·ÙÂ   become a camera\nÍÔÈÓ       become a player\nÌ˘≠ÛÂ„Û   list spectators on you\n·ÏÏ≠ÛÂ„Û  list all spectators\nÛËÔ˜≠ÚÂ„   toggle 'rec' display\n·ıÙÔÛ˜ÈÙ„Ë toggle autoswitching mode\nÌ·Ù„ËÌÔ‰Â  help on match commands\nUse fire button to switch between players when spectating.\n");
};

//SJB extra help for match mode commands
void(entity e) CC_WriteHelpInfo2 =
{
   sprint(e, "ç matchmode is enabled by starting with samelevel 2.\nÚÂ·‰˘    enter ready state\nÓÔÙÚÂ·‰˘ return to not ready state\nÚÂÛ·˜Ó  random/ordered respawning\nÓÔÒı·‰   remove quads\nÓÔÂÓÙ   remove pentagrams\nÓÔÚÈÓÁ   remove rings\n");
};

void() CC_LongMessageThink =
{
	if (self.state == 0)
	{
		if (self.owner.creepflags & CF_DOINGLONGMESSAGE)
		{
			self.nextthink = time + 1;
			return;
		}
		self.state = 1;
		self.owner.creepflags = self.owner.creepflags + CF_DOINGLONGMESSAGE;
	}
	self.lefty = self.lefty - 1;
	if (self.lefty > 1)
	{
		centerprint(self.owner, self.deathtype);
		self.nextthink = time + 0.7;
	}
	else
	{
		if (self.lefty == 1)
		{
			self.nextthink = time + AUTOSWITCH_DELAY;
		}
		else
		{
			self.owner.creepflags = self.owner.creepflags - CF_DOINGLONGMESSAGE;
			remove(self);
		}
	}
};

void(entity targ, float pauselen, string msg) CC_LongMessage = 
{
	local entity s;
	s = spawn();
	s.lefty = MOVETYPE_FLYMISSILE;
	s.deathtype = msg;
	s.owner = targ;
	s.think = CC_LongMessageThink;
	s.nextthink = time + pauselen;
	s.state = 0;
};

void(entity c) CC_ClearNameForAll = 
{
	WriteByte(MSG_ALL, SVC_UPDATENAME);
	WriteByte(MSG_ALL, c.colormap - 1);
	WriteString(MSG_ALL, string_null);
};

void(entity c) CC_ShowNameForAll = 
{
	WriteByte(MSG_ALL, SVC_UPDATENAME);
	WriteByte(MSG_ALL, c.colormap - 1);
	WriteString(MSG_ALL, c.netname);
};

void() CC_ClearCamNamesForAll = 
{
	local entity l;
	local entity c;
	l = playerlist;
	while (l != world)
	{
		c = l.clink;
		while (c != world)
		{
			CC_ClearNameForAll(c);
			c = c.clink;
		}
		l = l.tless;
	}
	c = freecamlist;
	while (c != world)
	{
		CC_ClearNameForAll(c);
		c = c.clink;
	}
};

float blinkstate /* = 0.000 */;
float scoreshowtime /* = 0.000 */;
float showflag /* = 0.000 */;

void(entity c) CC_ShowRec = 
{
	if ((c.flags & FL_CLIENT) == 0 || (c.creepflags & CF_NOSHOWREC))
	{
		return;
	}
	if (c.creepflags & CF_DOINGLONGMESSAGE)
	{
		return;
	}
//SJB disable blinker during countdown
   if(matchmode == 2)
      return;
	if (blinkstate)
	{
		centerprint(c, "\n\n\n\n\n\n\n\n\n\n\n                                 rec  ");
	}
	else
	{
		centerprint(c, "\n\n\n\n\n\n\n\n\n\n\n                                 rec ã");
	}
};

void(entity c) CC_StopBlink = 
{
	if ((c.flags & FL_CLIENT) == 0 || (c.creepflags & CF_NOSHOWREC))
	{
		return;
	}
	if (c.creepflags & CF_DOINGLONGMESSAGE)
	{
		return;
	}
	centerprint(c, string_null);
};

void(string s) CC_StuffToAllCams = 
{
	local entity c;
	c = world;
	while (c = find(c, classname, "camera"))  // this ought to flag as a compile warning, but I believe its ok?
	{
		stuffcmd(c, s);
	}
};

void() CC_BlinkThink = 
{
	local entity l;
	l = playerlist;
	while (l != world)
	{
		if (l.clink != world)
		{
			CC_ShowRec(l);
		}
		l = l.tless;
	}
	if (blinkstate)
	{
		CC_ClearCamNamesForAll();
	}
	blinkstate = 1 - blinkstate;
	self.nextthink = time + 1;
	if (time > scoreshowtime)
	{
		if (showflag)
		{
			CC_StuffToAllCams("+showscores\n");
//SJB reduced showscores time to 4 seconds
         scoreshowtime = time + 4;
		}
		else
		{
			CC_StuffToAllCams("-showscores\n");
         scoreshowtime = time + 116;
		}
		showflag = !showflag;
	}
};

void() CC_SpawnBlinker = 
{
	local entity e;
	e = spawn();
	e.think = CC_BlinkThink;
	e.nextthink = time + 1;
};

void(entity e) CC_ToggleShowRec = 
{
	if (e.creepflags & CF_NOSHOWREC)
	{
		sprint(e, "rec ã display ENABLED\n");
		e.creepflags = e.creepflags - CF_NOSHOWREC;
		if (e.camtype < 0 && e.clink != world)
		{
			CC_ShowRec(e);
		}
	}
	else
	{
		sprint(e, "rec ã display DISABLED\n");
		if (e.camtype < 0 && e.clink != world)
		{
			CC_StopBlink(e);
		}
		e.creepflags = e.creepflags + CF_NOSHOWREC;
	}
};

void(entity e) CC_ToggleAutoSwitch = 
{
	if (e.creepflags & CF_NOAUTOSWITCH)
	{
		sprint(e, "Camera autoswitch ENABLED\n");
		e.creepflags = e.creepflags - CF_NOAUTOSWITCH;
	}
	else
	{
		sprint(e, "Camera autoswitch DISABLED\n");
		e.creepflags = e.creepflags + CF_NOAUTOSWITCH;
	}
};

void(entity l) CC_WriteCameraList = 
{
	if (l)
	{
		sprint(self, l.netname);
		l = l.clink;
	}
	while (l)
	{
		sprint(self, ", ");
		sprint(self, l.netname);
		l = l.clink;
	}
	sprint(self, "\n");
};

void() CC_WhosFilmingMe = 
{
	if (self.camtype < 0)
	{
		if (!(self.clink))
		{
			sprint(self, "Nobody is watching you.\n");
		}
		else
		{
			sprint(self, "ç People watching you: ");
			CC_WriteCameraList(self.clink);
		}
	}
	if (self.camtype > 0)
	{
		if (!(self.owner))
		{
			sprint(self, "You're not watching anyone.\n");
		}
		else
		{
			sprint(self, "ç Watching ");
			sprint(self, self.owner.netname);
			sprint(self, ": ");
			CC_WriteCameraList(self.owner.clink);
		}
	}
};

void() CC_WritePlayerList = 
{
	local entity p;
	local string s;
	sprint(self, "ç List of all players:\n");
	if (!playerlist)
	{
		sprint(self, "None!\n");
	}
	else
	{
		p = playerlist;
		while (p != world)
		{
			sprint(self, p.netname);
			sprint(self, " (");
			s = ftos(p.colormap);
			sprint(self, s);
			sprint(self, ")\n");
			p = p.tless;
		}
	}
};

void() CC_WhosFilmingWho = 
{
	local entity p;
	local string s;
	if (c_count == 0)
	{
		sprint(self, "Nobody is in spectator mode.\nThe maximum is ");
		s = ftos(c_max);
		sprint(self, s);
		sprint(self, ".\n");
	}
	else
	{
		sprint(self, "ç List of all spectators:\n");
		p = playerlist;
		while (p != world)
		{
			if (p.clink != world)
			{
				sprint(self, "Watching ");
				sprint(self, p.netname);
				sprint(self, ": ");
				CC_WriteCameraList(p.clink);
			}
			p = p.tless;
		}
		if (freecamlist != world)
		{
			sprint(self, "Not watching anyone: ");
			CC_WriteCameraList(freecamlist);
		}
		sprint(self, "Total ");
		s = ftos(c_count);
		sprint(self, s);
		sprint(self, " spectator(s) out of ");
		s = ftos(c_max);
		sprint(self, s);
		sprint(self, " maximum.\n");
	}
};

entity(float targ) CC_GetPlayerIndexedBy = 
{
	local entity l;
	l = playerlist;
	while (l)
	{
		if (l.colormap == targ)
		{
			return l;
		}
		l = l.tless;
	}
	return world;
};

void() CC_PlayerImpulses = 
{
	if (self.impulse == 100)
	{
		CC_RequestCam();
	}
//SJB new impulses
   if (self.impulse == 102)
   {
      CC_ToggleRespawnMode();
   }
   if (self.impulse == 105)
   {
      CC_SetPlayerReady();
   }
   if (self.impulse == 106)
   {
      CC_SetPlayerNotReady();
   }
   if (self.impulse == 107)
   {
      CC_RemoveQuad();
   }
   if (self.impulse == 108)
   {
      CC_RemovePent();
   }
   if (self.impulse == 109)
   {
      CC_RemoveRing();
   }
   if (self.impulse == 119)
   {
      CC_WriteHelpInfo2(self);
   }
//SJB end of new impulses
	if (self.impulse == 120)
	{
		CC_WriteHelpInfo(self);
	}
	if (self.impulse == 121)
	{
		CC_ToggleShowRec(self);
	}
	if (self.impulse == 122)
	{
		CC_ToggleAutoSwitch(self);
	}
	if (self.impulse == FAST_TURN_RATE)
	{
		CC_WhosFilmingMe();
	}
	if (self.impulse == 151)
	{
		CC_WhosFilmingWho();
	}
	if (self.impulse == 152)
	{
		CC_WritePlayerList();
	}
};

