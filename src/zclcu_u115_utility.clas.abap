class ZCLCU_U115_UTILITY definition
  public
  final
  create public .

public section.

  interfaces ZIF_CU_SIP .

  class-methods GET_HEADER
    importing
      !IS_HEADER type ZCL_ZCU_U115_SP_MPC=>TS_HEADER
    exporting
      !ET_HEADER type ZCL_ZCU_U115_SP_MPC=>TT_HEADER .
  class-methods GET_ITEMS
    importing
      !IS_ITEM type ZCL_ZCU_U115_SP_MPC=>TS_ITEM
    exporting
      !ET_ITEMS type ZCL_ZCU_U115_SP_MPC=>TT_ITEM .
  class-methods SET_HEADER_ITEMS
    importing
      !IS_HEADER type ZCL_ZCU_U115_SP_MPC=>TS_HEADER
      !IT_ITEMS type ZCL_ZCU_U115_SP_MPC=>TT_ITEM
      !IV_NEW type BOOLEAN
    exporting
      !ES_HEADER_INS type ZTCU_SPHEADER
      !ES_HEADER_UPD type ZTCU_SPHEADER
      !ET_ITEM_INS type ZTTCU_SP_ITEM
      !ET_ITEM_UPD type ZTTCU_SP_ITEM
      !ET_ITEM_DEL type ZTTCU_SP_ITEM .
  class-methods GET_SPHEADER
    importing
      !IS_HEADER type ZCL_ZCU_U115_SP_MPC=>TS_HEADER
    exporting
      !ET_HEADER type ZCL_ZCU_U115_SP_MPC=>TT_HEADER .
  class-methods GET_SPITEMS
    importing
      !IS_ITEM type ZCL_ZCU_U115_SP_MPC=>TS_ITEM
    exporting
      !ET_ITEMS type ZCL_ZCU_U115_SP_MPC=>TT_ITEM .
  class-methods BATCH_PROCESS
    importing
      !IT_DEEP_STRUC type ZTTCU_DEEP_STRUC
      !IV_SPNO type Z_SPNO optional
      !IT_MEDIA_SLUG type ZCLCU_SIP_UTILITY=>TY_T_MEDIA_SLUG optional
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR optional
    changing
      !CT_RETURN type BAPIRET2_T optional
      !CT_ATTACH_CS type ZCLCU_SIP_MPC=>TT_ATTACHDOCUMENT optional .
  class-methods PROCESS_HEADER
    importing
      !IS_HEADER type ZCL_ZCU_U115_SP_MPC=>TS_HEADER
      !IV_NEW type BOOLEAN
    exporting
      !ES_HEADER_INS type ZTCU_SPHEADER
      !ES_HEADER_UPD type ZTCU_SPHEADER .
  class-methods PROCESS_ITEMS
    importing
      !IT_ITEMS type ZCL_ZCU_U115_SP_MPC=>TT_ITEM
      !IV_SUBMITTEDBY type UNAME
    exporting
      !ET_ITEM_INS type ZTTCU_SP_ITEM
      !ET_ITEM_UPD type ZTTCU_SP_ITEM
      !ET_ITEM_DEL type ZTTCU_SP_ITEM
      !EV_AMOUNT type Z_SIPAMOUNT .
  class-methods GET_CONTRACTS_SP
    importing
      !IV_CONTRACT type EBELN optional
    exporting
      !ET_DATA type ZCL_ZCU_U115_SP_MPC=>TT_CONTRACTSEARCHHELP .
protected section.
private section.
ENDCLASS.



CLASS ZCLCU_U115_UTILITY IMPLEMENTATION.


  METHOD batch_process.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 04.08.2020
*&  Functional Design Name : Special Project Application
*&  Purpose                : Save the changes of all tabs
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA : lw_items     TYPE zcl_zcu_u115_sp_mpc=>ts_item,
           lw_header    TYPE zcl_zcu_u115_sp_mpc=>ts_header,
           lw_key_tab   TYPE /iwbep/s_mgw_name_value_pair,
           lw_attach_cs TYPE zcl_zcu_u115_sp_mpc=>ts_attachdocument,
           lt_items     TYPE zcl_zcu_u115_sp_mpc=>tt_item,
           lw_routing   TYPE zcl_zcu_u115_sp_mpc=>ts_approvalflow,
           lw_attach    TYPE zscu_sip_attach,
           lt_attach    TYPE zttcu_sip_attach,
           lt_routing   TYPE zcl_zcu_u115_sp_mpc=>tt_approvalflow.



    LOOP AT it_deep_struc ASSIGNING FIELD-SYMBOL(<ls_deep_item>).

      IF <ls_deep_item>-header_sp IS NOT INITIAL AND lw_header IS INITIAL.
        "Header
        lw_header = <ls_deep_item>-header_sp.
        IF lw_header-spno IS INITIAL.
          "populate the new SIP created
          lw_header-spno = iv_spno.
          DATA(lv_new) = abap_true.
        ENDIF.
      ENDIF.
      "Items
      IF <ls_deep_item>-items_sp IS NOT INITIAL.
        lw_items = <ls_deep_item>-items_sp .
        IF lw_items-spno IS INITIAL.
          "populate the new SIP created
          lw_items-spno = iv_spno.
        ENDIF.
        APPEND lw_items TO lt_items.
        CLEAR : lw_items.
      ENDIF.
      "Approval flow
      IF <ls_deep_item>-routing IS NOT INITIAL AND lw_routing IS INITIAL.
        lw_routing = <ls_deep_item>-routing.
        IF <ls_deep_item>-routing-uniqueno IS INITIAL.
          lw_routing-uniqueno = iv_spno.
        ENDIF.
        APPEND lw_routing TO lt_routing.
        CLEAR : lw_routing.
      ENDIF.

      "Attachment
      IF <ls_deep_item>-attachheader IS NOT INITIAL.
        lw_attach = <ls_deep_item>-attachheader.
        IF <ls_deep_item>-attachheader-uniqueno IS INITIAL.
          lw_attach-uniqueno = iv_spno.
        ENDIF.
        APPEND lw_attach TO lt_attach.
        CLEAR : lw_attach.
      ENDIF.
    ENDLOOP.
    IF lw_header IS NOT INITIAL OR lt_items IS NOT INITIAL.
      "update header and item
      CALL METHOD zclcu_u115_utility=>set_header_items
        EXPORTING
          is_header     = lw_header
          it_items      = lt_items
          iv_new        = lv_new
        IMPORTING
          es_header_ins = DATA(ls_header_ins)
          es_header_upd = DATA(ls_header_upd)
          et_item_ins   = DATA(lt_item_ins)
          et_item_upd   = DATA(lt_item_upd)
          et_item_del   = DATA(lt_item_del).
    ENDIF.
    "delete Attachment
    IF lt_attach IS NOT INITIAL.
      CALL METHOD zclcu_sip_utility=>create_attachment_header
        EXPORTING
          it_sip_attach = lt_attach.
    ENDIF.
    "Approval flow
    IF lt_routing IS NOT INITIAL.
      CALL METHOD zclcu_sip_utility=>set_approvalflow
        EXPORTING
          it_approvalflow = lt_routing
        IMPORTING
          et_routing_ins  = DATA(lt_routing_ins)
          et_routing_upd  = DATA(lt_routing_upd)
          et_routing_del  = DATA(lt_routing_del).
    ENDIF.

    CALL FUNCTION 'ZCU_UPDATE_SP' IN UPDATE TASK
      EXPORTING
        iv_spno        = lw_header-spno
        is_header_ins  = ls_header_ins
        is_header_upd  = ls_header_upd
        it_item_ins    = lt_item_ins
        it_item_upd    = lt_item_upd
        it_item_del    = lt_item_del
        it_routing_ins = lt_routing_ins
        it_routing_upd = lt_routing_upd
        it_routing_del = lt_routing_del
        iv_delete      = abap_true.

    COMMIT WORK AND WAIT.
    "Create_stream for attachments
    IF it_media_slug IS NOT INITIAL.
      IF it_key_tab IS INITIAL.
        DATA(lt_temp_key_tab) = it_key_tab.
        IF iv_spno IS INITIAL.
          lw_key_tab-value = lw_header-spno.
        ELSE.
          lw_key_tab-value = iv_spno.
        ENDIF.
        lw_key_tab-name = 'SpNo'.

        APPEND lw_key_tab TO lt_temp_key_tab.
        CLEAR : lw_key_tab.
      ENDIF.
      "create multiple documents for multiple attachments
      LOOP AT it_media_slug ASSIGNING FIELD-SYMBOL(<ls_media_slug>).
        CALL METHOD zclcu_sip_utility=>attach_create_stream
          EXPORTING
            is_media_resource = <ls_media_slug>-media_resource
            it_key_tab        = lt_temp_key_tab
            iv_slug           = <ls_media_slug>-slug
          IMPORTING
            er_entity         = lw_attach_cs.

        APPEND lw_attach_cs TO ct_attach_cs.
        CLEAR : lw_attach_cs.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_contracts_sp.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi.K
*&  Created On             : 07.12.2020
*&  Functional Design Name : Special Project
*&  Purpose                : Get the contract F4
*&  Transport Request No   : D10K935617
*****************************************************************************
    CLEAR: et_data.

    DATA: lt_param   TYPE zttca_param,
          lv_enddate TYPE datum.

    "Get the validity end date extension
    NEW zcl_ca_utility( )->get_parameter(
    EXPORTING
      i_busproc           = 'CU'             " Business Process
      i_busact            = 'TECH'           " Business Activity
      i_validdate         = sy-datum         " Parameter Validity Start Date
      i_param             = 'VALIDITYEND'
    CHANGING
      t_param             = lt_param         " Parameter value
    EXCEPTIONS
      invalid_busprocess  = 1                " Invalid Business Process
      invalid_busactivity = 2                " Invalid Business Activity
      OTHERS              = 3
  ).
    IF sy-subrc = 0.
      READ TABLE lt_param ASSIGNING FIELD-SYMBOL(<ls_param>) INDEX 1.
      IF sy-subrc = 0.
        DATA(lv_extend) = <ls_param>-value.
      ENDIF.
    ENDIF.

    "Get contracts type - MKI Quotation - SIP
    IF iv_contract IS NOT INITIAL.
      SELECT ebeln,
             bukrs,
             kdatb,
             kdate
        FROM ekko
        INTO TABLE @DATA(lt_contract)
        WHERE ebeln  = @iv_contract AND
              bsart  = 'MKI' AND
              loekz  = @space AND
              angnr  = 'SIP'.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ELSE.
      SELECT ebeln,
             bukrs,
             kdatb,
             kdate
         FROM ekko
         INTO TABLE @lt_contract
         WHERE bsart  = 'MKI' AND
               loekz  = @space AND
               angnr = 'SIP'.
      IF sy-subrc EQ 0.
        SORT lt_contract BY ebeln.
      ENDIF.
    ENDIF.

    LOOP AT lt_contract ASSIGNING FIELD-SYMBOL(<ls_contract>).
      lv_enddate = <ls_contract>-kdate + lv_extend.

      IF ( <ls_contract>-kdatb LE sy-datum AND
           lv_enddate          GE sy-datum ).
        APPEND INITIAL LINE TO et_data ASSIGNING FIELD-SYMBOL(<ls_output>).
        <ls_output>-ebeln       = <ls_contract>-ebeln.
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


  METHOD get_header.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Header details
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA lw_header TYPE zclcu_sip_mpc=>ts_headersipwr.

    CLEAR et_header.

    IF is_header-spno IS NOT INITIAL.
      "Get Header details from Special Projects table
      CALL METHOD zclcu_u115_utility=>get_spheader
        EXPORTING
          is_header = is_header
        IMPORTING
          et_header = et_header.

    ELSE.
      "Get Header details from SAP contract table
      MOVE-CORRESPONDING is_header TO lw_header ##ENH_OK.
      CALL METHOD zclcu_sip_utility=>get_header
        EXPORTING
          is_header = lw_header
        IMPORTING
          et_header = DATA(lt_header).
      LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<ls_header>).
        APPEND INITIAL LINE TO et_header ASSIGNING FIELD-SYMBOL(<ls_etheader>).
        MOVE-CORRESPONDING <ls_header> TO <ls_etheader> ##ENH_OK.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_items.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Item details
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA lw_item TYPE zclcu_sip_mpc=>ts_item.

    CLEAR et_items.

    IF is_item-spno IS NOT INITIAL.
      "Get From Ticketing Item table
      CALL METHOD zclcu_u115_utility=>get_spitems
        EXPORTING
          is_item  = is_item
        IMPORTING
          et_items = et_items.

    ELSE.
      "Get From SAP contract table
      MOVE-CORRESPONDING is_item TO lw_item ##ENH_OK.
      CALL METHOD zclcu_sip_utility=>get_items
        EXPORTING
          is_item  = lw_item
        IMPORTING
          et_items = DATA(lt_output_items).
      LOOP AT lt_output_items ASSIGNING FIELD-SYMBOL(<ls_items>).
        APPEND INITIAL LINE TO et_items ASSIGNING FIELD-SYMBOL(<ls_etitems>).
        MOVE-CORRESPONDING <ls_items> TO <ls_etitems> ##ENH_OK.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_spheader.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Header details from Ticketing table
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_header.

    DATA : lv_costobj_wbs TYPE prps-pspnr,
           lv_costobj     TYPE aufnr.

    SELECT a~spno,
           a~spdescr,
           a~wrno,
           a~sipstatus,
           a~submittedby,
           a~planneddate,
           a~completiondate,
           a~createdon,
           a~suppliercompany,
           b~name1,
           b~regio,
           b~txjcd,
           a~contract,
           a~final,
           a~plant,
           a~project,
           a~addrline1,
           a~addrline2,
           a~city,
           a~state,
           a~country,
           a~postalcode,
           a~projdesc,
           a~coflag,
           a~costobject,
           a~autoapprove,
           a~extwrno
      FROM ztcu_spheader AS a
      LEFT OUTER JOIN lfa1 AS b
      ON a~suppliercompany = b~lifnr
      UP TO 1 ROWS
      INTO @DATA(lw_spheader)
      WHERE spno = @is_header-spno.
    ENDSELECT.
    IF sy-subrc = 0.
      IF lw_spheader-suppliercompany IS INITIAL.
        SELECT a~lifnr,
               a~name1,
               a~regio,
               a~txjcd
          FROM lfa1 AS a
          INNER JOIN ekko AS b
                    ON a~lifnr = b~lifnr
                    INTO @DATA(lw_vend_name)
          UP TO 1 ROWS
          WHERE ebeln = @lw_spheader-contract.
        ENDSELECT.
      ELSE.
        lw_vend_name-lifnr = lw_spheader-suppliercompany.
        lw_vend_name-name1 = lw_spheader-name1.
        lw_vend_name-regio = lw_spheader-regio.
        lw_vend_name-txjcd = lw_spheader-txjcd.
      ENDIF.

      APPEND INITIAL LINE TO et_header ASSIGNING FIELD-SYMBOL(<ls_header>).
      MOVE-CORRESPONDING lw_spheader TO <ls_header>.
      <ls_header>-suppliercompany     = lw_vend_name-lifnr.
      <ls_header>-suppliercompanyname = lw_vend_name-name1.
      <ls_header>-regio               = lw_vend_name-regio.
      <ls_header>-txjcd               = lw_vend_name-txjcd.
      <ls_header>-spdate              = lw_spheader-createdon.

      IF <ls_header>-contract IS NOT INITIAL.
        CALL METHOD zclcu_sip_utility=>get_contract_description
          EXPORTING
            iv_contract    = <ls_header>-contract
          IMPORTING
            ev_description = DATA(lv_descr).
        <ls_header>-contractdescr = lv_descr.
      ENDIF.

      CASE <ls_header>-coflag.
        WHEN 'IO' OR 'PM'.

          CALL FUNCTION 'CONVERSION_EXIT_AUFNR_INPUT' ##FM_SUBRC_OK
            EXPORTING
              input  = <ls_header>-costobject
            IMPORTING
              output = lv_costobj.
          IF sy-subrc EQ 0 ##FM_SUBRC_OK.
            SELECT SINGLE ktext
                 FROM aufk INTO @DATA(lv_orderdescr)
                 WHERE aufnr EQ @lv_costobj.
            IF sy-subrc EQ 0.
              <ls_header>-codesc =  lv_orderdescr.
            ENDIF.
          ENDIF.


        WHEN 'WBS'.
          CALL FUNCTION 'CONVERSION_EXIT_ABPSP_INPUT'
            EXPORTING
              input     = <ls_header>-costobject
            IMPORTING
              output    = lv_costobj_wbs
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc = 0.
            SELECT SINGLE
              post1 FROM prps
              INTO @DATA(lv_wbsdescr)
              WHERE pspnr EQ @lv_costobj_wbs.
            IF sy-subrc = 0.
              <ls_header>-codesc =  lv_wbsdescr.
            ENDIF.
          ENDIF.

      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD get_spitems.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Item details from SP table
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_items.

    DATA: ls_item      TYPE zclcu_sip_mpc=>ts_item,
          lw_spitem    TYPE zcl_zcu_u115_sp_mpc=>ts_item,
          lv_counter   TYPE bnfpo,
          lv_lineno    TYPE z_linenum,
          lv_designqty TYPE z_designqty.

    SELECT a~spno,
           b~itemcode,
           b~costobject,
           b~linenum,
           b~designqty,
           b~bussunit,
           b~woid,
           b~actqty,
           b~activity,
           b~coflag,
           a~contract
      FROM ztcu_spheader AS a
      INNER JOIN ztcu_spitem AS b
      ON a~spno = b~spno
      INTO TABLE @DATA(lt_spitem)
      WHERE a~spno = @is_item-spno.
    IF sy-subrc = 0.
      SORT lt_spitem BY spno itemcode costobject.

      "Fetch the netprice details
      ls_item-category = 'C'.
      ls_item-contract = lt_spitem[ 1 ]-contract.

      CALL METHOD zclcu_sip_utility=>get_items
        EXPORTING
          is_item  = ls_item
        IMPORTING
          et_items = DATA(lt_items).
      SORT lt_items BY itemcode.

      "Calculate the Accumulated Qty grouped based on material
      CALL METHOD zclcu_sip_utility=>calculate_accumulatedqty
        EXPORTING
          iv_appindicator   = is_item-appindicator
          iv_spno           = is_item-spno
        IMPORTING
          et_accumulatedqty = DATA(lt_accumulatedqty).

      LOOP AT lt_spitem ASSIGNING FIELD-SYMBOL(<ls_spitem>).
        AT NEW itemcode.
          lv_lineno = lv_lineno + 10 .
        ENDAT.

        AT NEW costobject.
          lw_spitem-spno    = <ls_spitem>-spno.
          lw_spitem-linenum = lv_lineno.
          IF lw_spitem-linenum IS NOT INITIAL.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = lw_spitem-linenum
              IMPORTING
                output = lw_spitem-linenum.
          ENDIF.

          lv_counter = lv_counter + 1.
          lw_spitem-counter = lv_counter.

          IF lv_counter > 1.
            lw_spitem-parentlineno   = lv_lineno.
            lw_spitem-splitindicator = zif_cu_sip=>gc_splitindicator-system.
          ENDIF.

          READ TABLE lt_items ASSIGNING FIELD-SYMBOL(<ls_ekpo>)
          WITH KEY itemcode = <ls_spitem>-itemcode BINARY SEARCH.
          IF sy-subrc = 0.
            lw_spitem-itemdescr      = <ls_ekpo>-itemdescr.
            lw_spitem-netprice  = <ls_ekpo>-netprice.
          ENDIF.

          lw_spitem-itemcode         = <ls_spitem>-itemcode.
          lw_spitem-category         = is_item-category.
          lw_spitem-appindicator     = is_item-appindicator.
          lw_spitem-contract         = <ls_spitem>-contract.
          lw_spitem-costobject       = <ls_spitem>-costobject.
          lw_spitem-coflag           = <ls_spitem>-coflag.
          lw_spitem-bussunit         = <ls_spitem>-bussunit.
          lw_spitem-woid             = <ls_spitem>-woid.
          lw_spitem-activity         = <ls_spitem>-activity.

        ENDAT.

        lv_designqty = lv_designqty + <ls_spitem>-actqty.

        AT END OF itemcode.
          IF lw_spitem-parentlineno IS NOT INITIAL.
            READ TABLE et_items ASSIGNING FIELD-SYMBOL(<ls_data>)
            WITH KEY wrno    = <ls_spitem>-spno
                     linenum = lv_lineno
                     counter = 1.
            IF sy-subrc = 0.
              <ls_data>-designqty = lv_designqty.

              READ TABLE lt_accumulatedqty ASSIGNING FIELD-SYMBOL(<ls_accumqty>)
              WITH KEY itemcode = <ls_spitem>-itemcode BINARY SEARCH.
              IF sy-subrc = 0.
                <ls_data>-accumalatedqty = <ls_accumqty>-accumqty.
              ENDIF.

              READ TABLE lt_items ASSIGNING <ls_ekpo>
              WITH KEY itemcode = <ls_spitem>-itemcode BINARY SEARCH.
              IF sy-subrc = 0.
                <ls_data>-designqtyuom = <ls_ekpo>-designqtyuom.
              ENDIF.
            ENDIF.
          ELSE.
            lw_spitem-designqty = lv_designqty.

            READ TABLE lt_accumulatedqty ASSIGNING <ls_accumqty>
            WITH KEY itemcode = <ls_spitem>-itemcode BINARY SEARCH.
            IF sy-subrc = 0.
              lw_spitem-accumalatedqty = <ls_accumqty>-accumqty.
            ENDIF.

            READ TABLE lt_items ASSIGNING <ls_ekpo>
            WITH KEY itemcode = <ls_spitem>-itemcode BINARY SEARCH.
            IF sy-subrc = 0.
              lw_spitem-designqtyuom = <ls_ekpo>-designqtyuom.
            ENDIF.
          ENDIF.
          CLEAR: lv_counter,
                 lv_designqty.
        ENDAT.

        AT END OF costobject.
          APPEND lw_spitem TO et_items.
          CLEAR: lw_spitem.
        ENDAT.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.


  METHOD process_header.
*****************************************************************************
*&  Program Name           : SET_HEADER_ITEMS
*&  Created By             : Kripa S Patil
*&  Created On             : 09.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Header details from UI
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : es_header_ins, es_header_upd.

    DATA : lw_header TYPE ztcu_spheader.
    MOVE-CORRESPONDING is_header TO lw_header ##ENH_OK.

    lw_header-sipstatus     = is_header-sipstatus.
    IF iv_new = abap_true.
      lw_header-createdby = is_header-submittedby.
      lw_header-createdon = sy-datum.
    ELSE.
      SELECT createdby,
             createdon
        UP TO 1 ROWS
        FROM ztcu_spheader
        INTO @DATA(lw_created)
        WHERE spno = @lw_header-spno.
      ENDSELECT.
      IF sy-subrc = 0.
        lw_header-createdby = lw_created-createdby.
        lw_header-createdon = lw_created-createdon.
      ENDIF.
      lw_header-changedby = is_header-submittedby.
      lw_header-changedon = sy-datum.
    ENDIF.

    CASE is_header-category .
      WHEN zif_cu_sip~gc_contract.
      WHEN zif_cu_sip~gc_wr.
        lw_header-wrno        = is_header-wrno.
      WHEN zif_cu_sip~gc_sp.
    ENDCASE.

    IF is_header-operation = zif_cu_sip=>gc_operation-insert.
      es_header_ins = lw_header.
    ELSEIF is_header-operation = zif_cu_sip=>gc_operation-update.
      es_header_upd = lw_header.
    ENDIF.
  ENDMETHOD.


  METHOD process_items.
*****************************************************************************
*&  Program Name           : SET_HEADER_ITEMS
*&  Created By             : Kripa S Patil
*&  Created On             : 08.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Save the changes of header and items
*&  Transport Request No   : D10K934677
*****************************************************************************

    CLEAR : et_item_ins, et_item_upd, et_item_del, ev_amount.

    LOOP AT it_items ASSIGNING FIELD-SYMBOL(<ls_items>).
      IF <ls_items>-operation = zif_cu_sip=>gc_operation-insert.
        APPEND INITIAL LINE TO et_item_ins ASSIGNING FIELD-SYMBOL(<ls_items_sp>).
      ELSEIF <ls_items>-operation = zif_cu_sip=>gc_operation-update.
        APPEND INITIAL LINE TO et_item_upd ASSIGNING <ls_items_sp>.
      ELSEIF <ls_items>-operation = zif_cu_sip=>gc_operation-delete.
        APPEND INITIAL LINE TO et_item_del ASSIGNING <ls_items_sp>.
      ENDIF.
      IF <ls_items_sp> IS ASSIGNED.
        MOVE-CORRESPONDING <ls_items> TO <ls_items_sp>.
        <ls_items_sp>-designqty = <ls_items>-actqty.
        DATA(lv_amt_prev)            = ev_amount.
        ev_amount                    = <ls_items>-netprice * <ls_items>-actqty.
        ev_amount                    = lv_amt_prev + ev_amount.
        <ls_items_sp>-changedby      = iv_submittedby.
        <ls_items_sp>-changedon      = sy-datum.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD set_header_items.
*****************************************************************************
*&  Program Name           : SET_HEADER_ITEMS
*&  Created By             : Kripa S Patil
*&  Created On             : 23.06.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Save the changes of header and items
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA lv_submittedby TYPE uname.

    " populate header fields
    CALL METHOD zclcu_u115_utility=>process_header
      EXPORTING
        is_header     = is_header
        iv_new        = iv_new
      IMPORTING
        es_header_ins = es_header_ins
        es_header_upd = es_header_upd.

    lv_submittedby = is_header-submittedby.

    " populate item fields.
    CALL METHOD zclcu_u115_utility=>process_items
      EXPORTING
        it_items       = it_items
        iv_submittedby = lv_submittedby
      IMPORTING
        et_item_ins    = et_item_ins
        et_item_upd    = et_item_upd
        et_item_del    = et_item_del
        ev_amount      = DATA(lv_amount) ##NEEDED.

  ENDMETHOD.
ENDCLASS.
