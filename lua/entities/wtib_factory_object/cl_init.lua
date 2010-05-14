include('shared.lua')

function ENT:Draw()
	local normal = self:GetUp()*-1
	local Mins = self:OBBMins().z
	local Maxs = self:OBBMaxs().z
	local distance = normal:Dot(self:LocalToWorld(Vector(0,0,Mins+(((Maxs-Mins)/100)*self.dt.Factory.dt.PercentageComplete))))
	render.EnableClipping(true)
		render.PushCustomClipPlane(normal,distance)
			render.CullMode(MATERIAL_CULLMODE_CW) 
			self:DrawModel()
			render.CullMode(MATERIAL_CULLMODE_CCW)
			self:DrawModel()
		render.PopCustomClipPlane()
	render.EnableClipping(false)
end

function ENT:Think()
	self:NextThink(CurTime()+1)
	return true
end
language.Add(WTib.GetClass(ENT),ENT.PrintName)
