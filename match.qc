//SJB This file containts most of the new match related features

void() CC_ToggleRespawnMode =
{
   if(self.classname == "player")
   {
      if(matchmode == 1)
      {
         if(standardspawn)
         {
            standardspawn = FALSE;
            bprint(self.netname);
            bprint(" has changed respawning to random.\n");
         }
         else
         {
            standardspawn = TRUE;
            bprint(self.netname);
            bprint(" has changed respawning to ordered.\n");
         }
      }
      else
         sprint(self,"you can only change the respawn type during pre-match setup\n");
   }
   else
      sprint(self,"spectators cannot use this command!\n");
};

void() CC_SetPlayerReady =
{
   local float rnd;
   local string pcolour;
   if(self.classname != "player")
      sprint(self,"spectators cannot use this command!\n");
   else
   {
      if(matchmode != 1)
         sprint(self,"you can only use the ready command in pre-match setup\n");
      else
      {
         if(self.ready)
            sprint(self,"you are already ready!\n");
         else
         {
            if(cvar("timelimit") > 0)
            {
               self.ready = TRUE;
               numready = numready + 1;
               if(teamplay)
               {
                  rnd = 1 + floor(random() * 13);
                  //before 'player'
                  if(rnd == 10)
                     bprint("for some reason ");
                  if(rnd == 11)
                     bprint("the opposition are glad ");

                  bprint(self.netname);
                  //between 'player' and 'team'
                  if(rnd == 1)
                     bprint(" sells his soul to ");
                  if(rnd == 2)
                     bprint(" ignores his mum's advice and joins ");
                  if(rnd == 3)
                     bprint(" swaps war stories with ");
                  if(rnd == 4)
                     bprint(" signs a contract in blood with ");
                  if(rnd == 5)
                     bprint(" sucks up to ");
                  if(rnd == 6)
                     bprint(" declares his allegiance to ");
                  if(rnd == 7)
                     bprint(" shares a cigarette with ");
                  if(rnd == 8)
                     bprint(" thinks he's the man for ");
                  if(rnd == 9)
                     bprint(" is accidently assigned to ");
                  if(rnd == 10)
                     bprint(" chose ");
                  if(rnd == 11)
                     bprint(" joined ");
                  if(rnd == 12)
                     bprint(" thinks being in ");
                  if(rnd == 13)
                     bprint(" blackmails his way into ");

                  pcolour = find_pants(self.team);
                  bprint(pcolour);
                  //after team colour
                  if(rnd == 12)
                     bprint(" team will make him a celeb\n");
                  else
                     bprint(" team\n");

               }
               else
               {
                  rnd = 1 + floor(random() * 9);
                  bprint(self.netname);
                  if(rnd == 1)
                     bprint(" can smell the blood already\n");
                  if(rnd == 2)
                     bprint(" checks his ammo one last time\n");
                  if(rnd == 3)
                     bprint(" is ready to spill his enemies guts\n");
                  if(rnd == 4)
                     bprint(" wants to take over the world\n");
                  if(rnd == 5)
                     bprint(" is gonna gib until it hurts\n");
                  if(rnd == 6)
                     bprint(" is gonna spread his disease\n");
                  if(rnd == 7)
                     bprint(" has a gun and is not afraid to use it\n");
                  if(rnd == 8)
                     bprint(" waves goodbye to mummy\n");
                  if(rnd == 9)
                     bprint(" knows the chicks dig him\n");

               }
               if(numready == numplayers)
               {
                  CC_StartCountDown();
               }
               else
                  play_sound("doors/runetry.wav");
               
            } else
               sprint(self,"a timelimit must be set before players can become ready\n");
         }
      }
   }
};

void() CC_SetPlayerNotReady =
{
   local float rnd;
   local string tempstring;
   local entity e;
   if(self.classname != "player")
      sprint(self,"spectators cannot use this command!\n");
   else
   {
      if(matchmode != 1 && matchmode != 2)
      {
         sprint(self,"notready only works in pre-match setup or countdown\n");
      }
      else
      {
         if(!self.ready)
         {
            sprint(self,"you are not ready!\n");
         }
         else
         {
            self.ready = FALSE;
            numready = numready - 1;

            bprint(self.netname);
            if(teamplay)
            {
               rnd = 1 + floor(random() * 7);
               if(rnd == 1)
                  bprint(" deserts his teammates\n");
               if(rnd == 2)
                  bprint(" wants to be in a decent team\n");
               if(rnd == 3)
                  bprint(" feels outclassed by his mates\n");
               if(rnd == 4)
                  bprint(" is the odd one out\n");
               if(rnd == 5)
                  bprint(" doesn't trust his teammates\n");
               if(rnd == 6)
                  bprint(" feels rejected by his teammates\n");
               if(rnd == 7)
                  bprint(" doesn't believe in commitment\n");
            }
            else
            {
               rnd = 1 + floor(random() * 18);
               if(rnd == 1)
                  bprint(" stops to change his diapers\n");
               if(rnd == 2)
                  bprint(" forgot to kiss his mummy goodbye\n");
               if(rnd == 3)
                  bprint(" thinks he's too good for this game\n");
               if(rnd == 4)
                  bprint(" is going to take a quick leak\n");
               if(rnd == 5)
                  bprint(" is having doubts about his ability\n");
               if(rnd == 6)
                  bprint(" can't go through with this\n");
               if(rnd == 7)
                  bprint(" hasn't got his mind on the job\n");
               if(rnd == 8)
                  bprint(" forgot to wipe his feet at the door\n");
               if(rnd == 9)
                  bprint(" forgot to put change in the parking meter\n");
               if(rnd == 10)
                  bprint(" wants to play duke3d instead\n");
               if(rnd == 11)
                  bprint(" wants to play with his sister's dollhouse\n");
               if(rnd == 12)
                  bprint(" wants out now!\n");
               if(rnd == 13)
                  bprint(" lost his nerve\n");
               if(rnd == 14)
                  bprint(" needs a swig of whiskey first\n");
               if(rnd == 15)
                  bprint(" wants a shot of morphine\n");
               if(rnd == 16)
                  bprint(" needs to relieve himself first\n");
               if(rnd == 17)
                  bprint(" answers the call of nature\n");
               if(rnd == 18)
                  bprint(" left his axe at home\n");
            }
            e = find(world,classname,"countdown_timer");
            if(e)
            {
               matchmode = 1;
               SetMode1Items();
               bprint("countdown aborted\n");
               play_sound("shambler/sdeath.wav");
               remove(e);
            }
            else
               play_sound("knight/kdeath.wav");
         }
      }
   }
};

//called in matchmode 2 if a player exits the game
void() CC_SetAllNotReady =
{
   local entity e;

   e = find(world,classname,"player");
   while(e != world)
   {
      e.ready = FALSE;
      e = find(e,classname,"player");
   }
   numready = 0;
   e = find(world,classname,"countdown_timer");
   if(e)
   {
      matchmode = 1;
      SetMode1Items();
      bprint("countdown aborted\n");
      play_sound("shambler/sdeath.wav");
      remove(e);
   }
};

void() CC_RemoveQuad =
{
   local entity e;
   if(self.classname == "player")
   {
      if(matchmode == 1)
      {
      
         e = find(world,classname,"item_artifact_super_damage");
         while(e != world)
         {
            remove(e);
            e = find(e,classname,"item_artifact_super_damage");
         }
         bprint(self.netname);
         bprint(" has removed all quads\n");
      }
      else
         sprint(self,"you can only remove quads during pre-match setup\n");
   }
   else
      sprint(self,"spectators cannot use this command!\n");
};

void() CC_RemovePent =
{
   local entity e;
   if(self.classname == "player")
   {
      if(matchmode == 1)
      {
      
         e = find(world,classname,"item_artifact_invulnerability");
         while (e != world)
         {
            remove(e);
            e = find(e,classname,"item_artifact_invulnerability");
         }
         bprint(self.netname);
         bprint(" has removed all pentagrams\n");
      }
      else
         sprint(self,"you can only remove pentagrams during pre-match setup\n");
   }
   else
      sprint(self,"spectators cannot use this command!\n");
};

void() CC_RemoveRing =
{
   local entity e;
   if(self.classname == "player")
   {
      if(matchmode == 1)
      {
         e = find(world,classname,"item_artifact_invisibility");
         while (e != world)
         {
            remove(e);
            e = find(e,classname,"item_artifact_invisibility");
         }
         bprint(self.netname);
         bprint(" has removed all ring of shawdows\n");
      }
      else
         sprint(self,"you can only remove ring of shadows during pre-match setup\n");
   }
   else
      sprint(self,"spectators cannot use this command!\n");
};

void() CC_StartCountDown =
{
   local entity countdown;
   local string tempstring;
   play_sound("misc/medkey.wav");
   matchtimer = cvar("timelimit");
   tempstring = ftos(matchtimer);
   bprint(tempstring);
   bprint(" minute timelimit set. 60 second countdown has begun\n");
   matchmode = 2;
   SetMode2Items();
   countdown = spawn();
   countdown.classname = "countdown_timer";
   countdown.owner = world;
   countdown.think = countdown_think;
   countdown.nextthink = time + 1;
   countdown.attack_finished = time + 60;
};

void() countdown_think =
{
   local entity e;
   local string tempstring;
   local float timeleft;

   timeleft = floor(self.attack_finished - time);
   tempstring = ftos(timeleft);
   if(timeleft <= 10 && timeleft > 0)
      play_sound("buttons/switch02.wav");
   e = find(world,classname,"player");
   while(e != world)
   {
      if(e.flags | FL_CLIENT)
         centerprint(e,tempstring);
      e = find(e,classname,"player");
   }
   e = find(world,classname,"camera");
   while(e != world)
   {
      if(e.flags | FL_CLIENT)
         centerprint(e,tempstring);
      e = find(e,classname,"camera");
   }
   if(timeleft <= 0)
   {
      remove_projectiles();
      cvar_set("timelimit","0");
      matchmode = 3;
      bprint("match has started\n");
      e = find(world,classname,"player");
      while(e != world)
      {
         if(e.flags | FL_CLIENT)
         {
            T_Damage(e,self,self,50000);
         }
         e = find(e,classname,"player");
      }
      self.think = timer_think;
      self.nextthink = time + 60;
      self.attack_finished = time + matchtimer * 60;
      return;
   }

   self.nextthink = time + 1;

};

void() SetMode1Items =
{
   local entity e;

   e = find(world,classname,"player");
   while (e != world)
   {
      if(e.flags & FL_CLIENT)
      {
         e.items = IT_AXE;
         e.health = 100;
         e.armorvalue = 0;
         e.ammo_shells = 0;
         e.ammo_nails = 0;
         e.ammo_rockets = 0;
         e.ammo_cells = 0;
         e.weapon = IT_AXE;
         e.armortype = 0;
         stuffcmd(e,"impulse 1\n");

         e = find(e,classname,"player");
      }
   }
};

void() SetMode2Items =
{
   local entity e;

   e = find(world,classname,"player");
   while (e != world)
   {
      if(e.flags & FL_CLIENT)
      {
         e.items = IT_AXE | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING | IT_ARMOR3;
         e.health = 100;
         e.armorvalue = 200;
         e.ammo_shells = 100;
         e.ammo_nails = 200;
         e.ammo_rockets = 100;
         e.ammo_cells = 100;
         e.weapon = IT_ROCKET_LAUNCHER;
         e.armortype = 0.8;
         stuffcmd(e,"impulse 7\n");

         e = find(e,classname,"player");
      }
   }
};

void() timer_think =
{
   local string tempstring;
   local float minleft,secleft;

   secleft = floor(self.attack_finished - time);
   minleft = floor(secleft / 60);

   if(self.attack_finished > time)
   {
      if(self.attack_finished < time + 20)
      {
         tempstring = ftos(secleft);
         bprint("match ends in ");
         bprint(tempstring);
         if(secleft > 1)
            bprint(" seconds\n");
         else
            bprint(" second\n");
         play_sound("buttons/switch02.wav");
         self.nextthink = time + 1;
      }
      else
      {
         tempstring = ftos(minleft);
         bprint("match ends in ");
         bprint(tempstring);
         if(minleft > 1)
            bprint(" minutes\n");
         else
            bprint(" minute\n");
         if(minleft <= 1)
            self.nextthink = time + 50;
         else
            self.nextthink = time + 60;
      }
   }
   else
   {
      self.think = execute_changelevel;
      self.nextthink = time + 0.1;
   }
};

void() remove_projectiles =
{
   local entity e;

   e = find(world,classname,"missile");
   while(e != world)
   {
      remove(e);
      e = find(e,classname,"missile");
   }

   e = find(world,classname,"grenade");
   while(e != world)
   {
      remove(e);
      e = find(e,classname,"grenade");
   }

   e = find(world,classname,"spike");
   while(e != world)
   {
      remove(e);
      e = find(e,classname,"spike");
   }
};

void(string sname) play_sound =
{
   sound(world,CHAN_AUTO,sname,1,ATTN_NONE);
};

void() intro_message =
{
   local string tempstring;

   if(cvar("timelimit") == 0)
   {
      bprint("no timelimit was set.");
      cvar_set("timelimit","20");
   }
   else
   {
      tempstring = ftos(cvar("timelimit"));
      bprint("using ");
      bprint(tempstring);
      bprint(" minute timelimit.\n");
   }
};
