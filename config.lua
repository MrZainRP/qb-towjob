Config = {}

Config.NotifyType = 'okok'                -- Change to "qb" for standard notifications or "okok" for okokNotify notifications.

Config.mzskills = true                    -- Change to "false" to disable the use of mz-skills
-- if Config.mzskills = true, the following parameters apply: 
Config.DriverXPlow = 3                    -- Lowest amount of "driving" XP obtained for completing a tow.
Config.DriverXPhigh = 5                   -- Highest amount of "driving" XP obtained for completing a tow.
Config.BonusChance = 50                   -- Percentage chance to receive bonus based on "Driving" XP

--BONUS ITEM -- not connected with mz-skills (i.e. do not have to have mz-skills enabled to have bonus items)
Config.bonus = true                       -- Set to "true" to enable bonuses, set to "false" to disable bonus items
-- if Config.bonus = true, then the following parameters apply: 
Config.bonusitem = "blankusb"             -- The bonus item that will drop.
Config.bonuschance = 15                   -- The chance of a bonus item dropping 

--PAYMENT--
Config.Lowpay = 500                       -- Lowest cash value (depends on payment formula - not the actual amount received).
Config.Highpay = 750                      -- Highest cash value (depends on payment formula - not the actual amount received).
Config.Paymenttax = 15                    -- Tax payable on income generated.

--BONUS OUTPUT--
--Level 1
Config.Level1Low = 1
Config.Level1High = 5
--Level 2
Config.Level2Low = 3
Config.Level2High = 8
--Level 3
Config.Level3Low = 5
Config.Level3High = 12
--Level 4
Config.Level4Low = 8
Config.Level4High = 16
--Level 5
Config.Level5Low = 10
Config.Level5High = 18
--Level 6
Config.Level6Low = 13
Config.Level6High = 22
--Level 7
Config.Level7Low = 15
Config.Level7High = 26
--Level 8
Config.Level8Low = 18
Config.Level8High = 30

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'

Config.BailPrice = 250

Config.Vehicles = {
    ["flatbed"] = "Flatbed",
}

Config.Locations = {
    ["main"] = {
        label = "Towing HQ",
        coords = vector4(471.39, -1311.03, 29.21, 114.5),
    },
    ["vehicle"] = {
        label = "Flatbed",
        coords = vector4(489.65, -1331.82, 29.33, 306.5),
    },
    ["dropoff"] = {
        label = "Vehicle Drop Off Location",
        coords = vector3(491.00, -1314.69, 29.25)
    },
    ["towspots"] = {
        [1] =  {model = "sultanrs", coords = vector3(-2480.8720703125, -211.96409606934, 17.397672653198)},
        [2] =  {model = "zion", coords = vector3(-2723.392578125, 13.207388877869, 15.12806892395)},
        [3] =  {model = "oracle", coords = vector3(-3169.6235351563, 976.18127441406, 15.038360595703)},
        [4] =  {model = "chino", coords = vector3(-3139.7568359375, 1078.7182617188, 20.189767837524)},
        [5] =  {model = "baller2", coords = vector3(-1656.9357910156, -246.16479492188, 54.510955810547)},
        [6] =  {model = "stanier", coords = vector3(-1586.6560058594, -647.56115722656, 29.441320419312)},
        [7] =  {model = "washington", coords = vector3(-1036.1470947266, -491.05856323242, 36.214912414551)},
        [8] =  {model = "buffalo", coords = vector3(-1029.1884765625, -475.53167724609, 36.416831970215)},
        [9] =  {model = "feltzer2", coords = vector3(75.212287902832, 164.8522644043, 104.69123077393)},
        [10] = {model = "asea", coords = vector3(-534.60491943359, -756.71801757813, 31.599143981934)},
        [11] = {model = "fq2", coords = vector3(487.24212646484, -30.827201843262, 88.856712341309)},
        [12] = {model = "jackal", coords = vector3(-772.20111083984, -1281.8114013672, 4.5642876625061)},
        [13] = {model = "sultanrs", coords = vector3(-663.84173583984, -1206.9936523438, 10.171216011047)},
        [14] = {model = "zion", coords = vector3(719.12451171875, -767.77545166016, 24.892364501953)},
        [15] = {model = "oracle", coords = vector3(-970.95465087891, -2410.4453125, 13.344270706177)},
        [16] = {model = "chino", coords = vector3(-1067.5234375, -2571.4064941406, 13.211874008179)},
        [17] = {model = "baller2", coords = vector3(-619.23968505859, -2207.2927246094, 5.5659561157227)},
        [18] = {model = "stanier", coords = vector3(1192.0831298828, -1336.9086914063, 35.106426239014)},
        [19] = {model = "washington", coords = vector3(-432.81033325195, -2166.0505371094, 9.8885231018066)},
        [20] = {model = "buffalo", coords = vector3(-451.82403564453, -2269.34765625, 7.1719741821289)},
        [21] = {model = "asea", coords = vector3(939.26702880859, -2197.5390625, 30.546691894531)},
        [22] = {model = "fq2", coords = vector3(-556.11486816406, -1794.7312011719, 22.043060302734)},
        [23] = {model = "jackal", coords = vector3(591.73504638672, -2628.2197265625, 5.5735430717468)},
        [24] = {model = "sultanrs", coords = vector3(1654.515625, -2535.8325195313, 74.491394042969)},
        [25] = {model = "oracle", coords = vector3(1642.6146240234, -2413.3159179688, 93.139915466309)},
        [26] = {model = "chino", coords = vector3(1371.3223876953, -2549.525390625, 47.575256347656)},
        [27] = {model = "baller2", coords = vector3(383.83779907227, -1652.8695068359, 37.278503417969)},
        [28] = {model = "stanier", coords = vector3(27.219129562378, -1030.8818359375, 29.414621353149)},
        [29] = {model = "washington", coords = vector3(229.26435852051, -365.91101074219, 43.750762939453)},
        [30] = {model = "asea", coords = vector3(-85.809432983398, -51.665500640869, 61.10591506958)},
        [31] = {model = "fq2", coords = vector3(-4.5967531204224, -670.27124023438, 31.85863494873)},
        [32] = {model = "oracle", coords = vector3(-111.89884185791, 91.96940612793, 71.080169677734)},
        [33] = {model = "zion", coords = vector3(-314.26129150391, -698.23309326172, 32.545776367188)},
        [34] = {model = "buffalo", coords = vector3(-366.90979003906, 115.53963470459, 65.575706481934)},
        [35] = {model = "fq2", coords = vector3(-592.06726074219, 138.20733642578, 60.074813842773)},
        [36] = {model = "zion", coords = vector3(-1613.8572998047, 18.759860992432, 61.799819946289)},
        [37] = {model = "baller2", coords = vector3(-1709.7995605469, 55.105819702148, 65.706237792969)},
        [38] = {model = "chino", coords = vector3(-521.88830566406, -266.7805480957, 34.940990447998)},
        [39] = {model = "washington", coords = vector3(-451.08666992188, -333.52026367188, 34.021533966064)},
        [40] = {model = "baller2", coords = vector3(322.36480712891, -1900.4990234375, 25.773607254028)},
    }
}
