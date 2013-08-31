//
//  main.m
//  Wish
//
//  Created by Michael Barriault on 8/4/2013.
//
//

#import <Tk/tk.h>

int AppInit(Tcl_Interp *interp) {
    if(Tcl_Init(interp) == TCL_ERROR) return TCL_ERROR;
    if(Tk_Init(interp) == TCL_ERROR) return TCL_ERROR;
    Tcl_SetVar(interp,"tcl_rcFileName","~/.wishrc",
               TCL_GLOBAL_ONLY);
    Tcl_Eval(interp, "load libTestLib.dylib; package require TestLib; puts Okay;");
    return TCL_OK;
}

int main(int argc, char *argv[]) {
    Tk_Main(argc, argv, AppInit);
    return 0;
}
