void () movetarget_f;

void () t_movetarget;

void () knight_walk1;

void () knight_bow6;

void () knight_bow1;
float current_yaw /* = 0.000 */;
entity sight_entity;
float sight_entity_time /* = 0.000 */;

float(float v) anglemod =
{
	while (v >= 360)
	{
		v = v - 360;
	}
	while (v < 0)
	{
		v = v + 360;
	}
	return v;
};

void() movetarget_f = 
{
	if (!(self.targetname))
	{
		objerror("monster_movetarget: no targetname");
	}
	self.solid = SOLID_TRIGGER;
	self.touch = t_movetarget;
	setsize(self, '-8 -8 -8', '8 8 8');
};

void() path_corner = 
{
	movetarget_f();
};

void() t_movetarget = 
{
	local entity temp;
	if (other.movetarget != self)
	{
		return;
	}
	if (other.enemy)
	{
		return;
	}
	temp = self;
	self = other;
	other = temp;
	if (self.classname == "monster_ogre")
	{
		sound(self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);
	}
	self.goalentity = self.movetarget = find(world, targetname, other.target);
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	if (!(self.movetarget))
	{
		self.pausetime = time + 999999;
		self.th_stand();
		return;
	}
};

float(entity targ) range = 
{
	local vector spot1;
	local vector spot2;
	local float r;
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	r = vlen(spot1 - spot2);
	if (r < 120)
	{
		return RANGE_MELEE;
	}
	if (r < 500)
	{
		return RANGE_NEAR;
	}
	if (r < 1000)
	{
		return RANGE_MID;
	}
	return RANGE_FAR;
};

float(entity targ) visible = 
{
	local vector spot1;
	local vector spot2;
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline(spot1, spot2, 1, self);
	if (trace_inopen && trace_inwater)
	{
		return 0;
	}
	if (trace_fraction == 1)
	{
		return 1;
	}
	return 0;
};

float(entity targ) infront = 
{
	local vector vec;
	local float dot;
	makevectors(self.angles);
	vec = normalize(targ.origin - self.origin);
	dot = vec * v_forward;
	if (dot > 0.3)
	{
		return 1;
	}
	return 0;
};

void() HuntTarget = 
{
	self.goalentity = self.enemy;
	self.think = self.th_run;
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.nextthink = time + 0.1;
	SUB_AttackFinished(1);
};

void() SightSound = 
{
	local float rsnd;
	if (self.classname == "monster_ogre")
	{
		sound(self, CHAN_VOICE, "ogre/ogwake.wav", 1, ATTN_NORM);
	}
	else
	{
		if (self.classname == "monster_knight")
		{
			sound(self, CHAN_VOICE, "knight/ksight.wav", 1, ATTN_NORM);
		}
		else
		{
			if (self.classname == "monster_shambler")
			{
				sound(self, CHAN_VOICE, "shambler/ssight.wav", 1, ATTN_NORM);
			}
			else
			{
				if (self.classname == "monster_demon1")
				{
					sound(self, CHAN_VOICE, "demon/sight2.wav", 1, ATTN_NORM);
				}
				else
				{
					if (self.classname == "monster_wizard")
					{
						sound(self, CHAN_VOICE, "wizard/wsight.wav", 1, ATTN_NORM);
					}
					else
					{
						if (self.classname == "monster_zombie")
						{
							sound(self, CHAN_VOICE, "zombie/z_idle.wav", 1, ATTN_NORM);
						}
						else
						{
							if (self.classname == "monster_dog")
							{
								sound(self, CHAN_VOICE, "dog/dsight.wav", 1, ATTN_NORM);
							}
							else
							{
								if (self.classname == "monster_hell_knight")
								{
									sound(self, CHAN_VOICE, "hknight/sight1.wav", 1, ATTN_NORM);
								}
								else
								{
									if (self.classname == "monster_tarbaby")
									{
										sound(self, CHAN_VOICE, "blob/sight1.wav", 1, ATTN_NORM);
									}
									else
									{
										if (self.classname == "monster_vomit")
										{
											sound(self, CHAN_VOICE, "vomitus/v_sight1.wav", 1, ATTN_NORM);
										}
										else
										{
											if (self.classname == "monster_enforcer")
											{
												rsnd = rint(random() * MOVETYPE_WALK);
												if (rsnd == 1)
												{
													sound(self, CHAN_VOICE, "enforcer/sight1.wav", 1, ATTN_NORM);
												}
												else
												{
													if (rsnd == FL_SWIM)
													{
														sound(self, CHAN_VOICE, "enforcer/sight2.wav", 1, ATTN_NORM);
													}
													else
													{
														if (rsnd == 0)
														{
															sound(self, CHAN_VOICE, "enforcer/sight3.wav", 1, ATTN_NORM);
														}
														else
														{
															sound(self, CHAN_VOICE, "enforcer/sight4.wav", 1, ATTN_NORM);
														}
													}
												}
											}
											else
											{
												if (self.classname == "monster_army")
												{
													sound(self, CHAN_VOICE, "soldier/sight1.wav", 1, ATTN_NORM);
												}
												else
												{
													if (self.classname == "monster_shalrath")
													{
														sound(self, CHAN_VOICE, "shalrath/sight.wav", 1, ATTN_NORM);
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
};

void() FoundTarget = 
{
	if (self.enemy.classname == "player")
	{
		sight_entity = self;
		sight_entity_time = time;
	}
	self.show_hostile = time + 1;
	SightSound();
	HuntTarget();
};

float() FindTarget = 
{
	local entity client;
	local float r;
	if (sight_entity_time >= time - 0.1 && !(self.spawnflags & MOVETYPE_WALK))
	{
		client = sight_entity;
		if (client.enemy == self.enemy)
		{
			return 0;
		}
	}
	else
	{
		client = checkclient();
		if (!client)
		{
			return 0;
		}
	}
	if (client == self.enemy)
	{
		return 0;
	}
	if (client.flags & FL_NOTARGET)
	{
		return 0;
	}
	if (client.items & IT_INVISIBILITY)
	{
		return 0;
	}
	r = range(client);
	if (r == RANGE_FAR)
	{
		return 0;
	}
	if (!visible(client))
	{
		return 0;
	}
	if (r == RANGE_NEAR)
	{
		if (client.show_hostile < time && !infront(client))
		{
			return 0;
		}
	}
	else
	{
		if (r == RANGE_MID)
		{
			if (!infront(client))
			{
				return 0;
			}
		}
	}
	self.enemy = client;
	if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return 0;
		}
	}
	FoundTarget();
	return 1;
};

void(float dist) ai_forward = 
{
	walkmove(self.angles_y, dist);
};

void(float dist) ai_back = 
{
	walkmove(self.angles_y + 180, dist);
};

void(float dist) ai_pain = 
{
	ai_back(dist);
};

void(float dist) ai_painforward = 
{
	walkmove(self.ideal_yaw, dist);
};

void(float dist) ai_walk = 
{
	local vector mtemp;
	movedist = dist;
	if (self.classname == "monster_dragon")
	{
		movetogoal(dist);
		return;
	}
	if (FindTarget())
	{
		return;
	}
	movetogoal(dist);
};

void() ai_stand = 
{
	if (FindTarget())
	{
		return;
	}
	if (time > self.pausetime)
	{
		self.th_walk();
		return;
	}
};

void() ai_turn = 
{
	if (FindTarget())
	{
		return;
	}
	ChangeYaw();
};

void(vector dest3) ChooseTurn = 
{
	local vector dir;
	local vector newdir;
	dir = self.origin - dest3;
	newdir_x = trace_plane_normal_y;
	newdir_y = 0 - trace_plane_normal_x;
	newdir_z = 0;
	if (dir * newdir > 0)
	{
		dir_x = 0 - trace_plane_normal_y;
		dir_y = trace_plane_normal_x;
	}
	else
	{
		dir_x = trace_plane_normal_y;
		dir_y = 0 - trace_plane_normal_x;
	}
	dir_z = 0;
	self.ideal_yaw = vectoyaw(dir);
};

float() FacingIdeal = 
{
	local float delta;
	delta = anglemod(self.angles_y - self.ideal_yaw);
	if (delta > 45 && delta < 315)
	{
		return 0;
	}
	return 1;
};

float () WizardCheckAttack;
float () DogCheckAttack;

float() CheckAnyAttack = 
{
	if (!enemy_vis)
	{
		return 0;
	}
	if (self.classname == "monster_army")
	{
		return SoldierCheckAttack();
	}
	if (self.classname == "monster_ogre")
	{
		return OgreCheckAttack();
	}
	if (self.classname == "monster_shambler")
	{
		return ShamCheckAttack();
	}
	if (self.classname == "monster_demon1")
	{
		return DemonCheckAttack();
	}
	if (self.classname == "monster_dog")
	{
		return DogCheckAttack();
	}
	if (self.classname == "monster_wizard")
	{
		return WizardCheckAttack();
	}
	return CheckAttack();
};

void() ai_run_melee = 
{
	self.ideal_yaw = enemy_yaw;
	ChangeYaw();
	if (FacingIdeal())
	{
		self.th_melee();
		self.attack_state = AS_STRAIGHT;
	}
};

void() ai_run_missile = 
{
	self.ideal_yaw = enemy_yaw;
	ChangeYaw();
	if (FacingIdeal())
	{
		self.th_missile();
		self.attack_state = AS_STRAIGHT;
	}
};

void() ai_run_slide = 
{
	local float ofs;
	self.ideal_yaw = enemy_yaw;
	ChangeYaw();
	if (self.lefty)
	{
		ofs = 90;
	}
	else
	{
		ofs = -90;
	}
	if (walkmove(self.ideal_yaw + ofs, movedist))
	{
		return;
	}
	self.lefty = 1 - self.lefty;
	walkmove(self.ideal_yaw - ofs, movedist);
};

void(float dist) ai_run = 
{
	local vector delta;
	local float axis;
	local float direct;
	local float ang_rint;
	local float ang_floor;
	local float ang_ceil;
	movedist = dist;
	if (self.enemy.health <= 0)
	{
		self.enemy = world;
		if (self.oldenemy.health > 0)
		{
			self.enemy = self.oldenemy;
			HuntTarget();
		}
		else
		{
			if (self.movetarget)
			{
				self.th_walk();
			}
			else
			{
				self.th_stand();
			}
			return;
		}
	}
	self.show_hostile = time + 1;
	enemy_vis = visible(self.enemy);
	if (enemy_vis)
	{
		self.search_time = time + MOVETYPE_FLY;
	}
	if (coop && self.search_time < time)
	{
		if (FindTarget())
		{
			return;
		}
	}
	enemy_infront = infront(self.enemy);
	enemy_range = range(self.enemy);
	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);
	if (self.attack_state == AS_MISSILE)
	{
		ai_run_missile();
		return;
	}
	if (self.attack_state == AS_MELEE)
	{
		ai_run_melee();
		return;
	}
	if (CheckAnyAttack())
	{
		return;
	}
	if (self.attack_state == AS_SLIDING)
	{
		ai_run_slide();
		return;
	}
	movetogoal(dist);
};

