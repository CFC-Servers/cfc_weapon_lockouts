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

-- If value is a number instead of true, it will specify that class' default lock duration.
CFCWeaponLockouts.LOCKABLE = {
    -- RPGs and similar weapons:
    weapon_rpg = true,
    ins2_atow_rpg7 = true,
    m9k_rpg7 = true,
    weapon_lfsmissilelauncher = true,

    -- Long-reload weapons (in general or compared to their peers):
    cw_tr09_aresshrike = true,
    m9k_minigun = true,
    m9k_ares_shrike = true,
    m9k_m249lmg = true,
    m9k_m60 = true,
    m9k_pkm = true,
    m9k_barret_m82 = true,
    m9k_psg1 = true,
    m9k_svu = true,
    m9k_svt40 = true,
    weapon_m249 = true,

    -- Misc:
    weapon_medkit = true,
    m9k_m98b = true
}

include( "cfc_weapon_lockouts/server/sv_locker.lua" )
