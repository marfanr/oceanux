%define Var.Base                       0x00007c00
%define Var.SectorBuffer               0x00000800
%define Var.SectorBuffer.Size          0x00000800
%define Var.Loader                     0x00008000
%define Var.LoaderSeg                  Var.Loader >> 4
%define Var.BaseSeg                    Var.Base >> 4
%define Var.StackTop                   0x00007c00
