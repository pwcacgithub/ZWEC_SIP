interface ZIF_CU_SIP
  public .


  constants GC_CONTRACT type CHAR1 value 'C' ##NO_TEXT.
  constants GC_WR type CHAR1 value 'W' ##NO_TEXT.
  constants GC_BILL type CHAR1 value 'J' ##NO_TEXT.
  constants GC_BATCH type CHAR1 value 'B' ##NO_TEXT.
  constants GC_SP type CHAR1 value 'S' ##NO_TEXT.
  constants:
    BEGIN OF gc_sipstatus,
      draft      TYPE z_sipstatus VALUE 'D',
      inprogress TYPE z_sipstatus VALUE 'I',
      completed  TYPE z_sipstatus VALUE 'C',
      cancelled  TYPE z_sipstatus VALUE 'W',
    END OF gc_sipstatus .
  constants:
    BEGIN OF gc_operation,
      insert TYPE z_sipoperation VALUE 'I',
      update TYPE z_sipoperation VALUE 'U',
      delete TYPE z_sipoperation VALUE 'D',
    END OF gc_operation .
  constants:
    BEGIN OF gc_source,
      wmis         TYPE z_source VALUE 'WMIS',
      wmis_lower   TYPE z_source VALUE 'wmis',
      maximo       TYPE z_source VALUE 'MAXIMO',
      maximo_lower TYPE z_source VALUE 'Maximo',
    END OF gc_source .
  constants:
    BEGIN OF gc_co,
      io  TYPE z_cotype VALUE 'IO',
      pm  TYPE z_cotype VALUE 'PM',
      wbs TYPE z_cotype VALUE 'WBS',
    END OF gc_co .
  constants:
    BEGIN OF gc_splitindicator,
      system TYPE z_splitindicator VALUE 'S',
      manual TYPE z_splitindicator VALUE 'M',
    END OF gc_splitindicator .
  constants GC_LINENO_010 type Z_LINENUM value '000010' ##NO_TEXT.
  constants GC_DYN_CONTRACT type CHAR10 value 'a~contract' ##NO_TEXT.
  constants GC_ZCU_MSG type SYST_MSGID value 'ZCU_MSG' ##NO_TEXT.
  constants GC_ERROR type BAPI_MTYPE value 'E' ##NO_TEXT.
  constants GC_USD type WAERS value 'USD' ##NO_TEXT.
  constants GC_I type Z_APPINDICATOR value 'I' ##NO_TEXT.
  constants GC_T type Z_APPINDICATOR value 'T' ##NO_TEXT.
  constants GC_I_PREFIX type CHAR2 value 'SR' ##NO_TEXT.
  constants GC_T_PREFIX type CHAR2 value 'FC' ##NO_TEXT.
  constants GC_SP_PREFIX type CHAR2 value 'FWO' ##NO_TEXT.
  constants GC_DYN_SPNO type CHAR10 value 'a~spno' ##NO_TEXT.
  constants GC_DYN_WR type CHAR10 value 'a~wrno' ##NO_TEXT.
  constants GC_REJECTED type CHAR10 value 'Rejected' ##NO_TEXT.
  constants GC_SAP_VENDOR_NUMBER type STRING value 'SAP Vendor Number' ##NO_TEXT.
  constants GC_DESIGNER_ID type STRING value 'Designer ID' ##NO_TEXT.
  constants GC_PLANT type STRING value 'Plant' ##NO_TEXT.
  constants GC_IO_NUMBER type STRING value 'IO Number' ##NO_TEXT.
  constants GC_IO_NUMBER_BLANKET type STRING value 'IO Number Blanket' ##NO_TEXT.
  constants GC_PMWOID type STRING value 'PM Work Order ID' ##NO_TEXT.
  constants GC_COMPANYCODE type STRING value 'Company code' ##NO_TEXT.
  constants GC_MATERIALNUMBER type STRING value 'Material Number' ##NO_TEXT.
  constants GC_COSTOBJECT type STRING value 'Cost Object' ##NO_TEXT.
  constants GC_DIGFROMLOC type STRING value 'Dig From Loc' ##NO_TEXT.
  constants GC_DIGTOLOC type STRING value 'Dig To Loc' ##NO_TEXT.
  constants GC_ACCEPTED type CHAR10 value 'Accepted' ##NO_TEXT.
  constants GC_UPDATE type CHAR1 value 'U' ##NO_TEXT.
  constants GC_NEW type CHAR1 value 'N' ##NO_TEXT.
  constants GC_SUCCESS type CHAR1 value 'S' ##NO_TEXT.
  constants GC_X type CHAR1 value 'X' ##NO_TEXT.
  constants GC_MCODE type STRING value 'Municipality code' ##NO_TEXT.
  constants GC_CONTRACT_TEXT type STRING value 'Contract' ##NO_TEXT.
  constants GC_SPNO type STRING value 'SPNo' ##NO_TEXT.
  constants GC_WRNO type STRING value 'WRNo' ##NO_TEXT.
  constants GC_CONTRACT_MSG type SYST_MSGV value 'Contract' ##NO_TEXT.
  constants GC_SPECIALPROJECT type SYST_MSGV value 'Special Project' ##NO_TEXT.
  constants GC_WORKORDER type SYST_MSGV value 'Work Order' ##NO_TEXT.
  constants GC_PROJECTOWNER type STRING value 'Project Owner' ##NO_TEXT.
  constants GC_OPERATIONS type STRING value 'Operation' ##NO_TEXT.
  constants GC_ACTIVE_MATERIALS type CHAR1 value 'A' ##NO_TEXT.
  constants GC_INACTIVE_MATERIALS type CHAR1 value 'I' ##NO_TEXT.
  constants:
    BEGIN OF gc_restoration,
      restor_lower TYPE char20 VALUE 'Rest',
      restor_upper TYPE char20 VALUE 'REST',
    END OF gc_restoration .
  constants GC_FPC type STRING value 'FPC' ##NO_TEXT.
endinterface.
