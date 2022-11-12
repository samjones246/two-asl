state("javaw")
{
    long framesPlayed: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1A0;
    long framesPaused: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1A8;
    bool mainActive: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x35A;
    int roomX: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1F0;
    int roomX: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1F4;
    int playerMaxHealth: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x218;
    int currentDream: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x204;
}

startup
{
    vars.Log = (Action<object>)((output) => print("[2 ASL] " + output));

    settings.Add("split_hearts", false, "Split when any heart collected");
}

start
{
    return current.mainActive && !old.mainActive;
}

reset
{
    return current.framesPlayed < old.framesPlayed;
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