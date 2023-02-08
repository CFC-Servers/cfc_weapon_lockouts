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
    if not savedAmmo then return end

    savedAmmo = savedAmmo[wepClass]
    if not savedAmmo then return end

    wep:SetClip1( savedAmmo.Clip1 )
    wep:SetClip2( savedAmmo.Clip2 )

    wep:SetNextPrimaryFire( savedAmmo.NextPrimaryFire )
    wep:SetNextSecondaryFire( savedAmmo.NextSecondaryFire )

    wep:SetSequence( savedAmmo.Sequence )
end )

hook.Add( "PlayerDroppedWeapon", "CFC_SavedAmmo_Save", function( ply, wep )
    local wepClass = wep:GetClass()
    local nextPrimary = wep:GetNextPrimaryFire()

    ply.SavedAmmo[wepClass] = {
        Clip1 = wep:Clip1(),
        Clip2 = wep:Clip2(),
        NextPrimaryFire = wep:GetNextPrimaryFire(),
        NextSecondaryFire = wep:GetNextSecondaryFire(),
        Sequence = wep:GetSequence(),
    }
end )

hook.Add( "PlayerSpawn", "CFC_SavedAmmo_Reset", function( ply )
    ply.SavedAmmo = {}
end )
