AddCSLuaFile()
resource.AddFile("sound/weapons/genji/genjidraw.wav")
resource.AddFile("sound/weapons/katana/katana_swing_miss.wav")
resource.AddFile("sound/weapons/katana/katana_impact_world1.wav")
SWEP.PrintName = "Genji's Katana"
SWEP.Author = "Rising Darkness"
SWEP.Instructions = "You know the drill!"
SWEP.Category = "Overwatch"
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP1
SWEP.AutoSpawnable = false
SWEP.AmmoEnt = ""
SWEP.InLoadoutFor = nil
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.Icon = "entities/genji_melee"
SWEP.EquipMenuData = {
   type = "Weapon",
   desc = [[Ryūjin no ken wo kurae!]]
};
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/melee/v_katana.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["ValveBiped.base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, -0.86, -0.005), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(-1.859, -1.543, -2.842), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(-0.389, 0, 0), angle = Angle(-8.622, -51.949, 0) }
}
SWEP.Slot = 7
SWEP.UseHands = true
SWEP.HoldType = "melee2" 
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.ReloadSound = Sound("weapons/pistol_reload_scout.wav")
SWEP.CSMuzzleFlashes = true
SWEP.Primary.Sound = Sound("weapons/doom_sniper_smg.wav") 
SWEP.Primary.Damage = 10
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = "no"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Spread = 0
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0
SWEP.Primary.Delay = 0.6
SWEP.Primary.Force = 5
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.WElements = {
	["sword"] = { type = "Model", model = "models/weapons/melee/w_katana.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.719, 1.939, -1.162), angle = Angle(180, 180, 0), size = Vector(1.016, 1.016, 1.016), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
local COLOR_WHITE      = Color(255, 255, 255, 255)
local COLOR_WHITE_FADE = Color(255, 255, 255, 1)

function SWEP:Initialize()
    self:SetHoldType("melee2")

    if CLIENT then
        -- Only copy if the tables exist and are not empty
        if self.VElements and next(self.VElements) then
            self.VElements = table.FullCopy(self.VElements)
            self:CreateModels(self.VElements)
        end
        if self.WElements and next(self.WElements) then
            self.WElements = table.FullCopy(self.WElements)
            self:CreateModels(self.WElements)
        end
        if self.ViewModelBoneMods and next(self.ViewModelBoneMods) then
            self.ViewModelBoneMods = table.FullCopy(self.ViewModelBoneMods)
        end

        local owner = self.Owner
        if IsValid(owner) then
            local vm = owner:GetViewModel()
            if IsValid(vm) then
                self:ResetBonePositions(vm)

                if self.ShowViewModel == nil or self.ShowViewModel then
                    vm:SetColor(COLOR_WHITE)
                else
                    vm:SetColor(COLOR_WHITE_FADE)
                    vm:SetMaterial("Debug/hsv") -- hides model without breaking hooks
                end
            end
        end
    end
end
function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Owner:EmitSound(Sound("weapons/genji/genjidraw.wav"))
end
function SWEP:PrimaryAttack()
	if !IsValid(self) or !IsValid(self.Owner) then return end 
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:EmitSound("weapons/katana/katana_swing_miss.wav")--slash in the wind sound here
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	timer.Simple(0.2, function()
		if IsValid(self) then
			self:Slash()
		end
	end)
	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end
-- Adjustable SWEP parameters
SWEP.SlashRange         = 120        -- How far the slash can reach
SWEP.SlashHullSize      = Vector(7, 7, 7)  -- Half-size of hitbox
SWEP.SlashDamageMin     = 6          -- Damage multiplier lower bound
SWEP.SlashDamageMax     = 10         -- Damage multiplier upper bound
SWEP.SlashForceMin      = 1000       -- Minimum knockback force
SWEP.SlashForceMax      = 20000      -- Maximum knockback force
SWEP.SlashViewPunch     = Angle(-10, -20, 0) -- Camera shake for players

function SWEP:Slash()
    local owner = self.Owner
    if not IsValid(self) or not IsValid(owner) then return end

    local pos  = owner:GetShootPos()
    local ang  = owner:GetAimVector()
    local pain = self.Primary.Damage * math.Rand(self.SlashDamageMin, self.SlashDamageMax)

    if SERVER then
        local slashtrace = util.TraceHull({
            start  = pos,
            endpos = pos + (ang * self.SlashRange),
            filter = owner,
            mins   = -self.SlashHullSize,
            maxs   = self.SlashHullSize
        })

        if not slashtrace.Hit then return end

        local targ = slashtrace.Entity

        if IsValid(targ) and (targ:IsPlayer() or targ:IsNPC()) then
            -- Play hit sound
            owner:EmitSound("weapons/katana/katana_impact_world1.wav")

            -- Prepare damage
            local paininfo = DamageInfo()
            paininfo:SetDamage(pain)
            paininfo:SetDamageType(DMG_SLASH)
            paininfo:SetAttacker(owner)
            paininfo:SetInflictor(self.Weapon)
            paininfo:SetDamageForce(slashtrace.Normal * math.random(self.SlashForceMin, self.SlashForceMax))

            -- Camera shake for players
            if targ:IsPlayer() then
                targ:ViewPunch(self.SlashViewPunch)
            end

            -- Blood effect
            local blood = targ:GetBloodColor()
            if blood >= 0 then
                local fleshimpact = EffectData()
                fleshimpact:SetEntity(self.Weapon)
                fleshimpact:SetOrigin(slashtrace.HitPos)
                fleshimpact:SetNormal(slashtrace.Normal)
                fleshimpact:SetColor(blood)
                util.Effect("BloodImpact", fleshimpact)
            end

            -- Apply damage
            targ:TakeDamageInfo(paininfo)

        else
            -- World decal for missed slash
            local look = owner:GetEyeTrace()
            util.Decal("ManhackCut", look.HitPos + look.HitNormal, look.HitPos - look.HitNormal)
        end
    end
end
function SWEP:SecondaryAttack()
end
function SWEP:Reload()
end
function SWEP:Holster()
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	return true
end
function SWEP:OnRemove()
	if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
		RunConsoleCommand("lastinv")
	end
end
if CLIENT then
	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		local owner = self.Owner
		if not IsValid(owner) then return end

		local vm = owner:GetViewModel()
		if not IsValid(vm) then return end

		local vElements = self.VElements
		if not vElements then return end

		self:UpdateBonePositions(vm)

		-- Build render order once
		local vRenderOrder = self.vRenderOrder
		if not vRenderOrder then
			vRenderOrder = {}
			for k, v in pairs(vElements) do
				if v.type == "Model" then
					table.insert(vRenderOrder, 1, k)
				else -- Sprite or Quad
					table.insert(vRenderOrder, k)
				end
			end
			self.vRenderOrder = vRenderOrder
		end

		for i = 1, #vRenderOrder do
			local v = vElements[vRenderOrder[i]]
			if not v then 
				self.vRenderOrder = nil 
				break 
			end
			if v.hide or not v.bone then continue end

			local pos, ang = self:GetBoneOrientation(vElements, v, vm)
			if not pos then continue end

			local vpos, vang = v.pos, v.angle

			if v.type == "Model" then
				local model = v.modelEnt
				if not IsValid(model) then continue end

				model:SetPos(pos + ang:Forward() * vpos.x + ang:Right() * vpos.y + ang:Up() * vpos.z)
				ang:RotateAroundAxis(ang:Up(), vang.y)
				ang:RotateAroundAxis(ang:Right(), vang.p)
				ang:RotateAroundAxis(ang:Forward(), vang.r)
				model:SetAngles(ang)

				if v.size.x ~= 1 or v.size.y ~= 1 or v.size.z ~= 1 then
					local matrix = Matrix()
					matrix:Scale(v.size)
					model:EnableMatrix("RenderMultiply", matrix)
				end

				local mat = v.material
				if mat == "" then
					model:SetMaterial("")
				elseif model:GetMaterial() ~= mat then
					model:SetMaterial(mat)
				end

				if v.skin and v.skin ~= model:GetSkin() then
				model:DrawModel()

				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				if v.surpresslightning then render.SuppressEngineLighting(false) end

			elseif v.type == "Sprite" then
				local sprite = v.spriteMaterial
				if not sprite then continue end
				local drawpos = pos + ang:Forward() * vpos.x + ang:Right() * vpos.y + ang:Up() * vpos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif v.type == "Quad" and v.draw_func then
				local drawpos = pos + ang:Forward() * vpos.x + ang:Right() * vpos.y + ang:Up() * vpos.z
				ang:RotateAroundAxis(ang:Up(), vang.y)
				ang:RotateAroundAxis(ang:Right(), vang.p)
				ang:RotateAroundAxis(ang:Forward(), vang.r)
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func(self)
				cam.End3D2D()
			end
		end
	end
      model:SetSkin(v.skin)
            end

            local bodygroup = v.bodygroup
            if bodygroup then
                for bgk, bgv in pairs(bodygroup) do
                    if model:GetBodygroup(bgk) ~= bgv then
                        model:SetBodygroup(bgk, bgv)
                    end
                end
            end

            if v.surpresslightning then render.SuppressEngineLighting(true) end
            local col = v.color
            render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
            render.SetBlend(col.a / 255)

          
	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
    -- Draw default model if enabled
    if self.ShowWorldModel ~= false then
        self:DrawModel()
    end

    -- Bail early if no elements
    if not self.WElements then return end

    -- Cache render order once
    if not self.wRenderOrder then
        self.wRenderOrder = {}
        for k, v in pairs(self.WElements) do
            if v.type == "Model" then
                table.insert(self.wRenderOrder, 1, k)
            elseif v.type == "Sprite" or v.type == "Quad" then
                table.insert(self.wRenderOrder, k)
            end
        end
    end

    local bone_ent = IsValid(self.Owner) and self.Owner or self

    -- Local helper to calculate offset position
    local function ApplyOffset(pos, ang, offset)
        return pos + ang:Forward() * offset.x + ang:Right() * offset.y + ang:Up() * offset.z
    end

    for _, name in ipairs(self.wRenderOrder) do
        local v = self.WElements[name]
        if not v then self.wRenderOrder = nil break end
        if v.hide then continue end

        local pos, ang
        if v.bone then
            pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
        else
            pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
        end
        if not pos then continue end

        if v.type == "Model" and IsValid(v.modelEnt) then
            local model = v.modelEnt

            model:SetPos(ApplyOffset(pos, ang, v.pos))

            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)
            model:SetAngles(ang)

            local matrix = Matrix()
            matrix:Scale(v.size)
            model:EnableMatrix("RenderMultiply", matrix)

            if v.material ~= "" and model:GetMaterial() ~= v.material then
                model:SetMaterial(v.material)
            elseif v.material == "" then
                model:SetMaterial("")
            end

            if v.skin and v.skin ~= model:GetSkin() then
                model:SetSkin(v.skin)
            end

            if v.bodygroup then
                for kBG, vBG in pairs(v.bodygroup) do
                    if model:GetBodygroup(kBG) ~= vBG then
                        model:SetBodygroup(kBG, vBG)
                    end
                end
            end

            if v.surpresslightning then render.SuppressEngineLighting(true) end
            render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
            render.SetBlend(v.color.a / 255)

            model:DrawModel()

            render.SetBlend(1)
            render.SetColorModulation(1, 1, 1)
            if v.surpresslightning then render.SuppressEngineLighting(false) end

        elseif v.type == "Sprite" and v.spriteMaterial then
            render.SetMaterial(v.spriteMaterial)
            render.DrawSprite(ApplyOffset(pos, ang, v.pos), v.size.x, v.size.y, v.color)

        elseif v.type == "Quad" and v.draw_func then
            local drawpos = ApplyOffset(pos, ang, v.pos)
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)

            cam.Start3D2D(drawpos, ang, v.size)
                v.draw_func(self)
            cam.End3D2D()
        end
    end
end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			local v = basetab[tab.rel]
			if (!v) then return end
			-- Technically, if there exists an element with the same name as a bone
			-- you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			if (!pos) then return end
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
		else
			bone = ent:LookupBone(bone_override or tab.bone)
			if (!bone) then return end
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r -- Fixes mirrored models
			end
		end
		return pos, ang
	end
	function SWEP:CreateModels( tab )
		if (!tab) then return end
		-- Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				-- make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end
				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
			end
		end
	end
	local allbones
	local hasGarryFixedBoneScalingYet = false
	function SWEP:UpdateBonePositions(vm)
		if self.ViewModelBoneMods then
			if (!vm:GetBoneCount()) then return end
			-- !! WORKAROUND !!
			-- We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				loopthrough = allbones
			end
			-- !! ----------- !!
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				-- !! WORKAROUND !!
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				s = s * ms
				-- !! ----------- !!
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
	end
	function SWEP:ResetBonePositions(vm)
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
	end
	--	Global utility code
	-- Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	-- Does not copy entities of course, only copies their reference.
	-- WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )
		if (!tab) then return nil end	
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) -- recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		return res
	end
end
hook.Add("TTTPlayerSpeedModifier", "genjikatanaspeed" , function(ply)
	local wep=ply:GetActiveWeapon()
	if wep and IsValid(wep) and wep:GetClass()=="genji_melee" and !ply.RandomatSuperSpeed then
		return 1.75
	end
end )
