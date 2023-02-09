local CurTime = CurTime
local IsValid = IsValid

local function getSavedAmmo( ply )
    local savedAmmo = ply.SavedAmmo

    if not savedAmmo then
        ErrorNoHalt( "CFC_SavedAmmo: SavedAmmo table not found for " .. ply:Nick() )
        savedAmmo = {}
        ply.SavedAmmo = savedAmmo
    end

    return savedAmmo
end

hook.Add( "WeaponEquip", "CFC_SavedAmmo_Restore", function( wep, ply )
    local wepClass = wep:GetClass()
    local savedAmmo = getSavedAmmo( ply )

    savedAmmo = savedAmmo[wepClass]
    if not savedAmmo then return end

    wep:SetClip1( savedAmmo.Clip1 )

    if savedAmmo.Clip2 then
        wep:SetClip2( savedAmmo.Clip2 )
    end

    timer.Simple( 0, function()
        if not IsValid( wep ) then return end
        if not IsValid( ply ) then return end

        local now = CurTime()

        local nextPrimary = savedAmmo.NextPrimaryFire
        if nextPrimary and nextPrimary > now then
            wep:SetNextPrimaryFire( nextPrimary )
        end

        local nextSecondary = savedAmmo.NextSecondaryFire
        if nextSecondary and nextSecondary > now then
            wep:SetNextSecondaryFire( nextSecondary )
        end
    end )
end )


hook.Add( "PlayerDroppedWeapon", "CFC_SavedAmmo_Save", function( ply, wep )
    local wepClass = wep:GetClass()

    ply.SavedAmmo[wepClass] = {
        Clip1 = wep:Clip1(),
        Clip2 = wep:Clip2(),
        NextPrimaryFire = wep:GetNextPrimaryFire(),
        NextSecondaryFire = wep:GetNextSecondaryFire()
    }
end )

hook.Add( "PlayerSpawn", "CFC_SavedAmmo_Reset", function( ply )
    ply.SavedAmmo = {}
end )
