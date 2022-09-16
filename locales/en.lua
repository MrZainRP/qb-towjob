local Translations = {
    error = {
        finish_work = "Tow truck can be returned after you complete your work.",
        vehicle_not_correct = "This is either not the right car or you aren't close enough",
        failed = "Job failed",
        not_towing_vehicle = "You need to be in the tow truck...",
        too_far_away = "You are too far away.",
        no_work_done = "You have not done any work yet",
        no_deposit = "$%{value} deposit required",
    },
    success = {
        paid_with_cash = "$%{value} paid in cash",
        paid_with_bank = "$%{value} paid from your bank",
        refund_to_cash = "$%{value} refunded to you in cash",
        you_earned = "You earned $%{value}",
    },
    menu = {
        header = "Available Tow Trucks",
        close_menu = "⬅ Close Menu",
    },
    mission = {
        delivered_vehicle = "You have successfully brought the vehicle to the Depot",
        get_new_vehicle = "A new client is seeking your assistance with their vehicle",
        towing_vehicle = "Loading up the vehicle",
        goto_depot = "Take the vehicle back to the Depot",
        vehicle_towed = "Vehicle has been towed",
        untowing_vehicle = "Removing the vehicle",
        vehicle_takenoff = "Removed client vehicle",
    },
    info = {
        tow = "Load a car up to the tow truck to take it back to the Depot",
        toggle_npc = "Go on shift",
        skick = "Attempted exploit abuse",
    },
    label = {
        payslip = "Payslip",
        vehicle = "Vehicle",
        npcz = "Client vehicle",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
