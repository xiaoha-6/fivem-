Config = {}

-- 菜单版本设置
-- v1 = nh-context v1 使用 arg1
-- v2 = nh-context v2
-- zf = nh-context v1 使用 args / zf_context
-- qb = qb-menu
-- ox = ox_lib
Config.SDMenuVersion = 'ox'

-- 输入版本设置
-- v1 = nh-keyboard v1
-- v2 = nh-keyboard v2
-- zf = zf_dialog
-- qb = qb-input
-- ox = ox_lib
Config.SDInputVersion = 'ox'

-- EMS 车辆配置
Config.EMSVehicles = {
    [0] = {spawnName = 'ambulance', label = 'Ambulance', spawnLoc = vector4(287.81, -589.1, 42.14, 340.2)}, -- 陆地
    [1] = {spawnName = 'polmav', label = 'Med 1', spawnLoc = vector4(352.33, -587.89, 74.16, 68.53)}, -- 空中
    [2] = {spawnName = 'seashark', label = 'Boat 1', spawnLoc = 'atPlayer'} -- 海上
}

-- 其他配置
Config.Locale = 'en'
Config.RespawnCoords = vector3(292.68, -1441.14, 28.97)
Config.RemoveItemsOnDeath = true
Config.BlipTimer = 5 -- 地图标记持续时间（以分钟为单位）

Config.UseBeds = true
Config.NancyPos = vector3(308.854, -594.262, 42.300)

-- 床位位置
Config.BedLocs = {
    vector4(309.54, -577.50, 43.3, 339.0),
    vector4(314.03, -579.20, 43.3, 339.0),
    vector4(319.48, -581.13, 43.3, 339.0),
}

Config.Grandmas = true -- 黑市复活地点
Config.GrandmaCoords = vector3(742.37, 4169.76, 40.09)

-- 武器配置
Config.Guns = {
    453432689, 3219281620, 1593441988, -1716589765, -1076751822, -771403250, 137902532, -598887786, -1045183535,
    584646201, 911657153, 1198879012, 324215364, -619010992, 736523883, 2024373456, -270015777, 171789620,
    -1660422300, 2144741730, 3686625920, 1627465347, -1121678507, -1074790547, 961495388, -2084633992, 4208062921,
    -1357824103, -1063057011, 2132975508, 1649403952, 100416529, 205991906, 177293209, -952879014, 487013001,
    2017895192, -1654528753, -494615257, -1466123874, 984333226, -275439685, 317205821, -1568386805, -1312131151,
    1119849093, 2138347493, 1834241177, 1672152130, 1305664598, 125959754
}

-- 近战武器配置
Config.Melee = {
    -1569615261, -1716189206, 1737195953, 1317494643, -1786099057, -2067956739, 1141786504, -102323637,
    -1834847097, -102973651, -656458692, -581044007, -1951375401, -538741184, -1810795771, 419712736, -853065399
}

-- 爆炸物配置
Config.Explosions = {
    -1813897027, 741814745, -1420407917, -1600701090, 615608432, 101631238, 883325847, 1233104067, 600439132,
    126349499, -37975472, -1169823560
}

-- 医院地图标记和坐标
Config.HospitalBlipCoords = vector3(292.3, -583.6, 43.2)
Config.HospitalCoords = vector3(292.3, -583.6, 43.2)

-- 补给物品配置
Config.Restock = {
    [0] = {item = 'medbag', label = 'Medical Bag'},
    [1] = {item = 'bandage', label = 'Bandage'},
    [2] = {item = 'medikit', label = 'Medkit'}
}
