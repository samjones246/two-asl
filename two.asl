state("javaw")
{
    long framesPlayed: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1A0;
    long framesPaused: "jvm.dll", 0x007C0EC0, 0x78, 0xD8, 0x1B0, 0x68, 0x1A8;
}

startup
{
    vars.Log = (Action<object>)((output) => print("[2 ASL] " + output));
}

start
{
    return current.framesPlayed > old.framesPlayed;
}

gameTime
{
    return TimeSpan.FromSeconds(current.framesPlayed + current.framesPaused / 30.0);
}

isLoading
{
    return current.framesPlayed == old.framesPlayed && current.framesPaused == old.framesPaused;
}