CFCWeaponLockouts = CFCWeaponLockouts or {}

function CFCWeaponLockouts.weaponIsLocked( ply, weaponClass )
    if not IsValid( ply ) then return end

    if not weaponClass then --The caller only knows the weapon, and not the player
        return ply.weaponLockoutIsLocked
    end

    ply.weaponLockouts = ply.weaponLockouts or {}

    return ply.weaponLockouts[weaponClass]
end

hook.Add( "EntityFireBullets", "CFC_WeaponLockouts_BlockShots", function( ent, data )
    if not IsValid( ent ) or not ent:IsPlayer() then return end

    local wep = ent:GetActiveWeapon()

    if not IsValid( wep ) or not wep:IsWeapon() then return end

    if CFCWeaponLockouts.weaponIsLocked( ent, wep:GetClass() ) then return false end
end )

if CLIENT then
    include( "cfc_weapon_lockouts/client/cl_net.lua" )
    return
end

util.AddNetworkString( "CFC_WeaponLockouts_LockWeapon" )
util.AddNetworkString( "CFC_WeaponLockouts_UnlockWeapon" )

CFCWeaponLockouts.LOCKOUT_TIME = 5
CFCWeaponLockouts.WARN_BUILDUP = 0.2
CFCWeaponLockouts.NOT_LOCKABLE = {
    gmod_camera = true,
    gmod_tool = true,
    none = true,
    weapon_physgun = true,
    weapon_physcannon = true,
    pac_357 = true,
    pac_ar2 = true,
    pac_crossbow = true,
    pac_crowbar = true,
    pac_dual = true,
    pac_pistol = true,
    pac_rpg = true,
    pac_shotgun = true,
    pac_slam = true,
    pac_smg = true,
    laserpointer = true,
    remotecontroller = true,
    weapon_simremote = true,
    weapon_simrepair = true,
}

include( "cfc_weapon_lockouts/server/sv_locker.lua" )
