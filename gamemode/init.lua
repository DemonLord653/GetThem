AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile("cl_shop.lua")
AddCSLuaFile("cl_score.lua")

include( "shared.lua" )
include("rounds.lua") -- Enable/disable rounds.
include("cl_shop.lua")


/*
  ________        __ ___________.__
 /  _____/  _____/  |\__    ___/|  |__   ____   _____
/   \  ____/ __ \   __\|    |   |  |  \_/ __ \ /     \
\    \_\  \  ___/|  |  |    |   |   Y  \  ___/|  Y Y  \
 \______  /\___  >__|  |____|   |___|  /\___  >__|_|  /
        \/     \/                    \/     \/      \/
*/




if ( SERVER ) then

	XP_STARTAMOUNT = 0

	function xFirstSpawn( ply )
		local experience = ply:GetPData( "xp" )

		if experience == nil then
			ply:SetPData("xp", XP_STARTAMOUNT)
			ply:SetXp( XP_STARTAMOUNT )
		else
		ply:SetXp( experience )
		end
	end

	hook.Add( "PlayerInitialSpawn", "xPlayerInitialSpawn", xFirstSpawn )



	function PrintXp( pl )
		pl:ChatPrint( "Your xp is: " .. pl:GetXp() )
	end

	function xPlayerDisconnect( ply )
		print("Player Disconnect: Xp saved to SQLLite and TXT")
		ply:SaveXp()
		ply:SaveXpTXT()
	end

	concommand.Add( "xp_get", PrintXp )

end

	///////////////////////////////////////////////////
	/////////////////SHOP!!////////////////////////////
	//////////////////////////////////////////////////
function Shop( ply )
	ply:ConCommand("shop")
end
hook.Add("ShowHelp", "MyHook", Shop)




/*
function ENT:OnTakeDamage(dmginfo)
	self:SetHealth(self:GetHealth() - dmginfo:GetDamage())
	for k, ply in pairs( player.GetAll() ) do
	ply:SetHealth( ply:Health() + 10 )
	end
end
*/

	///////////////////////////////////////////////////
	/////////////////SPAWN/////////////////////////////
	//////////////////////////////////////////////////

function GM:PlayerInitialSpawn(ply)
	ply:PrintMessage( HUD_PRINTTALK, "[GetThem]Welcome to the server, " .. ply:Nick() )
	local teamn = math.random(1, 2)
    math.randomseed(os.time())

    if team.NumPlayers(1) < team.NumPlayers(2) then
    ply:SetTeam(1)
	ply:SetModel( "models/player/hostage/hostage_02.mdl" )
    else
    ply:SetTeam(2)
	ply:SetModel( "models/player/Group03/Female_04.mdl" )
	end
end

	////////////////////////////////////////////////////
	/////////////////////CHANGE TEAM FUNCTION///////////
	////////////////////////////////////////////////////

function GM:PlayerLoadout(ply)
    if (ply:Team() == 1) then
        ply:Give("weapon_crowbar")
		ply:PrintMessage( HUD_PRINTTALK, "[GetThem]You are in team Blue!");
    else
        ply:Give("weapon_crowbar")
		ply:PrintMessage( HUD_PRINTTALK, "[GetThem]You are in team Red!");
end
	end

function GM:Initialize()
    timer.Create( "Healthgain", 1, 0, function()
	for k, ply in pairs( player.GetAll() ) do
if ply:Health() < ply:GetMaxHealth() then
	ply:SetHealth( ply:Health() + 1 )
	end
	end
	end)
end
	///////////////////////////////////////////////////
	/////////////////SPAWN NPC/////////////////////////
	//////////////////////////////////////////////////

function KeyPressed (ply, key)
if ( key == IN_USE ) then

if (ply:Health()>10) then
if (ply:Team() == 1) then
	SetGlobalInt("NPCteam1", GetGlobalInt("NPCteam1") + 1 )
	ply:SetHealth( ply:Health() - 10 )
	ply:AddFrags( 1 )
	local npc = ents.Create("npc_citizen")
	npc:AddEntityRelationship(player.GetByID(1), D_NU, 99 )
	npc:SetPos(ply:GetEyeTrace().HitPos)
	npc:SetHealth(99)
	npc:Spawn()
	npc:SetName("TEAM1")

else
	SetGlobalInt("NPCteam2", GetGlobalInt("NPCteam2") + 1 )
	ply:SetHealth( ply:Health() - 10 )
	ply:AddFrags( 1 )
	local npc = ents.Create("npc_citizen")
	npc:AddEntityRelationship(player.GetByID(1), D_NU, 99 )
	npc:SetPos(ply:GetEyeTrace().HitPos)
	npc:SetHealth(99)
	npc:Spawn()
	npc:SetName("TEAM2")
	npc:DrawShadow( false )
	npc:SetColor(255, 0, 0, 255)

	end
		end
			end
				end

hook.Add( "KeyPress", "KeyPressedHook", KeyPressed )

hook.Add("PlayerCanPickupWeapon","NoNPCPickups", function(ply,wep)
	if( wep.IsNPCWeapon ) then return false end
end )
	///////////////////////////////////////////////////
	/////////////////DONT MOVE NPC////////////////////
	//////////////////////////////////////////////////

function GM:Think()

	for _, npc in pairs( ents.FindByClass( "npc_*" ) ) do

		if ( IsValid( npc ) && npc:IsNPC() && npc:GetMovementActivity() != ACT_COVER  ) then
			npc:SetMovementActivity( ACT_COVER  )
		end

	end

end


	///////////////////////////////////////////////////
	/////////////////KILLED FUNCTIONS/////////////////
	//////////////////////////////////////////////////

function GM:OnNPCKilled( victim, killer, weapon )
	if victim:GetName() == "SpecialOne" then
	killer:AddXp( math.random(600, 1000) )
	for k,v in pairs(player.GetAll()) do
		v:PrintMessage( HUD_PRINTTALK, "[GetThem]A Special NPC has been killed.");
	end
	end

	if(killer:IsPlayer()) then
	if killer:Team() == 1 and victim:GetName() == "TEAM1" then
	SetGlobalInt("NPCteam1", GetGlobalInt("NPCteam1") - 1)
	killer:AddXp( math.random(-600, -1000) )
	else
	if killer:Team() == 2 and victim:GetName() == "TEAM2" then
	SetGlobalInt("NPCteam2", GetGlobalInt("NPCteam2") - 1 )
	killer:AddXp( math.random(-600, -1000) )
	end

    if killer:Team() == 1 and victim:GetName() == "TEAM2" then
	killer:AddXp( math.random(60, 100) )
	killer:SetNWInt("killcounter", killer:GetNWInt("killcounter") + 1)
	SetGlobalInt("NPCteam2", GetGlobalInt("NPCteam2") - 1)

	else
	if killer:Team() == 2 and victim:GetName() == "TEAM1" then
	killer:AddXp( math.random(60, 100) )
	killer:SetNWInt("killcounter", killer:GetNWInt("killcounter") + 1)
	SetGlobalInt("NPCteam1", GetGlobalInt("NPCteam1") - 1)
	end
	end
end
	hook.Call("HUDPaint");
end
end


function GM:PlayerDeath( victim, inflictor, killer )
		if(killer:IsPlayer()) then
	if killer:Team() == 1 and victim:Team() == 2 then
	killer:AddXp( math.random(60, 500) )
	else
	if killer:Team() == 2 and victim:Team() == 1 then
	killer:AddXp( math.random(60, 500) )
	end
	end
	end
end

--DropWeapon When Killed
function GM:DoPlayerDeath (ply , attacker, damage)
	local wep = ply:GetActiveWeapon()
	if (wep:IsValid()) then ply:DropWeapon(wep)end
end


	///////////////////////////////////////////////////
	/////////////////AUTO - DOOR FUNCTION/////////////
	//////////////////////////////////////////////////

local DoorTypes = { "func_door", "func_door_rotating", "prop_door_rotating" }

timer.Create( "DoorCheck", 1, 0, function()
    for k,v in pairs(DoorTypes) do
        for k2,v2 in pairs(ents.FindByClass(v)) do
            local EntTable = ents.FindInSphere(v2:GetPos(), 80)
            local PlayerTable = {}
            for _,ent in pairs(EntTable) do
                if ent:IsPlayer() then
                    table.insert(PlayerTable, ent)
                end
            end

            if table.Count(PlayerTable) > 0 then
                v2:Fire("open", "")
            else
                v2:Fire("close", "")
            end
        end
    end
end )


/*
function GM:PlayerDeath( victim, inflictor, attacker )
	if (attacker ~= victim) then
	attacker:AddXp( math.random(100, 200) )
	attacker:SetNWInt("killcounter", attacker:GetNWInt("killcounter") + 1)
    end


end
*/

	//////////////////////////////////////////////////
	/////////////////OLD '//' vieuw-function///////////
	//////////////////////////////////////////////////
function ISaid( ply, text, team )
			--local aliveNPCs1 = #ents.FindByName( "TEAM1" )
			--local aliveNPCs2 = #ents.FindByName( "TEAM2" )
			local SpecialOne = #ents.FindByName( "SpecialOne" )


    if (string.sub(text, 1, 2) == "//") then
	for k, v in ipairs( player.GetAll() ) do
	--v:PrintMessage( HUD_PRINTTALK, "The Blue Team Has " .. tostring( aliveNPCs1 ) .. " NPC's, The Red Team Has " .. tostring( aliveNPCs2 ) .. " NPC's." )
	v:PrintMessage( HUD_PRINTTALK, "There are " .. tostring( SpecialOne ) .. " Special NPC's." )

	end
	end

end

hook.Add( "PlayerSay", "ISaid", ISaid );

	///////////////////////////////////////////////////
	/////////////////ADMIN FUNCTIONS//////////////////
	//////////////////////////////////////////////////

function change_team( ply )
if (ply:Team() == 1) then
  ply:SetTeam(2)
  ply:PrintMessage( HUD_PRINTTALK, "[GetThem]You have been changed from team!");
else
  ply:SetTeam(1)
  ply:PrintMessage( HUD_PRINTTALK, "[GetThem]You have been changed from team!");
end

end
concommand.Add( "change_team", change_team )


function GM:PlayerNoClip(ply, on)
	if ply:IsAdmin() then
	return true
	end
	return false
end

function RestartMap(ply)
if ply:IsAdmin() then
game.CleanUpMap()
SetGlobalInt("NPCteam1", 0)
SetGlobalInt("NPCteam2", 0)

	for k,v in pairs(player.GetAll()) do
		v:Spawn()
		--v:PrintMessage( HUD_PRINTTALK, "[GetThem]The map has been cleaned!");
	end
end
end
concommand.Add( "clean_map", RestartMap )

function SpecialOne(ply)
if ply:IsAdmin() then
	for k,v in pairs(player.GetAll()) do
		v:PrintMessage( HUD_PRINTTALK, "[GetThem]A special NPC has spawned!");
	end
	local npc = ents.Create("npc_pigeon")
	npc:AddEntityRelationship(player.GetByID(1), D_NU, 99 )
	npc:SetPos(ply:GetEyeTrace().HitPos)
	npc:SetHealth(99)
	npc:Spawn()
	for k, v in pairs( ents.GetAll() ) do
	npc:DrawShadow( false )
	npc:SetName("SpecialOne")
	end
end
end
concommand.Add( "spawn_special", SpecialOne )

function PhysgunGive(ply)
if ply:IsAdmin() then
ply:Give("weapon_physgun")
end
end
concommand.Add( "give_physgun", PhysgunGive )

--DropWeapon command
local function DropWeapon(ply,cmd,args)
	if !ply:Alive() then return end

	local CurWeap = ply:GetActiveWeapon()

	if IsValid( CurWeap ) then
		ply:DropWeapon( CurWeap )
	end
end
concommand.Add( "drop", DropWeapon )


 function spawn_prop1(ply)
if ply:IsAdmin() then
barrel=ents.Create("prop_physics")
barrel:SetModel("models/props_lab/blastdoor001c.mdl")
barrel:SetPos(ply:GetEyeTrace().HitPos)
barrel:Spawn()
end
end
concommand.Add( "spawn_prop1", spawn_prop1 )


	///////////////////////////////////////////////////
	///////////////// XP  ////////////////////////////
	//////////////////////////////////////////////////

local meta = FindMetaTable("Player")

function meta:AddXp( amount )
	local current_xp = self:GetXp()
	self:SetXp( current_xp + amount )
end

function meta:SetXp( amount )
	self:SetNetworkedInt( "Xp", amount )
	self:SaveXp()
end

function meta:SaveXp()
	local experience = self:GetXp()
	self:SetPData( "xp", experience )
end

function meta:SaveXpTXT()
	file.Write( gmod.GetGamemode().Name .."/Xp/".. string.gsub(self:SteamID(), ":", "_") ..".txt", self:GetXpString() )
end

function meta:TakeXp( amount )
   self:AddXp( -amount )
end

function meta:GetXp()
	return self:GetNetworkedInt( "Xp" )
end



	/////////////////////////////////////////////////////////////
	/////////////////PAIDAY FUNCTION/////////////////////////////
	//TEAM 1 PAYDAY is diffrent than TEAM 2? now global..////////
		timer.Create( "GivePoints", 600, 0, function() //300
			local aliveNPCs1 = #ents.FindByName( "TEAM1" )
			local aliveNPCs2 = #ents.FindByName( "TEAM2" )
			for k, v in ipairs( player.GetAll() ) do
				v:AddXp( (aliveNPCs1 + aliveNPCs2) * 5 )
				v:PrintMessage( HUD_PRINTTALK, "[PAYDAY!]Every NPC is money, here are your " .. tostring( (aliveNPCs1 + aliveNPCs2) * 5 ) .. " points!");
			end
		end )
