CFCWeaponLockouts = CFCWeaponLockouts or {}

function CFCWeaponLockouts.weaponIsLocked( ply, weaponClass )
    if not IsValid( ply ) then return end

    if not weaponClass then -- The caller only knows the weapon, and not the player
        return ply.weaponLockout_IsLocked
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

CFCWeaponLockouts.LOCKOUT_TIME = CreateConVar(
    "cfc_weaponlockouts_lockout_time",
    5,
    FCVAR_NONE,
    "The time in seconds that weapons get locked out for (default 5)",
    0,
    50000
)
CFCWeaponLockouts.WARN_BUILDUP = CreateConVar(
    "cfc_weaponlockouts_warn_buildup_window",
    0.2,
    FCVAR_NONE,
    "The time window in seconds where locked weapons get grouped together (default 0.2)",
    0,
    50000
)
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
    cfc_weapon_parachute = true
}

include( "cfc_weapon_lockouts/server/sv_locker.lua" )
