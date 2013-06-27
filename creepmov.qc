float PRED_TIME    = 1.000;
float DUAL_BLEND_RATE    = 2.000;
float CLIP_TIME    = 0.050;
float MAX_SLACK    = 340.000;
float VIEWING_PITCH    = 22.000;
float FAST_TURN_RATE    = 150.000;
float SLOW_TURN_RATE    = 50.000;
float AUTOSWITCH_DELAY    = 1.200;
float TRACE_TEST    = 240.000;
float TRACE_BUFFER    = 0.200;
float TRACE_MINIMUM    = 0.400;
float TRACE_RATE    = 0.400;
float TRACE_PAUSE    = 0.500;
float STAIR_BLEND_RATE    = 140.000;
float FILM_HI_LIP    = 15.000;
float FILM_LO_LIP    = -23.000;
float SVC_SETVIEWPORT    = 5.000;
float SVC_UPDATENAME    = 13.000;
float SVC_UPDATEFRAGS    = 14.000;
float SVC_UPDATECOLORS    = 17.000;
float TURNING_INTOVIEW    = 1.000;
float TILTING_INTOVIEW    = 2.000;
float DUAL_BLEND_INTOVIEW    = 4.000;
float VIEW_FIXED_POINT    = 8.000;
float FIRST_GUY_KILLED    = 16.000;
float SECOND_GUY_KILLED    = 32.000;
float EITHER_GUY_KILLED    = 48.000;
float FIND_DIFFERENT_GUY    = 64.000;
float CF_SENTALIASES    = 1.000;
float CF_SENTMOTD    = 2.000;
float CF_NOSHOWREC    = 4.000;
float CF_NOAUTOSWITCH    = 8.000;
float CF_DOINGLONGMESSAGE    = 256.000;
float CF_DECODEFLAGS    = 262144.000;
float CF_DECODESHIFT    = 1024.000;
float CF_STAYASCAM    = 512.000;
float CF_KEEPBETWEENLEVELS    = 255.000;
float SPAM_TIMEINTERVAL    = 3.000;
float SPAM_ACTIONLIMIT    = 10.000;
float c_max /* = 0.000 */;
float c_count /* = 0.000 */;
entity playerlist;
entity freecamlist;
.entity clink;
.entity tless;
.float camtype;
.vector filmpos;
.vector predpos;
.float filmlip;
.float creepflags;
.vector slack1;
.vector slack2;
.vector cangles;
.entity autoswitch;
.float spam_time;
.float spam_count;

void (entity targ, float pauselen, string msg) CC_LongMessage;
entity (float targ) CC_GetPlayerIndexedBy;

void (entity c) CC_ShowNameForAll;

void () CC_ClearCamNamesForAll;
float (float v) anglemod;

vector(vector delta, float watercam) CC_GetDualAngles = 
{
	delta = vectoangles(delta);
	if (watercam)
	{
		if (delta_x > 180)
		{
			delta_x = 360 - VIEWING_PITCH - (delta_x - 360) / FL_SWIM;
		}
		else
		{
			delta_x = 360 - VIEWING_PITCH - delta_x / MOVETYPE_WALK;
		}
	}
	else
	{
		if (delta_x > 180)
		{
			delta_x = VIEWING_PITCH - (delta_x - 360) / 2.5;
		}
		else
		{
			delta_x = VIEWING_PITCH - delta_x / FL_SWIM;
		}
	}
	if (delta_x < 0)
	{
		delta_x = delta_x + 360;
	}
	return (delta);
};

void(entity cam) CC_StartCamTransition = 
{
	local vector dualangles;
	if (cam.state != 0)
	{
		if (cam.style & VIEW_FIXED_POINT)
		{
			dualangles = CC_GetDualAngles(cam.movetarget.filmpos - cam.dest, cam.owner.waterlevel > 0);
		}
		else
		{
			dualangles = CC_GetDualAngles(cam.movetarget.filmpos - cam.owner.filmpos, cam.owner.waterlevel > 0);
		}
		dualangles_z = anglemod(cam.cangles_y - dualangles_y + 60);
		if (dualangles_z > 120)
		{
			cam.style = cam.style | TURNING_INTOVIEW;
		}
	}
	cam.predpos = cam.filmpos;
	cam.lefty = 0;
	cam.style = cam.style | DUAL_BLEND_INTOVIEW | TILTING_INTOVIEW;
};

void(entity cam, float goal) CC_ControlCamFocalLength = 
{
	local float frac;
	if (goal > TRACE_MINIMUM)
	{
		frac = goal - TRACE_BUFFER;
		if (frac < TRACE_MINIMUM)
		{
			goal = TRACE_MINIMUM;
		}
	}
	else
	{
		frac = goal;
	}
	if (frac > cam.light_lev)
	{
		if (frac < TRACE_MINIMUM)
		{
			cam.light_lev = cam.light_lev + TRACE_RATE * frametime;
			if (cam.light_lev > frac)
			{
				cam.light_lev = frac;
			}
		}
		else
		{
			if (cam.search_time == CONTENT_EMPTY)
			{
				cam.search_time = time + TRACE_PAUSE;
			}
			else
			{
				if (time >= cam.search_time || frac < TRACE_MINIMUM)
				{
					cam.light_lev = cam.light_lev + TRACE_RATE * frametime;
					if (cam.light_lev > frac)
					{
						cam.light_lev = frac;
					}
				}
			}
		}
	}
	else
	{
		cam.search_time = CONTENT_EMPTY;
		if (frac < cam.light_lev)
		{
			cam.light_lev = cam.light_lev - TRACE_RATE * frametime;
			if (cam.light_lev > goal)
			{
				cam.light_lev = goal;
			}
			else
			{
				if (cam.light_lev < frac)
				{
					cam.light_lev = frac;
				}
			}
		}
	}
};

float(entity guy, entity rel) CC_InterestLevel = 
{
	local float lev;
	lev = 0;
	if (guy.classname == "player")
	{
		lev = lev + FL_NOTARGET;
	}
	if (guy.team != rel.team)
	{
		if (teamplay != 0)
		{
			lev = lev + FL_GODMODE;
		}
	}
	if (guy.items & IT_ROCKET_LAUNCHER && guy.ammo_rockets > FL_SWIM)
	{
		lev = lev + FL_MONSTER;
	}
	return lev;
};

void(entity cam) CC_CheckForBetterTarget = 
{
	local entity targ1;
	local entity targ2;
	local float tangle;
	local float worthit;
	local entity prevguy;
	local float lev1;
	local float lev2;
	if (cam.style & EITHER_GUY_KILLED)
	{
		return;
	}
	if (!playerlist)
	{
		return;
	}
	targ1 = cam.owner;
	targ2 = cam.oldenemy;
	if (targ2.camtype >= 0 || !targ2)
	{
		cam.oldenemy = world;
		targ2 = world;
	}
	while (1)
	{
		if (!targ2)
		{
			targ2 = playerlist;
		}
		else
		{
			targ2 = targ2.tless;
			if (!targ2)
			{
				if (cam.oldenemy)
				{
					cam.oldenemy = world;
					targ2 = playerlist;
				}
				else
				{
					return;
				}
			}
		}
		worthit = targ2 != targ1 && targ2.deadflag == DEAD_NO;
		if (worthit)
		{
			worthit = !(cam.state == FL_SWIM && cam.movetarget == targ2);
			if (worthit)
			{
				if (cam.style & FIND_DIFFERENT_GUY && cam.autoswitch == targ2)
				{
					worthit = 0;
					cam.style = cam.style - FIND_DIFFERENT_GUY;
					cam.autoswitch = world;
				}
			}
		}
		if (worthit)
		{
			cam.oldenemy = targ2;
			if (cam.state == 0)
			{
				traceline(targ1.predpos, targ2.predpos, 1, targ1);
				if (!trace_startsolid && trace_endpos == targ2.predpos)
				{
					cam.movetarget = targ2;
					cam.state = 1;
					cam.slack1 = targ1.predpos;
					cam.slack2 = targ2.predpos;
					CC_StartCamTransition(cam);
				}
			}
			else
			{
				traceline(targ1.filmpos, targ2.filmpos, 1, targ1);
				if (!trace_startsolid && trace_endpos == targ2.filmpos)
				{
					prevguy = cam.movetarget;
					if (prevguy == targ2)
					{
						cam.state = FL_SWIM;
					}
					else
					{
						lev1 = CC_InterestLevel(targ2, targ1);
						lev2 = CC_InterestLevel(prevguy, targ1);
						if (lev1 > lev2)
						{
							cam.state = FL_SWIM;
							cam.movetarget = targ2;
							CC_StartCamTransition(cam);
						}
					}
				}
			}
			return;
		}
	}
};

void(entity cam) CC_MoveSingleCamera = 
{
	local vector newvec;
	local float tangle;
	local float dangle;
	local float frac;
	newvec = cam.owner.velocity;
	newvec_z = 0;
	tangle = vectoyaw(newvec);
	dangle = anglemod(tangle - cam.cangles_y);
	frac = vlen(newvec) / 320;
	if (frac > 0.1 && (cam.style & VIEW_FIXED_POINT) == 0)
	{
		if (dangle < 180)
		{
			if (dangle > FILM_HI_LIP)
			{
				if (dangle < SLOW_TURN_RATE || (cam.style & DUAL_BLEND_INTOVIEW))
				{
					dangle = dangle - frametime * frac * SLOW_TURN_RATE;
				}
				else
				{
					dangle = dangle - frametime * frac * FAST_TURN_RATE;
				}
				if (dangle < FILM_HI_LIP)
				{
					dangle = FILM_HI_LIP;
				}
			}
		}
		else
		{
			if (dangle < 345)
			{
				if (dangle > 310 || (cam.style & DUAL_BLEND_INTOVIEW))
				{
					dangle = dangle + frametime * frac * SLOW_TURN_RATE;
				}
				else
				{
					dangle = dangle + frametime * frac * FAST_TURN_RATE;
				}
				if (dangle > 345)
				{
					dangle = 345;
				}
			}
		}
		cam.cangles_y = anglemod(tangle - dangle);
	}
	if (cam.owner.waterlevel >= MOVETYPE_WALK)
	{
		tangle = 0 - VIEWING_PITCH;
	}
	else
	{
		tangle = VIEWING_PITCH;
	}
	if ((cam.style & TILTING_INTOVIEW) == 0)
	{
		cam.cangles_x = tangle;
	}
	else
	{
		dangle = anglemod(cam.cangles_x - tangle);
		if (dangle < 180)
		{
			dangle = dangle - SLOW_TURN_RATE * frametime;
			if (dangle <= 0)
			{
				dangle = 0;
				cam.style = cam.style - TILTING_INTOVIEW;
			}
		}
		else
		{
			dangle = dangle + SLOW_TURN_RATE * frametime;
			if (dangle >= 360)
			{
				dangle = 0;
				cam.style = cam.style - TILTING_INTOVIEW;
			}
		}
		cam.cangles_x = anglemod(tangle + dangle);
	}
	cam.cangles_z = 0;
	makevectors(cam.cangles);
	if (cam.style & DUAL_BLEND_INTOVIEW)
	{
		cam.lefty = cam.lefty + DUAL_BLEND_RATE * frametime;
		if (cam.lefty > 1)
		{
			cam.lefty = 1;
			cam.style = cam.style - DUAL_BLEND_INTOVIEW;
		}
		cam.filmpos_x = cam.lefty * v_forward_x + (1 - cam.lefty) * cam.predpos_x;
		cam.filmpos_y = cam.lefty * v_forward_y + (1 - cam.lefty) * cam.predpos_y;
		cam.filmpos_z = cam.lefty * v_forward_z + (1 - cam.lefty) * cam.predpos_z;
		cam.v_angle = vectoangles(cam.filmpos);
		cam.v_angle_x = 0 - cam.v_angle_x;
	}
	else
	{
		cam.filmpos = v_forward;
		cam.v_angle = cam.cangles;
	}
	if (cam.style & VIEW_FIXED_POINT)
	{
		newvec = cam.dest;
	}
	else
	{
		newvec = cam.owner.filmpos;
	}
	traceline(newvec, newvec - v_forward * TRACE_TEST, 1, cam);
	CC_ControlCamFocalLength(cam, trace_fraction);
	setorigin(cam, newvec - v_forward * (TRACE_TEST * cam.light_lev - 2.5));
	cam.angles = cam.v_angle;
   cam.fixangle = 1;
};

void(entity cam) CC_UpdateDualCamState = 
{
	local entity targ1;
	local entity targ2;
	if (cam.state == FL_SWIM)
	{
		targ2 = cam.movetarget;
		if (targ2.camtype >= 0)
		{
			cam.style = cam.style - (cam.style & SECOND_GUY_KILLED);
			cam.state = 0;
			CC_StartCamTransition(cam);
		}
		else
		{
			targ1 = cam.owner;
			traceline(targ1.filmpos, targ2.filmpos, 1, targ1);
			if (trace_startsolid || trace_endpos != targ2.filmpos)
			{
				cam.state = 1;
			}
			else
			{
				cam.slack1 = targ1.filmpos;
				cam.slack2 = targ2.filmpos;
			}
		}
	}
	if (cam.state == 1)
	{
		if (vlen(cam.owner.filmpos - cam.slack1) > MAX_SLACK || vlen(cam.movetarget.filmpos - cam.slack2) > MAX_SLACK)
		{
			cam.state = 0;
			CC_StartCamTransition(cam);
		}
	}
};

void(entity cam) CC_MoveDualCamera = 
{
	local vector newvec;
	local vector dualangles;
	local float tangle;
	local float dangle;
	local float frac;
	local vector v1;
	local vector v2;
	local float vl1;
	local float vl2;
	local vector vnet;
	if (cam.style & VIEW_FIXED_POINT)
	{
		dualangles = CC_GetDualAngles(cam.movetarget.filmpos - cam.dest, cam.owner.waterlevel > 0);
	}
	else
	{
		dualangles = CC_GetDualAngles(cam.movetarget.filmpos - cam.owner.filmpos, cam.owner.waterlevel > 0);
	}
	if ((cam.style & TURNING_INTOVIEW) == 0)
	{
		newvec = cam.owner.velocity;
		newvec_z = 0;
		tangle = vectoyaw(newvec);
		dangle = anglemod(tangle - cam.cangles_y);
		frac = vlen(newvec) / 400;
		if (frac > 0.1 && (cam.style & VIEW_FIXED_POINT) == 0)
		{
			if (dangle < 180)
			{
				if (dangle > FILM_HI_LIP)
				{
					dangle = dangle - frametime * frac * FAST_TURN_RATE;
					if (dangle < FILM_HI_LIP)
					{
						dangle = FILM_HI_LIP;
					}
				}
			}
			else
			{
				if (dangle < 345)
				{
					dangle = dangle + frametime * frac * FAST_TURN_RATE;
					if (dangle > 345)
					{
						dangle = 345;
					}
				}
			}
			cam.cangles_y = anglemod(tangle - dangle);
		}
		if (anglemod(cam.cangles_y - dualangles_y + 60) > 120)
		{
			if (anglemod(cam.cangles_y - dualangles_y) < 180)
			{
				cam.cangles_y = anglemod(dualangles_y + 60);
			}
			else
			{
				cam.cangles_y = anglemod(dualangles_y - 60);
			}
		}
	}
	else
	{
		dangle = anglemod(cam.cangles_y - dualangles_y);
		if (dangle < 180)
		{
			dangle = dangle - FAST_TURN_RATE * frametime;
			if (dangle <= 60)
			{
				dangle = 60;
				cam.style = cam.style - TURNING_INTOVIEW;
			}
		}
		else
		{
			dangle = dangle + FAST_TURN_RATE * frametime;
			if (dangle >= 300)
			{
				dangle = 300;
				cam.style = cam.style - TURNING_INTOVIEW;
			}
		}
		cam.cangles_y = anglemod(dualangles_y + dangle);
	}
	if ((cam.style & TILTING_INTOVIEW) == 0)
	{
		cam.cangles_x = dualangles_x;
	}
	else
	{
		dangle = anglemod(cam.cangles_x - dualangles_x);
		if (dangle < 180)
		{
			dangle = dangle - FAST_TURN_RATE * frametime;
			if (dangle <= 0)
			{
				dangle = 0;
				cam.style = cam.style - TILTING_INTOVIEW;
			}
		}
		else
		{
			dangle = dangle + FAST_TURN_RATE * frametime;
			if (dangle >= 360)
			{
				dangle = 0;
				cam.style = cam.style - TILTING_INTOVIEW;
			}
		}
		cam.cangles_x = anglemod(dualangles_x + dangle);
	}
	cam.cangles_z = 0;
	makevectors(cam.cangles);
	if (cam.style & VIEW_FIXED_POINT)
	{
		newvec = cam.dest;
	}
	else
	{
		newvec = cam.owner.filmpos;
	}
	traceline(newvec, newvec - TRACE_TEST * v_forward, 1, cam);
	CC_ControlCamFocalLength(cam, trace_fraction);
	setorigin(cam, newvec - v_forward * (TRACE_TEST * cam.light_lev - 2.5));
	v1 = newvec - cam.origin;
	v2 = cam.movetarget.filmpos - cam.origin;
	vl1 = vlen(v1);
	vl2 = vlen(v2);
	vnet_x = v1_x / vl1 + v2_x / vl2;
	vnet_y = v1_y / vl1 + v2_y / vl2;
	vnet_z = v1_z / vl1 + v2_z / vl2;
	if (cam.style & DUAL_BLEND_INTOVIEW)
	{
		cam.lefty = cam.lefty + DUAL_BLEND_RATE * frametime;
		if (cam.lefty > 1)
		{
			cam.lefty = 1;
			cam.style = cam.style - DUAL_BLEND_INTOVIEW;
		}
		vnet_x = cam.lefty * vnet_x + (1 - cam.lefty) * cam.predpos_x;
		vnet_y = cam.lefty * vnet_y + (1 - cam.lefty) * cam.predpos_y;
		vnet_z = cam.lefty * vnet_z + (1 - cam.lefty) * cam.predpos_z;
	}
	cam.filmpos = vnet;
	cam.v_angle = vectoangles(vnet);
	cam.v_angle_x = 0 - cam.v_angle_x;
	cam.angles = cam.v_angle;
	cam.fixangle = 1;
};

void(entity cam) CC_DoCamAlgorithm = 
{
	local entity l;
	CC_UpdateDualCamState(cam);
	CC_CheckForBetterTarget(cam);
	if (cam.state == 0)
	{
		CC_MoveSingleCamera(cam);
	}
	else
	{
		CC_MoveDualCamera(cam);
	}
};

