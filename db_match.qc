/*
	Match funtions subs that are used during a match

   Writen By Michael Billing, some mods by Simon Byrnand :)
*/

//	This function updates a players stats....

void(entity e, float frag_db, float kill_db, float suicide_db, float death_db) UpdateMatchStats =
{

	e.db_kills = e.db_kills + kill_db;
	e.db_suicides = e.db_suicides + suicide_db;
	e.db_deaths = e.db_deaths + death_db;

// numplayers

};


// This function Prints Match Stats to the screen

void() PrintMatchStats =
{
	local entity e;

	bprint("\n€ƒƒ‚\n");
   bprint("\n ÄiMeÂ’XŸ CreepCam player results.\n\n");

   bprint("Frag Kill Suic Deth ");
	if(teamplay)
		bprint("TM  ");
	bprint("Player");
	bprint("\nşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşş\n");

	e = find(world,classname,"player");
	while (e != world)
	{
		PrintStats(e);
		e = find(e,classname,"player");
	}
//	bprint("ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß\n"); // Print a whole lot of "-"'s
	bprint("Ÿ\n");
	if(teamplay)
		PrintTeamStats();
	bprint("\n€ƒƒ‚\n");

};

// This fuction prints the team scores

void() PrintTeamStats =
{
	local entity t, p, team_db;
	local string pcolour;
	local float tflag;
	

// add the players scores to the team scores...
	p = find(p, classname, "player");
	while(p != world)
	{
		tflag = 0;
		t = find(t, classname, "db_team");
		while(t != world)
		{
			if(p.team == t.team) // team found
			{
				tflag = 1;
				team_db = t;
			}
			t = find(t, classname, "db_team");
		}
		if(tflag == 1)
			AddToTeamScore(team_db, p);
		else
		{
			team_db = spawn();
			team_db.classname = "db_team";
			team_db.team = p.team;
			pcolour = find_pants(p.team);
			team_db.netname = pcolour;
			team_db.num_players = 0;
			team_db.frags = 0;
			team_db.db_suicides = 0;
			team_db.db_deaths = 0;

			AddToTeamScore(team_db, p);
		}
		p = find(p, classname, "player");
	}

	bprint("\n");
	bprint(" ÄiMeÂ’XŸ CreepCam team results.\n\n");
	bprint("Frag Kill Suic Deth TM  Name");
	bprint("\nşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşş\n");

	t = find(t, classname, "db_team");
	while(t != world)
	{
		PrintStats(t);
		t = find(t, classname, "db_team");
	}
//	bprint("ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß\n"); // Print a whole lot of "-"'s
};

void (entity e) PrintStats =
{
	local string temp;
     	bprint_spaces(e.frags);
	temp = ftos(e.frags);
      bprint(temp);
     	bprint("ü");
      bprint_spaces(e.db_kills);
     	temp = ftos(e.db_kills);
	bprint(temp);
      bprint("ü");
	if(e.db_suicides < 100)
		bprint(" ");
     	if(e.db_suicides < 10)
		bprint(" ");
	temp = ftos(e.db_suicides);
	bprint(temp);
     	bprint("ü");
      bprint_spaces(e.db_deaths);
	temp = ftos(e.db_deaths);
	bprint(temp);
     	bprint("ü");
	if(teamplay)
	{
           	if(e.team < 10)
			bprint(" ");
		temp = ftos(e.team);
		bprint(temp);
		bprint("ü");
	}	
	bprint(e.netname);
	bprint("\n");
};

// this function adds players scores to the team scores
void (entity team_db, entity p) AddToTeamScore =
{
	team_db.num_players = team_db.num_players + 1;
	team_db.frags = team_db.frags + p.frags;
	team_db.db_kills = team_db.db_kills + p.db_kills;
	team_db.db_suicides = team_db.db_suicides + p.db_suicides;
	team_db.db_deaths = team_db.db_deaths + p.db_deaths;
};



//SJB this function is passed a float and works out how many extra spaces
//to print ahead of that number to line up columns of 4

void(float value) bprint_spaces =
{
   if(value >= -99 && value <= -10) bprint(" ");
   else if(value >= -9 && value <= -1) bprint ("  ");
   else if(value >= 0 && value <= 9) bprint ("   ");
   else if(value >= 10 && value <= 99) bprint("  ");
   else if(value >= 100 && value <= 999) bprint(" ");
};

string(float pteam) find_pants =
{
   local string pcolour;
//remember team variable is 1 higher than pants colour

   if(pteam == 1)
      pcolour = "white";
   else if(pteam == 2)
      pcolour = "brown";
   else if(pteam == 3)
      pcolour = "light blue";
   else if(pteam == 4)
      pcolour = "green";
   else if(pteam == 5)
      pcolour = "red";
   else if(pteam == 6)
      pcolour = "orange";
   else if(pteam == 7)
      pcolour = "pink";
   else if(pteam == 8)
      pcolour = "peach";
   else if(pteam == 9)
      pcolour = "lavender";
   else if(pteam == 10)
      pcolour = "purple";
   else if(pteam == 11)
      pcolour = "grey";
   else if(pteam == 12)
      pcolour = "aqua";
   else if(pteam == 13)
      pcolour = "yellow";
   else if(pteam == 14)
      pcolour = "blue";
   else
      pcolour = "invalid colour";

   return(pcolour);
};

//SJB we spawn an entity here to do the dirty work because we want our code
//to run under a non-player context...otherwise when that player gets
//disconnected or disconnects manually our code is aborted before finished

void() SpawnMatchOver =
{
   local entity e;

   e = spawn();
   e.classname = "match_over";
   e.think = MatchOver1;
   //display the intermission scoreboard longer for more players
   e.nextthink = time + (numplayers / 2) + 0.1;
};

void() MatchOver1 =
{
   local entity e;

   e = find(world,classname,"player");
   while(e != world)
   {
      if(e.flags & FL_CLIENT)
         stuffcmd(e,"toggleconsole\n");
      e = find(e,classname,"player");
   }

   e = find(world,classname,"camera");
   while(e != world)
   {
      if(e.flags & FL_CLIENT)
         stuffcmd(e,"toggleconsole\n");
      e = find(e,classname,"camera");
   }

	PrintMatchStats(); // Print the match stats
   
   bprint("\nÍáôãè Ïöåò\n"); //  Print "Match Over"

   self.think = MatchOver2;
   self.nextthink = time + 2;

};

void() MatchOver2 =
{
   local entity e,el;

	e = find(world,classname,"player");
   while (e != world)
	{
		if(e.flags & FL_CLIENT)
		{
         if(e.colormap != 1)
         {
            stuffcmd(e, "disconnect\n"); // Disconnect all the clients
         }
         else
            el = e;
		}
		e = find(e,classname,"player");
	}

   e = find(world,classname,"camera");
   while (e != world)
	{
		if(e.flags & FL_CLIENT)
		{
         if(e.colormap != 1)
         {
            stuffcmd(e, "disconnect\n"); // Disconnect all the clients
         }
         else
            el = e;
		}
      e = find(e,classname,"camera");
	}

//SJB the idea behind this is to make sure to stuff the disconnect command to
//the player on a listen server LAST, otherwise the server will be shutdown
//before disconnects are sent to other clients
   if(el)
   {
      stuffcmd(el, "disconnect\n");
   }
   self.think = MatchOver3;
   self.nextthink = time + 2;
};

//SJB we need to do this in the case of a dedicated server, otherwise the
//server sits on the intermission screen forever
void() MatchOver3 =
{
   localcmd("restart\n");
};

