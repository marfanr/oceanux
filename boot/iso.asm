struc ISO9660.PrimaryVolumeDescriptor
    .typeCode                       resb 1
    .idetifier                      resb 5
    .version                        resb 1
                                    resb 1 ; unused
    .systemIdentifier               resb 32
    .volumeIdentifier               resb 32
                                    resb 8 ; unused
    .VolumeSpaceSize                resb 8
                                    resb 32 ; unused
    .VolumeSetSize                  resb 4
    .VolumeSeqNumber                resb 4
    .logicalBlockSize               resb 4
    .PathTableSize                  resb 8
    .LPathTable                     resb 4
    .LPathTableOptional             resb 4
    .MpathTable                     resb 4
    .MpathTableOptional             resb 4
    .rootDirEntry                   resb 34
    .volumeSetIdentifier            resb 128
    .publisherIdentifier            resb 128
    .dataPreparerIdentifier         resb 128
    .applicationIdentifier          resb 128
    .copyrightFileIdentifier        resb 37
    .abstractFileIdentifier         resb 37
    .bibliographicFileIdentifier    resb 37
    .volumeCreationDateAndTime      resb 17
    .volumeModificationDateAndTime  resb 17
    .volumeExpirationDateAndTime    resb 17
    .volumeEffectiveDateAndTime     resb 17
    .FileStructVersion              resb 1
                                    resb 1 ; unused
    .applicationUsed                resb 512
    .reserved                       resb 653
endstruc

struc ISO9660.Directory
    .lengthRecord                   resb    1
    .extAttribRecLength             resb    1
    .locationLBA                    resq    1   ; int32 LSB-MSB
    .size                           resq    1   ; int32 LSB-MSB
    .recordingDateTime              resb    7
    .fileFlags                      resb    1
    .fileUnitSize                   resb    1
    .gapSize                        resb    1
    .volume                         resd    1   ; int16 LSB-MSB
    .nameLength                     resb    1
    .name:                                       ; Var length
endstruc

struc Saver
    .RootDir    resw  1
endstruc