REAL_ORG = #3c51
DICT_BEGIN = #3c49

    MACRO CHECKSUM start
fin = $ + 2
chk = 0
chk_cnt = 0
          dup fin - (start)
chk = chk ^ ({b start + chk_cnt})
chk = chk and 255
chk_cnt = chk_cnt + 1
        edup
        db chk
    ENDM

    MACRO MakeAceTap filename, lastLink
    org REAL_ORG - 30 ; Space for header
tapBegin:
    dw .headerEnd - .headerblock ; TAP chunk size
.headerblock
    db 0 ; type 0 - dict, FF - bytes
.name
name_org = $
    ds 10, 32 ; 10 bytes!
    org name_org + 10
    dw dataBlockEnd - dataBlock
    dw REAL_ORG
    dw lastLink ; Last word link
    dw #3c4c
    dw #3c4c
    dw #3c4f
    dw dataBlockEnd
    CHECKSUM .headerblock
.headerEnd 

; Data chunk!
    dw tapEnd - dataBlock
back_org = $
    org name_org
    db filename
    org back_org
    ENDM