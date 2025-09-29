CFCWeaponLockouts = CFCWeaponLockouts or {}

function CFCWeaponLockouts.weaponIsLocked( ply, weaponClass )
    if not IsValid( ply ) then return end

    if not weaponClass then -- The caller only knows the weapon, and not the player
        return ply.weaponLockout_IsLocked
    end

    ply.weaponLockouts = ply.weaponLockouts or {}

    return ply.weaponLockouts[weaponClass]
end

hook.Add( "EntityFireBullets", "CFC_WeaponLockouts_BlockShots", function( ent )
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

-- Weapons that should never be locked out.
CFCWeaponLockouts.NOT_LOCKABLE = {
    -- GMod:
    gmod_camera = true,
    gmod_tool = true,
    weapon_fists = true,
    weapon_physgun = true,

    -- HL2:
    weapon_bugbait = true,
    weapon_crowbar = true,
    weapon_frag = true,
    weapon_physcannon = true,
    weapon_slam = true,
    weapon_stunstick = true,

    -- HLS:
    weapon_crowbar_hl1 = true,
    weapon_handgrenade = true,
    weapon_satchel = true,
    weapon_snark = true,
    weapon_tripmine = true,

    -- CFC:
    cfc_antigrav_grenade = true,
    cfc_charged_cluster_grenade = true,
    cfc_cluster_grenade = true,
    cfc_curse_grenade = true,
    cfc_discombob = true,
    cfc_cinder_block = true,
    money_gun = true,
    cfc_prop_repair = true,
    cfc_rotten_tomato = true,
    cfc_weapon_shaped_charge = true,
    cfc_slappers = true,
    cfc_stone = true,
    cfc_super_cluster_grenade = true,
    cfc_super_cinder_block = true,
    cfc_super_slappers = true,

    -- CW2:
    cw_extrema_ratio_official = true,
    cw_flash_grenade = true,
    cw_frag_grenade = true,
    cw_smoke_grenade = true,
    cw_ws_pamachete = true,

    -- M9K:
    m9k_damascus = true,
    m9k_fists = true,
    m9k_harpoon = true,
    m9k_knife = true,
    m9k_machete = true,
    m9k_nitro = true,
    m9k_proxy_mine = true,
    m9k_sticky_grenade = true,
    m9k_suicide_bomb = true,

    -- PAC SWEPS:
    pac_357 = true,
    pac_crossbow = true,
    pac_crowbar = true,
    pac_dual = true,
    pac_knife = true,
    pac_pistol = true,
    pac_ar2 = true,
    pac_rpg = true,
    pac_shotgun = true,
    pac_slam = true,
    pac_smg = true,

    -- Wiremod:
    laserpointer = true,
    remotecontroller = true,

    -- Simfphys:
    weapon_simremote = true,
    weapon_simrepair = true,

    -- Glide:
    glide_homing_launcher = true,
    glide_repair = true,

    -- Simple Weapons: CSS
    simple_css_flashbang = true,
    simple_css_hegrenade = true,
    simple_css_knife = true,
    simple_css_smokegrenade = true,

    -- Simple Weapons: HL2
    simple_hl2_crowbar = true,
    simple_hl2_frag = true,
    simple_hl2_stunstick = true,

    -- TFA Modern Warfare
    tfa_l4d2mw_bat = true,
    tfa_l4d2mw_baton = true,
    tfa_l4d2mw_crowbar = true,
    tfa_l4d2mw_etool = true,
    tfa_l4d2mw_fireaxe = true,
    tfa_l4d2mw_golfclub = true,
    tfa_l4d2mw_katana = true,
    tfa_l4d2mw_knife = true,
    tfa_l4d2mw_machete = true,
    tfa_l4d2mw_metalbat = true,
    tfa_l4d2mw_pitchfork = true,
    tfa_l4d2mw_riotshield = true,
    tfa_l4d2mw_shovel = true,
    tfa_l4d2mw_sledgehammer = true,

    -- Misc:
    acf_torch = true,
    weapon_empty_hands = true,
    none = true,
    weapon_crapvidcam = true,
    keypad_cracker = true,
}

-- Allows for certain weapons to have custom lockout durations.
CFCWeaponLockouts.LOCK_DURATIONS = {
    -- GMod:
    weapon_medkit = 7,

    -- CFC:
    cfc_graviton_gun = 1,
    cfc_ion_cannon = 1,
    cfc_trash_blaster = 1,
}

include( "cfc_weapon_lockouts/server/sv_locker.lua" )
