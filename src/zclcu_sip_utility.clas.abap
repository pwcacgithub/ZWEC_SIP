class ZCLCU_SIP_UTILITY definition
  public
  final
  create public .

public section.

  interfaces ZIF_CU_SIP .

  types:
    BEGIN OF gty_approver_status,
        sipno    TYPE ztca_routinglog-batch_no,
        userid   TYPE sysid,
        userrole TYPE ztca_routinglog-userrole,
        status   TYPE ztca_routinglog-status,
      END OF gty_approver_status .
  types:
    gtt_approver_status TYPE STANDARD TABLE OF gty_approver_status .
  types:
    BEGIN OF gty_sipno,
        sipno TYPE z_sipno,
      END OF gty_sipno .
  types:
    gtt_sipno TYPE STANDARD TABLE OF gty_sipno .
  types:
    BEGIN OF gty_invoice,
        invoice TYPE re_belnr,
      END OF gty_invoice .
  types:
    gtt_invoice TYPE STANDARD TABLE OF gty_invoice .
  types:
    BEGIN OF gty_surrogate_supervisor,
        userid      TYPE string,
        suruserid   TYPE string,
        surusername TYPE string,
        supuserid   TYPE string,
        supusername TYPE string,
        escalation  TYPE n LENGTH 3,
      END OF gty_surrogate_supervisor .
  types:
    gtt_surrogate_supervisor TYPE STANDARD TABLE OF gty_surrogate_supervisor .
  types:
    BEGIN OF gty_sipitems,
        itemcode       TYPE	ztcu_sipitem-itemcode,
        costobject     TYPE	ztcu_sipitem-costobject,
        sipno          TYPE ztcu_sipitem-sipno,
        linenum        TYPE  ztcu_sipitem-linenum,
        counter        TYPE  ztcu_sipitem-counter,
        type           TYPE	ztcu_sipitem-type,
        bussunit       TYPE	ztcu_sipitem-bussunit,
        acctno1        TYPE  ztcu_sipitem-acctno1,
        acctno2        TYPE  ztcu_sipitem-acctno2,
        woid           TYPE	ztcu_sipitem-woid,
        servicecharge  TYPE  ztcu_sipitem-servicecharge,
        plasticsteel   TYPE	ztcu_sipitem-plasticsteel,
        actqty         TYPE	ztcu_sipitem-actqty,
        status         TYPE	ztcu_sipitem-status,
        parentlineno   TYPE ztcu_sipitem-parentlineno,
        operation      TYPE ztcu_sipitem-operation,
        originalqty    TYPE ztcu_sipitem-originalqty,
        accumalatedqty TYPE ztcu_sipitem-accumalatedqty,
        netprice       TYPE ztcu_sipitem-netprice,
        activity1      TYPE ztcu_sipitem-activity1,
        activity2      TYPE ztcu_sipitem-activity2,
        coflag         TYPE ztcu_sipitem-coflag,
        createdby      TYPE ztcu_sipitem-createdby,
        createdon      TYPE ztcu_sipitem-createdon,
        changedby      TYPE ztcu_sipitem-changedby,
        changedon      TYPE ztcu_sipitem-changedon,
        outoftolerance TYPE ztcu_sipitem-outoftolerance,
        tax            TYPE ztcu_sipitem-tax,
      END OF gty_sipitems .
  types:
    gtt_sipitems TYPE STANDARD TABLE OF gty_sipitems .
  types:
    BEGIN OF gty_routinglog,
        batch_no      TYPE ztca_routinglog-batch_no,
        ordernum      TYPE ztca_routinglog-ordernum,
        seqnum        TYPE ztca_routinglog-seqnum,
        userid        TYPE ztca_routinglog-userid,
        descr         TYPE ztca_routinglog-descr,
        status        TYPE ztca_routinglog-status,
        assignedon    TYPE ztca_routinglog-assignedon,
        completedon   TYPE ztca_routinglog-completedon,
        approved      TYPE ztca_routinglog-approved,
        taskname      TYPE ztca_routinglog-taskname,
        userrole      TYPE ztca_routinglog-userrole,
        username      TYPE ztca_routinglog-username,
        comments      TYPE ztca_routinglog-comments,
        timerequested TYPE ztca_audit_log-timerequested,
        timecompleted TYPE ztca_audit_log-timecompleted,
      END OF gty_routinglog .
  types:
    gtt_routinglog TYPE STANDARD TABLE OF gty_routinglog .
  types:
    BEGIN OF gty_accumulatedqty ,
        itemcode TYPE ztcu_sipitem-itemcode,
        accumqty TYPE z_accumalatedqty,
      END OF gty_accumulatedqty .
  types:
    BEGIN OF gty_wraccum ,
        wrno     TYPE ztcu_tktheader-wrno,
        itemcode TYPE ztcu_tktitem-itemcode,
        accumqty TYPE z_accumalatedqty,
      END OF gty_wraccum .
  types:
    BEGIN OF gty_spaccum ,
        spno     TYPE ztcu_tktheader-spno,
        itemcode TYPE ztcu_tktitem-itemcode,
        accumqty TYPE z_accumalatedqty,
      END OF gty_spaccum .
  types:
    BEGIN OF gty_contractaccum ,
        contract TYPE ztcu_tktheader-contract,
        itemcode TYPE ztcu_tktitem-itemcode,
        accumqty TYPE z_accumalatedqty,
      END OF gty_contractaccum .
  types:
    BEGIN OF gty_approvers_verifiers,
        role_id(2) TYPE c,
        role       TYPE agr_name,
        role_descr TYPE agr_title,
        usrid      TYPE sysid,
        name       TYPE ad_namtext,
      END OF gty_approvers_verifiers .
  types:
    gtt_approvers_verifiers TYPE STANDARD TABLE OF gty_approvers_verifiers .
  types:
    gtt_accumulatedqty      TYPE STANDARD TABLE OF gty_accumulatedqty .
  types:
    gtt_wraccum       TYPE STANDARD TABLE OF gty_wraccum .
  types:
    gtt_spaccum       TYPE STANDARD TABLE OF gty_spaccum .
  types:
    gtt_contractaccum TYPE STANDARD TABLE OF gty_contractaccum .
  types:
    BEGIN OF ty_s_media_slug,
        media_resource TYPE /iwbep/if_mgw_appl_types=>ty_s_media_resource,
        slug           TYPE string,
      END OF ty_s_media_slug .
  types:
    ty_t_media_slug TYPE STANDARD TABLE OF ty_s_media_slug .

  class-methods GET_APPROVALFLOW
    importing
      !IS_APPROVALFLOW type ZSCU_APPROVALFLOW
    exporting
      !ET_DATA type ZTTCU_APPFLOW .
  class-methods GET_ATACHMENT_HEADER
    importing
      !IV_DOCID type SAEARDOID
      !IV_SIPNO type Z_SIPNO
    exporting
      !ET_OUTPUT type ZCLCU_SIP_MPC=>TT_ATTACHMENTHEADER .
  class-methods CREATE_DOCUMENT
    importing
      !IV_CONTENT type XSTRING
    exporting
      !EV_ERROR_FLAG type CHAR1
    changing
      !CS_ATTACHDEATILS type ZSCU_SIP_ATTACH .
  class-methods GET_DOCUMENT
    exporting
      !EV_ERROR_FLAG type CHAR1
      !ES_STREAM type /IWBEP/IF_MGW_APPL_TYPES=>TY_S_MEDIA_RESOURCE
      !ES_HEADER type IHTTPNVP
    changing
      !CS_ATTACHDEATILS type ZSCU_SIP_ATTACH .
  class-methods DELETE_ATTACHDOCUMENT
    importing
      !IS_ATTACHDETAILS type ZSCU_SIP_ATTACH
    exporting
      !EV_ERROR_FLAG type CHAR1 .
  class-methods CREATE_ATTACHMENT_HEADER
    importing
      !IT_SIP_ATTACH type ZTTCU_SIP_ATTACH
    exporting
      !ET_ATTACH_INS type ZTTCU_SIP_ATTACHMENT
      !ET_ATTACH_UPD type ZTTCU_SIP_ATTACHMENT
      !ET_ATTACH_DEL type ZTTCU_SIP_ATTACHMENT .
  class-methods VALIDATE_MATERIAL
    importing
      !IT_INPUT type /IWBEP/T_MGW_NAME_VALUE_PAIR
    exporting
      !ES_RETURN type ZCLCU_SIP_MPC=>TS_RETURN .
  class-methods VALIDATE_CONTRACT
    importing
      !IT_INPUT type /IWBEP/T_MGW_NAME_VALUE_PAIR
    exporting
      !ES_RETURN type ZCLCU_SIP_MPC=>TS_RETURN .
  class-methods SET_APPROVALFLOW
    importing
      !IT_APPROVALFLOW type ZCLCU_SIP_MPC=>TT_APPROVALFLOW optional
    exporting
      !ET_ROUTING_INS type ZCLCU_SIP_MPC=>TT_APPROVALFLOW
      !ET_ROUTING_UPD type ZCLCU_SIP_MPC=>TT_APPROVALFLOW
      !ET_ROUTING_DEL type ZCLCU_SIP_MPC=>TT_APPROVALFLOW .
  class-methods GET_HEADER
    importing
      !IS_HEADER type ZCLCU_SIP_MPC=>TS_HEADERSIPWR
    exporting
      !ET_HEADER type ZCLCU_SIP_MPC=>TT_HEADERSIPWR .
  class-methods GET_ITEMS
    importing
      !IS_ITEM type ZCLCU_SIP_MPC=>TS_ITEM
    exporting
      !ET_ITEMS type ZCLCU_SIP_MPC=>TT_ITEM .
  class-methods GET_CONTRACTHEADER
    importing
      !IV_CONTRACT type EBELN
      !IV_SUBMITTEDBY type UNAME optional
    exporting
      !ET_HEADER type ZTTCU_HEADER .
  class-methods GET_CONTRACTITEM
    importing
      !IV_CONTRACT type EBELN
      !IV_APPINDICATOR type Z_APPINDICATOR optional
      !IV_WRNO type Z_WRNO optional
      !IV_SPNO type Z_SPNO optional
    exporting
      !ET_ITEMS type ZTTCU_ITEM .
  class-methods GET_NAME
    importing
      !IV_USERID type UNAME
    exporting
      !EV_NAME type PAD_CNAME .
  class-methods GET_VENDOR
    importing
      !IV_UNAME type SYST_UNAME
    exporting
      !EV_VENDOR type LIFNR .
  class-methods POPULATE_UNIQUEID
    importing
      !IV_APPINDICATOR type Z_APPINDICATOR
    exporting
      !EV_UNIQUEID type CHAR12 .
  class-methods ATTACH_CREATE_STREAM
    importing
      !IV_ENTITY_NAME type STRING optional
      !IV_ENTITY_SET_NAME type STRING optional
      !IV_SOURCE_NAME type STRING optional
      !IS_MEDIA_RESOURCE type /IWBEP/IF_MGW_APPL_TYPES=>TY_S_MEDIA_RESOURCE
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH optional
      !IV_SLUG type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
    exporting
      !ER_ENTITY type ZCLCU_SIP_MPC=>TS_ATTACHDOCUMENT .
  class-methods GET_APPROVER_VERIFIER
    importing
      !IV_APPROVERS type BOOLE_D optional
      !IV_VERIFIERS type BOOLE_D optional
      !IV_INSPECTOR1 type BOOLE_D optional
    exporting
      !ET_APPROVERS_VERIFIERS type GTT_APPROVERS_VERIFIERS .
  class-methods VALIDATE_USERID
    importing
      !IT_INPUT type /IWBEP/T_MGW_NAME_VALUE_PAIR
    exporting
      !ES_RETURN type ZCLCU_SIP_MPC=>TS_ROLEBASEDUSERID .
  class-methods GET_CONTRACTSF4
    importing
      !IV_CONTRACT type EBELN optional
      !IV_SP type BOOLEAN optional
      !IV_SUBMITTEDBY type UNAME optional
      !IV_VENDOR type LIFNR optional
    exporting
      !ET_DATA type ZCLCU_SIP_MPC=>TT_CONTRACTSEARCHHELP .
  class-methods GET_ACTIVITIES
    importing
      !IV_MATNR type MATNR
      !IV_PLANT type WERKS_D
    exporting
      !ET_DATA type ZCLCU_SIP_MPC=>TT_ACTIVITY .
  class-methods ITEM_SEARCHHELP
    importing
      !IS_ITEM type ZSCU_ITEMF4
      !IV_APPINDICATOR type Z_APPINDICATOR optional
    exporting
      !ET_DATA type ZTTCU_ITEMF4 .
  class-methods WR_SP_SEARCHHELP
    importing
      !IS_INPUT type ZSCU_WR_SP optional
      !IV_SUBMITTEDBY type UNAME optional
      !IV_VENDOR type LIFNR optional
    exporting
      !ET_DATA type ZCLCU_SIP_MPC=>TT_WRSPSEARCHHELP .
  class-methods CALCULATE_TAX
    importing
      !IV_CONTRACT type EBELN
      !IV_VENDOR type LIFNR
      !IV_PLANT type WERKS_D
      !IV_COMPANYCODE type BUKRS
    exporting
      !EV_TOTALTAX type RPDIFN
    changing
      !CT_ITEMS type ZTTCU_ITEM .
  class-methods GET_SURROGATE_SUPERVISOR
    importing
      !IV_USERID type SLDSTRING
      !IV_WFTYPE type Z_FIWFTYPE
    exporting
      !ET_DATA type ZCLCU_SIP_MPC=>TT_SURROGATESUPERVISOR .
  class-methods GET_CONTRACT_DESCRIPTION
    importing
      !IV_CONTRACT type EBELN
    exporting
      !EV_DESCRIPTION type STRING .
  class-methods CREATE_CONTRACT_INVOICE
    importing
      !IV_SIPNO type Z_SIPNO
      !IV_TESTRUN type BOOLE_D
      !IV_SUBMITTEDBY type UNAME optional
    exporting
      !ET_INVOICE type GTT_INVOICE
      !ET_RETURN type BAPIRET2_T .
  class-methods VALIDATE_INVOICE
    importing
      !IT_INPUT type /IWBEP/T_MGW_NAME_VALUE_PAIR
    exporting
      !ES_RETURN type ZCLCU_SIP_MPC=>TS_RETURN .
  class-methods CALL_INVOICE_BAPI
    importing
      !IS_HEADER type ZCLCU_SIP_MPC=>TS_HEADERSIPWR
      !IT_ITEMS type ZCLCU_SIP_MPC=>TT_ITEM
      !IV_TESTRUN type BOOLEAN
      !IV_SUBMITTEDBY type UNAME
    exporting
      !ET_INVOICE type GTT_INVOICE
      !ET_RETURN type BAPIRET2_T .
  class-methods PLANT_SEARCHHELP
    importing
      !IV_APPLICATION type CHAR4
    exporting
      !ET_PLANTSEARCHHELP type ZCLCU_SIP_MPC=>TT_PLANTSEARCHHELP .
  class-methods CALCULATE_TAX_MATERIAL
    importing
      !IV_COMPCODE type BUKRS
      !IV_PLANTREGION type REGIO
      !IV_PLANTJURISD type TXJCD
      !IV_VENDORREGION type REGIO
      !IV_VENDORJURISD type TXJCD
      !IV_TAXCODE type MWSKZ
    exporting
      !EV_TAXPERCENT type MSATZ_F05L .
  class-methods CALCULATE_ACCUMULATEDQTY
    importing
      !IV_APPINDICATOR type Z_APPINDICATOR
      !IV_SIPNO type Z_SIPNO optional
      !IV_TICKETNO type Z_TICKETNO optional
      !IV_CONTRACT type EBELN optional
      !IV_SPNO type Z_SPNO optional
      !IV_WRNO type Z_WRNO optional
    exporting
      !ET_ACCUMULATEDQTY type GTT_ACCUMULATEDQTY .
  class-methods GET_JUDETAILS
    importing
      !IT_MATF4 type ZTTCU_ITEMF4 optional
      !IT_ITEMS type ZCLCU_SIP_MPC=>TT_ITEM optional
    exporting
      !ET_MATF4 type ZTTCU_ITEMF4
      !ET_ITEMS type ZCLCU_SIP_MPC=>TT_ITEM .
  class-methods VALIDATE_PRICE_DISPLAY
    importing
      !IT_INPUT type /IWBEP/T_MGW_NAME_VALUE_PAIR
    exporting
      !ES_RETURN type ZCLCU_SIP_MPC=>TS_RETURN .
  class-methods GET_ROUTINGLOG_DETAILS
    importing
      !IT_SIPNO type RSELOPTION
    exporting
      !ET_ROUTINGLOG type GTT_ROUTINGLOG .
  class-methods UPDATE_STATUS
    importing
      !IT_INPUT type /IWBEP/T_MGW_NAME_VALUE_PAIR
    exporting
      !ES_RETURN type ZCLCU_SIP_MPC=>TS_RETURN .
  class-methods UPDATE_STATUS_FPC
    importing
      !IT_INPUT type /IWBEP/T_MGW_NAME_VALUE_PAIR
    exporting
      !ES_RETURN type ZCLCU_SIP_MPC=>TS_RETURN .
  class-methods CONNECT_ATTACH_TO_INVOICE
    importing
      !IV_SIPNO type Z_SIPNO
      !IV_INVOICE type RE_BELNR
    exporting
      !EV_ERROR_FLAG type FLAG .
  class-methods VALIDATE_MAT_STATE
    importing
      !IT_INPUT type /IWBEP/T_MGW_NAME_VALUE_PAIR
    exporting
      !ES_RETURN type ZCLCU_SIP_MPC=>TS_RETURN .
  class-methods CLASSIFY_MATERIALS
    importing
      !IV_SIPNO type Z_SIPNO optional
      !IV_CONTRACT type EBELN optional
      !IV_SPNO type Z_SPNO optional
    changing
      !CT_ITEMS type ZCLCU_SIP_MPC=>TT_ITEM .
  class-methods CLASSIFY_MATERIALS_FPC
    importing
      !IV_TKTNO type Z_TICKETNO optional
      !IV_CONTRACT type EBELN optional
      !IV_SPNO type Z_SPNO optional
    changing
      !CT_ITEMS type ZTTCU_ITEM .
  class-methods GET_APPROVER_STATUS
    importing
      !IT_SIPNO type GTT_SIPNO
    exporting
      !ET_APPROVER_STATUS type GTT_APPROVER_STATUS .
  class-methods GET_APPROVERS_AUDITLOG
    importing
      !IV_DATAKEY type Z_WORKFLOWID
    exporting
      !EV_APPROVERS type STRING .
  class-methods VALIDATE_ACCESS
    importing
      !IT_INPUT type /IWBEP/T_MGW_NAME_VALUE_PAIR
    exporting
      !ES_RETURN type ZCLCU_SIP_MPC=>TS_RETURN .
  class-methods VALIDATE_TKT_ACCESS
    importing
      !IT_INPUT type /IWBEP/T_MGW_NAME_VALUE_PAIR
    exporting
      !ES_RETURN type ZCLCU_SIP_MPC=>TS_RETURN .
  class-methods GET_WR_MAXIMO
    importing
      !IV_WRNO type Z_WRNO
    exporting
      !ET_MAXIMO type ZTTCU_ITEM_MAXIMO .
  class-methods GET_TIER_PRICES
    importing
      !IV_CONTRACT type EBELN
    exporting
      !ET_TIER_PRICE type ZCLCU_SIP_MPC=>TT_TIEREDPRICING .
  class-methods CALCULATE_ACCUMULATEDQTY_OFFL
    importing
      value(IT_HEADER) type ZCL_ZCU_W078_SIP_TK_O_MPC=>TT_HEADER
    exporting
      !ET_WR_ACCUMULATED type GTT_WRACCUM
      !ET_SP_ACCUMULATED type GTT_SPACCUM
      !ET_CONTRACT_ACCUMULATED type GTT_CONTRACTACCUM .
  class-methods GET_PM_ORDERS
    exporting
      !ET_DATA type ZCLCU_SIP_MPC=>TT_PMORDER .
  class-methods GET_INTERNAL_ORDERS
    exporting
      !ET_DATA type ZCLCU_SIP_MPC=>TT_INTERNALORDER .
  class-methods GET_STATES
    exporting
      !ET_DATA type ZCLCU_SIP_MPC=>TT_STATE .
  class-methods GET_ATTACHMENT_HEADER_NEW
    importing
      !IV_DOCID type SAEARDOID
      !IV_SIPNO type Z_SIPNO
    exporting
      !ET_OUTPUT type ZCL_ZSIP_W076_MPC=>TT_ATTACHDOCUMENT .
protected section.
private section.
ENDCLASS.



CLASS ZCLCU_SIP_UTILITY IMPLEMENTATION.


  method GET_INTERNAL_ORDERS.
    CLEAR: et_data.

    DATA : lt_data    TYPE zclcu_sip_mpc=>tt_internalorder.

    "Get the WRs
    SELECT *
           FROM aufk
           INTO TABLE @DATA(lt_wr)
           WHERE autyp eq '01'.

      IF sy-subrc <> 0.
       ENDIF.

    LOOP AT lt_wr ASSIGNING FIELD-SYMBOL(<ls_wr>).

        APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
        CLEAR : <ls_data>.
        <ls_data>-InternalOrderNum = <ls_wr>-aufnr.
        <ls_data>-INternalOrderDesc    = <ls_wr>-ktext.

    ENDLOOP.

    IF lt_data IS NOT INITIAL.
      et_data = lt_data.
    ENDIF.
  endmethod.


  METHOD get_items.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Item details
*&  Transport Request No   : D10K934677
*****************************************************************************
*    Comment Om
*    DATA: lw_spitem TYPE zcl_zcu_u115_sp_mpc=>ts_item,
*          lw_writem TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_item.
*
*    CLEAR : et_items.
*
*    CASE is_item-category.
*      WHEN 'C'.
*        "Call method contract item
*        CALL METHOD zclcu_sip_utility=>get_contractitem
*          EXPORTING
*            iv_contract     = is_item-contract
*            iv_appindicator = is_item-appindicator
*          IMPORTING
*            et_items        = et_items.
*        IF et_items IS NOT INITIAL.
*          DELETE et_items WHERE loekz IS NOT INITIAL.
*        ENDIF.
*
*      WHEN 'S'.
*        MOVE-CORRESPONDING is_item TO lw_spitem.
*
*        CALL METHOD zclcu_u115_utility=>get_items
*          EXPORTING
*            is_item  = lw_spitem
*          IMPORTING
*            et_items = DATA(lt_spitems).
*
*        LOOP AT lt_spitems ASSIGNING FIELD-SYMBOL(<ls_spitems>).
*          APPEND INITIAL LINE TO et_items ASSIGNING FIELD-SYMBOL(<ls_items>).
*          MOVE-CORRESPONDING <ls_spitems> TO <ls_items>.
*        ENDLOOP.
*
*        "Work Req/Order
*      WHEN 'W'.
*        MOVE-CORRESPONDING is_item TO lw_writem ##ENH_OK.
*
*        CALL METHOD zclcu_sip_sourcewr=>get_wr_item
*          EXPORTING
*            is_item = lw_writem
*          IMPORTING
*            et_data = DATA(lt_writems).
*
*        LOOP AT lt_writems ASSIGNING FIELD-SYMBOL(<ls_writems>).
*          APPEND INITIAL LINE TO et_items ASSIGNING FIELD-SYMBOL(<ls_wrdata>).
*          MOVE-CORRESPONDING <ls_writems> TO <ls_wrdata> ##ENH_OK.
*        ENDLOOP.
*      WHEN OTHERS.
*    ENDCASE.
  ENDMETHOD.


  METHOD get_judetails.
*****************************************************************************
*&  Created By             : Kripa S P
*&  Created On             : 10.12.2020
*&  Functional Design Name : W073/U116
*&  Purpose                : Get comm company items based on SAP Materials
*&  Transport Request No   : D10K936732
*****************************************************************************
    CLEAR: et_matf4,
           et_items.

    IF it_matf4 IS NOT INITIAL.
      DATA(lt_mat) = it_matf4.
      "Material F4
      "Get the material has JU materials linked and fetch the sys/se/bo type
      SELECT a~type,
             b~matnr,
             c~taxindicator
        FROM ztcu_juitem AS a
        INNER JOIN ztcu_juitemasso AS b
        ON ( a~item = b~catvid
        OR a~item = b~teleid )
        INNER JOIN ztcu_juitemtax AS c
        ON a~item = c~item
        INTO TABLE @DATA(lt_ju_type)
        FOR ALL ENTRIES IN @lt_mat
        WHERE b~matnr = @lt_mat-matnr.

      IF sy-subrc EQ 0.
        SORT lt_ju_type BY matnr.
      ENDIF.
      CLEAR : et_matf4.
      LOOP AT lt_mat ASSIGNING FIELD-SYMBOL(<ls_mat>).
        APPEND INITIAL LINE TO et_matf4 ASSIGNING FIELD-SYMBOL(<ls_matf4>).
        MOVE-CORRESPONDING <ls_mat> TO <ls_matf4>.
        READ TABLE lt_ju_type ASSIGNING FIELD-SYMBOL(<ls_ju_type>) WITH KEY matnr = <ls_mat>-matnr BINARY SEARCH.
        IF sy-subrc = 0.
          <ls_matf4>-juflag = abap_true.
          <ls_matf4>-jutype = <ls_ju_type>-type.
          <ls_matf4>-jutaxind = <ls_ju_type>-taxindicator.
        ENDIF.
      ENDLOOP.
    ELSE.
      DATA(lt_items) = it_items.
      SORT lt_items BY material.
      "Item Entity
      "Get the material has JU materials linked and fetch the sys/se/bo type
      SELECT a~type,
             b~matnr,
             c~taxindicator
        FROM ztcu_juitem AS a
        INNER JOIN ztcu_juitemasso AS b
        ON ( a~item = b~catvid
        OR a~item = b~teleid )
        INNER JOIN ztcu_juitemtax AS c
        ON a~item = c~item
        INTO TABLE @lt_ju_type
        FOR ALL ENTRIES IN @lt_items
        WHERE b~matnr = @lt_items-material.
      IF sy-subrc EQ 0.
        SORT lt_ju_type BY matnr.
      ENDIF.
      CLEAR et_items.
      LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_items>).
        APPEND INITIAL LINE TO et_items ASSIGNING FIELD-SYMBOL(<ls_eitems>).
        MOVE-CORRESPONDING <ls_items> TO <ls_eitems>.
        READ TABLE lt_ju_type ASSIGNING <ls_ju_type> WITH KEY matnr = <ls_items>-material BINARY SEARCH.
        IF sy-subrc = 0.
          <ls_eitems>-juflag = abap_true.
          <ls_eitems>-jutype = <ls_ju_type>-type.
          <ls_eitems>-jutaxind = <ls_ju_type>-taxindicator.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_name.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 31.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the User name for the User id
*&  Transport Request No   : D10K934677
*****************************************************************************
    SELECT  b~name_text
            FROM usr21 AS a
            INNER JOIN adrp AS b
            ON a~persnumber = b~persnumber
            UP TO 1 ROWS
            INTO @ev_name
            WHERE a~bname = @iv_userid.
    ENDSELECT.
    IF sy-subrc <> 0.
      CLEAR ev_name.
    ENDIF.
  ENDMETHOD.


  method GET_PM_ORDERS.
    CLEAR: et_data.

    DATA : lt_data    TYPE zclcu_sip_mpc=>tt_pmorder.

    "Get the WRs
    SELECT *
           FROM aufk
           INTO TABLE @DATA(lt_wr)
           WHERE autyp eq '30'.

      IF sy-subrc <> 0.
       ENDIF.

    LOOP AT lt_wr ASSIGNING FIELD-SYMBOL(<ls_wr>).

        APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
        CLEAR : <ls_data>.
        <ls_data>-order = <ls_wr>-aufnr.
        <ls_data>-description    = <ls_wr>-ktext.

    ENDLOOP.

    IF lt_data IS NOT INITIAL.
      et_data = lt_data.
    ENDIF.
  endmethod.


  METHOD get_routinglog_details.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 31.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Routing Log details
*&  Transport Request No   : D10K934677
*****************************************************************************
    TYPES: BEGIN OF lty_audit,
             data_keys     TYPE z_workflowid,
             sequence_no   TYPE numc2,
             timerequested TYPE tims,
             timecompleted TYPE tims,
           END OF lty_audit.

    DATA: lt_audit  TYPE STANDARD TABLE OF lty_audit,
          lv_seqnum TYPE char10.

    CLEAR: et_routinglog.

    SELECT batch_no,
           ordernum,
           seqnum,
           userid,
           descr,
           status,
           assignedon,
           completedon,
           approved,
           taskname,
           userrole,
           username,
           comments
      FROM ztca_routinglog
      INTO TABLE @DATA(lt_routinglog)
      WHERE batch_no IN @it_sipno.
    IF sy-subrc = 0.
      SORT lt_routinglog BY batch_no seqnum.

      SELECT data_keys,
             sequence_no,
             timerequested,
             timecompleted
        FROM ztca_audit_log
        INTO TABLE @DATA(lt_auditlog)
        WHERE data_keys IN @it_sipno.
      IF sy-subrc = 0.
        LOOP AT lt_auditlog ASSIGNING FIELD-SYMBOL(<ls_auditlog>).
          APPEND INITIAL LINE TO lt_audit ASSIGNING FIELD-SYMBOL(<ls_audit>).
          MOVE-CORRESPONDING <ls_auditlog> TO <ls_audit>.
          CONDENSE <ls_auditlog>-sequence_no.
          <ls_audit>-sequence_no = <ls_auditlog>-sequence_no.
        ENDLOOP.
        SORT lt_audit BY data_keys sequence_no.
      ENDIF.

      LOOP AT lt_routinglog ASSIGNING FIELD-SYMBOL(<ls_routinglog>).
        APPEND INITIAL LINE TO et_routinglog ASSIGNING FIELD-SYMBOL(<ls_output>).
        MOVE-CORRESPONDING <ls_routinglog> TO <ls_output>.

        lv_seqnum = <ls_routinglog>-seqnum + ( <ls_routinglog>-seqnum - 1 ).
        READ TABLE lt_audit  ASSIGNING <ls_audit>
        WITH KEY data_keys   = <ls_routinglog>-batch_no
                 sequence_no = lv_seqnum BINARY SEARCH.
        IF sy-subrc = 0.
          <ls_output>-timerequested = <ls_audit>-timerequested.
        ENDIF.

        lv_seqnum = lv_seqnum + 1.
        READ TABLE lt_audit  ASSIGNING <ls_audit>
        WITH KEY data_keys   = <ls_routinglog>-batch_no
                 sequence_no = lv_seqnum BINARY SEARCH.
        IF sy-subrc = 0.
          <ls_output>-timecompleted = <ls_audit>-timecompleted.
        ENDIF.

        "When called from BPM, Audit log table update happens later
        IF <ls_output>-completedon IS NOT INITIAL AND
           <ls_output>-timecompleted IS INITIAL.
          <ls_output>-timecompleted = sy-uzeit.
        ENDIF.

        CLEAR: lv_seqnum.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  method GET_STATES.
        CLEAR: et_data.

    DATA : lt_data    TYPE zclcu_sip_mpc=>tt_state.

    "Get the WRs
    SELECT *
           FROM t005s
           INTO TABLE @DATA(lt_wr)
           WHERE land1 eq 'US'.

      IF sy-subrc <> 0.
       ENDIF.

    LOOP AT lt_wr ASSIGNING FIELD-SYMBOL(<ls_wr>).

        APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
        CLEAR : <ls_data>.
        <ls_data>-Country = <ls_wr>-land1.
        <ls_data>-StateCode = <ls_wr>-bland.
        <ls_data>-Description    = <ls_wr>-bland.

    ENDLOOP.

    IF lt_data IS NOT INITIAL.
      et_data = lt_data.
    ENDIF.
  endmethod.


  METHOD get_surrogate_supervisor.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 26.08.2020
*&  Functional Design Name : SWR/FPC
*&  Purpose                : Get the supervisor/surrogate details
*&  Transport Request No   : D10K934677
*****************************************************************************
*    Comment Om
*    CLEAR: et_data.
*
*    DATA : lt_sur   TYPE TABLE OF zsfi_sequence_usr_names,
*           lt_sup   TYPE TABLE OF zsfi_sequence_usr_names,
*           lt_param TYPE zttca_param,
*           lw_data  TYPE zclcu_sip_mpc=>ts_surrogatesupervisor.
*
*    "Surrogate users
*    CALL FUNCTION 'ZCA_RFC_GETSURROGATE_USER'
*      EXPORTING
*        i_user   = iv_userid
*        i_wftype = iv_wftype
*      TABLES
*        e_detail = lt_sur.
*
*
*    "supervisors
*    CALL FUNCTION 'ZCA_RFC_GETSUPERVISOR'
*      EXPORTING
*        i_user     = iv_userid
*        i_direct   = abap_true
*      TABLES
*        et_details = lt_sup.
*
*
*    LOOP AT lt_sur ASSIGNING FIELD-SYMBOL(<ls_sur>).
*      IF <ls_sur>-zusrid = iv_userid.
*        lw_data-userid      = <ls_sur>-zusrid.
*      ELSE.
*        lw_data-suruserid   = <ls_sur>-zusrid.
*        lw_data-surusername = <ls_sur>-zusername.
*      ENDIF.
*    ENDLOOP.
*
*
*    LOOP AT lt_sup ASSIGNING FIELD-SYMBOL(<ls_sup>).
*      lw_data-supuserid   = <ls_sup>-zusrid.
*      lw_data-supusername = <ls_sup>-zusername.
*    ENDLOOP.
*
*    NEW zcl_ca_utility( )->get_parameter(
*     EXPORTING
*       i_busproc           = 'CU'             " Business Process
*       i_busact            = 'TECH'           " Business Activity
*       i_validdate         = sy-datum         " Parameter Validity Start Date
*       i_param             = 'ESCALATION'
*     CHANGING
*       t_param             = lt_param         " Parameter value
*     EXCEPTIONS
*       invalid_busprocess  = 1                " Invalid Business Process
*       invalid_busactivity = 2                " Invalid Business Activity
*       OTHERS              = 3
*   ).
*
*    IF lt_param IS NOT INITIAL.
*      lw_data-escalation = lt_param[ 1 ]-value.
*    ENDIF.
*
*    IF lw_data IS NOT INITIAL.
*      APPEND lw_data TO et_data.
*    ENDIF.
  ENDMETHOD.


  METHOD get_tier_prices.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.01.2021
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get Tier pricing details for contract
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR: et_tier_price.

    SELECT ebeln,
           matnr,
           netpr
      FROM ekpo
      INTO TABLE @DATA(lt_ekpo)
      WHERE ebeln = @iv_contract.
    IF sy-subrc = 0.
      SORT lt_ekpo BY matnr.

      SELECT a~evrtn,
             b~matnr,
             a~knumh,
             c~kstbm,
             c~kbetr
        FROM a016 AS a
        INNER JOIN ekpo AS b
        ON a~evrtn = b~ebeln AND
           a~evrtp = b~ebelp
        INNER JOIN konm AS c
        ON a~knumh = c~knumh
        INTO TABLE @DATA(lt_cond)
        WHERE a~kappl = 'M' AND
              a~evrtn = @iv_contract AND
              a~kschl = 'PB00' AND
              a~datbi GE @sy-datum AND
              a~datab LE @sy-datum.
      IF sy-subrc = 0.
        SORT lt_cond BY evrtn matnr.
      ENDIF.

      LOOP AT lt_ekpo ASSIGNING FIELD-SYMBOL(<ls_ekpo>).
        LOOP AT lt_cond ASSIGNING FIELD-SYMBOL(<ls_cond>) WHERE matnr = <ls_ekpo>-matnr.
          APPEND INITIAL LINE TO et_tier_price ASSIGNING FIELD-SYMBOL(<ls_tier_price>).
          DATA(lv_scales) = abap_true.
          <ls_tier_price>-contract      = <ls_cond>-evrtn.
          <ls_tier_price>-itemcode      = <ls_cond>-matnr.
          <ls_tier_price>-scalequantity = <ls_cond>-kstbm.
          <ls_tier_price>-amount        = <ls_cond>-kbetr.
        ENDLOOP.

        IF lv_scales = abap_false.
          APPEND INITIAL LINE TO et_tier_price ASSIGNING <ls_tier_price>.
          <ls_tier_price>-contract = <ls_ekpo>-ebeln.
          <ls_tier_price>-itemcode = <ls_ekpo>-matnr.
          <ls_tier_price>-amount   = <ls_ekpo>-netpr.
        ENDIF.

        CLEAR: lv_scales.
      ENDLOOP.

      SORT et_tier_price BY contract itemcode scalequantity.

    ENDIF.

  ENDMETHOD.


  METHOD get_vendor.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 31.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Vendor for the User id
*&  Transport Request No   : D10K934677
*****************************************************************************
    SELECT lifnr FROM ztcu_sip_users
    INTO ev_vendor
      UP TO 1 ROWS
      WHERE uname = iv_uname AND
            validfrom LE sy-datum AND
            validto   GE sy-datum.
    ENDSELECT.
    IF sy-subrc NE 0.
      CLEAR : ev_vendor.
    ENDIF.
  ENDMETHOD.


  METHOD get_wr_maximo.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.01.2021
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the WR Maximo details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR: et_maximo.

    SELECT a~wrno,
           a~source,
           b~linenum,
           b~itemcode,
           c~maktx,
           b~diglength,
           b~digwidth,
           b~digfromloc,
           b~digtoloc
      FROM ztcu_wrheader AS a
      INNER JOIN ztcu_writem AS b
      ON a~wrno = b~wrno
      LEFT OUTER JOIN makt AS c
      ON b~itemcode = c~matnr
      AND c~spras   = @sy-langu
      INTO TABLE @DATA(lt_writem)
      WHERE a~wrno   = @iv_wrno.
    IF sy-subrc = 0.
      LOOP AT lt_writem ASSIGNING FIELD-SYMBOL(<ls_writem>).
        IF <ls_writem>-source = zif_cu_sip=>gc_source-maximo OR
           <ls_writem>-source = zif_cu_sip=>gc_source-maximo_lower.
          APPEND INITIAL LINE TO et_maximo ASSIGNING FIELD-SYMBOL(<ls_maximo>).
          MOVE-CORRESPONDING <ls_writem> TO <ls_maximo>.
         " <ls_maximo>-materialdescr = <ls_writem>-maktx.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD item_searchhelp.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 21.08.2020
*&  Functional Design Name : SWR/Ticketing/SP Application
*&  Purpose                : Get contracts
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR: et_data.

    DATA: lt_data             TYPE zttcu_itemf4,
          lv_tolerancepercent TYPE i,
          lt_param            TYPE zttca_param,
          lv_taxcode          TYPE mwskz.

    "get details from contract
*    SELECT  a~ebeln,
*            b~matnr,
*            c~maktx,
*            a~peinh,
*            a~netpr,
*            a~meins,
*            a~mwskz
*      FROM ekpo AS a
*      INNER JOIN mara AS b
*      ON a~matnr = b~matnr AND
*         b~lvorm = @space
*      LEFT OUTER JOIN makt AS c
*      ON a~matnr = c~matnr AND
*         c~spras = @sy-langu
*      INTO TABLE @DATA(lt_cont)
*      WHERE a~ebeln = @is_item-ebeln AND
*            a~loekz = @space.
*    IF sy-subrc EQ 0.
*
*      IF iv_appindicator = 'I'.
*        "Get WEC tax indicator
*        IF is_item-werks IS NOT INITIAL.
*          SELECT a~matnr,
*                 a~werks,
*                 a~casnr,
*                 b~mtart
*            FROM marc AS a
*            INNER JOIN mara AS b
*            ON a~matnr = b~matnr
*            INTO TABLE @DATA(lt_wectax)
*            WHERE werks = @is_item-werks.
*          IF sy-subrc = 0.
*            SORT lt_wectax BY matnr werks.
*          ENDIF.
*        ENDIF.
*
*        "Get the material types for which taxcode has to be determined
*        NEW zcl_ca_utility( )->get_parameter(
*        EXPORTING
*          i_busproc           = 'PU'             " Business Process
*          i_busact            = 'TECH'           " Business Activity
*          i_validdate         = sy-datum         " Parameter Validity Start Date
*          i_param             = 'MTART'
*        CHANGING
*          t_param             = lt_param         " Parameter value
*        EXCEPTIONS
*          invalid_busprocess  = 1                " Invalid Business Process
*          invalid_busactivity = 2                " Invalid Business Activity
*          OTHERS              = 3
*      ).
*        IF sy-subrc = 0.
*          SORT lt_param BY value.
*        ENDIF.
*      ENDIF.
*      "Get tolerance details
*      SELECT  matnr,
*              tolerance,
*              toleranceabsol,
*              exempttolerance,
*              exempttoleranceabsol
*        FROM ztcu_tolerance
*        INTO TABLE @DATA(lt_tolerance)
*        FOR ALL ENTRIES IN @lt_cont
*        WHERE matnr = @lt_cont-matnr AND
*            validfrom LE @sy-datum AND
*            validto   GE @sy-datum.
*      IF sy-subrc = 0.
*        SORT lt_tolerance BY matnr.
*      ENDIF.
*    ENDIF.
*    "Item F4 for ticketing app
*    IF is_item-wrno IS NOT INITIAL.
*      "Get mateerials based on work request
*      SELECT a~wrno,
*             a~itemcode,
*             a~designqty,
*             a~woid,
*             b~source
*        FROM ztcu_writem AS a
*        INNER JOIN ztcu_wrheader AS b
*        ON a~wrno = b~wrno
*        INTO TABLE @DATA(lt_tkt)
*        WHERE a~wrno = @is_item-wrno.
*
*      IF sy-subrc EQ 0.
*        SORT lt_tkt BY itemcode.
*      ENDIF.
*
*      "Item F4 for special project
*    ELSEIF is_item-spno IS NOT INITIAL.
*      "Get materials based on special proj no
*      SELECT spno,
*             itemcode,
*             actqty,
*             costobject,
*             coflag
*        FROM ztcu_spitem
*        INTO TABLE @DATA(lt_sp)
*        WHERE spno = @is_item-spno.
*      IF sy-subrc EQ 0.
*        SORT lt_sp BY itemcode.
*      ENDIF.
*    ENDIF.
*
*    "Calculate Accumulated Qty
*    IF iv_appindicator IS NOT INITIAL AND
*       is_item-category IS NOT INITIAL.
*
*      "Calculate Accumulated Qty for items not in WR/SP but in contract
*      zclcu_sip_utility=>calculate_accumulatedqty(
*      EXPORTING
*        iv_appindicator   = iv_appindicator
*        iv_sipno          = is_item-sipno
*        iv_ticketno       = is_item-ticketno
*        iv_contract       = is_item-ebeln
*        iv_spno           = is_item-spno
*        iv_wrno           = is_item-wrno
*      IMPORTING
*        et_accumulatedqty = DATA(lt_accumulatedqty_new)
*    ).
*
*      "Calculate Accumulated Qty for Items from contract in WR and SP scenario
*      IF is_item-category <> 'C'.
*        zclcu_sip_utility=>calculate_accumulatedqty(
*          EXPORTING
*            iv_appindicator   = iv_appindicator
*            iv_sipno          = is_item-sipno
*            iv_ticketno       = is_item-ticketno
*            iv_spno           = is_item-spno
*            iv_wrno           = is_item-wrno
*          IMPORTING
*            et_accumulatedqty = DATA(lt_accumulatedqty)
*        ).
*      ENDIF.
*    ENDIF.
*
*    LOOP AT lt_cont ASSIGNING FIELD-SYMBOL(<ls_cont>).
*      APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
*
*      <ls_data>-ebeln   = <ls_cont>-ebeln.
*      <ls_data>-netpr   = <ls_cont>-netpr.
*      <ls_data>-peinh   = <ls_cont>-peinh.
*      <ls_data>-matnr   = <ls_cont>-matnr.
*      <ls_data>-maktx   = <ls_cont>-maktx.
*      <ls_data>-meins   = <ls_cont>-meins.
*      "Marking new item oly for Planned Scenario
*      <ls_data>-newitem = abap_true.
*
*      READ TABLE lt_accumulatedqty_new ASSIGNING FIELD-SYMBOL(<ls_accumqty>)
*      WITH KEY itemcode = <ls_cont>-matnr BINARY SEARCH.
*      IF sy-subrc = 0.
*        <ls_data>-accumqty = <ls_accumqty>-accumqty.
*      ENDIF.
*
*      "Tax code determination
*      IF iv_appindicator = 'I'.
*        "Check if the material type is CM00 or DIEN
*        READ TABLE lt_wectax ASSIGNING FIELD-SYMBOL(<ls_wectax>)
*        WITH KEY matnr = <ls_cont>-matnr
*                 werks = is_item-werks BINARY SEARCH.
*        IF sy-subrc = 0.
*          READ TABLE lt_param TRANSPORTING NO FIELDS
*          WITH KEY value = <ls_wectax>-mtart BINARY SEARCH.
*          IF sy-subrc = 0.
*            IF <ls_cont>-mwskz IS NOT INITIAL.
*              lv_taxcode = <ls_cont>-mwskz.
*            ELSE.
*              "Determine tax code based on WEC tax indicator
*              CASE <ls_wectax>-casnr.
*                WHEN 'E'.
*                  lv_taxcode = 'EX'.
*                WHEN 'I'.
*                  lv_taxcode = 'IN'.
*                WHEN 'M'.
*                  lv_taxcode = 'EX'.
*                WHEN 'R'.
*                  lv_taxcode = 'EX'.
*                WHEN 'S'.
*                  lv_taxcode = 'TS'.
*                WHEN 'T'.
*                  lv_taxcode = 'TV'.
*              ENDCASE.
*            ENDIF.
*          ELSE.
*            lv_taxcode = 'TS'.
*          ENDIF.
*        ENDIF.
*
*        IF lv_taxcode = 'TV'.
*          CALL METHOD zclcu_sip_utility=>calculate_tax_material
*            EXPORTING
*              iv_compcode     = is_item-compcode
*              iv_plantregion  = is_item-plantregion
*              iv_plantjurisd  = is_item-plantjurisd
*              iv_vendorregion = is_item-vendorregion
*              iv_vendorjurisd = is_item-vendorjurisd
*              iv_taxcode      = lv_taxcode
*            IMPORTING
*              ev_taxpercent   = <ls_data>-taxpercent.
*        ENDIF.
*      ENDIF.
*
*      IF is_item-wrno IS NOT INITIAL.
*        READ TABLE lt_tkt ASSIGNING FIELD-SYMBOL(<ls_tkt>) WITH KEY itemcode = <ls_cont>-matnr BINARY SEARCH.
*        IF sy-subrc EQ 0.
*          <ls_data>-wrno       = <ls_tkt>-wrno.
*          <ls_data>-designqty  = <ls_tkt>-designqty.
*          <ls_data>-meins      = <ls_cont>-meins.
*          <ls_data>-costobject = <ls_tkt>-woid.
*          <ls_data>-newitem    = abap_false.
*
*          READ TABLE lt_accumulatedqty ASSIGNING <ls_accumqty>
*          WITH KEY itemcode = <ls_cont>-matnr BINARY SEARCH.
*          IF sy-subrc = 0.
*            <ls_data>-accumqty = <ls_accumqty>-accumqty.
*          ENDIF.
*
*          IF <ls_data>-costobject IS NOT INITIAL.
*            IF <ls_tkt>-source = 'WMIS'.
*              <ls_data>-coflag = 'IO'.
*            ELSEIF <ls_tkt>-source = 'MAXIMO'.
*              <ls_data>-coflag = 'PM'.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ELSEIF is_item-spno IS NOT INITIAL.
*        READ TABLE lt_sp ASSIGNING FIELD-SYMBOL(<ls_sp>) WITH KEY itemcode = <ls_cont>-matnr BINARY SEARCH.
*        IF sy-subrc EQ 0.
*          <ls_data>-spno       = <ls_sp>-spno.
*          <ls_data>-designqty  = <ls_sp>-actqty.
*          <ls_data>-meins      = <ls_cont>-meins.
*          <ls_data>-costobject = <ls_sp>-costobject.
*          <ls_data>-coflag     = <ls_sp>-coflag.
*          <ls_data>-newitem    = abap_false.
*
*          READ TABLE lt_accumulatedqty ASSIGNING <ls_accumqty>
*          WITH KEY itemcode = <ls_cont>-matnr BINARY SEARCH.
*          IF sy-subrc = 0.
*            <ls_data>-accumqty = <ls_accumqty>-accumqty.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
*      IF <ls_data>-wrno IS NOT INITIAL OR
*         <ls_data>-spno IS NOT INITIAL.
*        READ TABLE lt_tolerance ASSIGNING FIELD-SYMBOL(<ls_tol>) WITH KEY matnr = <ls_cont>-matnr BINARY SEARCH.
*        IF sy-subrc EQ 0.
*          IF  <ls_tol>-exempttolerance IS INITIAL
*             OR  <ls_tol>-exempttoleranceabsol IS INITIAL.
*
*            IF ( ( <ls_tol>-exempttoleranceabsol IS INITIAL AND <ls_tol>-toleranceabsol IS NOT INITIAL ) OR
*                 ( <ls_tol>-exempttolerance IS INITIAL AND <ls_tol>-tolerance IS NOT INITIAL ) ).
*
*              IF <ls_tol>-exempttoleranceabsol IS INITIAL AND
*                 <ls_tol>-toleranceabsol IS NOT INITIAL.
*                <ls_data>-toleranceflag = abap_true.
*                <ls_data>-tolerance     =  <ls_tol>-toleranceabsol.
*              ENDIF.
*              IF  <ls_tol>-exempttolerance IS INITIAL AND
*                  <ls_tol>-tolerance IS NOT INITIAL.
*                <ls_data>-toleranceflag = abap_true.
*                lv_tolerancepercent = ( ( <ls_data>-designqty * <ls_tol>-tolerance ) ).
*                IF <ls_data>-tolerance IS NOT INITIAL.
*                  IF <ls_data>-tolerance > lv_tolerancepercent.
*                    <ls_data>-tolerance = lv_tolerancepercent.
*                  ENDIF.
*                ELSE.
*                  <ls_data>-tolerance = lv_tolerancepercent.
*                ENDIF.
*              ENDIF.
*
*            ELSEIF <ls_tol>-toleranceabsol IS INITIAL AND <ls_tol>-tolerance IS INITIAL.
*              <ls_data>-toleranceflag = abap_false.
*            ENDIF.
*          ELSE.
*            <ls_data>-toleranceflag = abap_false.
*          ENDIF.
*        ELSE.
*          <ls_data>-toleranceflag = abap_true.
*        ENDIF.
*
*      ELSE.
*        <ls_data>-toleranceflag = abap_false.
*      ENDIF.
*      CLEAR: lv_tolerancepercent.
*    ENDLOOP.
*
*
*    IF lt_data IS NOT INITIAL.
*      IF is_item-wrno IS NOT INITIAL.
*        SORT lt_data BY ebeln matnr wrno.
*        DELETE ADJACENT DUPLICATES FROM lt_data COMPARING ebeln matnr wrno.
*      ELSEIF is_item-spno IS NOT INITIAL.
*        SORT lt_data BY ebeln matnr spno.
*        DELETE ADJACENT DUPLICATES FROM lt_data COMPARING ebeln matnr spno.
*      ELSE.
*        SORT lt_data BY ebeln matnr.
*        DELETE ADJACENT DUPLICATES FROM lt_data COMPARING ebeln matnr.
*      ENDIF.
*      IF is_item-matnr IS NOT INITIAL.
*        DATA(lt_temp) = lt_data.
*        CLEAR : lt_data.
*        LOOP AT lt_temp ASSIGNING FIELD-SYMBOL(<ls_temp>) WHERE matnr = is_item-matnr.
*          APPEND INITIAL LINE TO lt_data ASSIGNING <ls_data>.
*          CLEAR : <ls_data>.
*          <ls_data> = <ls_temp>.
*        ENDLOOP.
*
*      ENDIF.
*    ENDIF.
*
*
*    "Check if materials are linked to JU and get the unit type(sy/se/bo)
*    CALL METHOD zclcu_sip_utility=>get_judetails
*      EXPORTING
*        it_matf4 = lt_data
*      IMPORTING
*        et_matf4 = et_data.

  CLEAR: et_data.


"get details from contract
    SELECT  a~ebeln,
            b~matnr,
            c~maktx,
            a~peinh,
            a~netpr,
            a~meins,
            a~mwskz
      FROM ekpo AS a
      INNER JOIN mara AS b
      ON a~matnr = b~matnr AND
         b~lvorm = @space
      LEFT OUTER JOIN makt AS c
      ON a~matnr = c~matnr AND
         c~spras = @sy-langu
      INTO TABLE @DATA(lt_wr)
      WHERE a~ebeln = @is_item-ebeln AND
            a~loekz = @space.


      IF sy-subrc <> 0.
       ENDIF.

    LOOP AT lt_wr ASSIGNING FIELD-SYMBOL(<ls_wr>).

        APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
        CLEAR : <ls_data>.
        <ls_data>-matnr = <ls_wr>-matnr.
        <ls_data>-ebeln    = <ls_wr>-ebeln.
        <ls_data>-meins    = <ls_wr>-meins.
        <ls_data>-netpr    = <ls_wr>-netpr.
        <ls_data>-peinh    = <ls_wr>-peinh.
        <ls_data>-maktx    = <ls_wr>-maktx.


    ENDLOOP.

    IF lt_data IS NOT INITIAL.
      et_data = lt_data.
    ENDIF.

  ENDMETHOD.


  METHOD plant_searchhelp.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 31.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Plant info for Search help
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lt_param TYPE zttca_param,
          lv_param TYPE z_param.

    CLEAR: et_plantsearchhelp.

*-----Fetch plant data from T001W table
    SELECT a~werks,
           a~name1,
           a~regio,
           a~txjcd,
           b~bukrs
           FROM t001w AS a
      INNER JOIN t001k AS b
      ON a~bwkey = b~bwkey
      INTO TABLE @DATA(lt_t001w).
    IF sy-subrc = 0.
      CONCATENATE 'AUTOAPP' iv_application INTO lv_param
      SEPARATED BY '_'.

      IF lv_param IS NOT INITIAL.
        NEW zcl_ca_utility( )->get_parameter(
          EXPORTING
            i_busproc           = 'CU'             " Business Process
            i_busact            = 'TECH'           " Business Activity
            i_validdate         = sy-datum         " Parameter Validity Start Date
            i_param             = lv_param
          CHANGING
            t_param             = lt_param         " Parameter value
          EXCEPTIONS
            invalid_busprocess  = 1                " Invalid Business Process
            invalid_busactivity = 2                " Invalid Business Activity
            OTHERS              = 3
        ).
        IF sy-subrc = 0.
          SORT lt_param BY value.
        ENDIF.
      ENDIF.

      LOOP AT lt_t001w ASSIGNING FIELD-SYMBOL(<ls_t001w>).
        APPEND INITIAL LINE TO et_plantsearchhelp ASSIGNING FIELD-SYMBOL(<ls_plant>).
        <ls_plant>-plant = <ls_t001w>-werks.
        <ls_plant>-description = <ls_t001w>-name1.
        <ls_plant>-companycode = <ls_t001w>-bukrs.
        <ls_plant>-planttaxjur = <ls_t001w>-txjcd.
        <ls_plant>-plantregion = <ls_t001w>-regio.

        READ TABLE lt_param TRANSPORTING NO FIELDS
        WITH KEY value = <ls_plant>-companycode.
        IF sy-subrc = 0.
          <ls_plant>-autoapprove = abap_true.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD populate_uniqueid.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 31.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Populate unique Id for each app
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA : lv_number(10) TYPE n,
           lv_nrobject   TYPE inri-object,
           lv_prefix     TYPE char2.

    CONSTANTS : lc_si    TYPE inri-object VALUE 'ZW073_SI',
                lc_fc    TYPE inri-object VALUE 'ZW076_FC',
                lc_ug    TYPE inri-object VALUE 'ZU115_UG',
                lc_batch TYPE inri-object VALUE 'ZU116_JUBA',
                lc_bill  TYPE inri-object VALUE 'ZU116_JUB'.

    CASE iv_appindicator.

      WHEN zif_cu_sip~gc_i.
        lv_nrobject = lc_si.
        lv_prefix = zif_cu_sip~gc_i_prefix.

      WHEN zif_cu_sip~gc_t.
        lv_nrobject = lc_fc.
        lv_prefix = zif_cu_sip~gc_t_prefix.

      WHEN zif_cu_sip~gc_sp.
        lv_nrobject = lc_ug.
        lv_prefix = zif_cu_sip~gc_sp_prefix.

      WHEN zif_cu_sip~gc_batch.
        lv_nrobject = lc_batch.

      WHEN zif_cu_sip~gc_bill.
        lv_nrobject = lc_bill.
    ENDCASE.


    CLEAR ev_uniqueid.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = lv_nrobject
        quantity                = 1
      IMPORTING
        number                  = lv_number
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.

    IF sy-subrc = 0.
      CONCATENATE lv_prefix
      lv_number INTO ev_uniqueid.
    ELSE.
      CLEAR ev_uniqueid.
    ENDIF.

  ENDMETHOD.


  METHOD set_approvalflow.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 13/07/2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Save the changes of approval flow
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR: et_routing_ins,
           et_routing_upd,
           et_routing_del.

    IF it_approvalflow IS NOT INITIAL.
      DATA(lt_approvalflow) = it_approvalflow.
      SORT lt_approvalflow BY ordernum DESCENDING.

      LOOP AT it_approvalflow ASSIGNING FIELD-SYMBOL(<ls_appflow>).
        IF <ls_appflow>-operation = zif_cu_sip=>gc_operation-insert.
          APPEND INITIAL LINE TO et_routing_ins ASSIGNING FIELD-SYMBOL(<ls_approvalflow>).
        ELSEIF <ls_appflow>-operation = zif_cu_sip=>gc_operation-update.
          APPEND INITIAL LINE TO et_routing_upd ASSIGNING <ls_approvalflow>.
        ELSEIF <ls_appflow>-operation = zif_cu_sip=>gc_operation-delete.
          APPEND INITIAL LINE TO et_routing_del ASSIGNING <ls_approvalflow>.
        ENDIF.

        IF <ls_approvalflow> IS ASSIGNED.
          <ls_approvalflow>-sipno = <ls_appflow>-sipno.

          MOVE-CORRESPONDING <ls_appflow> TO <ls_approvalflow> ##ENH_OK.
          <ls_approvalflow>-seqnum   = <ls_appflow>-ordernum.
          <ls_approvalflow>-ordernum = <ls_appflow>-ordernum.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD update_status.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 31.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Update status in SIP Header
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lv_sipno  TYPE z_sipno,
          lv_status TYPE z_sipstatus.

    READ TABLE it_input ASSIGNING FIELD-SYMBOL(<ls_parameter>)
    WITH KEY name = 'SIPNo'.                             "#EC CI_STDSEQ
    IF sy-subrc EQ 0.
      lv_sipno = <ls_parameter>-value.
    ENDIF.

    READ TABLE it_input ASSIGNING <ls_parameter>
    WITH KEY name = 'Status'.                            "#EC CI_STDSEQ
    IF sy-subrc EQ 0.
      lv_status = <ls_parameter>-value.
    ENDIF.

    IF lv_sipno IS NOT INITIAL AND
       lv_status IS NOT INITIAL.
      UPDATE ztcu_sipheader SET sipstatus = lv_status WHERE sipno = lv_sipno.
      IF sy-subrc = 0.
        COMMIT WORK.

        es_return-type = 'S'.
        es_return-message = 'Status updated succesfully'.
      ELSE.
        es_return-type = 'E'.
        es_return-message = 'Error in updating status'.
      ENDIF.

    ELSE.
      es_return-type = 'E'.
      es_return-message = 'Mandatory parameters missing'.
    ENDIF.
  ENDMETHOD.


  METHOD update_status_fpc.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 31.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Update status in Ticket Header
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lv_tktno  TYPE z_ticketno,
          lv_status TYPE z_sipstatus.

    READ TABLE it_input ASSIGNING FIELD-SYMBOL(<ls_parameter>)
    WITH KEY name = 'TicketNo'.                          "#EC CI_STDSEQ
    IF sy-subrc EQ 0.
      lv_tktno = <ls_parameter>-value.
    ENDIF.

    READ TABLE it_input ASSIGNING <ls_parameter>
    WITH KEY name = 'Status'.                            "#EC CI_STDSEQ
    IF sy-subrc EQ 0.
      lv_status = <ls_parameter>-value.
    ENDIF.

    IF lv_tktno IS NOT INITIAL AND
       lv_status IS NOT INITIAL.
      UPDATE ztcu_tktheader SET sipstatus = lv_status WHERE ticketno = lv_tktno.
      IF sy-subrc = 0.
        COMMIT WORK.

        es_return-type = 'S'.
        es_return-message = 'Status updated succesfully'.
      ELSE.
        es_return-type = 'E'.
        es_return-message = 'Error in updating status'.
      ENDIF.

    ELSE.
      es_return-type = 'E'.
      es_return-message = 'Mandatory parameters missing'.
    ENDIF.
  ENDMETHOD.


  METHOD validate_access.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 06.01.2021
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Validate Access
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : es_return.

    DATA: lv_sipno  TYPE z_sipno,
          lv_userid TYPE string,
          lv_taskid TYPE string,
          lv_count  TYPE i,
          lt_param  TYPE zttca_param,
          lt_split  TYPE STANDARD TABLE OF char40.

    IF it_input IS NOT INITIAL .
      READ TABLE it_input ASSIGNING FIELD-SYMBOL(<ls_parameter>) WITH KEY name = 'SIPNo'. "#EC CI_STDSEQ
      IF sy-subrc EQ 0.
        lv_sipno = <ls_parameter>-value.   "SIPno
      ENDIF.

      READ TABLE it_input ASSIGNING <ls_parameter> WITH KEY name = 'TaskID'. "#EC CI_STDSEQ
      IF sy-subrc EQ 0.
        lv_taskid = <ls_parameter>-value.  "Task Id
      ENDIF.


      READ TABLE it_input ASSIGNING <ls_parameter> WITH KEY name = 'UserID'. "#EC CI_STDSEQ
      IF sy-subrc EQ 0.
        lv_userid = <ls_parameter>-value.  "UserId
      ENDIF.

      IF lv_sipno IS NOT INITIAL AND
         ( lv_taskid IS NOT INITIAL OR
           lv_userid IS NOT INITIAL ).
        "Get the audit log details
        SELECT data_keys,
               workflow_status,
               sequence_no,
               field5,
               field6
          FROM ztca_audit_log
          INTO TABLE @DATA(lt_auditlog)
          WHERE data_keys = @lv_sipno.
        IF sy-subrc = 0.
          SORT lt_auditlog BY sequence_no ASCENDING.
          READ TABLE lt_auditlog ASSIGNING FIELD-SYMBOL(<ls_auditlog>)
          INDEX 1.
          IF sy-subrc = 0 AND
             <ls_auditlog>-workflow_status = 'COMPLETED'.

            es_return-type = zif_cu_sip=>gc_error.

            CALL FUNCTION 'FORMAT_MESSAGE'
              EXPORTING
                id        = zif_cu_sip=>gc_zcu_msg
                lang      = sy-langu
                no        = '030'
              IMPORTING
                msg       = es_return-message
              EXCEPTIONS
                not_found = 1
                OTHERS    = 2.
            IF sy-subrc <> 0.
              CLEAR es_return-message.
            ENDIF.
          ENDIF.
          IF es_return IS INITIAL.

            "Get the creation date of the SIP
            SELECT SINGLE createdon
              INTO @DATA(lv_createdon)
              FROM ztcu_sipheader
              WHERE sipno = @lv_sipno.
            IF sy-subrc = 0.

              "Get the date from which validation has to happen
              NEW zcl_ca_utility( )->get_parameter(
              EXPORTING
                i_busproc           = 'CU'             " Business Process
                i_busact            = 'TECH'           " Business Activity
                i_validdate         = sy-datum         " Parameter Validity Start Date
                i_param             = 'VALID_ACCESS'
              CHANGING
                t_param             = lt_param         " Parameter value
              EXCEPTIONS
                invalid_busprocess  = 1                " Invalid Business Process
                invalid_busactivity = 2                " Invalid Business Activity
                OTHERS              = 3
            ).

              "If creation date less than value in paramter table - success
              IF sy-subrc = 0.
                READ TABLE lt_param ASSIGNING FIELD-SYMBOL(<ls_param>)
                INDEX 1.
                IF sy-subrc = 0.
                  IF lv_createdon LT <ls_param>-value.
                    es_return-type = zif_cu_sip=>gc_success.
                  ENDIF.
                ENDIF.
              ENDIF.

              IF es_return IS INITIAL.
                "Check if task is final
                IF lv_taskid IS NOT INITIAL.
                  DESCRIBE TABLE lt_auditlog LINES lv_count.
                  IF lv_count = 2.
                    es_return-type = zif_cu_sip=>gc_success.

                  ELSE.
                    READ TABLE lt_auditlog ASSIGNING <ls_auditlog>
                    WITH KEY field6 = lv_taskid.
                    IF sy-subrc <> 0.
                      es_return-type = zif_cu_sip=>gc_success.

                    ELSE.
                      es_return-type = zif_cu_sip=>gc_error.

                      CALL FUNCTION 'FORMAT_MESSAGE'
                        EXPORTING
                          id        = zif_cu_sip=>gc_zcu_msg
                          lang      = sy-langu
                          no        = '029'
                        IMPORTING
                          msg       = es_return-message
                        EXCEPTIONS
                          not_found = 1
                          OTHERS    = 2.
                      IF sy-subrc <> 0.
                        CLEAR es_return-message.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.

                "Check if the user is valid
                IF lv_userid IS NOT INITIAL AND
                   es_return-type <> zif_cu_sip=>gc_error.

                  SORT lt_auditlog BY sequence_no DESCENDING.
                  READ TABLE lt_auditlog ASSIGNING <ls_auditlog>
                  INDEX 1.
                  IF sy-subrc = 0.
                    SPLIT <ls_auditlog>-field5 AT ',' INTO TABLE lt_split.
                    READ TABLE lt_split TRANSPORTING NO FIELDS
                    WITH KEY table_line = lv_userid.
                    IF sy-subrc = 0.
                      es_return-type = zif_cu_sip=>gc_success.
                    ELSE.
                      es_return-type = zif_cu_sip=>gc_error.

                      CALL FUNCTION 'FORMAT_MESSAGE'
                        EXPORTING
                          id        = zif_cu_sip=>gc_zcu_msg
                          lang      = sy-langu
                          no        = '024'
                          v1        = TEXT-022
                          v2        = TEXT-023
                        IMPORTING
                          msg       = es_return-message
                        EXCEPTIONS
                          not_found = 1
                          OTHERS    = 2.
                      IF sy-subrc <> 0.
                        CLEAR es_return-message.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.

              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD validate_contract.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 08.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Contract Validation
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : es_return.
    DATA: lv_contract TYPE ekko-ebeln.

    CONSTANTS: lc_bsart   TYPE ekko-bsart VALUE 'MKI',
               lc_err     TYPE string VALUE 'E',
               lc_success TYPE string VALUE 'S'.

    IF it_input IS NOT INITIAL .
      READ TABLE it_input ASSIGNING FIELD-SYMBOL(<ls_parameter>) WITH KEY name = TEXT-002. "#EC CI_STDSEQ
      IF sy-subrc EQ 0.
        lv_contract = <ls_parameter>-value.   "Contract

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_contract
          IMPORTING
            output = lv_contract.
      ENDIF.

      "Check if user is valid contract
      SELECT SINGLE ebeln
            FROM ekko
            INTO @DATA(lv_valid)
            WHERE ebeln = @lv_contract
            AND bsart = @lc_bsart .

      IF sy-subrc <> 0.
        "Invalid contract
        es_return-type = lc_err.
        CALL FUNCTION 'FORMAT_MESSAGE'
          EXPORTING
            id        = zif_cu_sip=>gc_zcu_msg
            lang      = sy-langu
            no        = '007'
          IMPORTING
            msg       = es_return-message
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
        IF sy-subrc <> 0.
          CLEAR es_return-message.
        ENDIF.
      ELSE.
        es_return-type = lc_success.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD validate_invoice.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi.K
*&  Created On             : 08.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Validate if there are Invoices in progress
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lw_fpcitem  TYPE zclcu_sip_mpc=>ts_fpcitem,
          lv_contract TYPE ebeln,
          lv_sp       TYPE z_spno,
          lv_wr       TYPE z_wrno,
          lv_fpc      TYPE flag.

    CLEAR: es_return.

    READ TABLE it_input ASSIGNING FIELD-SYMBOL(<ls_parameter>) WITH KEY name = zif_cu_sip=>gc_contract_text. "#EC CI_STDSEQ
    IF sy-subrc EQ 0.
      lv_contract = <ls_parameter>-value.   "Contract
    ENDIF.

    READ TABLE it_input ASSIGNING <ls_parameter> WITH KEY name = zif_cu_sip=>gc_spno. "#EC CI_STDSEQ
    IF sy-subrc EQ 0.
      lv_sp = <ls_parameter>-value.   "Contract
    ENDIF.

    READ TABLE it_input ASSIGNING <ls_parameter> WITH KEY name = zif_cu_sip=>gc_wrno. "#EC CI_STDSEQ
    IF sy-subrc EQ 0.
      lv_wr = <ls_parameter>-value.   "Contract
    ENDIF.

    READ TABLE it_input ASSIGNING <ls_parameter> WITH KEY name = zif_cu_sip=>gc_fpc. "#EC CI_STDSEQ
    IF sy-subrc EQ 0.
      lv_fpc = <ls_parameter>-value.   "FPC
    ENDIF.

    IF lv_fpc = abap_true.
      IF lv_contract IS NOT INITIAL.

        lw_fpcitem-contract = lv_contract.
        "Get approved tkts for Contract
        CALL METHOD zclcu_w076_utility=>get_approved_tickets
          EXPORTING
            is_fpcitem = lw_fpcitem
          IMPORTING
            et_fpcitem = DATA(lt_fpcitem).

        DELETE lt_fpcitem WHERE sipstatus <> zif_cu_sip=>gc_sipstatus-completed.
        IF lt_fpcitem IS INITIAL.
          es_return-type = 'E'.

          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = zif_cu_sip=>gc_zcu_msg
              lang      = sy-langu
              no        = '055'
              v1        = 'Contract'
              v2        = lv_contract
            IMPORTING
              msg       = es_return-message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc <> 0.
            CLEAR es_return-message.
          ENDIF.
        ELSE.
          es_return-type = 'S'.
        ENDIF.

      ELSEIF lv_sp IS NOT INITIAL.
        lw_fpcitem-spno = lv_sp.
        "Get approved tkts for SP
        CALL METHOD zclcu_w076_utility=>get_approved_tickets
          EXPORTING
            is_fpcitem = lw_fpcitem
          IMPORTING
            et_fpcitem = lt_fpcitem.

        DELETE lt_fpcitem WHERE sipstatus <> zif_cu_sip=>gc_sipstatus-completed.
        IF lt_fpcitem IS INITIAL.
          es_return-type = 'E'.

          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = zif_cu_sip=>gc_zcu_msg
              lang      = sy-langu
              no        = '055'
              v1        = 'Field Work Order'
              v2        = lv_sp
            IMPORTING
              msg       = es_return-message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc <> 0.
            CLEAR es_return-message.
          ENDIF.
        ELSE.
          es_return-type = 'S'.
        ENDIF.

      ELSEIF lv_wr IS NOT INITIAL.
        lw_fpcitem-wrno = lv_wr.
        "Get approved tkts for WR
        CALL METHOD zclcu_w076_utility=>get_approved_tickets
          EXPORTING
            is_fpcitem = lw_fpcitem
          IMPORTING
            et_fpcitem = lt_fpcitem.

        DELETE lt_fpcitem WHERE sipstatus <> zif_cu_sip=>gc_sipstatus-completed.
        IF lt_fpcitem IS INITIAL.
          es_return-type = 'E'.

          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = zif_cu_sip=>gc_zcu_msg
              lang      = sy-langu
              no        = '055'
              v1        = 'Work Request'
              v2        = lv_wr
            IMPORTING
              msg       = es_return-message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc <> 0.
            CLEAR es_return-message.
          ENDIF.
        ELSE.
          es_return-type = 'S'.
        ENDIF.
      ENDIF.


    ELSE.

      IF lv_contract IS NOT INITIAL.
        SELECT  sipno,
               sipstatus
          UP TO 1 ROWS
          FROM ztcu_sipheader
          INTO @DATA(ls_invoice)
          WHERE contract = @lv_contract AND
                sipstatus = @zif_cu_sip=>gc_sipstatus-inprogress. "In Progress
        ENDSELECT.
        IF sy-subrc = 0.
          es_return-type = 'W'.

          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = zif_cu_sip=>gc_zcu_msg
              lang      = sy-langu
              no        = '018'
              v1        = ls_invoice-sipno
              v2        = zif_cu_sip=>gc_contract_msg
              v3        = lv_contract
            IMPORTING
              msg       = es_return-message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc <> 0.
            CLEAR es_return-message.
          ENDIF.
        ELSE.
          es_return-type = 'S'.
        ENDIF.

      ELSEIF lv_sp IS NOT INITIAL.
        SELECT sipno,
               sipstatus
          UP TO 1 ROWS
          FROM ztcu_sipheader
          INTO @ls_invoice
          WHERE spno = @lv_sp AND
                sipstatus = @zif_cu_sip=>gc_sipstatus-inprogress. "In Progress
        ENDSELECT.
        IF sy-subrc = 0.
          es_return-type = 'W'.

          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = zif_cu_sip=>gc_zcu_msg
              lang      = sy-langu
              no        = '018'
              v1        = ls_invoice-sipno
              v2        = zif_cu_sip=>gc_specialproject
              v3        = lv_sp
            IMPORTING
              msg       = es_return-message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc <> 0.
            CLEAR es_return-message.
          ENDIF.
        ELSE.
          es_return-type = 'S'.
        ENDIF.
      ELSEIF lv_wr IS NOT INITIAL.
        SELECT sipno,
               sipstatus
          FROM ztcu_sipheader
          UP TO 1 ROWS
          INTO @ls_invoice
          WHERE wrno = @lv_wr AND
                sipstatus = @zif_cu_sip=>gc_sipstatus-inprogress. "In Progress
        ENDSELECT.
        IF sy-subrc = 0.
          es_return-type = 'W'.

          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = zif_cu_sip=>gc_zcu_msg
              lang      = sy-langu
              no        = '018'
              v1        = ls_invoice-sipno
              v2        = zif_cu_sip=>gc_workorder
              v3        = lv_wr
            IMPORTING
              msg       = es_return-message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc <> 0.
            CLEAR es_return-message.
          ENDIF.
        ELSE.
          es_return-type = 'S'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD validate_material.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 06.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Material Validation
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : es_return.
    DATA: lv_contract TYPE ekko-ebeln,
          lv_mat      TYPE ekpo-matnr.

    CONSTANTS: lc_err     TYPE string VALUE 'E',
               lc_success TYPE string VALUE 'S'.

    IF it_input IS NOT INITIAL .
      READ TABLE it_input ASSIGNING FIELD-SYMBOL(<ls_parameter>) WITH KEY name = TEXT-002. "#EC CI_STDSEQ
      IF sy-subrc EQ 0.
        lv_contract = <ls_parameter>-value.   "Contract
      ENDIF.

      READ TABLE it_input ASSIGNING <ls_parameter> WITH KEY name = TEXT-003. "#EC CI_STDSEQ
      IF sy-subrc EQ 0.
        lv_mat = <ls_parameter>-value.        "Material
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_mat
          IMPORTING
            output = lv_mat.
      ENDIF.

      "Check if user is valid material
      SELECT SINGLE matnr
            FROM mara
            INTO @DATA(lv_valid)
            WHERE matnr = @lv_mat.
      IF sy-subrc <> 0.
        "Invalid material
        es_return-type = lc_err.
        CALL FUNCTION 'FORMAT_MESSAGE'
          EXPORTING
            id        = zif_cu_sip=>gc_zcu_msg
            lang      = sy-langu
            no        = '003'
          IMPORTING
            msg       = es_return-message
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
        IF sy-subrc <> 0.
          CLEAR es_return-message.
        ENDIF.
      ELSE.
        "Get the materials linked to the contract
        SELECT ebeln,
               matnr
               FROM ekpo
               INTO TABLE @DATA(lt_ekpo)
               WHERE ebeln = @lv_contract.
        IF sy-subrc EQ 0.
          "Check whether the entered material belongs to that contract
          SORT lt_ekpo BY matnr.
          READ TABLE lt_ekpo TRANSPORTING NO FIELDS
          WITH KEY matnr = lv_mat BINARY SEARCH.
          IF sy-subrc = 0.
            DATA(lv_flag) = abap_true.
          ENDIF.

          IF lv_flag EQ abap_true.
            es_return-type = lc_success.
          ELSE.
            "Invalid material for the contract
            es_return-type = lc_err.
            CALL FUNCTION 'FORMAT_MESSAGE'
              EXPORTING
                id        = zif_cu_sip=>gc_zcu_msg
                lang      = sy-langu
                no        = '004'
                v1        = lv_mat
                v2        = lv_contract
              IMPORTING
                msg       = es_return-message
              EXCEPTIONS
                not_found = 1
                OTHERS    = 2.
            IF sy-subrc <> 0.
              CLEAR es_return-message.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD validate_mat_state.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 11.20.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : SAP Material and state combination Validation
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : es_return.
    TYPES : BEGIN OF ty_sapmat,
              matnr TYPE matnr,
            END OF ty_sapmat.
    DATA: lv_state    TYPE regio,
          lv_temp_mat TYPE matnr,
          lv_mat      TYPE string,
          lt_sapmat   TYPE TABLE OF ty_sapmat,
          lw_sapmat   TYPE ty_sapmat.

    CONSTANTS: lc_err     TYPE string VALUE 'E',
               lc_success TYPE string VALUE 'S'.

    IF it_input IS NOT INITIAL .
      READ TABLE it_input ASSIGNING FIELD-SYMBOL(<ls_parameter>) WITH KEY name = TEXT-018. "#EC CI_STDSEQ
      IF sy-subrc EQ 0.
        lv_state = <ls_parameter>-value.   "Contract
      ENDIF.

      READ TABLE it_input ASSIGNING <ls_parameter> WITH KEY name = TEXT-017. "#EC CI_STDSEQ
      IF sy-subrc EQ 0.
        lv_mat = <ls_parameter>-value.        "Materials
        "split comma separated materials into a internal table
        SPLIT lv_mat AT ',' INTO TABLE lt_sapmat.
      ENDIF.
      IF lt_sapmat IS NOT INITIAL.
        SORT lt_sapmat BY matnr.
        DELETE ADJACENT DUPLICATES FROM lt_sapmat COMPARING matnr.
        "Get the Ju materials linked to sap materials sent in the filter
        SELECT a~matnr,
               a~catvid,
               a~teleid,
               b~state
          FROM ztcu_juitemasso AS a
          INNER JOIN ztcu_juitemtax AS b
          ON ( a~catvid = b~item
          OR  a~teleid = b~item )
          INTO TABLE @DATA(lt_ju)
          FOR ALL ENTRIES IN @lt_sapmat
          WHERE a~matnr = @lt_sapmat-matnr.

        IF sy-subrc EQ 0.
          SORT lt_ju BY matnr state.
          CLEAR : lv_mat.
          DELETE ADJACENT DUPLICATES FROM lt_ju COMPARING matnr state.
          CLEAR :  lt_sapmat.
          " to REmove the entries that have correct state
          LOOP AT lt_ju ASSIGNING FIELD-SYMBOL(<ls_matju>) WHERE state = lv_state.
            lw_sapmat-matnr = <ls_matju>-matnr.
            APPEND lw_sapmat TO lt_sapmat.
            CLEAR : lw_sapmat.
          ENDLOOP.

          LOOP AT lt_ju ASSIGNING FIELD-SYMBOL(<ls_ju>).
            READ TABLE lt_sapmat TRANSPORTING NO FIELDS WITH KEY matnr = <ls_ju>-matnr BINARY SEARCH.
            IF sy-subrc NE 0.
              IF lv_temp_mat NE <ls_ju>-matnr.
                IF <ls_ju>-catvid IS NOT INITIAL.
                  DATA(lv_ju) = <ls_ju>-catvid.
                ELSE.
                  lv_ju = <ls_ju>-teleid.
                ENDIF.
                IF lv_mat IS INITIAL.
                  CONCATENATE lv_mat <ls_ju>-matnr '(JU :' lv_ju ')' INTO lv_mat.
                ELSE.
                  CONCATENATE lv_mat ', ' <ls_ju>-matnr '(JU :' lv_ju ')'  INTO lv_mat.
                ENDIF.
                lv_temp_mat = <ls_ju>-matnr.
              ENDIF.

            ENDIF.
          ENDLOOP.
          IF lv_mat IS NOT INITIAL.
            "Get the error msg if materials dont belong to the selected state
            CONCATENATE text-021 lv_mat TEXT-019 lv_state TEXT-020 INTO es_return-message SEPARATED BY ' '.
            es_return-type = lc_err.
          ELSE.
            es_return-type = lc_success.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD validate_price_display.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi.K
*&  Created On             : 08.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Validate if user is authorized to view price
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lv_userid TYPE uname,
          lv_role   TYPE agr_name,
          lt_param  TYPE zttca_param.

    CLEAR: es_return.

    READ TABLE it_input ASSIGNING FIELD-SYMBOL(<ls_parameter>)
    WITH KEY name = 'UserId'.                            "#EC CI_STDSEQ
    IF sy-subrc EQ 0.
      lv_userid = <ls_parameter>-value.
    ENDIF.

    IF lv_userid IS NOT INITIAL.
      NEW zcl_ca_utility( )->get_parameter(
      EXPORTING
        i_busproc           = 'CU'             " Business Process
        i_busact            = 'TECH'           " Business Activity
        i_validdate         = sy-datum         " Parameter Validity Start Date
        i_param             = 'PRICEDISPLAY'
      CHANGING
        t_param             = lt_param         " Parameter value
      EXCEPTIONS
        invalid_busprocess  = 1                " Invalid Business Process
        invalid_busactivity = 2                " Invalid Business Activity
        OTHERS              = 3
    ).
      IF lt_param IS NOT INITIAL.
        lv_role = lt_param[ 1 ]-value.
      ENDIF.

      IF lv_role IS NOT INITIAL.
        SELECT agr_name,
               uname
        UP TO 1 ROWS
        FROM agr_users
        INTO @DATA(lt_users)
        WHERE agr_name  = @lv_role AND
              uname     = @lv_userid AND
              from_dat LE @sy-datum AND
              to_dat   GE @sy-datum.
        ENDSELECT.
        IF sy-subrc = 0.
          es_return-type = 'S'.
        ELSE.
          es_return-type = 'E'.
          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = zif_cu_sip=>gc_zcu_msg
              lang      = sy-langu
              no        = '021'
            IMPORTING
              msg       = es_return-message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc <> 0.
            CLEAR es_return-message.
          ENDIF.
        ENDIF.
      ELSE.
        es_return-type = 'E'.
        CALL FUNCTION 'FORMAT_MESSAGE'
          EXPORTING
            id        = zif_cu_sip=>gc_zcu_msg
            lang      = sy-langu
            no        = '020'
          IMPORTING
            msg       = es_return-message
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
        IF sy-subrc <> 0.
          CLEAR es_return-message.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD validate_tkt_access.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 06.01.2021
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Validate Access
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : es_return.

    DATA: lv_tktno  TYPE z_ticketno,
          lv_userid TYPE string,
          lv_taskid TYPE string,
          lv_count  TYPE i,
          lt_param  TYPE zttca_param,
          lt_split  TYPE STANDARD TABLE OF char40.

    IF it_input IS NOT INITIAL .
      READ TABLE it_input ASSIGNING FIELD-SYMBOL(<ls_parameter>) WITH KEY name = 'TKTNo'. "#EC CI_STDSEQ
      IF sy-subrc EQ 0.
        lv_tktno = <ls_parameter>-value.   "SIPno
      ENDIF.

      READ TABLE it_input ASSIGNING <ls_parameter> WITH KEY name = 'TaskID'. "#EC CI_STDSEQ
      IF sy-subrc EQ 0.
        lv_taskid = <ls_parameter>-value.  "Task Id
      ENDIF.


      READ TABLE it_input ASSIGNING <ls_parameter> WITH KEY name = 'UserID'. "#EC CI_STDSEQ
      IF sy-subrc EQ 0.
        lv_userid = <ls_parameter>-value.  "UserId
      ENDIF.

      IF lv_tktno IS NOT INITIAL AND
         ( lv_taskid IS NOT INITIAL OR
           lv_userid IS NOT INITIAL ).
        "Get the audit log details
        SELECT data_keys,
               workflow_status,
               sequence_no,
               field5,
               field6
          FROM ztca_audit_log
          INTO TABLE @DATA(lt_auditlog)
          WHERE data_keys = @lv_tktno.
        IF sy-subrc = 0.
          SORT lt_auditlog BY sequence_no ASCENDING.
          READ TABLE lt_auditlog ASSIGNING FIELD-SYMBOL(<ls_auditlog>)
          INDEX 1.
          IF sy-subrc = 0 AND
             <ls_auditlog>-workflow_status = 'COMPLETED'.

            es_return-type = zif_cu_sip=>gc_error.

            CALL FUNCTION 'FORMAT_MESSAGE'
              EXPORTING
                id        = zif_cu_sip=>gc_zcu_msg
                lang      = sy-langu
                no        = '030'
              IMPORTING
                msg       = es_return-message
              EXCEPTIONS
                not_found = 1
                OTHERS    = 2.
            IF sy-subrc <> 0.
              CLEAR es_return-message.
            ENDIF.
          ENDIF.
          IF es_return IS INITIAL.

            "Get the creation date of the SIP
            SELECT SINGLE createdon
              INTO @DATA(lv_createdon)
              FROM ztcu_tktheader
              WHERE ticketno = @lv_tktno.
            IF sy-subrc = 0.

              "Get the date from which validation has to happen
              NEW zcl_ca_utility( )->get_parameter(
              EXPORTING
                i_busproc           = 'CU'             " Business Process
                i_busact            = 'TECH'           " Business Activity
                i_validdate         = sy-datum         " Parameter Validity Start Date
                i_param             = 'VALID_ACC_TK'
              CHANGING
                t_param             = lt_param         " Parameter value
              EXCEPTIONS
                invalid_busprocess  = 1                " Invalid Business Process
                invalid_busactivity = 2                " Invalid Business Activity
                OTHERS              = 3
            ).

              "If creation date less than value in paramter table - success
              IF sy-subrc = 0.
                READ TABLE lt_param ASSIGNING FIELD-SYMBOL(<ls_param>)
                INDEX 1.
                IF sy-subrc = 0.
                  IF lv_createdon LT <ls_param>-value.
                    es_return-type = zif_cu_sip=>gc_success.
                  ENDIF.
                ENDIF.
              ENDIF.

              IF es_return IS INITIAL.
                "Check if task is final
                IF lv_taskid IS NOT INITIAL.
                  DESCRIBE TABLE lt_auditlog LINES lv_count.
                  IF lv_count = 2.
                    es_return-type = zif_cu_sip=>gc_success.

                  ELSE.
                    READ TABLE lt_auditlog ASSIGNING <ls_auditlog>
                    WITH KEY field6 = lv_taskid.
                    IF sy-subrc <> 0.
                      es_return-type = zif_cu_sip=>gc_success.

                    ELSE.
                      es_return-type = zif_cu_sip=>gc_error.

                      CALL FUNCTION 'FORMAT_MESSAGE'
                        EXPORTING
                          id        = zif_cu_sip=>gc_zcu_msg
                          lang      = sy-langu
                          no        = '029'
                        IMPORTING
                          msg       = es_return-message
                        EXCEPTIONS
                          not_found = 1
                          OTHERS    = 2.
                      IF sy-subrc <> 0.
                        CLEAR es_return-message.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.

                "Check if the user is valid
                IF lv_userid IS NOT INITIAL AND
                   es_return-type <> zif_cu_sip=>gc_error.

                  SORT lt_auditlog BY sequence_no DESCENDING.
                  READ TABLE lt_auditlog ASSIGNING <ls_auditlog>
                  INDEX 1.
                  IF sy-subrc = 0.
                    SPLIT <ls_auditlog>-field5 AT ',' INTO TABLE lt_split.
                    READ TABLE lt_split TRANSPORTING NO FIELDS
                    WITH KEY table_line = lv_userid.
                    IF sy-subrc = 0.
                      es_return-type = zif_cu_sip=>gc_success.
                    ELSE.
                      es_return-type = zif_cu_sip=>gc_error.

                      CALL FUNCTION 'FORMAT_MESSAGE'
                        EXPORTING
                          id        = zif_cu_sip=>gc_zcu_msg
                          lang      = sy-langu
                          no        = '024'
                          v1        = TEXT-022
                          v2        = TEXT-023
                        IMPORTING
                          msg       = es_return-message
                        EXCEPTIONS
                          not_found = 1
                          OTHERS    = 2.
                      IF sy-subrc <> 0.
                        CLEAR es_return-message.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.

              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD validate_userid.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 07.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Validate user id based on role
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : es_return.

    CONSTANTS: lc_err     TYPE string VALUE 'E',
               lc_success TYPE string VALUE 'S'.

    IF it_input IS NOT INITIAL .
      READ TABLE it_input ASSIGNING FIELD-SYMBOL(<ls_parameter>) WITH KEY name = TEXT-012. "#EC CI_STDSEQ
      IF sy-subrc EQ 0.
        DATA(lv_role) = <ls_parameter>-value.   "Contract
        IF lv_role = 'AP'. "Approver
          DATA(lv_approver) = abap_true.
        ELSE.
          DATA(lv_verifier) = abap_true.
        ENDIF.
      ENDIF.
      READ TABLE it_input ASSIGNING <ls_parameter> WITH KEY name = TEXT-013. "#EC CI_STDSEQ
      IF sy-subrc EQ 0.
        DATA(lv_userid) = <ls_parameter>-value.
      ENDIF.


      CALL METHOD zclcu_sip_utility=>get_approver_verifier
        EXPORTING
          iv_approvers           = lv_approver
          iv_verifiers           = lv_verifier
        IMPORTING
          et_approvers_verifiers = DATA(lt_appr_verif).
      "get the roles
      IF lt_appr_verif IS NOT INITIAL.
        LOOP AT lt_appr_verif ASSIGNING FIELD-SYMBOL(<ls_appr_verif>).
          IF <ls_appr_verif>-usrid = lv_userid.
            DATA(lv_valid) = abap_true.
            DATA(lv_role_ret) = <ls_appr_verif>-role_id.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF lv_valid = abap_false.
          "Invalid material
          es_return-type = lc_err.
          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = zif_cu_sip=>gc_zcu_msg
              lang      = sy-langu
              no        = '009'
            IMPORTING
              msg       = es_return-message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc <> 0.
            CLEAR es_return-message.
          ENDIF.
        ELSE.
          es_return-type = lc_success.
          es_return-role = lv_role_ret.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD wr_sp_searchhelp.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 21.08.2020
*&  Functional Design Name : SWR/Ticketing/SP Application
*&  Purpose                : Get WR and SPs
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR: et_data.

    DATA : lt_data    TYPE zttcu_wr_sp.

    "Get the WRs
    SELECT *
           FROM ztcu_wrheader
           INTO TABLE @DATA(lt_wr).
       IF sy-subrc <> 0.
       ENDIF.

    LOOP AT lt_wr ASSIGNING FIELD-SYMBOL(<ls_wr>).

        APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
        CLEAR : <ls_data>.
        <ls_data>-wr_spno = <ls_wr>-wrno.
        <ls_data>-desc    = <ls_wr>-wrname.
        <ls_data>-flag    = 'WR'.
        <ls_data>-company = <ls_wr>-suppliercompany.
        <ls_data>-enddate = <ls_wr>-cdate.
        <ls_data>-state   = <ls_wr>-state.

    ENDLOOP.

    IF is_input-wr_spno IS NOT INITIAL.
      DATA(lt_temp) = lt_data.
      CLEAR : lt_data.
      LOOP AT lt_temp ASSIGNING FIELD-SYMBOL(<ls_temp>) WHERE wr_spno = is_input-wr_spno.
        APPEND INITIAL LINE TO lt_data ASSIGNING <ls_data>.
        CLEAR : <ls_data>.
        <ls_data> = <ls_temp>.
      ENDLOOP.
    ENDIF.

    IF lt_data IS NOT INITIAL.
      et_data = lt_data.
    ENDIF.
  ENDMETHOD.


  METHOD attach_create_stream.
************************************************************************
* Program ID:      CREATE_ATTACHMENT
* Program Title:   To create Attachments for SIP
* Created By:      Venkata Gopisetty/C144527
* Creation Date:   23.06.2020
* RICEFW ID:       W073
* Description:     To Create SIP Atatchments linked to BUS2081
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 18.06.2020  C144527           1        D10K934677 / Initial version
************************************************************************

*----------------------------------------------------------------------*
*Local Variables
*----------------------------------------------------------------------*
    CLEAR: er_entity.

    DATA : lw_sip_attach TYPE ZSCU_SIP_ATTACH,
           lv_error_flag TYPE boolean.

****Gte keys from Entityset
    READ TABLE it_key_tab INTO DATA(lw_key_tab) INDEX 1.
    IF sy-subrc EQ 0.
      lw_sip_attach-uniqueno = lw_key_tab-value.
    ENDIF.

***To get the File name and Extension
    SPLIT iv_slug AT '|' INTO lw_sip_attach-filename lw_sip_attach-doctype lw_sip_attach-description.
    SPLIT lw_sip_attach-filename AT '.' INTO lw_sip_attach-filename lw_sip_attach-doctype.
***Call Utility class for data
    zclcu_sip_utility=>create_document(
      EXPORTING
        iv_content       = is_media_resource-value
      IMPORTING
        ev_error_flag    =  lv_error_flag                " Single-Character Flag
      CHANGING
        cs_attachdeatils =   lw_sip_attach  ).             " SIP Attachment header details


    IF lv_error_flag IS INITIAL.
      er_entity = lw_sip_attach.
    ENDIF.
  ENDMETHOD.


  METHOD calculate_accumulatedqty.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 31.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Calculate Accumulated Qty
*&  Transport Request No   : D10K934677
*****************************************************************************
    TYPES: BEGIN OF ty_matdetails,
             sip_ticket TYPE char20,
             sipstatus  TYPE z_sipstatus,
             itemcode   TYPE z_itemcode,
             actqty     TYPE z_actqty,
           END OF ty_matdetails.

    DATA: lt_matdetails TYPE STANDARD TABLE OF ty_matdetails,
          lt_accumqty   TYPE gtt_accumulatedqty,
          ls_accumqty   TYPE gty_accumulatedqty,
          lv_clause     TYPE string.

    CONSTANTS: lc_quote TYPE char1 VALUE ''''.

    CLEAR: et_accumulatedqty.

    IF iv_contract IS NOT INITIAL AND
       iv_wrno IS NOT INITIAL.
      CONCATENATE zif_cu_sip=>gc_dyn_contract space '=' space lc_quote iv_contract lc_quote space 'AND' space
                  zif_cu_sip=>gc_dyn_wr space '=' space lc_quote iv_wrno lc_quote
      INTO   lv_clause RESPECTING BLANKS.

    ELSEIF iv_contract IS NOT INITIAL AND
           iv_spno IS NOT INITIAL.
      CONCATENATE zif_cu_sip=>gc_dyn_contract space '=' space lc_quote iv_contract lc_quote space 'AND' space
                  zif_cu_sip=>gc_dyn_spno space '=' space lc_quote iv_spno lc_quote
      INTO   lv_clause RESPECTING BLANKS.

    ELSEIF iv_contract IS NOT INITIAL.
      CONCATENATE zif_cu_sip=>gc_dyn_contract space '=' space lc_quote iv_contract lc_quote
      INTO   lv_clause RESPECTING BLANKS.

    ELSEIF iv_spno IS NOT INITIAL.
      CONCATENATE zif_cu_sip=>gc_dyn_spno space '=' space lc_quote iv_spno lc_quote
      INTO   lv_clause RESPECTING BLANKS.

    ELSEIF iv_wrno IS NOT INITIAL.
      CONCATENATE zif_cu_sip=>gc_dyn_wr space '=' space lc_quote iv_wrno lc_quote
      INTO   lv_clause RESPECTING BLANKS.
    ENDIF.

    "Fetch all the SIP's for the contract
    IF lv_clause IS NOT INITIAL.
      IF iv_appindicator = 'I'.
        SELECT a~sipno,
               a~sipstatus,
               b~itemcode,
               b~actqty
          FROM ztcu_sipheader AS a
          INNER JOIN ztcu_sipitem AS b                 "#EC CI_DYNWHERE
          ON a~sipno = b~sipno
          INTO TABLE @lt_matdetails
          WHERE (lv_clause).
        IF sy-subrc <> 0.
          CLEAR lt_matdetails.
        ENDIF.

      ELSEIF iv_appindicator = 'T'.
        SELECT a~ticketno,
               a~sipstatus,
               b~itemcode,
               b~actqty
          FROM ztcu_tktheader AS a
          INNER JOIN ztcu_tktitem AS b                 "#EC CI_DYNWHERE
          ON a~ticketno = b~ticketno
          INTO TABLE @lt_matdetails
          WHERE (lv_clause).
        IF sy-subrc <> 0.
          CLEAR lt_matdetails.
        ENDIF.
      ENDIF.

      LOOP AT lt_matdetails ASSIGNING FIELD-SYMBOL(<ls_matdetails>)
        WHERE sipstatus = zif_cu_sip=>gc_sipstatus-inprogress OR
              sipstatus = zif_cu_sip=>gc_sipstatus-completed.
        IF ( iv_appindicator = 'I' AND <ls_matdetails>-sip_ticket <> iv_sipno ) OR
           ( iv_appindicator = 'T' AND <ls_matdetails>-sip_ticket <> iv_ticketno ).
          ls_accumqty-itemcode = <ls_matdetails>-itemcode.
          ls_accumqty-accumqty = <ls_matdetails>-actqty.
          COLLECT ls_accumqty INTO lt_accumqty.
        ENDIF.
      ENDLOOP.

      IF lt_accumqty IS NOT INITIAL.
        SORT lt_accumqty BY itemcode.
        et_accumulatedqty = lt_accumqty.
      ENDIF.

    ENDIF.
  ENDMETHOD.


  METHOD calculate_accumulatedqty_offl.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 31.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Calculate Accumulated Qty Offline
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lw_wraccum       TYPE gty_wraccum,
          lw_spaccum       TYPE gty_spaccum,
          lw_contractaccum TYPE gty_contractaccum.

    DATA: lt_contract TYPE RANGE OF ebeln,
          lt_sp       TYPE RANGE OF z_spno,
          lt_wr       TYPE RANGE OF z_wrno.

    CLEAR: et_wr_accumulated,
           et_sp_accumulated,
           et_contract_accumulated.

    LOOP AT it_header ASSIGNING FIELD-SYMBOL(<ls_header>).
      IF <ls_header>-wrno IS NOT INITIAL.
        APPEND INITIAL LINE TO lt_wr ASSIGNING FIELD-SYMBOL(<ls_wr>).
        <ls_wr>-sign   = 'I'.
        <ls_wr>-option = 'EQ'.
        <ls_wr>-low    = <ls_header>-wrno.

      ELSEIF <ls_header>-spno IS NOT INITIAL.
        APPEND INITIAL LINE TO lt_sp ASSIGNING FIELD-SYMBOL(<ls_sp>).
        <ls_sp>-sign   = 'I'.
        <ls_sp>-option = 'EQ'.
        <ls_sp>-low    = <ls_header>-spno.

      ELSEIF <ls_header>-wrno IS INITIAL AND
             <ls_header>-spno IS INITIAL AND
             <ls_header>-contract IS NOT INITIAL.
        APPEND INITIAL LINE TO lt_contract ASSIGNING FIELD-SYMBOL(<ls_contract>).
        <ls_contract>-sign   = 'I'.
        <ls_contract>-option = 'EQ'.
        <ls_contract>-low    = <ls_header>-contract.

      ENDIF.
    ENDLOOP.

    IF lt_wr IS NOT INITIAL.
      SELECT a~wrno,
             a~sipstatus,
             b~itemcode,
             b~actqty
        FROM ztcu_tktheader AS a
        INNER JOIN ztcu_tktitem AS b                   "#EC CI_DYNWHERE
        ON a~ticketno = b~ticketno
        INTO TABLE @DATA(lt_wrdetails)
        WHERE a~wrno IN @lt_wr.
      IF sy-subrc <> 0.
        CLEAR lt_wrdetails.
      ELSE.
        SORT lt_wrdetails BY wrno itemcode.
      ENDIF.
    ENDIF.

    IF lt_sp IS NOT INITIAL.
      SELECT a~spno,
             a~sipstatus,
             b~itemcode,
             b~actqty
        FROM ztcu_tktheader AS a
        INNER JOIN ztcu_tktitem AS b                   "#EC CI_DYNWHERE
        ON a~ticketno = b~ticketno
        INTO TABLE @DATA(lt_spdetails)
        WHERE a~spno IN @lt_sp.
      IF sy-subrc <> 0.
        CLEAR lt_spdetails.
      ELSE.
        SORT lt_spdetails BY spno itemcode.
      ENDIF.
    ENDIF.

    IF lt_contract IS NOT INITIAL.
      SELECT a~contract,
             a~sipstatus,
             b~itemcode,
             b~actqty
        FROM ztcu_tktheader AS a
        INNER JOIN ztcu_tktitem AS b                   "#EC CI_DYNWHERE
        ON a~ticketno = b~ticketno
        INTO TABLE @DATA(lt_contractdetails)
        WHERE a~contract IN @lt_contract.
      IF sy-subrc <> 0.
        CLEAR lt_contractdetails.
      ELSE.
        SORT lt_contractdetails BY contract itemcode.
      ENDIF.
    ENDIF.

    LOOP AT lt_wrdetails ASSIGNING FIELD-SYMBOL(<ls_wrdetails>)
     WHERE sipstatus = zif_cu_sip=>gc_sipstatus-inprogress OR
           sipstatus = zif_cu_sip=>gc_sipstatus-completed.
      lw_wraccum-wrno = <ls_wrdetails>-wrno.
      lw_wraccum-itemcode = <ls_wrdetails>-itemcode.
      lw_wraccum-accumqty = <ls_wrdetails>-actqty.

      COLLECT lw_wraccum INTO et_wr_accumulated.

      CLEAR: lw_wraccum.
    ENDLOOP.

    LOOP AT lt_spdetails ASSIGNING FIELD-SYMBOL(<ls_spdetails>)
     WHERE sipstatus = zif_cu_sip=>gc_sipstatus-inprogress OR
           sipstatus = zif_cu_sip=>gc_sipstatus-completed.
      lw_spaccum-spno     = <ls_spdetails>-spno.
      lw_spaccum-itemcode = <ls_spdetails>-itemcode.
      lw_spaccum-accumqty = <ls_spdetails>-actqty.

      COLLECT lw_spaccum INTO et_sp_accumulated.

      CLEAR: lw_spaccum.
    ENDLOOP.

    LOOP AT lt_contractdetails ASSIGNING FIELD-SYMBOL(<ls_contractdetails>)
      WHERE sipstatus = zif_cu_sip=>gc_sipstatus-inprogress OR
            sipstatus = zif_cu_sip=>gc_sipstatus-completed.
      lw_contractaccum-contract = <ls_contractdetails>-contract.
      lw_contractaccum-itemcode = <ls_contractdetails>-itemcode.
      lw_contractaccum-accumqty = <ls_contractdetails>-actqty.

      COLLECT lw_contractaccum INTO et_contract_accumulated.

      CLEAR: lw_contractaccum.
    ENDLOOP.

  ENDMETHOD.


  METHOD calculate_tax.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 08.26.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Compute tax for price of items
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR: ev_totaltax.

    DATA: lt_param    TYPE zttca_param,
          lt_mwdat    TYPE STANDARD TABLE OF rtax1u15,
          lv_taxrate  TYPE wmwst,
          lv_currency TYPE bkpf-waers.

    IF ct_items IS NOT INITIAL.
      "Get material type,tax indicator,region,tax jurisdiction
      SELECT a~matnr,
             a~mtart,
             b~werks,
             b~casnr,
             c~regio,
             c~txjcd
        FROM mara AS a
        INNER JOIN marc AS b
        ON a~matnr = b~matnr
        INNER JOIN t001w AS c
        ON b~werks = c~werks
        INTO TABLE @DATA(lt_matdetails)
        FOR ALL ENTRIES IN @ct_items
        WHERE a~matnr = @ct_items-itemcode AND
              b~werks = @iv_plant.
      IF sy-subrc = 0.
        SORT lt_matdetails BY matnr werks.

        "Get currency and tax code from contract
        SELECT  a~ebeln,
                a~waers,
                b~matnr,
                b~mwskz
          FROM ekko AS a
          INNER JOIN ekpo AS b
          ON a~ebeln = b~ebeln
          INTO TABLE @DATA(lt_contract)
          FOR ALL ENTRIES IN @ct_items
          WHERE a~ebeln = @iv_contract AND
                b~matnr = @ct_items-itemcode.
        IF sy-subrc = 0.
          SORT lt_contract BY matnr.
        ENDIF.

        "Get vendor and tax jurisdiction from vendor
        SELECT SINGLE lifnr,
                      regio,
                      txjcd
          FROM lfa1
          INTO @DATA(ls_lfa1)
          WHERE lifnr = @iv_vendor.
        IF sy-subrc <> 0.
          CLEAR ls_lfa1.
        ENDIF.

        "Get the material types for which taxcode has to be determined
        NEW zcl_ca_utility( )->get_parameter(
        EXPORTING
          i_busproc           = 'PU'             " Business Process
          i_busact            = 'TECH'           " Business Activity
          i_validdate         = sy-datum         " Parameter Validity Start Date
          i_param             = 'MTART'
        CHANGING
          t_param             = lt_param         " Parameter value
        EXCEPTIONS
          invalid_busprocess  = 1                " Invalid Business Process
          invalid_busactivity = 2                " Invalid Business Activity
          OTHERS              = 3
      ).
        IF sy-subrc = 0.
          SORT lt_param BY value.
        ENDIF.

        LOOP AT ct_items ASSIGNING FIELD-SYMBOL(<ls_items>).
          READ TABLE lt_matdetails ASSIGNING FIELD-SYMBOL(<ls_matdetails>)
          WITH KEY matnr = <ls_items>-itemcode
                   werks = iv_plant BINARY SEARCH.
          IF sy-subrc = 0.
            "Tax jurisdiction
            "Check if plant region is Illinois
            IF <ls_matdetails>-regio+0(2) = 'IL'.
              "Check if vendor region is Illinois
              IF ls_lfa1-regio+0(2) = 'IL'.
                <ls_items>-taxjurcode = ls_lfa1-txjcd.
              ELSE.
                <ls_items>-taxjurcode = <ls_matdetails>-txjcd.
              ENDIF.
            ELSE.
              <ls_items>-taxjurcode = <ls_matdetails>-txjcd.
            ENDIF.

            "Tax code
            "Check if the material type is CM00 or DIEN
            READ TABLE lt_param TRANSPORTING NO FIELDS
            WITH KEY value = <ls_matdetails>-mtart BINARY SEARCH.
            IF sy-subrc = 0.
              "Check if the tax code is available in contract
              READ TABLE lt_contract ASSIGNING FIELD-SYMBOL(<ls_contract>)
              WITH KEY matnr = <ls_items>-itemcode BINARY SEARCH.
              IF sy-subrc = 0.
                lv_currency = <ls_contract>-waers.
                IF <ls_contract>-mwskz IS NOT INITIAL.
                  <ls_items>-taxcode = <ls_contract>-mwskz.
                ENDIF.
              ENDIF.

              IF <ls_items>-taxcode IS INITIAL.
                "Determine tax code based on WEC tax indicator
                CASE <ls_matdetails>-casnr.
                  WHEN 'E'.
                    <ls_items>-taxcode = 'EX'.
                  WHEN 'I'.
                    <ls_items>-taxcode = 'IN'.
                  WHEN 'M'.
                    <ls_items>-taxcode = 'EX'.
                  WHEN 'R'.
                    <ls_items>-taxcode = 'EX'.
                  WHEN 'S'.
                    <ls_items>-taxcode = 'TS'.
                  WHEN 'T'.
                    <ls_items>-taxcode = 'TV'.
                ENDCASE.

              ENDIF.
            ELSE.
              <ls_items>-taxcode = 'TS'.
            ENDIF.

            "Compute tax only if tax code = 'TV'
            IF <ls_items>-taxcode = 'TV'.
              CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
                EXPORTING
                  i_bukrs           = iv_companycode
                  i_mwskz           = <ls_items>-taxcode
                  i_txjcd           = <ls_items>-taxjurcode
                  i_waers           = lv_currency
                  i_wrbtr           = <ls_items>-netprice
                TABLES
                  t_mwdat           = lt_mwdat
                EXCEPTIONS
                  bukrs_not_found   = 1
                  country_not_found = 2
                  mwskz_not_defined = 3
                  mwskz_not_valid   = 4
                  ktosl_not_found   = 5
                  kalsm_not_found   = 6
                  parameter_error   = 7
                  knumh_not_found   = 8
                  kschl_not_found   = 9
                  unknown_error     = 10
                  account_not_found = 11
                  txjcd_not_valid   = 12
                  OTHERS            = 13.
              IF sy-subrc =  0.
                LOOP AT lt_mwdat ASSIGNING FIELD-SYMBOL(<ls_mwdat>) WHERE ktosl = 'NVV'.
                  lv_taxrate = lv_taxrate + <ls_mwdat>-wmwst.
                ENDLOOP.
                <ls_items>-tax = lv_taxrate.
                ev_totaltax =  ev_totaltax + lv_taxrate.
              ENDIF.
            ENDIF.
          ENDIF.
          CLEAR: lv_taxrate,
                 lt_mwdat,
                 lv_currency.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD calculate_tax_material.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 31.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Calculate Tax
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lv_taxjurcode TYPE txjcd,
          lt_mwdat      TYPE STANDARD TABLE OF rtax1u15,
          lv_wrbtr      TYPE wrbtr.

    CLEAR: ev_taxpercent.

    "Tax jurisdiction
    "Check if plant region is Illinois
    IF iv_plantregion+0(2) = 'IL'.
      "Check if vendor region is Illinois
      IF iv_vendorregion+0(2) = 'IL'.
        lv_taxjurcode = iv_vendorjurisd.
      ELSE.
        lv_taxjurcode = iv_plantjurisd.
      ENDIF.
    ELSE.
      lv_taxjurcode = iv_plantjurisd.
    ENDIF.

    IF iv_taxcode = 'TV'.
      CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
        EXPORTING
          i_bukrs           = iv_compcode
          i_mwskz           = iv_taxcode
          i_txjcd           = lv_taxjurcode
          i_waers           = 'USD'
          i_wrbtr           = lv_wrbtr
        TABLES
          t_mwdat           = lt_mwdat
        EXCEPTIONS
          bukrs_not_found   = 1
          country_not_found = 2
          mwskz_not_defined = 3
          mwskz_not_valid   = 4
          ktosl_not_found   = 5
          kalsm_not_found   = 6
          parameter_error   = 7
          knumh_not_found   = 8
          kschl_not_found   = 9
          unknown_error     = 10
          account_not_found = 11
          txjcd_not_valid   = 12
          OTHERS            = 13.
      IF sy-subrc =  0.
        LOOP AT lt_mwdat ASSIGNING FIELD-SYMBOL(<ls_mwdat>) WHERE ktosl = 'NVV'.
          ev_taxpercent = ev_taxpercent + <ls_mwdat>-msatz.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD call_invoice_bapi.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Create Invoice for SIP
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: ls_headerdata     TYPE          bapi_incinv_create_header,
          lv_invoicedocu    TYPE bapi_incinv_fld-inv_doc_no,
          lv_fyear          TYPE bapi_incinv_fld-fisc_year ##NEEDED,
          lv_itemno         TYPE i,
          lv_accitemno      TYPE i,
          lv_nontax_itm_amt TYPE rpdifn,
          lt_itemdata       TYPE TABLE OF bapi_incinv_create_item,
          ls_itemdata       TYPE bapi_incinv_create_item,
          lt_accountdata    TYPE TABLE OF bapi_incinv_create_account,
          ls_accountdata    TYPE bapi_incinv_create_account,
          lt_glaccount      TYPE TABLE OF bapi_incinv_create_gl_account,
          lt_bapiret2       TYPE TABLE OF bapiret2,
          lw_return_commit  TYPE bapiret2,
          lt_taxitems       TYPE zttcu_item,
          lt_extensionin    TYPE TABLE OF bapiparex,
          lw_extensionin    TYPE          bapiparex,
          lt_sipinvoice     TYPE STANDARD TABLE OF ztcu_sipinvoice,
          lv_matnr_error    TYPE matnr,
          lv_error          TYPE bapi_msg,
          lv_errortext1     TYPE bapi_msg,
          lv_errortext2     TYPE bapi_msg,
          lv_sip_invoice    TYPE char1,
          lt_items_sorted   TYPE gtt_sipitems.

    CONSTANTS: lc_extn_id  TYPE char15 VALUE 'RICEF_ID',
               lc_extn_val TYPE char20 VALUE 'I126_CONTRACT_INV',
               lc_acct_tab TYPE char8  VALUE 'ACCT_TAB',
               lc_item_tab TYPE char8  VALUE 'ITEM_TAB'.

    CLEAR: et_return,
           et_invoice.

    IF   is_header IS NOT INITIAL AND
         it_items IS NOT INITIAL.
      "Get Company code, Currency, Payment key from Contract header
      SELECT SINGLE bukrs,
                    zterm,
                    waers
      FROM ekko INTO @DATA(ls_ekko)
      WHERE ebeln = @is_header-contract.
      IF sy-subrc = 0.
        "Get Price details from Contract Item
        SELECT ebeln,
          ebelp,
          matnr,
          meins,
          netpr,
          peinh
          FROM ekpo
          INTO TABLE @DATA(lt_ekpo)
          WHERE ebeln = @is_header-contract AND
                loekz = @space.
        IF sy-subrc = 0.
          SORT lt_ekpo BY ebeln matnr.
          "Get the Material Valuation details
          SELECT matnr,
                 bwkey,
                 bklas
          FROM mbew INTO TABLE @DATA(lt_mbew)
          FOR ALL ENTRIES IN @it_items
          WHERE matnr = @it_items-material AND
                bwkey = @is_header-plant.
          IF sy-subrc = 0.
            SORT lt_mbew BY matnr bwkey.
            "Get the GL Account details
            SELECT ktopl,
                   ktosl,
                   bwmod,
                   komok,
                   bklas,
                   konts
            FROM t030 INTO TABLE @DATA(lt_t030)
            FOR ALL ENTRIES IN @lt_mbew
            WHERE ktopl = 'OPER' AND
                  ktosl = 'GBB' AND
                  komok = 'VBR' AND
                  bklas = @lt_mbew-bklas.
            IF sy-subrc = 0.
              SORT lt_t030 BY ktopl ktosl bwmod komok bklas .
            ENDIF.
          ENDIF.

          "Get the date of submission of SIP
          SELECT daterequested
            UP TO 1 ROWS
            FROM ztca_audit_log
            INTO @DATA(lv_docdate)
            WHERE data_keys   = @is_header-sipno AND
                  sequence_no = '1'.
          ENDSELECT.
          IF sy-subrc <> 0.
            lv_docdate = sy-datum.
          ENDIF.

          "Get the PM order details for Maximo
          IF is_header-category = 'W'.
            SELECT SINGLE wrno,
                          source,
                          woid,
                          pmoperation
              FROM ztcu_wrheader
              INTO @DATA(ls_wrheader)
              WHERE wrno = @is_header-WORKREQUESTNO.
            IF sy-subrc <> 0.
              CLEAR ls_wrheader.
            ENDIF.
          ENDIF.

          "Fill the item strcuture
          DATA(lt_items) = it_items.
          SORT lt_items BY material.
          DELETE ADJACENT DUPLICATES FROM lt_items COMPARING material.
          "Get the item and price to calculate the tax
          LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_items>).
            APPEND INITIAL LINE TO lt_taxitems ASSIGNING FIELD-SYMBOL(<ls_taxitems>).
            <ls_taxitems>-itemcode = <ls_items>-material.
            <ls_taxitems>-netprice = <ls_items>-netprice.
          ENDLOOP.

          "Calculate tax for all items
          "Comment by Sarvotham
*          zclcu_sip_utility=>calculate_tax(
*            EXPORTING
*              iv_contract    = is_header-contract
*              iv_vendor      = is_header-suppliercompany
*              iv_plant       = is_header-plant
*              iv_companycode = ls_ekko-bukrs
*            IMPORTING
*              ev_totaltax    = DATA(lv_totaltax)
*            CHANGING
*              ct_items       = lt_taxitems
*          ).

          "Fill the header structure
          ls_headerdata-invoice_ind   = abap_true.
          ls_headerdata-doc_date      = lv_docdate.
          ls_headerdata-bline_date    = lv_docdate.
          ls_headerdata-pstng_date    = sy-datum.
          ls_headerdata-comp_code     = ls_ekko-bukrs."
          ls_headerdata-currency      = ls_ekko-waers.
          ls_headerdata-pmnttrms      = ls_ekko-zterm.
          ls_headerdata-ref_doc_no    = is_header-sipno."
*          ls_headerdata-header_txt    = is_header-sipdescr."
          ls_headerdata-item_text     = ls_headerdata-header_txt."
          IF iv_testrun = abap_true.
            ls_headerdata-simulation = abap_true.
          ENDIF.

          lw_extensionin-structure  =  lc_extn_id. "'RICEF_ID'.
          lw_extensionin-valuepart1 =  lc_extn_val."'I126_CONTRACT_INV'.
          APPEND lw_extensionin TO lt_extensionin.

          "Fill the item strcuture
          LOOP AT it_items ASSIGNING <ls_items>
          WHERE actualqty > 0.
            APPEND INITIAL LINE TO lt_items_sorted ASSIGNING FIELD-SYMBOL(<ls_sipitem>).
            MOVE-CORRESPONDING <ls_items> TO <ls_sipitem>.

            "If Maximo, CO will always be PM Order
            IF ls_wrheader-source = zif_cu_sip=>gc_source-maximo OR
               ls_wrheader-source = zif_cu_sip=>gc_source-maximo_lower.
              <ls_sipitem>-costobject = ls_wrheader-woid.
              <ls_sipitem>-coflag     = 'PM'.
            ENDIF.
          ENDLOOP.
          SORT lt_items_sorted BY itemcode costobject.
          DESCRIBE TABLE lt_items_sorted LINES DATA(lv_itemcount).

          LOOP AT lt_items_sorted ASSIGNING <ls_sipitem>.
            DATA(lv_tabix) = sy-tabix.
            READ TABLE lt_ekpo ASSIGNING FIELD-SYMBOL(<ls_ekpo>)
            WITH KEY ebeln = is_header-contract
                     matnr = <ls_sipitem>-itemcode.
            IF sy-subrc = 0.

              AT NEW itemcode.
                CLEAR: ls_itemdata.
                "Item Data
                lv_itemno                    = lv_itemno + 1.
                ls_itemdata-invoice_doc_item = lv_itemno.
                ls_itemdata-po_number        = is_header-contract.
                ls_itemdata-po_item          = <ls_ekpo>-ebelp."
                ls_itemdata-po_unit          = <ls_ekpo>-meins.
                ls_itemdata-item_text        = is_header-plant."
                lv_nontax_itm_amt            = lv_nontax_itm_amt + <ls_sipitem>-netprice.
                "Comment by Sarvotham
*                READ TABLE lt_taxitems ASSIGNING <ls_taxitems>
*                WITH KEY itemcode = <ls_sipitem>-itemcode.
*                IF sy-subrc = 0.
*                  ls_itemdata-taxjurcode = <ls_taxitems>-taxjurcode.
*                  ls_itemdata-tax_code   = <ls_taxitems>-taxcode.
*
*                  IF ls_headerdata-calc_tax_ind IS INITIAL.
*                    IF ls_itemdata-tax_code = 'TV'.
*                      ls_headerdata-calc_tax_ind = abap_true.
*                    ENDIF.
*                  ENDIF.
*                ENDIF.
              ENDAT.

              ls_itemdata-quantity = ls_itemdata-quantity + <ls_sipitem>-actqty.

              AT END OF itemcode.
*---Fill Extension Tab for all Item table entires---*
                lw_extensionin-structure  = lc_item_tab."'ITEM_TAB'.
                lw_extensionin-valuepart2 = <ls_ekpo>-matnr.
                lw_extensionin-valuepart1 = <ls_ekpo>-ebelp.
                lw_extensionin-valuepart3 = is_header-plant.
                APPEND lw_extensionin TO lt_extensionin.
                APPEND ls_itemdata TO lt_itemdata.
              ENDAT.

              "Accounting data
              AT NEW costobject.
                CLEAR: ls_accountdata.

                lv_accitemno                    = lv_accitemno + 1.
                ls_accountdata-invoice_doc_item = ls_itemdata-invoice_doc_item.
                ls_accountdata-serial_no        = lv_accitemno.
                ls_accountdata-po_unit          = <ls_ekpo>-meins.
                ls_accountdata-tax_code         = ls_itemdata-tax_code.
                ls_accountdata-taxjurcode       = ls_itemdata-taxjurcode.

                CASE <ls_sipitem>-coflag.
                  WHEN 'WBS'. "WBS Element
                    IF <ls_sipitem>-costobject IS NOT INITIAL.
                      CALL FUNCTION 'CONVERSION_EXIT_ABPSP_INPUT'
                        EXPORTING
                          input         = <ls_sipitem>-costobject
                        IMPORTING
                          output        = ls_accountdata-wbs_elem
                        EXCEPTIONS
                          error_message = 0
                          OTHERS        = 0.
                    ENDIF.

                  WHEN 'IO'. "Internal Order
                    IF <ls_sipitem>-costobject IS NOT INITIAL.
                      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                        EXPORTING
                          input  = <ls_sipitem>-costobject
                        IMPORTING
                          output = ls_accountdata-orderid.
                    ENDIF.

                  WHEN 'PM'. "PM Order
                    IF <ls_sipitem>-costobject IS NOT INITIAL.
                      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                        EXPORTING
                          input  = <ls_sipitem>-costobject
                        IMPORTING
                          output = ls_accountdata-orderid.

                      "Operation mandatory if order type 'PM'
                      IF ls_wrheader-pmoperation IS NOT INITIAL.
                        ls_accountdata-activity = ls_wrheader-pmoperation.
                      ELSE.
                        ls_accountdata-activity = '0010'.
                      ENDIF.
                    ENDIF.

                  WHEN OTHERS.
                    CLEAR ls_accountdata-orderid.
                ENDCASE.

                READ TABLE lt_mbew ASSIGNING FIELD-SYMBOL(<ls_mbew>)
                WITH KEY matnr = <ls_sipitem>-itemcode
                         bwkey = is_header-plant BINARY SEARCH.
                IF sy-subrc = 0.
                  READ TABLE lt_t030 ASSIGNING FIELD-SYMBOL(<ls_t030>)
                  WITH KEY ktopl = 'OPER'
                           ktosl = 'GBB'
                           bwmod = ls_ekko-bukrs
                           komok = 'VBR'
                           bklas = <ls_mbew>-bklas BINARY SEARCH.
                  IF sy-subrc = 0.
                    ls_accountdata-gl_account = <ls_t030>-konts.
                  ENDIF.

                ELSE.
                  IF lv_error IS INITIAL.
                    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
                      EXPORTING
                        input  = <ls_sipitem>-itemcode
                      IMPORTING
                        output = lv_matnr_error.

                    lv_error = lv_matnr_error.
                  ELSE.
                    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
                      EXPORTING
                        input  = <ls_sipitem>-itemcode
                      IMPORTING
                        output = lv_matnr_error.

                    CONCATENATE lv_error lv_matnr_error INTO lv_error SEPARATED BY ','.
                  ENDIF.
                ENDIF.
              ENDAT.

              ls_accountdata-quantity = ls_accountdata-quantity + <ls_sipitem>-actqty.

              AT END OF costobject.
                ls_accountdata-item_amount      = ( ls_accountdata-quantity * <ls_sipitem>-netprice ) / <ls_ekpo>-peinh .

*---Fill Extension Tab for all Account Assignment table entires---*
                lw_extensionin-structure  = lc_acct_tab."'ACCT_TAB'.
                lw_extensionin-valuepart1 = <ls_ekpo>-ebelp.
                lw_extensionin-valuepart2 = ls_accountdata-serial_no.
                lw_extensionin-valuepart3 = is_header-plant.
                APPEND lw_extensionin TO lt_extensionin.

                APPEND ls_accountdata TO lt_accountdata.
              ENDAT.

              IF lv_error IS INITIAL.
                IF lv_itemno = '499' OR
                   lv_tabix = lv_itemcount.
                 " ls_headerdata-gross_amount = lv_totaltax + lv_nontax_itm_amt. Comment by Sarvotham
                  ls_headerdata-gross_amount = lv_nontax_itm_amt.  "Change by Sarvotham
                  "To activate enhancement to avoid contract validity end error
                  lv_sip_invoice = abap_true.
                  EXPORT lv_sip_invoice FROM lv_sip_invoice TO MEMORY ID 'W073_SIP_INVOICE'.

                  CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
                    EXPORTING
                      headerdata       = ls_headerdata
                    IMPORTING
                      invoicedocnumber = lv_invoicedocu
                      fiscalyear       = lv_fyear
                    TABLES
                      itemdata         = lt_itemdata
                      accountingdata   = lt_accountdata
                      glaccountdata    = lt_glaccount
                      return           = lt_bapiret2
                      extensionin      = lt_extensionin.

                  IF lv_invoicedocu IS NOT INITIAL.
                    APPEND INITIAL LINE TO et_invoice ASSIGNING FIELD-SYMBOL(<ls_invoice>).
                    <ls_invoice>-invoice = lv_invoicedocu.
                  ENDIF.

                  APPEND LINES OF lt_bapiret2 TO et_return.

                  CLEAR: lv_itemno,
                         lv_accitemno,
                         lt_itemdata,
                         lt_accountdata,
                         lt_glaccount,
                         lt_extensionin,
                         lv_nontax_itm_amt,
                         lv_invoicedocu,
                         lv_fyear,
                         lv_sip_invoice.

                  FREE MEMORY ID 'W073_SIP_INVOICE'.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.

          "Error message - GL account - materials not extended to selected plant
          IF lv_error IS NOT INITIAL.
            APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<ls_return>).
            <ls_return>-type       = zif_cu_sip=>gc_error.
            <ls_return>-id         = zif_cu_sip=>gc_zcu_msg.
            <ls_return>-number     = '024'.
            CONCATENATE TEXT-014 lv_error INTO lv_errortext1 SEPARATED BY space.
            CONCATENATE TEXT-015 is_header-plant INTO lv_errortext2 SEPARATED BY space.
            <ls_return>-message_v1 = lv_errortext1.
            <ls_return>-message_v2 = lv_errortext2.
            <ls_return>-message_v3 = TEXT-016.

            CALL FUNCTION 'MESSAGE_TEXT_BUILD'
              EXPORTING
                msgid               = zif_cu_sip=>gc_zcu_msg
                msgnr               = '024'
                msgv1               = lv_errortext1
                msgv2               = lv_errortext2
                msgv3               = TEXT-016
              IMPORTING
                message_text_output = <ls_return>-message.
          ENDIF.

          "If test run, do not commit
          IF iv_testrun = abap_false.
            READ TABLE et_return TRANSPORTING NO FIELDS
            WITH KEY type = zif_cu_sip=>gc_error.
            IF sy-subrc <> 0.
              "Update the Invoice numbers against the SIP number
              LOOP AT et_invoice ASSIGNING <ls_invoice>.
                APPEND INITIAL LINE TO lt_sipinvoice ASSIGNING FIELD-SYMBOL(<ls_sipinvoice>).
                <ls_sipinvoice>-sipno     = is_header-sipno.
                <ls_sipinvoice>-invoice   = <ls_invoice>-invoice.
                <ls_sipinvoice>-createdby = iv_submittedby.
                <ls_sipinvoice>-createdon = sy-datum.
              ENDLOOP.

              IF lt_sipinvoice IS NOT INITIAL.
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    wait   = abap_true
                  IMPORTING
                    return = lw_return_commit.

                "If Commit was succesful
                IF lw_return_commit-type <> zif_cu_sip=>gc_error.
                  MODIFY ztcu_sipinvoice FROM TABLE lt_sipinvoice.
                  IF sy-subrc = 0.
                    COMMIT WORK AND WAIT.
                  ELSE.
                    APPEND INITIAL LINE TO et_return ASSIGNING <ls_return>.
                    <ls_return>-type       = zif_cu_sip=>gc_error.
                    <ls_return>-id         = zif_cu_sip=>gc_zcu_msg.
                    <ls_return>-number     = '033'.
                    <ls_return>-message_v1 = is_header-sipno.

                    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
                      EXPORTING
                        msgid               = zif_cu_sip=>gc_zcu_msg
                        msgnr               = '033'
                        msgv1               = is_header-sipno
                      IMPORTING
                        message_text_output = <ls_return>-message.
                  ENDIF.

                  SELECT SINGLE * FROM ztcu_sipheader
                    INTO @DATA(ls_sipheader)
                    WHERE sipno = @is_header-sipno.
                  IF sy-subrc = 0.
                    DELETE FROM ztcu_sipheader WHERE sipno = is_header-sipno.
                    IF sy-subrc = 0.
                      COMMIT WORK AND WAIT.

                      "Wait if the items are not deleted
                      "SIPHeader
                      DO 5 TIMES.
                        SELECT COUNT(*) FROM ztcu_sipheader
                          WHERE sipno = is_header-sipno.
                        IF sy-subrc = 0.
                          WAIT UP TO 1 SECONDS.
                        ELSE.
                          EXIT.
                        ENDIF.
                      ENDDO.

                      ls_sipheader-sipstatus = 'C'.
                      INSERT ztcu_sipheader FROM ls_sipheader.
                      IF sy-subrc = 0.
                        COMMIT WORK AND WAIT.
                      ELSE.
                        APPEND INITIAL LINE TO et_return ASSIGNING <ls_return>.
                        <ls_return>-type       = zif_cu_sip=>gc_error.
                        <ls_return>-id         = zif_cu_sip=>gc_zcu_msg.
                        <ls_return>-number     = '034'.
                        <ls_return>-message_v1 = is_header-sipno.

                        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
                          EXPORTING
                            msgid               = zif_cu_sip=>gc_zcu_msg
                            msgnr               = '034'
                            msgv1               = is_header-sipno
                          IMPORTING
                            message_text_output = <ls_return>-message.
                      ENDIF.
                    ELSE.
                      APPEND INITIAL LINE TO et_return ASSIGNING <ls_return>.
                      <ls_return>-type       = zif_cu_sip=>gc_error.
                      <ls_return>-id         = zif_cu_sip=>gc_zcu_msg.
                      <ls_return>-number     = '036'.
                      <ls_return>-message_v1 = is_header-sipno.

                      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
                        EXPORTING
                          msgid               = zif_cu_sip=>gc_zcu_msg
                          msgnr               = '036'
                          msgv1               = is_header-sipno
                        IMPORTING
                          message_text_output = <ls_return>-message.
                    ENDIF.
                  ENDIF.
                ELSE.
                  APPEND lw_return_commit TO et_return.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD classify_materials.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Classify Active and Inactive materials
*&  Transport Request No   : D10K934677
*****************************************************************************
    IF ct_items IS NOT INITIAL.
      "Check if the SIP is invoiced
      IF iv_sipno IS NOT INITIAL.
        SELECT invoice
          FROM ztcu_sipinvoice
          INTO TABLE @DATA(lt_invoice)
          WHERE sipno = @iv_sipno.
        IF sy-subrc <> 0.
          CLEAR lt_invoice.
        ENDIF.
      ENDIF.

      "If invoiced, use the status from SIPITEM table
      IF lt_invoice IS INITIAL.
        "Get the materials from material master
        SELECT matnr,
               lvorm
          FROM mara
          INTO TABLE @DATA(lt_matnr)
          FOR ALL ENTRIES IN @ct_items
          WHERE matnr = @ct_items-material.
        IF sy-subrc = 0.
          SORT lt_matnr BY matnr.
        ENDIF.

        "Get the materials from contract
        IF iv_contract IS INITIAL.
          IF iv_spno IS NOT INITIAL.
            SELECT contract
              UP TO 1 ROWS
              FROM ztcu_spheader
              INTO @DATA(lv_contract)
              WHERE spno = @iv_spno.
            ENDSELECT.
            IF sy-subrc <> 0.
              CLEAR lv_contract.
            ENDIF.
          ENDIF.
        ELSE.
          lv_contract = iv_contract.
        ENDIF.

        IF lv_contract IS NOT INITIAL.
          SELECT matnr
            FROM ekpo
            INTO TABLE @DATA(lt_contract)
            FOR ALL ENTRIES IN @ct_items
            WHERE ebeln = @lv_contract AND
                  matnr = @ct_items-material AND
                  loekz = @space.
          IF sy-subrc = 0.
            SORT lt_contract BY matnr.
          ENDIF.
        ENDIF.

        LOOP AT ct_items ASSIGNING FIELD-SYMBOL(<ls_items>).
          "Initialize the inactive indicator
          CLEAR <ls_items>-inactive.

          "Check if material is valid
          READ TABLE lt_matnr ASSIGNING FIELD-SYMBOL(<ls_matnr>)
          WITH KEY matnr = <ls_items>-material BINARY SEARCH.
          IF sy-subrc <> 0.
            <ls_items>-inactive = 'E'.
            CONTINUE.
          ELSE.
            IF <ls_matnr>-lvorm <> space.
              <ls_items>-inactive = 'D'.
              CONTINUE.
            ENDIF.
          ENDIF.

          IF iv_contract IS NOT INITIAL.
            "Check if material is in contract
            READ TABLE lt_contract TRANSPORTING NO FIELDS
            WITH KEY matnr = <ls_items>-material BINARY SEARCH.
            IF sy-subrc <> 0.
              <ls_items>-inactive = 'C'.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD classify_materials_fpc.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Classify Active and Inactive materials - FPC
*&  Transport Request No   : D10K934677
*****************************************************************************
    IF ct_items IS NOT INITIAL.
      IF iv_tktno IS NOT INITIAL.
        SELECT sipstatus
          UP TO 1 ROWS
          INTO @DATA(lv_status)
          FROM ztcu_tktheader
          WHERE ticketno = @iv_tktno.
        ENDSELECT.
        IF sy-subrc <> 0.
          CLEAR lv_status.
        ENDIF.
      ENDIF.

      IF lv_status <> 'C'.
        "Get the materials from material master
        SELECT matnr,
               lvorm
          FROM mara
          INTO TABLE @DATA(lt_matnr)
          FOR ALL ENTRIES IN @ct_items
          WHERE matnr = @ct_items-itemcode.
        IF sy-subrc = 0.
          SORT lt_matnr BY matnr.
        ENDIF.

        "Get the materials from contract
        IF iv_contract IS INITIAL.
          IF iv_spno IS NOT INITIAL.
            SELECT contract
              UP TO 1 ROWS
              FROM ztcu_spheader
              INTO @DATA(lv_contract)
              WHERE spno = @iv_spno.
            ENDSELECT.
            IF sy-subrc <> 0.
              CLEAR lv_contract.
            ENDIF.
          ENDIF.
        ELSE.
          lv_contract = iv_contract.
        ENDIF.

        IF lv_contract IS NOT INITIAL.
          SELECT matnr
            FROM ekpo
            INTO TABLE @DATA(lt_contract)
            FOR ALL ENTRIES IN @ct_items
            WHERE ebeln = @lv_contract AND
                  matnr = @ct_items-itemcode AND
                  loekz = @space.
          IF sy-subrc = 0.
            SORT lt_contract BY matnr.
          ENDIF.
        ENDIF.

        LOOP AT ct_items ASSIGNING FIELD-SYMBOL(<ls_items>).
          "Initialize the inactive indicator
          CLEAR <ls_items>-inactive.

          "Check if material is valid
          READ TABLE lt_matnr ASSIGNING FIELD-SYMBOL(<ls_matnr>)
          WITH KEY matnr = <ls_items>-itemcode BINARY SEARCH.
          IF sy-subrc <> 0.
            <ls_items>-inactive = 'E'.
            CONTINUE.
          ELSE.
            IF <ls_matnr>-lvorm <> space.
              <ls_items>-inactive = 'D'.
              CONTINUE.
            ENDIF.
          ENDIF.

          IF iv_contract IS NOT INITIAL.
            "Check if material is in contract
            READ TABLE lt_contract TRANSPORTING NO FIELDS
            WITH KEY matnr = <ls_items>-itemcode BINARY SEARCH.
            IF sy-subrc <> 0.
              <ls_items>-inactive = 'C'.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD connect_attach_to_invoice.
************************************************************************
* Program ID:      CONNECT_ATTACH_TO_INVOICE
* Program Title:   Update Invoice with Attachments from Archiv
* Created By:      Venkata Gopisetty/C144527
* Creation Date:   23.06.2020
* RICEFW ID:       W073
* Description:     Connect Invoice with Attachments from Archiv
*                  Tables
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 30.06.2020  C144527           1        D10K934677 / Initial version
************************************************************************
    CLEAR : ev_error_flag.
*----------------------------------------------------------------------------*
*Declaration of Variable
*----------------------------------------------------------------------------*
    DATA : lv_archiv_id  TYPE  toav0-archiv_id,
           lv_arc_doc_id TYPE  toav0-arc_doc_id,
           lv_ar_object  TYPE  toaom-ar_object,
           lv_datum      TYPE string,
           lv_object_id  TYPE  sapb-sapobjid,
           lv_doc_type   TYPE  toadv-doc_type,
           lv_filename   TYPE  toaat-filename,
           lv_descr      TYPE  toaat-descr.

****Get the Doc Id and archiv Id from Archiv table
    SELECT  b~docid,
            b~doctype,
            b~filename,
            b~description,
            a~archiv_id,
            a~ar_object
       FROM toa01 AS a INNER JOIN ztcu_sip_attach AS b
         ON a~arc_doc_id = b~docid
       INTO TABLE @DATA(lt_archiv_docids)
      WHERE b~uniqueno = @iv_sipno.
    IF sy-subrc = 0.
      LOOP AT lt_archiv_docids ASSIGNING FIELD-SYMBOL(<ls_archiv_docids>).
        CONCATENATE <ls_archiv_docids>-filename '.' <ls_archiv_docids>-doctype INTO lv_filename.
        lv_archiv_id    = <ls_archiv_docids>-archiv_id.
        lv_arc_doc_id   = <ls_archiv_docids>-docid.
        lv_descr        = <ls_archiv_docids>-description. "#EC CI_CONV_OK
        lv_ar_object    = <ls_archiv_docids>-ar_object.
        lv_doc_type     = <ls_archiv_docids>-doctype.
        TRANSLATE lv_doc_type TO UPPER CASE.
        lv_datum = sy-datum.
        CONCATENATE iv_invoice lv_datum+0(4) INTO  lv_object_id  ##NEEDED.
        lv_doc_type     = <ls_archiv_docids>-doctype.

*----------------------------------------------------------------------------*
*Archiv Attachment from Bus object to Invoice Connection
*----------------------------------------------------------------------------*
        CALL FUNCTION 'ARCHIV_CONNECTION_INSERT'
          EXPORTING
            archiv_id             = lv_archiv_id
            arc_doc_id            = lv_arc_doc_id
            ar_date               = sy-datum
            ar_object             = lv_ar_object
            mandant               = sy-mandt
            object_id             = lv_object_id
            sap_object            = 'BUS2081'
            doc_type              = lv_doc_type
            filename              = lv_filename
            descr                 = lv_descr
          EXCEPTIONS
            error_connectiontable = 1
            OTHERS                = 2.
        IF sy-subrc               = 0.
          COMMIT WORK AND WAIT.
        ELSE.
          ev_error_flag = abap_true.
        ENDIF.

        CLEAR : lv_filename,
                lv_archiv_id,
                lv_arc_doc_id,
                lv_descr,
                lv_ar_object,
                lv_object_id,
                lv_doc_type.

      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD create_attachment_header.
************************************************************************
* Program ID:      CREATE_ATTACHMENT_HEADER
* Program Title:   To update Attachment header table - ZTCU_SIP_ATTACH
* Created By:      Venkata Gopisetty/C144527
* Creation Date:   23.06.2020
* RICEFW ID:       W073
* Description:     To update Attachment header table - ZTCU_SIP_ATTACH
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 18.06.2020  C144527           1        D10K934677 / Initial version
************************************************************************

*----------------------------------------------------------------------*
*Internal Tables
*----------------------------------------------------------------------*
    CLEAR: et_attach_ins,
           et_attach_upd,
           et_attach_del.

    LOOP AT it_sip_attach ASSIGNING FIELD-SYMBOL(<ls_sip_attach>).
      IF <ls_sip_attach>-operation = zif_cu_sip=>gc_operation-insert.
        APPEND INITIAL LINE TO et_attach_ins ASSIGNING FIELD-SYMBOL(<ls_attach>).
      ELSEIF <ls_sip_attach>-operation = zif_cu_sip=>gc_operation-update.
        APPEND INITIAL LINE TO et_attach_upd ASSIGNING <ls_attach>.
      ELSEIF <ls_sip_attach>-operation = zif_cu_sip=>gc_operation-delete.
        APPEND INITIAL LINE TO et_attach_del ASSIGNING <ls_attach>.
      ENDIF.

      IF <ls_attach> IS ASSIGNED.
        MOVE-CORRESPONDING <ls_sip_attach> TO <ls_attach> ##ENH_OK.
      ENDIF.

      zclcu_sip_utility=>delete_attachdocument(
        EXPORTING
          is_attachdetails =  <ls_sip_attach> ).

    ENDLOOP.

  ENDMETHOD.


  METHOD create_contract_invoice.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Create Invoice for SIP
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: ls_header TYPE   zclcu_sip_mpc=>ts_headersipwr,
          lt_item   TYPE   zclcu_sip_mpc=>tt_item.

    CLEAR: et_return,
           et_invoice.

    "Get the SIP Header details
    SELECT SINGLE sipno,
                  suppliercompany,
                  contract,
                  wrno,
                  createdon,
                  contractdesc,
                  plant,
                  category
      FROM ztcu_sipheader
      INTO @DATA(ls_sipheader)
      WHERE sipno = @iv_sipno.
    IF sy-subrc = 0.
      "GEt the SIP item details
      SELECT sipno,
             linenum,
             itemcode,
             actqty,
             costobject,
             parentlineno,
             originalqty,
             netprice,
             coflag
        FROM ztcu_sipitem
        INTO TABLE @DATA(lt_sipitem)
        WHERE sipno    = @iv_sipno AND
              inactive = @space.
      IF sy-subrc = 0.
        ls_header-sipno           = ls_sipheader-sipno.
        ls_header-suppliercompany = ls_sipheader-suppliercompany.
        ls_header-contract        = ls_sipheader-contract.
        ls_header-workrequestno            = ls_sipheader-wrno.
*        ls_header-createdon       = ls_sipheader-createdon.
*        ls_header-contractdesc    = ls_sipheader-contractdesc.
        ls_header-plant           = ls_sipheader-plant.
        ls_header-category        = ls_sipheader-category.

        LOOP AT lt_sipitem ASSIGNING FIELD-SYMBOL(<ls_sipitem>).
          APPEND INITIAL LINE TO lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
          <ls_item>-sipno        = <ls_sipitem>-sipno.
          <ls_item>-linenum      = <ls_sipitem>-linenum.
          <ls_item>-material     = <ls_sipitem>-itemcode.
          <ls_item>-actualqty       = <ls_sipitem>-actqty.
          <ls_item>-costobject   = <ls_sipitem>-costobject.
          <ls_item>-parentlineitem = <ls_sipitem>-parentlineno.
          <ls_item>-originalqty  = <ls_sipitem>-originalqty.
          <ls_item>-netprice     = <ls_sipitem>-netprice.
          <ls_item>-cotype       = <ls_sipitem>-coflag.
        ENDLOOP.

        CALL METHOD zclcu_sip_utility=>call_invoice_bapi
          EXPORTING
            is_header      = ls_header
            it_items       = lt_item
            iv_testrun     = iv_testrun
            iv_submittedby = iv_submittedby
          IMPORTING
            et_invoice     = et_invoice
            et_return      = et_return.

      ELSE.
        APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<ls_return>).
        <ls_return>-type       = zif_cu_sip=>gc_error.
        <ls_return>-id         = zif_cu_sip=>gc_zcu_msg.
        <ls_return>-number     = '032'.
        <ls_return>-message_v1 = iv_sipno.

        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            msgid               = zif_cu_sip=>gc_zcu_msg
            msgnr               = '032'
            msgv1               = iv_sipno
          IMPORTING
            message_text_output = <ls_return>-message.
      ENDIF.
    ELSE.
      APPEND INITIAL LINE TO et_return ASSIGNING <ls_return>.
      <ls_return>-type       = zif_cu_sip=>gc_error.
      <ls_return>-id         = zif_cu_sip=>gc_zcu_msg.
      <ls_return>-number     = '031'.
      <ls_return>-message_v1 = iv_sipno.

      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = zif_cu_sip=>gc_zcu_msg
          msgnr               = '031'
          msgv1               = iv_sipno
        IMPORTING
          message_text_output = <ls_return>-message.
    ENDIF.
  ENDMETHOD.


  METHOD create_document.
************************************************************************
* Program ID:      CREATE_ATTACHMENT
* Program Title:   To create Attachments for SIP
* Created By:      Venkata Gopisetty/C144527
* Creation Date:   23.06.2020
* RICEFW ID:       W073
* Description:     To Create SIP Atatchments linked to BUS2081
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 18.06.2020  C144527           1        D10K934677 / Initial version
************************************************************************

*----------------------------------------------------------------------*
*Internal Tables
*----------------------------------------------------------------------*
    DATA : lt_outdoc          TYPE toadt,
           lt_binarchivobject TYPE STANDARD TABLE OF tbl1024.

*----------------------------------------------------------------------*
*Local Variables
*----------------------------------------------------------------------*
    DATA : lv_filename   TYPE toaat-filename,
           lw_sip_attach TYPE ztcu_sip_attach,
           lv_count      TYPE i,
           lv_sip        TYPE sapb-sapobjid,
           lv_filetype   TYPE toadd-doc_type,
           lv_desc(60)   TYPE c.

    CLEAR ev_error_flag.

    lv_filetype = cs_attachdeatils-doctype.
    lv_sip = cs_attachdeatils-uniqueno.
    lv_filename = cs_attachdeatils-filename.
    lv_desc = cs_attachdeatils-description.             "#EC CI_CONV_OK

    TRANSLATE lv_filetype TO UPPER CASE.

***Get the BUS Object File type and extension
    SELECT ar_object  FROM toaom INTO @DATA(lv_toaom) UP TO 1 ROWS WHERE sap_object = 'BUS2081'
                                                            AND doc_type = @lv_filetype.
    ENDSELECT.
    IF sy-subrc NE 0.
      CLEAR : lv_toaom.
    ENDIF.

***Passing Extension also to show in UI .
    CONCATENATE lv_filename '.' lv_filetype INTO lv_filename.

************************************************************************
* Get attachment in binary format and link to Business object
************************************************************************
    IF lv_sip IS NOT INITIAL AND lv_toaom IS NOT INITIAL.

      CALL FUNCTION 'ARCHIV_CREATE_TABLE'
        EXPORTING
          ar_object                = lv_toaom
          object_id                = lv_sip
          sap_object               = 'BUS2081'
          doc_type                 = lv_filetype
          document                 = iv_content
          mandt                    = sy-mandt
          vscan_profile            = '/SCMS/KPRO_CREATE'
          filename                 = lv_filename
          descr                    = lv_desc            "lv_description
        IMPORTING
          outdoc                   = lt_outdoc
        TABLES
          binarchivobject          = lt_binarchivobject
        EXCEPTIONS
          error_archiv             = 1
          error_communicationtable = 2
          error_connectiontable    = 3
          error_kernel             = 4
          error_parameter          = 5
          error_user_exit          = 6
          error_mandant            = 7
          blocked_by_policy        = 8
          OTHERS                   = 9.
****Checking for Error Details

      IF sy-subrc = 0.

***Get attachment table count for SEQ number of attachments
        SELECT seqno
          FROM ztcu_sip_attach
          INTO TABLE @DATA(lt_sip_attach)
          WHERE uniqueno = @cs_attachdeatils-uniqueno.
        IF sy-subrc = 0.
          DESCRIBE TABLE lt_sip_attach LINES lv_count.
        ENDIF.

        MOVE-CORRESPONDING cs_attachdeatils TO lw_sip_attach ##ENH_OK.
        TRANSLATE lw_sip_attach-doctype TO LOWER CASE.
        lv_count = lv_count + 1.                        "#EC CI_CONV_OK
        lw_sip_attach-seqno = lv_count.
        lw_sip_attach-docid = lt_outdoc-arc_doc_id.
        lw_sip_attach-mandt = sy-mandt.
        lw_sip_attach-filename = lv_filename.
        lw_sip_attach-createdon = sy-datum.
        lw_sip_attach-uniqueno = cs_attachdeatils-uniqueno.
        lw_sip_attach-description = lv_desc.
        CONVERT DATE sy-datum TIME sy-uzeit
        INTO TIME STAMP lw_sip_attach-timestamp TIME ZONE sy-zonlo.
***Modify Custom Attach table with update details
        MODIFY ztcu_sip_attach FROM lw_sip_attach.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
          MOVE-CORRESPONDING lw_sip_attach TO cs_attachdeatils ##ENH_OK.
        ENDIF.
      ELSE.
****Send flag for Business exception
        ev_error_flag = abap_true.

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD delete_attachdocument.
*****************************************************************************
* Program ID:      DELETE_ATTACHDOCUMENT
* Program Title:   Delete attachment from BUS2081 and table - ZTCU_SIP_ATTACH
* Created By:      Venkata Gopisetty/C144527
* Creation Date:   23.06.2020
* RICEFW ID:       W073
* Description:     T0 Delete attachment from BUS2081
*                  and from table - ZTCU_SIP_ATTACH
*****************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 18.06.2020  C144527           1        D10K934677 / Initial version
************************************************************************
*----------------------------------------------------------------------*
*Local Vairables
*----------------------------------------------------------------------*
    DATA  : lv_attach_con_id TYPE sapb-sapadokid,
            lw_sip_attach    TYPE ztcu_sip_attach.

    CLEAR ev_error_flag.

    IF is_attachdetails IS NOT INITIAL.

****Get the record from table for deletion
      SELECT *
         FROM ztcu_sip_attach
         INTO lw_sip_attach
         UP TO 1 ROWS
        WHERE uniqueno = is_attachdetails-uniqueno AND
              docid = is_attachdetails-docid.
      ENDSELECT.
      IF sy-subrc NE 0.
        CLEAR : lw_sip_attach.
      ENDIF.
    ENDIF.

    DELETE ztcu_sip_attach FROM lw_sip_attach.

    IF sy-subrc = 0.
**Pass to local variables
      lv_attach_con_id = is_attachdetails-docid.

****Get the archiv Id from Business object
      SELECT archiv_id FROM toa01 INTO @DATA(lv_toa01) UP TO 1 ROWS WHERE sap_object = 'BUS2081'
                                                                AND arc_doc_id = @is_attachdetails-docid.
      ENDSELECT.
      IF sy-subrc NE 0.
        CLEAR lv_toa01.
      ENDIF.

***********************************************************************
***Calling ARHCIVE Context for Attachment to Handle Deletion
***********************************************************************
* delete archive object
      CALL FUNCTION 'ARCHIVOBJECT_DELETE'
        EXPORTING
          archiv_doc_id            = lv_attach_con_id
          archiv_id                = lv_toa01
        EXCEPTIONS
          error_archiv             = 1
          error_communicationtable = 2
          error_kernel             = 3
          OTHERS                   = 4.

***Checking for Error Details

      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        ev_error_flag = abap_true.
      ENDIF.

    ELSE.
      ev_error_flag = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD get_activities.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 18.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the activities based on material and plant
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR: et_data.

    "Pass material & plant to get unit activity L1 & L2 details
    SELECT a~activity1,
           b~activity2,
           b~plant,
           b~iosuffix,
           b~io
      INTO TABLE @DATA(lt_act)
      FROM ztcu_activityl1 AS a
      INNER JOIN ztcu_activityl2 AS b
      ON a~activity1 = b~activity1
      WHERE a~matnr = @iv_matnr
      AND b~plant = @iv_plant.
    IF sy-subrc = 0.
      SORT lt_act BY activity1 activity2.

      "get the activity desc
      SELECT param,
             value,
             valueto
          FROM ztca_param
          INTO TABLE @DATA(lt_desc)
          WHERE ( param = 'ACTIVITYL1'
          OR param = 'ACTIVITYL2' ).
      IF sy-subrc NE 0.
        CLEAR : lt_desc.
      ENDIF.
      LOOP AT lt_act ASSIGNING FIELD-SYMBOL(<ls_act>).
        AT NEW activity1.
          APPEND INITIAL LINE TO et_data ASSIGNING FIELD-SYMBOL(<ls_data>).
          <ls_data>-key         = <ls_act>-activity1.
          <ls_data>-material       = iv_matnr.
          <ls_data>-plant       = iv_plant.
          <ls_data>-cosuffix    = <ls_act>-iosuffix.
          <ls_data>-activitykey = <ls_act>-activity1.
*          <ls_data>-activity    = <ls_act>-activity1.
          <ls_data>-type        = 'P'.

          READ TABLE lt_desc ASSIGNING FIELD-SYMBOL(<ls_desc>) WITH KEY value = <ls_act>-activity1 .
          IF sy-subrc EQ 0.
            <ls_data>-actdesc   = <ls_desc>-valueto.
          ENDIF.
        ENDAT.

        AT NEW activity2.
          APPEND INITIAL LINE TO et_data ASSIGNING <ls_data>.
          <ls_data>-key         = <ls_act>-activity1.
          <ls_data>-material       = iv_matnr.
          <ls_data>-plant    = iv_plant.
          <ls_data>-cosuffix    = <ls_act>-iosuffix.
          CONCATENATE <ls_act>-activity1 <ls_act>-activity2 INTO <ls_data>-activitykey SEPARATED BY '-'.
          <ls_data>-ActivityL1L2    = <ls_act>-activity2.
          <ls_data>-costobject  = <ls_act>-io.
          <ls_data>-type        = 'C'.

          READ TABLE lt_desc ASSIGNING <ls_desc> WITH KEY value = <ls_act>-activity2 .
          IF sy-subrc EQ 0.
            <ls_data>-actdesc = <ls_desc>-valueto.
          ENDIF.
        ENDAT.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD get_approvalflow.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 07.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get approval flow data
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA : lt_sipno TYPE rseloption,
           lw_data  TYPE zscu_approvalflow.

    CLEAR et_data.

    IF is_approvalflow-uniqueno IS NOT INITIAL.

      "Get the WF log details
      APPEND INITIAL LINE TO lt_sipno ASSIGNING FIELD-SYMBOL(<ls_sipno>).
      <ls_sipno>-sign   = 'I'.
      <ls_sipno>-option = 'EQ'.
      <ls_sipno>-low    = is_approvalflow-uniqueno.

      CALL METHOD zclcu_sip_utility=>get_routinglog_details
        EXPORTING
          it_sipno      = lt_sipno
        IMPORTING
          et_routinglog = DATA(lt_route).
      IF sy-subrc EQ 0.
        LOOP AT lt_route INTO DATA(lw_route).
          lw_data-uniqueno    = lw_route-batch_no.
          lw_data-ordernum    = lw_route-ordernum.
          SHIFT lw_data-ordernum LEFT DELETING LEADING '0'.
          lw_data-seqnum      = lw_route-seqnum.
          lw_data-userid      = lw_route-userid.
          lw_data-descr       = lw_route-descr.
          lw_data-status      = lw_route-status.
          lw_data-assignedon  = lw_route-assignedon.
          lw_data-completedon = lw_route-completedon.
          lw_data-assignedat  = lw_route-timerequested.
          lw_data-completedat = lw_route-timecompleted.
          lw_data-approved    = lw_route-approved.
          lw_data-taskname    = lw_route-taskname.
          lw_data-userrole    = lw_route-userrole.
          lw_data-username    = lw_route-username.
          lw_data-comments    = lw_route-comments.
          lw_data-category    = is_approvalflow-category.
          APPEND lw_data TO et_data.
          CLEAR : lw_data, lw_route.
        ENDLOOP.
      ENDIF.

    ELSE.
      "Get the deafault approver
      IF is_approvalflow-contract IS NOT INITIAL AND
         is_approvalflow-plant IS NOT INITIAL.
        SELECT userid
          FROM ztcu_sipapprover
          INTO @DATA(lv_default)
          UP TO 1 ROWS
          WHERE contract  = @is_approvalflow-contract AND
                plant     = @is_approvalflow-plant AND
                validfrom LE @sy-datum AND
                validto   GE @sy-datum.
        ENDSELECT.
        IF sy-subrc = 0.
          APPEND INITIAL LINE TO et_data ASSIGNING FIELD-SYMBOL(<ls_data>).
          <ls_data>-userid   = lv_default.
          <ls_data>-userrole = 'Approver'.

          zclcu_sip_utility=>get_name(
            EXPORTING
              iv_userid = lv_default
            IMPORTING
              ev_name   = DATA(lv_name)
          ).

          <ls_data>-username = lv_name.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_approvers_auditlog.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 05.01.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Approvers from Audit Log table
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR: ev_approvers.

    SELECT data_keys,
           sequence_no,
           field5
      FROM ztca_audit_log
      INTO TABLE @DATA(lt_approvers)
      WHERE data_keys = @iv_datakey.
    IF sy-subrc = 0.
      SORT lt_approvers BY sequence_no DESCENDING.

      READ TABLE lt_approvers ASSIGNING FIELD-SYMBOL(<ls_approvers>)
      INDEX 1.
      IF sy-subrc = 0.
        ev_approvers = <ls_approvers>-field5.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_approver_status.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the current user and status of SIP - Routing
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR: et_approver_status.

    IF it_sipno IS NOT INITIAL.
      DATA(lt_sipno) = it_sipno.
      SORT lt_sipno BY sipno.
      DELETE ADJACENT DUPLICATES FROM lt_sipno COMPARING sipno.

      "Get the routing log details
      SELECT batch_no,
             ordernum,
             seqnum,
             userid,
             status,
             userrole
        FROM ztca_routinglog
        INTO TABLE @DATA(lt_routinglog)
        FOR ALL ENTRIES IN @lt_sipno
        WHERE batch_no = @lt_sipno-sipno.
      IF sy-subrc = 0.
        "Sort routing log details by descending to get latest status
        DATA(lt_status) = lt_routinglog.
        DELETE lt_status WHERE status = space.
        SORT lt_status BY batch_no ASCENDING ordernum DESCENDING.

        "Approver details
        DATA(lt_approver) = lt_routinglog.
        DELETE lt_approver WHERE userrole <> 'Approver'.
        SORT lt_approver BY batch_no ordernum.

        "Verifier details
        DATA(lt_verifier) = lt_routinglog.
        DELETE lt_verifier WHERE userrole <> 'Verifier'.
        SORT lt_verifier BY batch_no ordernum.


        LOOP AT lt_sipno ASSIGNING FIELD-SYMBOL(<ls_sipno>).
          APPEND INITIAL LINE TO et_approver_status ASSIGNING FIELD-SYMBOL(<ls_approver_status>).
          <ls_approver_status>-sipno = <ls_sipno>-sipno.

          "Get the latest status for the SIP
          READ TABLE lt_status ASSIGNING FIELD-SYMBOL(<ls_status>)
          WITH KEY batch_no = <ls_sipno>-sipno.
          IF sy-subrc = 0.
            TRANSLATE <ls_status>-status TO UPPER CASE.
            <ls_approver_status>-status = <ls_status>-status.
          ENDIF.

          "Incorporate Parallel cursor approach
          READ TABLE lt_approver TRANSPORTING NO FIELDS
          WITH KEY batch_no = <ls_sipno>-sipno BINARY SEARCH.
          IF sy-subrc = 0.
            DATA(lv_tabix) = sy-tabix.

            "Check if we have an Approver for the SIP
            LOOP AT lt_approver ASSIGNING FIELD-SYMBOL(<ls_approver>)
            FROM lv_tabix.
              IF <ls_approver>-batch_no = <ls_sipno>-sipno.
                IF <ls_approver>-userid IS ASSIGNED.
                  TRANSLATE <ls_approver>-userid TO UPPER CASE.
                ENDIF.
                "SIP in progress or not completed
                IF <ls_approver>-status = 'IN-PROGRESS' OR
                   <ls_approver>-status IS INITIAL.
                  <ls_approver_status>-userid   = <ls_approver>-userid.
                  <ls_approver_status>-userrole = <ls_approver>-userrole.
                  EXIT.

                ELSE.
                  <ls_approver_status>-userid   = <ls_approver>-userid.
                  <ls_approver_status>-userrole = <ls_approver>-userrole.
                ENDIF.

              ELSE.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.

          "Only get verifier if Approver is not available
          IF <ls_approver_status>-userid IS INITIAL.
            "Incorporate Parallel cursor approach
            READ TABLE lt_verifier TRANSPORTING NO FIELDS
            WITH KEY batch_no = <ls_sipno>-sipno BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_tabix_ver) = sy-tabix.

              "Check if we have an Verifier for the SIP
              LOOP AT lt_verifier ASSIGNING FIELD-SYMBOL(<ls_verifier>)
              FROM lv_tabix_ver.
                IF <ls_verifier>-batch_no = <ls_sipno>-sipno.
                  IF <ls_verifier>-userid IS ASSIGNED.
                    TRANSLATE <ls_verifier>-userid TO UPPER CASE.
                  ENDIF.
                  "SIP in progress or not completed
                  IF <ls_verifier>-status = 'IN-PROGRESS' OR
                     <ls_verifier>-status IS INITIAL.
                    <ls_approver_status>-userid   = <ls_verifier>-userid.
                    <ls_approver_status>-userrole = <ls_verifier>-userrole.
                    EXIT.

                  ELSE.
                    <ls_approver_status>-userid   = <ls_verifier>-userid.
                    <ls_approver_status>-userrole = <ls_verifier>-userrole.
                  ENDIF.

                ELSE.
                  EXIT.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.

          CLEAR: lv_tabix,
                 lv_tabix_ver.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_approver_verifier.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 08.26.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get approvers and verfiers based on roles
*&  Transport Request No   : D10K934677
*****************************************************************************
*    CLEAR: et_approvers_verifiers.
*
*    TYPES: lr_roles TYPE RANGE OF agr_name.
*
*    DATA: lt_roles TYPE lr_roles,
*          lt_param TYPE zttca_param.
*
*
*    IF iv_approvers IS INITIAL AND
*       iv_verifiers IS INITIAL AND
*       iv_inspector1 IS INITIAL.
*      DATA(lv_approvers) = abap_true.
*      DATA(lv_verifiers) = abap_true.
*    ELSE.
*      IF iv_approvers IS NOT INITIAL.
*        lv_approvers = abap_true.
*      ENDIF.
*      IF iv_verifiers IS NOT INITIAL.
*        lv_verifiers = abap_true.
*      ENDIF.
*      IF iv_inspector1 IS NOT INITIAL.
*        DATA(lv_inspector1) = abap_true.
*      ENDIF.
*    ENDIF.
*
*    NEW zcl_ca_utility( )->get_parameter(
*      EXPORTING
*        i_busproc           = 'CU'             " Business Process
*        i_busact            = 'TECH'           " Business Activity
*        i_validdate         = sy-datum         " Parameter Validity Start Date
*      CHANGING
*        t_param             = lt_param         " Parameter value
*      EXCEPTIONS
*        invalid_busprocess  = 1                " Invalid Business Process
*        invalid_busactivity = 2                " Invalid Business Activity
*        OTHERS              = 3
*    ).
*    IF sy-subrc = 0.
*      SORT lt_param BY param.
*      IF lv_approvers IS NOT INITIAL.
*        READ TABLE lt_param INTO DATA(ls_param_app)
*        WITH KEY param = 'APPROVER' BINARY SEARCH.
*        IF sy-subrc = 0.
*          APPEND VALUE #( sign   = 'I' option = 'EQ' low = ls_param_app-value ) TO lt_roles.
*        ENDIF.
*      ENDIF.
*      IF lv_verifiers IS NOT INITIAL.
*        READ TABLE lt_param INTO DATA(ls_param_ver)
*        WITH KEY param = 'VERIFIER' BINARY SEARCH.
*        IF sy-subrc = 0.
*          APPEND VALUE #( sign   = 'I' option = 'EQ' low = ls_param_ver-value ) TO lt_roles.
*        ENDIF.
*      ENDIF.
*      IF lv_inspector1 IS NOT INITIAL.
*        READ TABLE lt_param INTO DATA(ls_param_ins1)
*        WITH KEY param = 'W076_FC' BINARY SEARCH.
*        IF sy-subrc = 0.
*          APPEND VALUE #( sign   = 'I' option = 'EQ' low = ls_param_ins1-value ) TO lt_roles.
*        ENDIF.
*      ENDIF.
*
*      IF lt_roles IS NOT INITIAL.
*        SELECT agr_name,
*               uname
*          FROM agr_users
*          INTO TABLE @DATA(lt_users)
*          WHERE agr_name IN @lt_roles AND
*                from_dat LE @sy-datum AND
*                to_dat   GE @sy-datum.
*        IF sy-subrc = 0.
*          SELECT a~bname,
*                 a~persnumber,
*                 b~name_text
*            FROM usr21 AS a
*            INNER JOIN adrp AS b
*            ON a~persnumber = b~persnumber
*            INTO TABLE @DATA(lt_name)
*            FOR ALL ENTRIES IN @lt_users
*            WHERE a~bname = @lt_users-uname.
*          IF sy-subrc = 0.
*            SORT lt_name BY bname.
*          ENDIF.
*          LOOP AT lt_users ASSIGNING FIELD-SYMBOL(<ls_users>).
*            APPEND INITIAL LINE TO et_approvers_verifiers ASSIGNING FIELD-SYMBOL(<ls_approvers_verifiers>).
*            IF <ls_users>-agr_name = ls_param_app-value.
*              <ls_approvers_verifiers>-role_id = 'AP'.
*              <ls_approvers_verifiers>-role = ls_param_app-value.
*              <ls_approvers_verifiers>-role_descr = ls_param_app-descr.
*            ELSEIF <ls_users>-agr_name = ls_param_ver-value.
*              <ls_approvers_verifiers>-role_id = 'VE'.
*              <ls_approvers_verifiers>-role = ls_param_ver-value.
*              <ls_approvers_verifiers>-role_descr = ls_param_ver-descr.
*            ELSEIF <ls_users>-agr_name = ls_param_ins1-value.
*              <ls_approvers_verifiers>-role_id = 'I1'.
*              <ls_approvers_verifiers>-role = ls_param_ins1-value.
*              <ls_approvers_verifiers>-role_descr = ls_param_ins1-descr.
*            ENDIF.
*            <ls_approvers_verifiers>-usrid = <ls_users>-uname.
*
*            READ TABLE lt_name ASSIGNING FIELD-SYMBOL(<ls_name>)
*            WITH KEY bname = <ls_users>-uname BINARY SEARCH.
*            IF sy-subrc  = 0.
*              <ls_approvers_verifiers>-name  = <ls_name>-name_text.
*            ENDIF.
*          ENDLOOP.
*          SORT et_approvers_verifiers BY role_id.
*        ENDIF.
*      ENDIF.
*    ENDIF.
 SELECT agr_name,
               uname
          FROM agr_users
          INTO TABLE @DATA(lt_users)
          WHERE agr_name IN ('DEVELOPER_ROLE') AND
                from_dat LE @sy-datum AND
                to_dat   GE @sy-datum.


          SELECT a~bname,
                 a~persnumber,
                 b~name_text
            FROM usr21 AS a
            INNER JOIN adrp AS b
            ON a~persnumber = b~persnumber
            INTO TABLE @DATA(lt_name)
            FOR ALL ENTRIES IN @lt_users
            WHERE a~bname = @lt_users-uname.
          IF sy-subrc = 0.
            SORT lt_name BY bname.
          ENDIF.
 LOOP AT lt_users ASSIGNING FIELD-SYMBOL(<ls_users>).
            APPEND INITIAL LINE TO et_approvers_verifiers ASSIGNING FIELD-SYMBOL(<ls_approvers_verifiers>).

              <ls_approvers_verifiers>-role_id = 'AP'.
              <ls_approvers_verifiers>-role = 'DEVELOPER'.
              <ls_approvers_verifiers>-role_descr = 'TEST'.


            <ls_approvers_verifiers>-usrid = <ls_users>-uname.

            READ TABLE lt_name ASSIGNING FIELD-SYMBOL(<ls_name>)
            WITH KEY bname = <ls_users>-uname BINARY SEARCH.
            IF sy-subrc  = 0.
              <ls_approvers_verifiers>-name  = <ls_name>-name_text.
            ENDIF.
          ENDLOOP.
  ENDMETHOD.


  METHOD get_atachment_header.
************************************************************************
* Program ID:      GET_ATACHMENT_HEADER
* Program Title:   Get the attachment Header details
* Created By:      Venkata Gopisetty/C144527
* Creation Date:   23.06.2020
* RICEFW ID:       W073
* Description:     T0 get the attachment Header details from
*                  Table - ZTCU_SIP_ATTACH
* Additional Information:
************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 18.06.2020  C144527           1        D10K934677 / Initial version
************************************************************************

*----------------------------------------------------------------------*
*Local Variables
*----------------------------------------------------------------------*

    DATA lw_output TYPE ZCLCU_SIP_MPC=>Ts_ATTACHMENTHEADER.

    CLEAR et_output.

***Fetch Attachment header details with SIP number

    IF iv_docid IS NOT INITIAL.
      SELECT *
        FROM ztcu_sip_attach INTO TABLE @DATA(lt_sip_attach)
        WHERE uniqueno = @iv_sipno
          AND docid = @iv_docid.
    ELSE.
      SELECT *
        FROM ztcu_sip_attach INTO TABLE @lt_sip_attach
        WHERE uniqueno = @iv_sipno.
    ENDIF.

    IF sy-subrc = 0.
      LOOP AT lt_sip_attach ASSIGNING FIELD-SYMBOL(<ls_sip_attach>).
        MOVE-CORRESPONDING <ls_sip_attach> TO lw_output ##ENH_OK.
        APPEND lw_output TO et_output.
        CLEAR : lw_output.
      ENDLOOP.

*      SORT et_output ASCENDING BY uniqueno seqno timestamp.

      SORT et_output ASCENDING BY seqno timestamp.
    ENDIF.
  ENDMETHOD.


METHOD get_attachment_header_new.
*DATA lw_output TYPE ZCLCU_SIP_MPC=>Ts_ATTACHMENTHEADER.
*
*    CLEAR et_output.
*
****Fetch Attachment header details with SIP number
*
*    IF iv_docid IS NOT INITIAL.
*      SELECT *
*        FROM ztcu_sip_attach INTO TABLE @DATA(lt_sip_attach)
*        WHERE uniqueno = @iv_sipno
*          AND docid = @iv_docid.
*    ELSE.
*      SELECT *
*        FROM ztcu_sip_attach INTO TABLE @lt_sip_attach
*        WHERE uniqueno = @iv_sipno.
*    ENDIF.
*
*    IF sy-subrc = 0.
*      LOOP AT lt_sip_attach ASSIGNING FIELD-SYMBOL(<ls_sip_attach>).
*        MOVE-CORRESPONDING <ls_sip_attach> TO lw_output ##ENH_OK.
*        APPEND lw_output TO et_output.
*        CLEAR : lw_output.
*      ENDLOOP.
*
**      SORT et_output ASCENDING BY uniqueno seqno timestamp.
*
*      SORT et_output ASCENDING BY seqno timestamp.
*    ENDIF.

  endmethod.


  METHOD get_contractheader.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the header details from SAP contract table
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_header.
    SELECT a~ebeln,
           a~lifnr,
           b~name1,
           b~regio,
           b~txjcd
      FROM ekko AS a
      INNER JOIN lfa1 AS b
      ON a~lifnr = b~lifnr
      INTO @DATA(ls_header)
      UP TO 1 ROWS
      WHERE ebeln = @iv_contract.
    ENDSELECT.
    IF sy-subrc = 0.
      APPEND INITIAL LINE TO et_header ASSIGNING FIELD-SYMBOL(<ls_header>).
      <ls_header>-contract            = ls_header-ebeln.
      <ls_header>-suppliercompany     = ls_header-lifnr.
      <ls_header>-suppliercompanyname = ls_header-name1.
      <ls_header>-regio               = ls_header-regio.
      <ls_header>-txjd               = ls_header-txjcd.
      <ls_header>-supplier            = iv_submittedby.
      IF <ls_header>-contract IS NOT INITIAL.
        CALL METHOD zclcu_sip_utility=>get_contract_description
          EXPORTING
            iv_contract    = <ls_header>-contract
          IMPORTING
            ev_description = DATA(lv_descr).
        <ls_header>-contractdescr = lv_descr.
      ENDIF.
      IF <ls_header>-supplier IS NOT INITIAL.
        CALL METHOD zclcu_sip_utility=>get_name
          EXPORTING
            iv_userid = <ls_header>-supplier
          IMPORTING
            ev_name   = <ls_header>-suppliername.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_contractitem.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Item details from SAP contract table
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_items.
    SELECT a~ebeln,
           a~ebelp,
           a~loekz,
           a~matnr,
           b~maktx,
           a~ktmng,
           a~meins,
           a~netpr
      FROM ekpo AS a
      LEFT OUTER JOIN makt AS b
      ON a~matnr = b~matnr AND
         b~spras = @sy-langu
      INTO TABLE @DATA(lt_ekpo)
      WHERE a~ebeln = @iv_contract.
    IF sy-subrc = 0.
      "Calculate Accumulated Quantity
      zclcu_sip_utility=>calculate_accumulatedqty(
        EXPORTING
          iv_appindicator   = iv_appindicator
          iv_contract       = iv_contract
          iv_wrno           = iv_wrno
          iv_spno           = iv_spno
        IMPORTING
          et_accumulatedqty = DATA(lt_accumulatedqty)
      ).

      LOOP AT lt_ekpo ASSIGNING FIELD-SYMBOL(<ls_ekpo>).
        APPEND INITIAL LINE TO et_items ASSIGNING FIELD-SYMBOL(<ls_items>).

        <ls_items>-counter      = 1.
        <ls_items>-itemcode     = <ls_ekpo>-matnr.
        <ls_items>-itemdescr    = <ls_ekpo>-maktx.
        <ls_items>-loekz        = <ls_ekpo>-loekz.
        <ls_items>-contract     = iv_contract.
        <ls_items>-designqty    = <ls_ekpo>-ktmng.
        <ls_items>-designqtyuom = <ls_ekpo>-meins.
        <ls_items>-netprice     = <ls_ekpo>-netpr.

        READ TABLE lt_accumulatedqty ASSIGNING FIELD-SYMBOL(<ls_accumqty>)
        WITH KEY itemcode = <ls_ekpo>-matnr.
        IF sy-subrc = 0.
          <ls_items>-accumalatedqty = <ls_accumqty>-accumqty.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_contractsf4.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 13.08.2020
*&  Functional Design Name : Special Project
*&  Purpose                : Get the contract F4
*&  Transport Request No   : D10K935617
*****************************************************************************
    CLEAR: et_data.

    DATA: lt_param   TYPE zttca_param,
          lv_enddate TYPE datum.

*    IF iv_vendor IS INITIAL.
      "Get the vendor for the user
*      SELECT lifnr
*        FROM ztcu_sip_users
*        INTO @DATA(lv_vendor)
*        UP TO 1 ROWS
*        WHERE uname = @iv_submittedby AND
*              validfrom LE @sy-datum AND
*              validto   GE @sy-datum.
*      ENDSELECT.
*      IF sy-subrc = 0 OR
*         iv_sp = abap_true.
*
*        "Get the material types for which taxcode has to be determined
*        NEW zcl_ca_utility( )->get_parameter(
*        EXPORTING
*          i_busproc           = 'CU'             " Business Process
*          i_busact            = 'TECH'           " Business Activity
*          i_validdate         = sy-datum         " Parameter Validity Start Date
*          i_param             = 'VALIDITYEND'
*        CHANGING
*          t_param             = lt_param         " Parameter value
*        EXCEPTIONS
*          invalid_busprocess  = 1                " Invalid Business Process
*          invalid_busactivity = 2                " Invalid Business Activity
*          OTHERS              = 3
*      ).
*        IF sy-subrc = 0.
*          READ TABLE lt_param ASSIGNING FIELD-SYMBOL(<ls_param>) INDEX 1.
*          IF sy-subrc = 0.
*            DATA(lv_extend) = <ls_param>-value.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.

    "Get contracts
*    IF iv_contract IS NOT INITIAL.
      SELECT ebeln,
             bukrs,
             kdatb,
             kdate
        FROM ekko
        INTO TABLE @DATA(lt_contract).
      IF sy-subrc EQ 0.
        SORT lt_contract BY ebeln.
        DELETE ADJACENT DUPLICATES FROM lt_contract COMPARING ebeln.
      ENDIF.
*    ELSE.
*      SELECT ebeln,
*             bukrs,
*             kdatb,
*             kdate
*         FROM ekko
*         INTO TABLE @lt_contract
*         WHERE bsart  = 'MKI' AND
*               loekz  = @space AND
*               lifnr  = @lv_vendor AND
*               angnr = 'SIP'.
*      IF sy-subrc EQ 0.
*        SORT lt_contract BY ebeln.
*        DELETE ADJACENT DUPLICATES FROM lt_contract COMPARING ebeln.
*      ENDIF.
*    ENDIF.

    LOOP AT lt_contract ASSIGNING FIELD-SYMBOL(<ls_contract>).
      lv_enddate = <ls_contract>-kdate .

      IF ( <ls_contract>-kdatb LE sy-datum AND
           lv_enddate          GE sy-datum ).
        APPEND INITIAL LINE TO et_data ASSIGNING FIELD-SYMBOL(<ls_output>).
        <ls_output>-contract       = <ls_contract>-ebeln.
        <ls_output>-companycode = <ls_contract>-bukrs.
        <ls_output>-enddate     = <ls_contract>-kdate.

        CALL METHOD zclcu_sip_utility=>get_contract_description
          EXPORTING
            iv_contract    = <ls_contract>-ebeln
          IMPORTING
            ev_description = <ls_output>-contractdescr.
      ENDIF.
      CLEAR: lv_enddate.
    ENDLOOP.


  ENDMETHOD.


  METHOD get_contract_description.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Contract Description
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR ev_description.
    DATA: lt_tline  TYPE STANDARD TABLE OF tline,
          lv_tdname TYPE tdobname,
          lv_desc   TYPE char40.

    lv_tdname               = iv_contract.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client                  = sy-mandt
        id                      = 'K17'
        language                = sy-langu
        name                    = lv_tdname
        object                  = 'EKKO'
      TABLES
        lines                   = lt_tline
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc = 0.
      CALL FUNCTION 'IDMX_DI_TLINE_INTO_STRING'
        EXPORTING
          it_tline       = lt_tline
        IMPORTING
          ev_text_string = ev_description.
      IF ev_description IS NOT INITIAL.
        lv_desc = ev_description.
        CLEAR ev_description.
        ev_description = lv_desc.
        CLEAR lv_desc.
      ENDIF.

    ELSE.
      CLEAR ev_description.
    ENDIF.
  ENDMETHOD.


  METHOD get_document.
********************************************************************************
* Program ID:      GET_DOCUMENT
* Program Title:   Get the attachment from BUS2081 and table - ZTCU_SIP_ATTACH
* Created By:      Venkata Gopisetty/C144527
* Creation Date:   23.06.2020
* RICEFW ID:       W073
* Description:     To get attachment from BUS2081 and table - ZTCU_SIP_ATTACH
*                  Table - ZTCU_SIP_ATTACH
*********************************************************************************
* Modification History
************************************************************************
* Date        User ID        REQ#        Transport# / Description
* ----------  ------------ ----------  ------------------------
* 18.06.2020  C144527           1        D10K934677 / Initial version
************************************************************************
    CLEAR : ev_error_flag,
            es_stream,
            es_header.

**----------------------------------------------------------------------*
**Local Variable Declaration
**----------------------------------------------------------------------*
    DATA : lv_size          TYPE i,
           lv_solisti1      TYPE solisti1,
           lv_obj_type      TYPE saedoktyp,
           lv_filename      TYPE so_obj_des,
           lv_string        TYPE string,
           lv_attach_con_id TYPE saeardoid,
           lv_xstring       TYPE xstring,
           lv_size_opentxt  TYPE i.

**----------------------------------------------------------------------*
**Internal Table Declaration
**----------------------------------------------------------------------*
    DATA: lt_binary_content  TYPE solix_tab.

    IF cs_attachdeatils-docid IS NOT INITIAL.

      lv_attach_con_id = cs_attachdeatils-docid.

****Get the archiv Id from Business object
      SELECT  archiv_id FROM toa01 INTO @DATA(lv_toa01) UP TO 1 ROWS WHERE sap_object = 'BUS2081'
                                                                AND arc_doc_id = @lv_attach_con_id.
      ENDSELECT.
      IF sy-subrc NE 0.
        CLEAR lv_toa01.
      ENDIF.

***Get file Size
      CALL FUNCTION 'SCMS_HTTP_GET'
        EXPORTING
          mandt                 = sy-mandt
          crep_id               = lv_toa01 "'PG'
          doc_id                = lv_attach_con_id
        IMPORTING
          length                = lv_size_opentxt
        TABLES
          data                  = lt_binary_content
        EXCEPTIONS
          bad_request           = 1
          unauthorized          = 2
          not_found             = 3
          conflict              = 4
          internal_server_error = 5
          error_http            = 6
          error_url             = 7
          error_signature       = 8
          OTHERS                = 9.

      IF sy-subrc = 0.

        IF cs_attachdeatils-doctype = TEXT-007.
*
          LOOP AT lt_binary_content INTO DATA(lw_object_content).
            lv_solisti1 = CONV solisti1( lw_object_content-line ).
            CONCATENATE lv_solisti1 cl_abap_char_utilities=>cr_lf
            INTO lv_solisti1.                           "#EC CI_CONV_OK
            CLEAR: lw_object_content.
          ENDLOOP.

          lv_string = CONV string( lv_solisti1 ).

          CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
            EXPORTING
              text   = lv_string
            IMPORTING
              buffer = lv_xstring.

          SELECT SINGLE
                 doc_type,
                 mimetype
                 FROM toadd WHERE doc_type = @lv_obj_type
                 INTO @DATA(lw_toadd).

          IF sy-subrc = 0.
            IF NOT lv_xstring IS INITIAL.
              es_stream-value = lv_xstring.
              es_stream-mime_type = lw_toadd-mimetype.
              es_header-name = TEXT-001.
              lv_filename = CONV so_obj_des( cs_attachdeatils-filename ).
              TRANSLATE cs_attachdeatils-doctype TO LOWER CASE.
              CONCATENATE TEXT-008 space TEXT-006 '=' lv_filename '. ' cs_attachdeatils-doctype ';' INTO es_header-value.
            ENDIF.
          ENDIF.
        ELSE.

          lv_size = lv_size_opentxt.
          lv_obj_type = cs_attachdeatils-doctype.

******Convert Binary Data to XSTRING********
          CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
            EXPORTING
              input_length = lv_size
            IMPORTING
              buffer       = lv_xstring
            TABLES
              binary_tab   = lt_binary_content
            EXCEPTIONS
              failed       = 1
              OTHERS       = 2 ##FM_SUBRC_OK.
          IF sy-subrc = 0.
            SELECT SINGLE
                   doc_type,
                   mimetype
                   FROM toadd WHERE doc_type = @lv_obj_type
                   INTO @lw_toadd.
            IF sy-subrc = 0.
              IF NOT lv_xstring IS INITIAL.
                es_stream-value = lv_xstring.
                es_stream-mime_type = lw_toadd-mimetype.
                es_header-name = TEXT-001.
                lv_filename = CONV so_obj_des( cs_attachdeatils-filename ).
                TRANSLATE cs_attachdeatils-doctype TO LOWER CASE.
                CONCATENATE TEXT-008 space TEXT-006 '=' lv_filename ';' INTO es_header-value.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_header.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the header details from SAP contract table
*&  Transport Request No   : D10K934677
*****************************************************************************
*    Comment Om
*    DATA: lw_header   TYPE zcl_zcu_u115_sp_mpc=>ts_header,
*          lw_wrheader TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_header.
*
*    CLEAR : et_header.
*    CASE is_header-category.
*      WHEN 'C'.
*        "Call method contract header
*        CALL METHOD zclcu_sip_utility=>get_contractheader
*          EXPORTING
*            iv_contract    = is_header-contract
*            iv_submittedby = is_header-submittedby
*          IMPORTING
*            et_header      = et_header.
*
*      WHEN 'S'.
*        MOVE-CORRESPONDING is_header TO lw_header ##ENH_OK.
*
*        CALL METHOD zclcu_u115_utility=>get_header
*          EXPORTING
*            is_header = lw_header
*          IMPORTING
*            et_header = DATA(lt_header).
*
*        LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<ls_header>).
*          APPEND INITIAL LINE TO et_header ASSIGNING FIELD-SYMBOL(<ls_output>).
*          MOVE-CORRESPONDING <ls_header> TO <ls_output> ##ENH_OK.
*        ENDLOOP.
*        "Work Req/Order
*      WHEN 'W'.
*        MOVE-CORRESPONDING is_header TO lw_wrheader ##ENH_OK.
*
*        CALL METHOD zclcu_sip_sourcewr=>get_wr_header
*          EXPORTING
*            is_header = lw_wrheader
*          IMPORTING
*            et_data   = DATA(lt_wrheader).
*
*        LOOP AT lt_wrheader ASSIGNING FIELD-SYMBOL(<ls_wrheader>).
*          APPEND INITIAL LINE TO et_header ASSIGNING FIELD-SYMBOL(<ls_wr_output>).
*          MOVE-CORRESPONDING <ls_wrheader> TO <ls_wr_output> ##ENH_OK.
*        ENDLOOP.
*
*      WHEN OTHERS.
*    ENDCASE.

        DATA: lw_header   TYPE zcl_zcu_u115_sp_mpc=>ts_header,
          lw_wrheader TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_header.

    CLEAR : et_header.
    CASE is_header-category.
      WHEN 'C'.
        "Call method contract header
        CALL METHOD zclcu_sip_utility=>get_contractheader
          EXPORTING
            iv_contract    = is_header-contract
            iv_submittedby = is_header-submittedby
          IMPORTING
            et_header      = DATA(lt_Contractheader).

  LOOP AT lt_Contractheader ASSIGNING FIELD-SYMBOL(<ls_header>).
          APPEND INITIAL LINE TO et_header ASSIGNING FIELD-SYMBOL(<ls_output>).
          MOVE-CORRESPONDING <ls_header> TO <ls_output> ##ENH_OK.
        ENDLOOP.

      WHEN 'S'.
        MOVE-CORRESPONDING is_header TO lw_header ##ENH_OK.

        CALL METHOD zclcu_u115_utility=>get_header
          EXPORTING
            is_header = lw_header
          IMPORTING
            et_header = DATA(lt_header).

        LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<lsp_header>).
          APPEND INITIAL LINE TO et_header ASSIGNING FIELD-SYMBOL(<ls_outputsp>).
          MOVE-CORRESPONDING <lsp_header> TO <ls_outputsp> ##ENH_OK.
        ENDLOOP.
        "Work Req/Order
*      WHEN 'W'.
*        MOVE-CORRESPONDING is_header TO lw_wrheader ##ENH_OK.
*
*        CALL METHOD zclcu_sip_sourcewr=>get_wr_header
*          EXPORTING
*            is_header = lw_wrheader
*          IMPORTING
*            et_data   = DATA(lt_wrheader).
*
*        LOOP AT lt_wrheader ASSIGNING FIELD-SYMBOL(<ls_wrheader>).
*          APPEND INITIAL LINE TO et_header ASSIGNING FIELD-SYMBOL(<ls_wr_output>).
*          MOVE-CORRESPONDING <ls_wrheader> TO <ls_wr_output> ##ENH_OK.
*        ENDLOOP.

WHEN OTHERS.
    ENDCASE.


  ENDMETHOD.
ENDCLASS.
