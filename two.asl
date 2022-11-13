state("javaw")
{
    long framesPlayed: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1A0;
    long framesPaused: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1A8;
    bool mainActive: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x35A;
    int roomX: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1F0;
    int roomY: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1F4;
    int playerMaxHealth: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x218;
    int currentDream: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x204;
    int eventPtr: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0xFC;
    bool gotWallSlide: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x346;
    bool gotGun: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x347;
    bool gotBombs: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x348;
    bool gotMapDoor: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x349;
    bool gotMapIcons: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x34A;
    bool gotBoots: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x34C;
    bool gotStench: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x34D;
    bool gotClover: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x34E;
}

startup
{
    vars.Log = (Action<object>)((output) => print("[2 ASL] " + output));

    vars.getEvent = (Func<Process, int, int>)((g, index) => {
        IntPtr addr = new IntPtr((vars.eventPtr + (index * 4) + 0x10) & 0xFFFFFFFF);
        return g.ReadValue<int>(addr);
    });

    settings.Add("split_hearts", false, "Split when any heart collected");

    vars.bossEventIds = new int[] { 0, 3, 8, 21, 33, 38, 44 };
    vars.bossRooms = new int[][] {
        new int[] {5, 3},
        new int[] {9, 1},
        new int[] {15, 2},
        new int[] {13, 4},
        new int[] {7, 7},
        new int[] {3, 5},
        new int[] {4, 4},
    };
    settings.Add("split_boss", true, "Split on boss defeated");
    settings.Add("split_event_0", false, "J-Boy", "split_boss");
    settings.Add("split_event_3", true, "Drifter", "split_boss");
    settings.Add("split_event_8", false, "Banaan", "split_boss");
    settings.Add("split_event_21", false, "Slick", "split_boss");
    settings.Add("split_event_33", true, "Puke", "split_boss");
    settings.Add("split_event_38", false, "Duke", "split_boss");
    settings.Add("split_event_44", false, "Papa", "split_boss");

    settings.Add("split_boss_enter", false, "Split on enter boss room");
    settings.Add("split_room_5_3", false, "J-Boy", "split_boss_enter");
    settings.Add("split_room_9_1", false, "Drifter", "split_boss_enter");
    settings.Add("split_room_15_2", false, "Banaan", "split_boss_enter");
    settings.Add("split_room_13_4", false, "Slick", "split_boss_enter");
    settings.Add("split_room_7_7", false, "Puke", "split_boss_enter");
    settings.Add("split_room_3_5", false, "Duke", "split_boss_enter");
    settings.Add("split_room_4_4", false, "Papa", "split_boss_enter");

    settings.Add("split_chest", false, "Split on chest opened");
    settings.Add("split_chest_banner", false, "Banner", "split_chest");
    settings.Add("split_chest_gun", false, "Stocking", "split_chest");
    settings.Add("split_chest_bombs", false, "Cherry Bombs", "split_chest");
    settings.Add("split_chest_map_door", false, "Jelly Map Upgrade", "split_chest");
    settings.Add("split_chest_map_icons", false, "Bloody Map upgrade", "split_chest");
    settings.Add("split_chest_boots", false, "Cool Boots", "split_chest");
    settings.Add("split_chest_stench", false, "Stench", "split_chest");
    settings.Add("split_chest_clover", false, "Clover", "split_chest");
    settings.Add("split_chest_snorkle", false, "Snorkel", "split_chest");
    settings.Add("split_chest_bombs_upgrade", false, "Bomb Upgrade", "split_chest");
    settings.Add("split_chest_bulb", false, "Bombastic Bulb", "split_chest");
}

init
{
    vars.eventPtr = null;
}

start
{
    return current.mainActive && !old.mainActive;
} 

reset
{
    return current.framesPlayed < old.framesPlayed;
}

update
{
    // Read event array
    IntPtr eventPtr = new IntPtr((current.eventPtr + 0x10) & 0xFFFFFFFF);
    byte[] eventBytes = game.ReadBytes(eventPtr, 100 * 4);
    int[] eventInts = new int[100];
    for (int i=0;i<100;i++){
        eventInts[i] = BitConverter.ToInt32(eventBytes, i * 4);
    }
    current.eventArray = eventInts;
}

split
{
    // Heart collected
    if (current.playerMaxHealth > old.playerMaxHealth) {
        // Final heart
        if (current.currentDream == 13) {
            return true;
        }
        // Other heart
        else {
            return settings["split_hearts"];
        }
    }

    // -- Event splits --
    // - Bosses -
    foreach (int index in vars.bossEventIds)
    {
        if (current.eventArray[index] == 1 && old.eventArray[index] != 1) {
            return settings["split_event_"+index];
        }
    }

    // -- Room entry --
    if (current.roomX != old.roomX || current.roomY != old.roomY) {
        // Boss rooms
        for (int i=0;i<vars.bossRooms.Length;i++)
        {
            int[] pos = vars.bossRooms[i];
            bool defeated = current.eventArray[vars.bossEventIds[i]] == 1;
            if (!defeated && current.roomX == pos[0] && current.roomY == pos[1]) {
                return settings["split_room_"+pos[0]+"_"+pos[1]];
            }
        }
    }

    // -- Chest opening --
    if (current.gotWallSlide && ! old.gotWallSlide) {
        return settings["split_chest_banner"];
    }
    if (current.gotGun && ! old.gotGun) {
        return settings["split_chest_gun"];
    }
    if (current.gotBombs && ! old.gotBombs) {
        return settings["split_chest_bombs"];
    }
    if (current.gotMapDoor && ! old.gotMapDoor) {
        return settings["split_chest_map_door"];
    }
    if (current.gotMapIcons && ! old.gotMapIcons ) {
        return settings["split_chest_map_icons"];
    }
    if (current.gotBoots && ! old.gotBoots) {
        return settings["split_chest_boots"];
    }
    if (current.gotStench && ! old.gotStench) {
        return settings["split_chest_stench"];
    }
    if (current.gotClover && ! old.gotClover) {
        return settings["split_chest_clover"];
    }
    if (current.eventArray[16] == 1 && old.eventArray[16] != 1) {
        return settings["split_chest_snorkel"];
    }
    if (current.eventArray[40] == 1 && old.eventArray[40] != 1) {
        return settings["split_chest_bombs_upgrade"];
    }
    if (current.eventArray[45] == 1 && old.eventArray[45] != 1) {
        return settings["split_chest_bulb"];
    }

    return false;
}

gameTime
{
    return TimeSpan.FromSeconds((current.framesPlayed + current.framesPaused) / 30.0);
}

isLoading
{
    return current.framesPlayed == old.framesPlayed && current.framesPaused == old.framesPaused;
}