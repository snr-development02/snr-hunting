


--===================== SETTİNGS ============================--
Config = { --SELLER NPC İTEMS
    Detaylar = {
        ["Geyik Eti"] = {
            GerekliItemler = {
                {Esya = 'geyiketi', Miktar = 1, TemizParaMiktar = 1}
            },
            VerilenEsya = {Item = 'cash', labeltarih = 'Geyik Eti', Miktar = 20000, TemizParaMiktar = 10000}
        },
        ["Geyik Derisi"] = {
            GerekliItemler = {
                {Esya = 'geyikderisi', Miktar = 1, TemizParaMiktar = 1}
            },
            VerilenEsya = {Item = 'cash', labeltarih = 'Geyik Derisi', Miktar = 20000, TemizParaMiktar = 10000}
        }
    }
}

--NPC SİDE
Config.NPCOlsunmu = false -- Do you want npc?(true/false) // NPC istiyormusun?(true/false)
Config.NPCKodu = "a_m_m_eastsa_02" -- NPC Hash
Config.NPCTargetName = "Avcı Dayı ile konuş"
Config.NPCKonumu = {x = -1188.83, y = -1551.43, z = 4.3638, h = 100.00 } --NPC Coords // NPC Kordinatlari
Config.MeslekOlsunmu = false -- Do you want add job to npc?(true/false) // Meslek sorgusu aç/kapat(true/false)
Config.MeslekIsim = "freq" --İf you select true which job open npc? // Meslek Sorgusunu aktif ettiysen hangi meslek açsın?
Config.MesleksizBildirim = "Seni tanıdığımı düşünmüyorum." 
Config.NPCLOGwebhook = "--" -- ADD WEBHOOK
-- NOTİFYS
Config.dontanimallook = "Bir Hayvana Bakmıyorsun!"
Config.onlydeer = "Geyik Dışında Bir Hayvanı Kesemezsin!"
Config.ClosestPlayer = "Yakınında Biri Varken Bunu Yapamazsın!"
Config.youareveryfartoanimal = "Hayvana Çok Uzaksın!"
Config.Cutting = "Kesiliyor..."
Config.CuttingTime = 40000
Config.useitemdelay = "Bu Eşyayı 3 Saniyede Bir Kullanabilirsin!"
Config.HuntingAreaJoin = 'Avcılık alanına giriş yaptın, Dikkatli ol!'
Config.HuntingAreaLeave = "Avcılık alanından çıkış yaptın!"

--=========================== İNFO =================================--

--[[ COMMANDS;
"/hayvansil" = DELETE ALL ANİMALS
]]


--[[ ADD THİS İTEMS;
"huntingknife"
"geyiketi"
"geyikderisi"
]]


--[[ HUNTİNG AREAS
    Paleto Forest
    Raton Canyon
    Mount Chiliad
    Mount Gordo
    Cassidy Creek ]]
    