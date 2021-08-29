if(CLIENT) then return end

print("[LeyHitreg] Loaded!")

LeyHitreg = LeyHitreg or {}

-- SETTINGS START
LeyHitreg.SecurityCheckBulletPos = false -- confirm the bullet position
LeyHitreg.SecurityCheckVisibility = false -- confirm whether the player can see his target
LeyHitreg.DisableWhenPlayers = 40 -- more than these many players = disable hitreg, useful for big servers

local option_customnetmsg = "037a94c087291025f4b8a246bbf9d258bb3a7d14be151723ac5b28a782f6c8f7" -- if you change this, do so in both files

LeyHitreg.SecurityCheckBulletMaxDist = 600 -- NOT visibility its for bullet confirmation

LeyHitreg.EnableLagComp = true -- LeyHitreg lag compensation enabled?


LeyHitreg.DisableSourceHitHandling = false -- DONT CHANGE; This is mainly for testing. If this is enabled sources hit handling will always be ignored.
-- SETTINGS END

util.AddNetworkString(option_customnetmsg)

local debugmode = false

local dprint = function(...)
	if(debugmode) then
		Msg("[LeyHitreg] [dbg] ")
		print(...)
		
		local tbl = {...}

		local msg = ""
	
		for k,v in pairs(tbl) do
			msg = msg .. tostring(v)
		end

		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("[LeyHitreg] [dbg] " .. msg)
		end
	end
end

-- shity hack to get more control over the lag compensation

local pmeta = FindMetaTable("Player")
pmeta.OLagCompensation = pmeta.OLagCompensation or pmeta.LagCompensation
util.OTraceLine = util.OTraceLine or util.TraceLine
util.OTraceHull = util.OTraceHull or util.TraceHull

oldDamageInfo = oldDamageInfo or DamageInfo

local dmginfo = nil

function cDamageInfo()
	if(not dmginfo) then
		dmginfo = oldDamageInfo()
	end
	
	return dmginfo
end

/*
function util.TraceLine(tr)

	if(not LeyHitreg.EnableLagComp) then
		return util.OTraceLine(tr)
	end

	local result = nil

	for k,v in pairs(player.GetAll()) do
		if(not v.OLagCompensation) then continue end
		pmeta.OLagCompensation(v, true)
	end

	result = util.OTraceLine(tr)

	for k,v in pairs(player.GetAll()) do
		if(not v.OLagCompensation) then continue end
		pmeta.OLagCompensation(v, false)
	end

	return result
end


function util.TraceHull(tr)

	if(not LeyHitreg.EnableLagComp) then
		return util.OTraceHull(tr)
	end

	local result = nil

	for k,v in pairs(player.GetAll()) do
		if(not v.OLagCompensation) then continue end
		pmeta.OLagCompensation(v, true)
	end

	result = util.OTraceHull(tr)

	for k,v in pairs(player.GetAll()) do
		if(not v.OLagCompensation) then continue end
		pmeta.OLagCompensation(v, false)
	end

	return result
end

function pmeta:LagCompensation( enable )

	if(LeyHitreg.EnableLagComp) then return end

	return pmeta.OLagCompensation(self, enable)
end


*/

-- shity hack to fix broken crossbow bolts
hook.Add("EntityTakeDamage", "LeyHitreg.fix_crossbowbolts", function(ent, dmg)

	local inf = dmg:GetInflictor()
	
	if IsValid(inf) and inf:GetClass() == "crossbow_bolt" and dmg:GetDamage() == 0 then
		dmg:SetDamage(50)
	end
end)

-- shity hack to fix gmod Damageinfo:SetDamage/GetDamage bug
local dmgmeta = FindMetaTable("CTakeDamageInfo")
dmgmeta.OGetDamage = dmgmeta.OGetDamage or dmgmeta.GetDamage
dmgmeta.OSetDamage = dmgmeta.OSetDamage or dmgmeta.SetDamage
CTakeDamageInfo__CachedDamages = {}

function dmgmeta:GetDamage()
	local origret = self:OGetDamage()
	if(origret and origret != 0 or not CTakeDamageInfo__CachedDamages) then
		return origret
	end
	return CTakeDamageInfo__CachedDamages[self] or 0
end

function dmgmeta:SetDamage(amount)
	local origret = self:OSetDamage(amount)
	if(not CTakeDamageInfo__CachedDamages) then
		return origret
	end

	if(table.Count(CTakeDamageInfo__CachedDamages) > 50000) then
		CTakeDamageInfo__CachedDamages = {}
	end

	CTakeDamageInfo__CachedDamages[self] = amount




	return origret
end
--shity hack to fix bullet callbacks sometimes not working properly

local meta = FindMetaTable("Entity")
meta.OFireBullets = meta.OFireBullets or meta.FireBullets
LeyHitreg.CachedBulletCallbacks = LeyHitreg.CachedBulletCallbacks or {}

local function bulletCallback(ply, tr, dmginfo, cb)

	dprint("In bullet cb")

	local ent = tr and IsValid(tr.Entity) and tr.Entity or nil
		
	ply.leyhitreg_expectingbullet = true

	if(IsValid(ent)) then -- source engine bullet handling worked fine, do nothing
		dprint("Source hit handling worked fine")
		ply.lastbullet = ply.lastbullet or {}

		local lbullet = ply.lastbullet[1]
		table.remove(ply.lastbullet, 1)
		if(cb) then
			cb(ply, tr, dmginfo)
		end

		return
	end



	local proc = LeyHitreg.ProcessServerHit( ply )
	if(proc) then return end

	local eind = ply:EntIndex()

	timer.Create("leyhitreg_stopexpect_secureproc" .. eind, 0.5, 6, function()
		if(not ply.leyhitreg_expectingbullet or LeyHitreg.ProcessServerHit( ply )) then timer.Remove("leyhitreg_stopexpect_secureproc" .. eind) end

		
	end)


		
end

function meta:LeyHitregIgnoredFire( bullet )
	LeyHitreg.IgnoreBullet = true
	local ret = self:OFireBullets(bullet)
	LeyHitreg.IgnoreBullet = false
	return ret
end

function meta:FireBullets( bullet )

	if(not bullet or bullet.Num != 1) then return self:OFireBullets(bullet) end

	if(LeyHitreg.DisableWhenPlayers and player.GetCount() > LeyHitreg.DisableWhenPlayers) then
		return self:LeyHitregIgnoredFire(bullet)
	end


	local wep = self

	if(not self:IsPlayer() and not self:IsWeapon()) then return self:LeyHitregIgnoredFire(bullet) end

	if(LeyHitreg.DisableSourceHitHandling) then
		bullet.Dir = Vector(300,300,300)
		bullet.Src = Vector(0,0,0)
	end

	local ocb = bullet.Callback

	bullet.Callback = function(a,b,c)
		dprint("cb ow")
		if(a == "gt") then
			dprint("bullet gt")
			return ocb
		end

		local ret = bulletCallback(a,b,c, ocb)
		if(ret != nil) then return ret end
	end

	local ret = self:OFireBullets(bullet)
	
	return ret
end

--end hack

LeyHitreg.SecurityCheckBulletMaxDistSqr = LeyHitreg.SecurityCheckBulletMaxDist * LeyHitreg.SecurityCheckBulletMaxDist

LeyHitreg.QueuedHits= LeyHitreg.QueuedHits or {}

function LeyHitreg.QueueClientHit( ... )

	local ourt = {...}

	table.insert(LeyHitreg.QueuedHits, ourt)


	for k,v in pairs(LeyHitreg.QueuedHits) do

		local who = v[2]
		if(not IsValid(who)) then continue end
		who.leyhitreg_queuedbullets = who.leyhitreg_queuedbullets or 0
		who.leyhitreg_queuedbullets = who.leyhitreg_queuedbullets + 1

		if(who.leyhitreg_queuedbullets > 10000) then -- 10.000 bullets in 1seconds, OK
			who.leyhitreg_bulletspammer = true
		end

	end
	
	for k,v in pairs(player.GetAll()) do
		if(not v.leyhitreg_bulletspammer) then continue end

		v:Kick("[LeyHitreg] stop tryna exploit")
	end

end


timer.Create("LeyHitreg.ResetQueuedCount", 1, 0, function()
	for k,v in pairs(player.GetAll()) do v.leyhitreg_queuedbullets = 0 end
end)


LeyHitreg.HitCounter = LeyHitreg.HitCounter or {}

timer.Create("LeyHitreg.ResetCaches", 60*3, 0, function()
	
	LeyHitreg.HitCounter = {}
	CTakeDamageInfo__CachedDamages = {}


end)

function LeyHitreg.ProcessServerHit( ply )

	local processedsth = false

	local toremoveentries = {}

	for k,v in pairs(LeyHitreg.QueuedHits) do
		local time = v[1]
		local who = v[2]

		if(not IsValid(who) or math.abs(os.time() - time) >  3 or time == 0) then -- no lagswitching 4u big boi
			table.insert(toremoveentries, v)
			continue
		end

		if(who != ply) then continue end

		LeyHitreg.HitCounter[ply] = LeyHitreg.HitCounter[ply] or 0
		LeyHitreg.HitCounter[ply] = LeyHitreg.HitCounter[ply] - 1
		
		if(0>LeyHitreg.HitCounter[ply]) then
			local mismatch = -LeyHitreg.HitCounter[ply]
			
			if(mismatch > 100) then
				--ply:Kick("[LeyHitreg] Bullet mismatch.")
				--return
			end

		end
		
		processedsth = true
		local expectingbullettbl = LeyHitreg.ProcessClientHit(unpack(v))
		if(not expectingbullettbl) then
			v[1] = 0
			table.insert(toremoveentries, v)
		end
	end


	for k,v in pairs(toremoveentries) do
		table.RemoveByValue(LeyHitreg.QueuedHits, v)
	end

	return processedsth
end

local hl2damages = {}

hl2damages["weapon_pistol"] = 12
hl2damages["weapon_357"] = 75
hl2damages["weapon_smg1"] = 12
hl2damages["weapon_ar2"] = 11

LeyHitreg.IgnoreBullet = false

function LeyHitreg.EntityFireBullets( ent, bullet )
	dprint("ENTFIREBULLETSHK")
	if(not IsValid(ent) or not bullet or bullet.Num != 1 or not IsFirstTimePredicted()) then return end
	
	if(LeyHitreg.DisableWhenPlayers and player.GetCount() > LeyHitreg.DisableWhenPlayers) then
		return
	end
	
	if(LeyHitreg.IgnoreBullet) then
		dprint("ignore")
		return
	end
	
	if(not ent:IsPlayer()) then
		local owna = ent.Owner and ent.Owner or nil
		local ownb = ent.GetOwner and ent:GetOwner()  or nil
		
		if(ownb and ownb:IsPlayer()) then
			ent = ownb
		elseif(owna and owna:IsPlayer()) then
			ent = owna
		end

	end
	
	if(not ent.IsPlayer or not ent:IsPlayer() or not ent.GetActiveWeapon) then print"nonvalid" return end

	local wep = ent:GetActiveWeapon()

	if(not IsValid(wep)) then
		if(ent.Nick) then
			dprint(ent:Nick() .. " HAS NO WEAPON")
		end
		return
	end

	local wepclass = wep:GetClass()
	
	if(hl2damages[wepclass]) then
		bullet.Damage = hl2damages[wepclass]
		return
	end

	--local spread = bullet.Spread

	--bullet.Spread = Vector(0,0,0)

	--math.randomseed( CurTime() + math.sqrt( bullet.Dir.x ^ 2 * bullet.Dir.y ^ 2 * bullet.Dir.z ^ 2 ) )
	--bullet.Dir = bullet.Dir + Vector( spread.x * (math.random() * 2 - 1), spread.y * (math.random() * 2 - 1), spread.z *(math.random() * 2 - 1)) -- we don't fire this bullet either way          -- 76561198057647051

	if(1>bullet.Damage) then
		bullet.Damage = 0
	end
	
	dprint("DMGSET: " .. bullet.Damage)

	if(ent.lastbulletwep and ent.lastbulletwep != wep) then
		ent.lastbulletwep = wep
		ent.lastbullet = {}
	end

	local copy = table.Copy(bullet)
	local cb = nil
	
	local succ, passed = pcall(bullet.Callback, "gt")

	if(succ) then
		copy.bulletCallback = passed
	end

	local ply = NULL
	if(ent:IsPlayer()) then
		ply = ent
	elseif (ent:IsWeapon()) then
		local owna = ent.Owner and ent.Owner or nil
		local ownb = ent.GetOwner and ent:GetOwner()  or nil
		
		if(ownb and ownb:IsPlayer()) then
			ply = ownb
		elseif(owna and owna:IsPlayer()) then
			ply = owna
		end
	end

	if(IsValid(ply)) then
		LeyHitreg.HitCounter[ply] = LeyHitreg.HitCounter[ply] or 0
		LeyHitreg.HitCounter[ply] = LeyHitreg.HitCounter[ply] + 1
	end
	


	copy.lastbulletwep = wep

	ent.lastbullet = ent.lastbullet or {}
	table.insert(ent.lastbullet, copy)

	ent.lastbulletwep = wep

	timer.Create("bulletlast_" .. ent:EntIndex(), 1, 1, function()
		if(not IsValid(ent)) then return end
		
		--LeyHitreg.FireLegacyBullet(ent)
		ent.lastbullet = {}
	end)
	bullet.Testings = true

	--LeyHitreg.ProcessServerHit( ent )
	--ent:ChatPrint("registered serverside")

end

hook.Add("EntityFireBullets", "LeyHitreg.EntityFireBullets", LeyHitreg.EntityFireBullets)



local world = nil

function LeyHitreg.ProcessClientHit( svtime, ply, primaryfire, weapon, hitent, bulletsrc, bulletdir, hitpos, hitboxhit )
	dprint("CLIENT")

	if(not IsValid(weapon)) then
		dprint("Invalid weapon")
		table.remove(ply.lastbullet, 1)
		return
	end

	--change: add some nice edgechecking meme
	local trace = {}
	trace.Entity = NULL

	local predplypos = nil
	
	local trtbl = {}	
	trtbl.start = bulletsrc
	trtbl.endpos = trtbl.start + (bulletdir * (56756 * 8))
	trtbl.mask = MASK_SHOT

	if(IsValid(hitent)) then

		local filtered = {}

		for k,v in pairs(ents.GetAll()) do
			if(not IsValid(v)) then continue end
			if(v == hitent) then continue end

			if(v.IsNPC and v:IsNPC() or v.IsPlayer and v:IsPlayer()) then
				table.insert(filtered, v)
			end
		end

		table.insert(filtered, ply)

		trtbl.filter = filtered

		local obbmins = ply:OBBMins()
		local obbmaxs = ply:OBBMaxs()

		trtbl.mins = obbmins * 2
		trtbl.maxs = obbmaxs * 2
		trace = {}

		--trtbl.output = trace

		ply:LagCompensation(false)



		trace = util.OTraceLine(trtbl) -- visibility and validity check

		if(not IsValid(trace.Entity)) then
			trace = util.OTraceHull(trtbl)
		end

		if(not IsValid(trace.Entity)) then
			trtbl.endpos = hitent:GetPos()
			trace = util.OTraceLine(trtbl)
		end

		if(not IsValid(trace.Entity)) then
			trace = util.OTraceHull(trtbl)
		end

		if(LeyHitreg.EnableLagComp and not IsValid(trace.Entity)) then
			ply:LagCompensation(true)
			predplypos = ply:GetPos()
			trace = util.OTraceLine(trtbl) -- visibility and validity check

			if(not IsValid(trace.Entity)) then
				trace = util.OTraceHull(trtbl)
			end

			if(not IsValid(trace.Entity)) then
				trtbl.endpos = hitent:GetPos()
				trace = util.OTraceLine(trtbl)
			end

			if(not IsValid(trace.Entity)) then
				trace = util.OTraceHull(trtbl)
			end

			ply:LagCompensation(false)
		else
			if(LeyHitreg.SecurityCheckBulletPos) then
				ply:LagCompensation(true)
				predplypos = ply:GetPos()
				ply:LagCompensation(false)
			end
		end

		if(IsValid(hitent)) then

			if(LeyHitreg.SecurityCheckVisibility and not IsValid(trace.Entity)) then
				ply:ChatPrint("you cant see said person")
				dprint("you cant see said person")
				table.remove(ply.lastbullet, 1)
				return
			else
				trtbl.endpos = hitent:GetPos()
				trace = util.TraceLine(trtbl)

				if(not IsValid(trace.Entity)) then
					trace.Entity = hitent
				else
					if(trace.Entity:IsPlayer() or trace.Entity:IsNPC()) then
						hitent = trace.Entity
					end
				end

			end

		else
			if(IsValid(trace.Entity)) then
				hitent = trace.Entity
				ply:ChatPrint("client actually is wrong, you can see person")
				dprint("client actually is wrong, you can see person")
			end
		end


	else
		trtbl.filter = ply
		trace = util.OTraceLine(trtbl) -- visibility and validity check
	end



	world = world or game.GetWorld()

	if(ply.lastbulletwep and ply.lastbulletwep != weapon) then
		ply.lastbulletwep = weapon
		ply.lastbullet = {}
		dprint("Switched weapon while shooting")
		return
	end

	if(not ply:Alive()) then
		dprint("Player is not alive and thus can't shoot")
		ply.lastbullet = {}
		return
	end

	if(ply.GetObserverMode and ply:GetObserverMode() != OBS_MODE_NONE) then
		dprint("Tried shooting while spec")
		ply.lastbullet = {}
		return
	end

	if(IsValid(hitent)) then
		if(ply == hitent or hitent.GetObserverMode and hitent:GetObserverMode() != OBS_MODE_NONE) then
			dprint("Tried shooting spec or himself")
			table.remove(ply.lastbullet, 1)
			return
		end
	end

	if(ply:GetActiveWeapon() != weapon) then
		dprint("Active weapon is not the weapon used for this shot")
		table.remove(ply.lastbullet, 1)
		return
	end



	if(LeyHitreg.SecurityCheckBulletPos and LeyHitreg.SecurityCheckBulletMaxDist) then

		local bulletdisttoply = bulletsrc:DistToSqr(ply:GetPos())
		
		local bulletdisttoply2 = nil

		if(predplypos) then
			bulletdisttoply2 = bulletsrc:DistToSqr(predplypos)
			if(bulletdisttoply>bulletdisttoply2) then
				bulletdisttoply = bulletdisttoply2
			end
		end

		if(bulletdisttoply> LeyHitreg.SecurityCheckBulletMaxDistSqr) then
			ply:ChatPrint("bullet distance to players cur pos too big")
			dprint("Players distance to his own bullet is too big")
			table.remove(ply.lastbullet, 1)
			return
		end
	end



	--ply:ChatPrint("DIST: " .. tostring(bulletdisttoply))

	ply.lastbullet = ply.lastbullet or {}

	if(table.Count(ply.lastbullet) == 0) then
		dprint("empty bullet table")
		ply.leyhitreg_expectingbullettable = true
		return true
	end

	local bullet = ply.lastbullet[1]

	if(not bullet) then
		dprint("NO BULLET DATA")
		return
	end

	table.remove(ply.lastbullet, 1)

	local ammotype = weapon:GetPrimaryAmmoType()

	if(not primaryfire) then
		ammotype = weapon:GetSecondaryAmmoType() or weapon:GetPrimaryAmmoType()
	end

	dprint("DMG: " .. bullet.Damage)

	dprint("ye all good")



	local hkret = nil
	dprint("hbox: " .. hitboxhit)

	local is_npc = hitent:IsNPC()
	local is_player = hitent:IsPlayer()

	local callbackfn = bullet.bulletCallback
	
	local bdmg = bullet.Damage
	
	DamageInfo = cDamageInfo -- shity hack
	
	local d = DamageInfo()
	d:SetAttacker(ply)
	d:SetInflictor(weapon)
	d:SetDamageType( DMG_BULLET )
	d:SetDamagePosition(hitpos)
	d:SetDamageForce(bulletdir * bullet.Force)
	d:SetAmmoType(ammotype)
	d:SetDamage(bdmg)
	
	if(callbackfn) then
		
		local succ, err = pcall(callbackfn, ply, trace, d)
		if(not succ) then
			ErrorNoHalt("[LeyHitreg] Bullet callback err: " .. err)
		end

	end

	if(hitent == NULL) then
		dprint("hitent is null")
		return
	end

	if(is_player) then
		
		hkret = hook.Call("PlayerTraceAttack", GAMEMODE, hitent, d, bulletdir, trace, ply)

		if(hkret) then return end

		hkret = hook.Call("ScalePlayerDamage", GAMEMODE, hitent, hitboxhit, d)
		

	else
		if(is_npc) then
			hkret = hook.Call("ScaleNPCDamage", GAMEMODE, hitent, hitboxhit, d)
		end
	end

	if(not hkret and not is_npc and not is_player) then
		dprint("take damage: " .. tostring(d:GetDamage()))
		hitent:DispatchTraceAttack(d, trace, trace.HitNormal)
	else

		if(d:GetDamage() > 0) then
			dprint("take damage2: " .. tostring(d:GetDamage()))
			hitent:TakeDamageInfo(d)
		end
	end

	DamageInfo = oldDamageInfo -- shity hack

end
	

net.Receive(option_customnetmsg, function(l, ply)

	if(LeyHitreg.DisableWhenPlayers and player.GetCount() > LeyHitreg.DisableWhenPlayers) then
		return
	end
	
	local msgtype = net.ReadUInt(8)

	if(msgtype != 1) then return end

	if(msgtype == 1) then
		
		local primaryfire = net.ReadBool()
		local weapon = net.ReadEntity()
		local hitent = net.ReadEntity()

		local bulletsrc = net.ReadVector()
		local bulletdir = net.ReadVector()

		local hitpos = net.ReadVector()

		local hitboxhit = net.ReadUInt(8)

		local cltime = net.ReadUInt(32)
		local svtime = os.time()

		if(not ply.lastbullet) then
			ply.lastbullet = {}
		end

		local activewep = ply:GetActiveWeapon()
		if(ply.lastbulletwep and ply.lastbulletwep != activewep) then
			ply.lastbulletwep = activewep
			ply.lastbullet = {}
		end
		
		LeyHitreg.QueueClientHit(svtime, ply, primaryfire, weapon, hitent, bulletsrc, bulletdir, hitpos, hitboxhit, cltime)

		if(ply.leyhitreg_expectingbullet) then
			LeyHitreg.ProcessServerHit(ply)
			ply.leyhitreg_expectingbullet = false
		else
			timer.Create("LeyHitreg.ProcessExpected_" .. ply:EntIndex(), 0.5, 4, function()
				if(not IsValid(ply) or not ply.leyhitreg_expectingbullet) then return end
				LeyHitreg.ProcessServerHit(ply)
				ply.leyhitreg_expectingbullet = false
			end)
		end

	end
end)