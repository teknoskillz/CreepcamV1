void() info_null = 
{
	remove(self);
};

void() info_notnull = 
{
};
float START_OFF    = 1.000;

void() light_use = 
{
	if (self.spawnflags & START_OFF)
	{
		lightstyle(self.style, "m");
		self.spawnflags = self.spawnflags - START_OFF;
	}
	else
	{
		lightstyle(self.style, "a");
		self.spawnflags = self.spawnflags + START_OFF;
	}
};

void() light = 
{
	if (!(self.targetname))
	{
		remove(self);
		return;
	}
	if (self.style >= FL_MONSTER)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
		{
			lightstyle(self.style, "a");
		}
		else
		{
			lightstyle(self.style, "m");
		}
	}
};

void() light_fluoro = 
{
	if (self.style >= FL_MONSTER)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
		{
			lightstyle(self.style, "a");
		}
		else
		{
			lightstyle(self.style, "m");
		}
	}
	precache_sound("ambience/fl_hum1.wav");
	ambientsound(self.origin, "ambience/fl_hum1.wav", TRACE_PAUSE, ATTN_STATIC);
};

void() light_fluorospark = 
{
	if (!(self.style))
	{
		self.style = MOVETYPE_BOUNCE;
	}
	precache_sound("ambience/buzz1.wav");
	ambientsound(self.origin, "ambience/buzz1.wav", TRACE_PAUSE, ATTN_STATIC);
};

void() light_globe = 
{
	precache_model("progs/s_light.spr");
	setmodel(self, "progs/s_light.spr");
	makestatic(self);
};

void() FireAmbient = 
{
	precache_sound("ambience/fire1.wav");
	ambientsound(self.origin, "ambience/fire1.wav", TRACE_PAUSE, ATTN_STATIC);
};

void() light_torch_small_walltorch = 
{
	precache_model("progs/flame.mdl");
	setmodel(self, "progs/flame.mdl");
	FireAmbient();
	makestatic(self);
};

void() light_flame_large_yellow = 
{
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");
	self.frame = 1;
	FireAmbient();
	makestatic(self);
};

void() light_flame_small_yellow = 
{
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");
	FireAmbient();
	makestatic(self);
};

void() light_flame_small_white = 
{
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");
	FireAmbient();
	makestatic(self);
};

void () fire_fly;

void () fire_touch;

void() misc_fireball = 
{
	precache_model("progs/lavaball.mdl");
	self.classname = "fireball";
	self.nextthink = time + random() * MOVETYPE_FLY;
	self.think = fire_fly;
	if (!(self.speed))
	{
		self.speed = 1000;
	}
};

void() fire_fly = 
{
	local entity fireball;
	fireball = spawn();
	fireball.solid = SOLID_TRIGGER;
	fireball.movetype = MOVETYPE_TOSS;
	fireball.velocity = '0 0 1000';
	fireball.velocity_x = random() * 100 - SLOW_TURN_RATE;
	fireball.velocity_y = random() * 100 - SLOW_TURN_RATE;
	fireball.velocity_z = self.speed + random() * 200;
	fireball.classname = "fireball";
	setmodel(fireball, "progs/lavaball.mdl");
	setsize(fireball, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(fireball, self.origin);
	fireball.nextthink = time + MOVETYPE_FLY;
	fireball.think = SUB_Remove;
	fireball.touch = fire_touch;
	self.nextthink = time + random() * MOVETYPE_FLY + MOVETYPE_WALK;
	self.think = fire_fly;
};

void() fire_touch = 
{
	T_Damage(other, self, self, 20);
	remove(self);
};

void() barrel_explode = 
{
	self.takedamage = DAMAGE_NO;
	self.classname = "explo_box";
	T_RadiusDamage(self, self, 160, world);
	sound(self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);
	particle(self.origin, VEC_ORIGIN, 75, CF_KEEPBETWEENLEVELS);
	self.origin_z = self.origin_z + FL_MONSTER;
	BecomeExplosion();
};

void() misc_explobox = 
{
	local float oldz;
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model("maps/b_explob.bsp");
	setmodel(self, "maps/b_explob.bsp");
	precache_sound("weapons/r_exp3.wav");
	self.health = 20;
	self.th_die = barrel_explode;
	self.takedamage = DAMAGE_AIM;
	self.origin_z = self.origin_z + FL_SWIM;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250)
	{
		dprint("item fell out of level at ");
		dprint(vtos(self.origin));
		dprint("\n");
		remove(self);
	}
};

void() misc_explobox2 = 
{
	local float oldz;
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model2("maps/b_exbox2.bsp");
	setmodel(self, "maps/b_exbox2.bsp");
	precache_sound("weapons/r_exp3.wav");
	self.health = 20;
	self.th_die = barrel_explode;
	self.takedamage = DAMAGE_AIM;
	self.origin_z = self.origin_z + FL_SWIM;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250)
	{
		dprint("item fell out of level at ");
		dprint(vtos(self.origin));
		dprint("\n");
		remove(self);
	}
};

float SPAWNFLAG_SUPERSPIKE    = 1.000;
float SPAWNFLAG_LASER    = 2.000;

void (vector org, vector vec) LaunchLaser;

void() spikeshooter_use = 
{
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		sound(self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		LaunchLaser(self.origin, self.movedir);
	}
	else
	{
		sound(self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		launch_spike(self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
		{
			newmis.touch = superspike_touch;
		}
	}
};

void() shooter_think = 
{
	spikeshooter_use();
	self.nextthink = time + self.wait;
	newmis.velocity = self.movedir * 500;
};

void() trap_spikeshooter = 
{
	SetMovedir();
	self.use = spikeshooter_use;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model2("progs/laser.mdl");
		precache_sound2("enforcer/enfire.wav");
		precache_sound2("enforcer/enfstop.wav");
	}
	else
	{
		precache_sound("weapons/spike2.wav");
	}
};

void() trap_shooter = 
{
	trap_spikeshooter();
	if (self.wait == 0)
	{
		self.wait = 1;
	}
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
};

void () make_bubbles;

void () bubble_remove;

void() air_bubbles = 
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model("progs/s_bubble.spr");
	self.nextthink = time + 1;
	self.think = make_bubbles;
};

void() make_bubbles = 
{
	local entity bubble;
	bubble = spawn();
	setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + TRACE_PAUSE;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + random() + TRACE_PAUSE;
	self.think = make_bubbles;
};

void() bubble_split = 
{
	local entity bubble;
	bubble = spawn();
	setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = self.velocity;
	bubble.nextthink = time + TRACE_PAUSE;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 1;
	bubble.cnt = MOVETYPE_BOUNCE;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	self.frame = 1;
	self.cnt = MOVETYPE_BOUNCE;
	if (self.waterlevel != MOVETYPE_WALK)
	{
		remove(self);
	}
};

void() bubble_remove = 
{
	if (other.classname == self.classname)
	{
		return;
	}
	remove(self);
};

void() bubble_bob = 
{
	local float rnd1;
	local float rnd2;
	local float rnd3;
	local vector vtmp1;
	local vector modi;
	self.cnt = self.cnt + 1;
	if (self.cnt == MOVETYPE_STEP)
	{
		bubble_split();
	}
	if (self.cnt == 20)
	{
		remove(self);
	}
	rnd1 = self.velocity_x + (-10 + random() * 20);
	rnd2 = self.velocity_y + (-10 + random() * 20);
	rnd3 = self.velocity_z + MOVETYPE_BOUNCE + random() * MOVETYPE_BOUNCE;
	if (rnd1 > MOVETYPE_BOUNCE)
	{
		rnd1 = MOVETYPE_FLY;
	}
	if (rnd1 < -10)
	{
		rnd1 = CONTENT_LAVA;
	}
	if (rnd2 > MOVETYPE_BOUNCE)
	{
		rnd2 = MOVETYPE_FLY;
	}
	if (rnd2 < -10)
	{
		rnd2 = CONTENT_LAVA;
	}
	if (rnd3 < MOVETYPE_BOUNCE)
	{
		rnd3 = FILM_HI_LIP;
	}
	if (rnd3 > SVC_INTERMISSION)
	{
		rnd3 = 25;
	}
	self.velocity_x = rnd1;
	self.velocity_y = rnd2;
	self.velocity_z = rnd3;
	self.nextthink = time + TRACE_PAUSE;
	self.think = bubble_bob;
};

void() viewthing = 
{
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	precache_model("progs/player.mdl");
	setmodel(self, "progs/player.mdl");
};

void() func_wall_use = 
{
	self.frame = 1 - self.frame;
};

void() func_wall = 
{
	self.angles = VEC_ORIGIN;
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel(self, self.model);
};

void() func_illusionary = 
{
	self.angles = VEC_ORIGIN;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel(self, self.model);
	makestatic(self);
};

void() func_episodegate = 
{
	if (!(serverflags & self.spawnflags))
	{
		return;
	}
	self.angles = VEC_ORIGIN;
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel(self, self.model);
};

void() func_bossgate = 
{
	if ((serverflags & FILM_HI_LIP) == FILM_HI_LIP)
	{
		return;
	}
	self.angles = VEC_ORIGIN;
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel(self, self.model);
};

void() ambient_suck_wind = 
{
	precache_sound("ambience/suck1.wav");
	ambientsound(self.origin, "ambience/suck1.wav", 1, ATTN_STATIC);
};

void() ambient_drone = 
{
	precache_sound("ambience/drone6.wav");
	ambientsound(self.origin, "ambience/drone6.wav", TRACE_PAUSE, ATTN_STATIC);
};

void() ambient_flouro_buzz = 
{
	precache_sound("ambience/buzz1.wav");
	ambientsound(self.origin, "ambience/buzz1.wav", 1, ATTN_STATIC);
};

void() ambient_drip = 
{
	precache_sound("ambience/drip1.wav");
	ambientsound(self.origin, "ambience/drip1.wav", TRACE_PAUSE, ATTN_STATIC);
};

void() ambient_comp_hum = 
{
	precache_sound("ambience/comp1.wav");
	ambientsound(self.origin, "ambience/comp1.wav", 1, ATTN_STATIC);
};

void() ambient_thunder = 
{
	precache_sound("ambience/thunder1.wav");
	ambientsound(self.origin, "ambience/thunder1.wav", TRACE_PAUSE, ATTN_STATIC);
};

void() ambient_light_buzz = 
{
	precache_sound("ambience/fl_hum1.wav");
	ambientsound(self.origin, "ambience/fl_hum1.wav", TRACE_PAUSE, ATTN_STATIC);
};

void() ambient_swamp1 = 
{
	precache_sound("ambience/swamp1.wav");
	ambientsound(self.origin, "ambience/swamp1.wav", TRACE_PAUSE, ATTN_STATIC);
};

void() ambient_swamp2 = 
{
	precache_sound("ambience/swamp2.wav");
	ambientsound(self.origin, "ambience/swamp2.wav", TRACE_PAUSE, ATTN_STATIC);
};

void() noise_think = 
{
	self.nextthink = time + TRACE_PAUSE;
	sound(self, 1, "enforcer/enfire.wav", 1, ATTN_NORM);
	sound(self, FL_SWIM, "enforcer/enfstop.wav", 1, ATTN_NORM);
	sound(self, MOVETYPE_WALK, "enforcer/sight1.wav", 1, ATTN_NORM);
	sound(self, MOVETYPE_STEP, "enforcer/sight2.wav", 1, ATTN_NORM);
	sound(self, MOVETYPE_FLY, "enforcer/sight3.wav", 1, ATTN_NORM);
	sound(self, MOVETYPE_TOSS, "enforcer/sight4.wav", 1, ATTN_NORM);
	sound(self, MOVETYPE_PUSH, "enforcer/pain1.wav", 1, ATTN_NORM);
};

void() misc_noisemaker = 
{
	precache_sound2("enforcer/enfire.wav");
	precache_sound2("enforcer/enfstop.wav");
	precache_sound2("enforcer/sight1.wav");
	precache_sound2("enforcer/sight2.wav");
	precache_sound2("enforcer/sight3.wav");
	precache_sound2("enforcer/sight4.wav");
	precache_sound2("enforcer/pain1.wav");
	precache_sound2("enforcer/pain2.wav");
	precache_sound2("enforcer/death1.wav");
	precache_sound2("enforcer/idle1.wav");
	self.nextthink = time + 0.1 + random();
	self.think = noise_think;
};

