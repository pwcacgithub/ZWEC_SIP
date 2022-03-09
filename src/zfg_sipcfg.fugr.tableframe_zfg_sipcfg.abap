*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZFG_SIPCFG
*   generation date: 07.05.2021 at 09:46:16
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZFG_SIPCFG         .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
