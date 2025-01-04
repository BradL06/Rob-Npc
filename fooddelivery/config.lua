Config = {}

Config.DeliveryPoints = {
    vector3(-1193.6, -892.5, 13.9),  -- Little Seoul
    vector3(31.4, -1770.3, 29.6),     -- Grove Street
    vector3(1133.1, -982.5, 46.4),    -- Mirror Park
    vector3(-1475.8, -674.7, 29.0),   -- Del Perro
}

Config.StartPoint = vector3(-1258.2, -1461.1, 4.3)  -- Vespucci Beach
Config.VehicleSpawnPoint = vector3(-1269.5, -1435.4, 4.3)
Config.VehicleModel = 'faggio'

Config.MinPayment = 50      -- Minimum payment per delivery
Config.MaxPayment = 200     -- Maximum payment per delivery
Config.DeliveryTime = 300   -- Time limit in seconds (5 minutes)

-- Props and animations
Config.DeliveryProp = 'prop_paper_bag_01'  -- Food delivery bag
Config.DeliveryAnimDict = 'anim@heists@box_carry@'  -- Animation dictionary
Config.DeliveryAnim = 'idle'               -- Animation name
