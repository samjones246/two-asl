state("javaw")
{
    long framesPlayed: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1A0;
    long framesPaused: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1A8;
    bool mainActive: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x35A;
    int roomX: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1F0;
    int roomX: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1F4;
    int playerMaxHealth: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x218;
    int currentDream: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x204;
    int eventPtr: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0xFC;
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
    settings.Add("split_boss", true, "Split on boss defeated");
    settings.Add("split_event_0", false, "J-Boy", "split_boss");
    settings.Add("split_event_3", true, "Drifter", "split_boss");
    settings.Add("split_event_8", false, "Banaan", "split_boss");
    settings.Add("split_event_21", false, "Slick", "split_boss");
    settings.Add("split_event_33", true, "Puke", "split_boss");
    settings.Add("split_event_38", false, "Duke", "split_boss");
    settings.Add("split_event_44", false, "Papa", "split_boss");
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