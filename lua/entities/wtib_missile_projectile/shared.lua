ENT.Type			= "anim"
ENT.PrintName		= "Missile"
ENT.Author			= "kevkev/Warrior xXx"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Category		= "Tiberium"
ENT.WTib_IsMissile	= true

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Warhead")
end

function ENT:GetWarhead()
	return self.dt.Warhead
end

function ENT:GetWarheadTable(int)
	return self.Warheads[int or self.dt.Warhead]
end

ENT.Warheads =	{}
ENT.Warheads[1] =	{
						Name = "Basic",
						Explode = function(self,data)
							data = data or {}
							util.BlastDamage(self,self.WDSO,self:GetPos(),math.Rand(200,300),math.Rand(300,400))
							local ed = EffectData()
							ed:SetOrigin(data.HitPos or self:GetPos())
							ed:SetStart(data.HitPos or self:GetPos())
							ed:SetScale(3)
							util.Effect("Explosion",ed)
							self:Remove()
						end,
						Launch = function(self)
							local e = ents.Create("env_fire_trail")
							e:SetAngles(self:GetAngles())
							e:SetPos(self:LocalToWorld(Vector(-70,0,7)))
							e:SetParent(self)
							e:Spawn()
							e:Activate()
							self:DeleteOnRemove(e)
						end,
						Think = function(self)
							// Do nothing.
						end
					}

WTib.Factory.AddObject({
	Name = ENT.PrintName,
	Class = WTib.GetClass(ENT),
	Model = "models/Tiberium/tiberium_missile.mdl",
	PercentDelay = 0.02,
	Information =	{
						ENT.PrintName,
						"\nThis factory converts refined Tiberium into Tiberium chemicals."
					},
	CreateEnt = function( factory, angles, pos, id, ply )
		local Obj = WTib.Factory.GetObjectByID(id)
		local ent = ents.Create(Obj.Class)
		ent:SetPos(pos)
		ent:SetAngles(angles)
		ent:Spawn()
		ent:Activate()
		ent:SetModel(Obj.Model)
		
		if ply then
			ent.WDSO = ply
			undo.Create(Obj.Name)
				undo.AddEntity(ent)
				undo.SetPlayer(ply)
			undo.Finish()
		end
		
		return ent
	end
})
