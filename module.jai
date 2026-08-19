#if OS == .WINDOWS {
    #load "windows.jai";
    
    #scope_file
    #import "Windows"; // for GUID

} else {
    #assert(false);
}
