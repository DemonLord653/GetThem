if SERVER then

AddCSLuaFile()

SWEP.Weight = 5

SWEP.Base = "weapon_base"

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

elseif CLIENT then

SWEP.PrintName = "GT Spawner"

SWEP.Slot = 0
SWEP.SlotPos = 1

SWEP.DrawAmmo = false

SWEP.DrawCrosshair = true

end

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = 3
SWEP.Secondary.DefaultClip = 3
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "gwDashCharges"

SWEP.SwingSound = "Weapon_Crowbar.Single"
SWEP.HitSound = "Weapon_Crowbar.Melee_Hit"
SWEP.HitWorldSound = "Weapon_Crowbar.Melee_HitWorld"

SWEP.AllowDrop = false
SWEP.Kind = WEAPON_MELEE
SWEP.HoldType = "melee"

SWEP.Delay = 0.7
SWEP.Range = 85
SWEP.Damage = 20
SWEP.AutoSpawnable = false

SWEP.Author = "DarthSwedo"
SWEP.Contact = "matthieu19@msn.com"
SWEP.Purpose = "Spawns Human"
SWEP.Instructions = "Mouse 2"

SWEP.Category = "weapons"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

local ShootSound = Sound("Metal.SawbladeStick")

function SWEP:Initialize()
if CLIENT then
	local ply = LocalPlayer()
	if(ply:Team() == 1) then
	ply:GetViewModel():SetColor(Color(0,0,255,255))
	else
	ply:GetViewModel():SetColor(Color(255,0,0,255))
	end
end
end

function SWEP:Reload()
end

function SWEP:Think()
end


function SWEP:spawn_humans ()
local tr = self.Owner:GetEyeTrace()

--We now exit if this function is not running serverside
if (!SERVER) then return end
local ply = self:GetOwner()
if (ply:Health()>10) then
if (ply:Team() == 1) then
	SetGlobalInt("NPCteam1", GetGlobalInt("NPCteam1") + 1 )
	ply:SetHealth( ply:Health() - 10 )
	ply:AddFrags( 1 )
	local npc = ents.Create("simple_human")
	npc:SetPos(ply:GetEyeTrace().HitPos)
	npc:SetHealth(99)
	npc:Spawn()
	npc:SetName("TEAM1")

else
	SetGlobalInt("NPCteam2", GetGlobalInt("NPCteam2") + 1 )
	ply:SetHealth( ply:Health() - 10 )
	ply:AddFrags( 1 )
	local npc = ents.Create("simple_human")
	npc:SetPos(ply:GetEyeTrace().HitPos)
	npc:SetHealth(99)
	npc:Spawn()
	npc:SetName("TEAM2")
	npc:DrawShadow( false )
	npc:SetColor(255, 0, 0, 255)

	end
		end
end
function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire(CurTime() + self.Delay)

	if self.Owner.LagCompensation then
			self.Owner:LagCompensation(true)
	end
	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + (self.Owner:GetAimVector() * self.Range)
	trace.filter = self.Owner
	trace.mins = Vector(1, 1, 1) * - 10
	trace.maxs = Vector(1, 1, 1) * 10
	trace = util.TraceLine(trace)
	self.Owner:LagCompensation(false)

	if SERVER then self.Owner:EmitSound(self.SwingSound) end

	if trace.Fraction < 1 and trace.HitNonWorld and trace.Entity:IsPlayer() then
			if SERVER then
					trace.Entity:TakeDamage( self.Damage * 2, self.Owner, self )
					self.Owner:EmitSound(self.HitSound)
			end
			self:SendWeaponAnim(ACT_VM_HITCENTER)
	elseif trace.Hit and trace.Entity then
			if SERVER then
					trace.Entity:TakeDamage( self.Damage * 3, self.Owner, self )
					self.Owner:EmitSound(self.HitSound)
			end
			self:SendWeaponAnim(ACT_VM_HITCENTER)
	else
			self:SendWeaponAnim(ACT_VM_MISSCENTER)
	end
	self.Owner:SetAnimation( PLAYER_ATTACK1 )


end
--Throw a wooden chair on secondary attack
function SWEP:SecondaryAttack()
self:spawn_humans()
end
