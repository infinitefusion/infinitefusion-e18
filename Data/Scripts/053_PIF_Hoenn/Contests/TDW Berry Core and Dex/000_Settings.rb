module Settings
    #====================================================================================
    #================================ Berrydex Settings =================================
    #====================================================================================
    
        #--------------------------------------------------------------------------------
        # Switch ID to be set to true to have access to the Berrydex.
        # Set to 0 to always allow access.
        #--------------------------------------------------------------------------------	
        ACCESS_BERRYDEX_SWITCH_ID         = 0

        #--------------------------------------------------------------------------------
        # If true, the Berrydex will prepend the berry name with its number, determined
        # by the order it appears in berry_dexes.txt
        #--------------------------------------------------------------------------------		
        BERRYDEX_SHOW_NUMBER             = true

        #--------------------------------------------------------------------------------
        # If true, the images for berries in the Berrydex will use those found in the
        # Tag Icons folder, instead of their item icons. Item icons will be the fallback
        # if a Tag Icon image does not exist for a berry.
        #--------------------------------------------------------------------------------		
        BERRYDEX_USE_TAG_ICONS           = true

        #--------------------------------------------------------------------------------
        # Defines how DryingPerHour values appear in the Berry Dex's Plant tab. You can
        # define each range to meet your needs, or add additional ranges.
        # [Label to appear in the Dex, min value (inclusive), max value (inclusive)]
        #--------------------------------------------------------------------------------		
        BERRYDEX_DRY_RATE_CATEGORIES     = [
            [_INTL("Slow"),0,6],
            [_INTL("Average"),7,13],
            [_INTL("Fast"),14,22],
            [_INTL("Very Fast"),23,99]
        ]

end