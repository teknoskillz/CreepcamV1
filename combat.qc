void () T_MissileTouch;

void () info_player_start;

void (entity targ, entity attacker) ClientObituary;

void () monster_death_use;

float(entity targ, entity inflictor) CanDamage =
{
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, TRACE_PAUSE * (targ.absmin + targ.absmax), 1, self);
		if (trace_fraction == 1)
		{
			return 1;
		}
		if (trace_ent == targ)
		{
			return 1;
		}
		return 0;
	}
	traceline(inflictor.origin, targ.origin, 1, self);
	if (trace_fraction == 1)
	{
		return 1;
	}
	traceline(inflictor.origin, targ.origin + '15 15 0', 1, self);
	if (trace_fraction == 1)
	{
		return 1;
	}
	traceline(inflictor.origin, targ.origin + '-15 -15 0', 1, self);
	if (trace_fraction == 1)
	{
		return 1;
	}
	traceline(inflictor.origin, targ.origin + '-15 15 0', 1, self);
	if (trace_fraction == 1)
	{
		return 1;
	}
	traceline(inflictor.origin, targ.origin + '15 -15 0', 1, self);
	if (trace_fraction == 1)
	{
		return 1;
	}
	return 0;
};

void(entity targ, entity attacker) Killed = 
{
	local entity oself;
	oself = self;
	self = targ;
	if (self.health < -99)
	{
		self.health = -99;
	}
	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{
		self.th_die();
		self = oself;
		return;
	}
	self.enemy = attacker;
	if (self.flags & FL_MONSTER)
	{
		killed_monsters = killed_monsters + 1;
		WriteByte(MSG_ALL, SVC_KILLEDMONSTER);
	}
	ClientObituary(self, attacker);
	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;
	monster_death_use();
	self.th_die();
	self = oself;
};

void(entity targ, entity inflictor, entity attacker, float damage) T_Damage = 
{
	local vector dir;
	local entity oldself;
	local float save;
	local float take;
	if (!(targ.takedamage))
	{
		return;
	}
	damage_attacker = attacker;
	if (attacker.super_damage_finished > time)
	{
		damage = damage * MOVETYPE_STEP;
	}
	save = ceil(targ.armortype * damage);
//SJB
   if(matchmode != 1 && matchmode != 2)
   {
   if (save >= targ.armorvalue)
   {
      save = targ.armorvalue;
      targ.armortype = 0;
      targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}
	targ.armorvalue = targ.armorvalue - save;
	take = ceil(damage - save);
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}
   }
	if (inflictor != world && targ.movetype == MOVETYPE_WALK)
	{
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * TRACE_PAUSE;
		dir = normalize(dir);
		targ.velocity = targ.velocity + dir * damage * FL_CLIENT;
	}
	if (targ.flags & FL_GODMODE)
	{
		return;
	}
	if (targ.invincible_finished >= time)
	{
		if (self.invincible_sound < time)
		{
			sound(targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + FL_SWIM;
		}
		return;
	}
	if (teamplay == 1 && targ.team > 0 && targ.team == attacker.team)
	{
		return;
	}
	targ.health = targ.health - take;
	if (targ.health <= 0)
	{
		Killed(targ, attacker);
		return;
	}
	oldself = self;
	self = targ;
	if (self.flags & FL_MONSTER && attacker != world)
	{
		if (self != attacker && attacker != self.enemy)
		{
			if (self.classname != attacker.classname || self.classname == "monster_army")
			{
				if (self.enemy.classname == "player")
				{
					self.oldenemy = self.enemy;
				}
				self.enemy = attacker;
				FoundTarget();
			}
		}
	}
	if (self.th_pain)
	{
		self.th_pain(attacker, take);
		if (skill == MOVETYPE_WALK)
		{
			self.pain_finished = time + MOVETYPE_FLY;
		}
	}
	self = oldself;
};

void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage = 
{
	local float points;
	local entity head;
	local vector org;
	head = findradius(inflictor.origin, damage + 40);
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs) * TRACE_PAUSE;
				points = TRACE_PAUSE * vlen(inflictor.origin - org);
				if (points < 0)
				{
					points = 0;
				}
				points = damage - points;
				if (head == attacker)
				{
					points = points * TRACE_PAUSE;
				}
				if (points > 0)
				{
					if (CanDamage(head, inflictor))
					{
						if (head.classname == "monster_shambler")
						{
							T_Damage(head, inflictor, attacker, points * TRACE_PAUSE);
						}
						else
						{
							T_Damage(head, inflictor, attacker, points);
						}
					}
				}
			}
		}
		head = head.chain;
	}
};

void(entity attacker, float damage) T_BeamDamage = 
{
	local float points;
	local entity head;
	head = findradius(attacker.origin, damage + 40);
	while (head)
	{
		if (head.takedamage)
		{
			points = TRACE_PAUSE * vlen(attacker.origin - head.origin);
			if (points < 0)
			{
				points = 0;
			}
			points = damage - points;
			if (head == attacker)
			{
				points = points * TRACE_PAUSE;
			}
			if (points > 0)
			{
				if (CanDamage(head, attacker))
				{
					if (head.classname == "monster_shambler")
					{
						T_Damage(head, attacker, attacker, points * TRACE_PAUSE);
					}
					else
					{
						T_Damage(head, attacker, attacker, points);
					}
				}
			}
		}
		head = head.chain;
	}
};

