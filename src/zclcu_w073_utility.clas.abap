class ZCLCU_W073_UTILITY definition
  public
  final
  create public .

public section.

  interfaces ZIF_CU_SIP .

  class-methods GET_HEADER
    importing
      !IS_HEADER type ZCLCU_SIP_MPC=>TS_HEADERSIPWR
    exporting
      !ET_HEADER type ZCLCU_SIP_MPC=>TT_HEADERSIPWR .
  class-methods GET_ITEMS
    importing
      !IS_ITEM type ZCLCU_SIP_MPC=>TS_ITEM
      !IV_MATERIAL_TYPE type CHAR1 optional
    exporting
      !ET_ITEMS type ZCLCU_SIP_MPC=>TT_ITEM .
  class-methods SET_HEADER_ITEMS
    importing
      !IS_HEADER type ZCLCU_SIP_MPC=>TS_HEADERSIPWR
      !IT_ITEMS type ZCLCU_SIP_MPC=>TT_ITEM
      !IT_ITEMS_INACTIVE type ZCLCU_SIP_MPC=>TT_ITEMINACTIVE optional
      !IV_NEW type BOOLEAN
    exporting
      !ES_HEADER_INS type ZCLCU_SIP_MPC=>TS_HEADERSIPWR
      !ES_HEADER_UPD type ZCLCU_SIP_MPC=>TS_HEADERSIPWR
      !ET_ITEM_INS type ZCLCU_SIP_MPC=>TT_ITEM
      !ET_ITEM_UPD type ZCLCU_SIP_MPC=>TT_ITEM
      !ET_ITEM_DEL type ZCLCU_SIP_MPC=>TT_ITEM .
  class-methods BATCH_PROCESS
    importing
      !IT_DEEP_STRUC type ZTTCU_DEEP_STRUC
      !IV_SIPNO type Z_SIPNO optional
      !IT_MEDIA_SLUG type ZCLCU_SIP_UTILITY=>TY_T_MEDIA_SLUG optional
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR optional
    changing
      !CT_RETURN type BAPIRET2_T optional
      !CT_ATTACH_CS type ZTTCU_ATTACH optional .
  class-methods GET_SIPHEADER
    importing
      !IV_SIPNO type Z_SIPNO
    exporting
      !ET_HEADER type ZCLCU_SIP_MPC=>TT_HEADERSIPWR .
  class-methods GET_SIPITEM
    importing
      !IS_ITEM type ZCLCU_SIP_MPC=>TS_ITEM
    exporting
      !ET_ITEMS type ZCLCU_SIP_MPC=>TT_ITEM .
  class-methods PROCESS_HEADER
    importing
      !IS_HEADER type ZCLCU_SIP_MPC=>TS_HEADERSIPWR
      !IV_NEW type BOOLEAN
    exporting
      !ES_HEADER_INS type ZCLCU_SIP_MPC=>TS_HEADERSIPWR
      !ES_HEADER_UPD type ZCLCU_SIP_MPC=>TS_HEADERSIPWR .
  class-methods PROCESS_ITEMS
    importing
      !IT_ITEMS type ZCLCU_SIP_MPC=>TT_ITEM
      !IT_ITEMS_INACTIVE type ZCLCU_SIP_MPC=>TT_ITEMINACTIVE optional
      !IV_SUBMITTEDBY type UNAME
    exporting
      !ET_ITEM_INS type ZCLCU_SIP_MPC=>TT_ITEM
      !ET_ITEM_UPD type ZCLCU_SIP_MPC=>TT_ITEM
      !ET_ITEM_DEL type ZCLCU_SIP_MPC=>TT_ITEM
      !EV_AMOUNT type Z_SIPAMOUNT .
  class-methods GET_SIP_FPCTICKETS
    importing
      !IV_SIPNO type Z_SIPNO
    exporting
      !ET_SIPFPC type ZTTCU_SIP_FPC .
  class-methods SET_SIP_FPCTICKETS
    importing
      !IT_FPCITEM type ZCLCU_SIP_MPC=>TT_FPCITEM
    exporting
      !ET_FPCITEM_INS type ZCLCU_SIP_MPC=>TT_FPCITEM .
  class-methods GET_FPCITEMS
    importing
      !IS_FPCITEM type ZSCU_SIP_FPC
    exporting
      !ET_FPCITEM type ZTTCU_SIP_FPC .
  class-methods GET_SIPS
    importing
      !IS_SIP type ZCLCU_SIP_MPC=>TS_SIPSEARCHHELP
    exporting
      !ET_SIP type ZCLCU_SIP_MPC=>TT_SIPSEARCHHELP .
  protected section.
private section.
ENDCLASS.



CLASS ZCLCU_W073_UTILITY IMPLEMENTATION.


  METHOD batch_process.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 24.06.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Save the changes of all tabs
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA : lw_items          TYPE zclcu_sip_mpc=>ts_item,
           lw_items_inactive TYPE zclcu_sip_mpc=>ts_iteminactive,
           lw_fpcitems       TYPE zclcu_sip_mpc=>ts_fpcitem,
           lw_header         TYPE zclcu_sip_mpc=>ts_headersipwr,
           lw_attach         TYPE zscu_sip_attach,
           lw_key_tab        TYPE /iwbep/s_mgw_name_value_pair,
           lw_attach_cs      TYPE zclcu_sip_mpc=>ts_attachdocument,
           lt_attach         TYPE zttcu_sip_attach,
           lt_items          TYPE zclcu_sip_mpc=>tt_item,
           lt_items_inactive TYPE zclcu_sip_mpc=>tt_iteminactive,
           lw_routing        TYPE zclcu_sip_mpc=>ts_approvalflow,
           lt_fpcitems       TYPE zclcu_sip_mpc=>tt_fpcitem,
           lt_routing        TYPE zclcu_sip_mpc=>tt_approvalflow
           .


    LOOP AT it_deep_struc ASSIGNING FIELD-SYMBOL(<ls_deep_item>).

      IF <ls_deep_item>-header IS NOT INITIAL AND lw_header IS INITIAL.
        "Header
*        lw_header = <ls_deep_item>-header.
        MOVE-CORRESPONDING <ls_deep_item>-header TO lw_header.
        IF lw_header-sipno IS INITIAL.
          "populate the new SIP created
          lw_header-sipno = iv_sipno.
          DATA(lv_new) = abap_true.
        ENDIF.
      ENDIF.

      "Items
      IF <ls_deep_item>-items IS NOT INITIAL.
*        lw_items = <ls_deep_item>-items .
        MOVE-CORRESPONDING <ls_deep_item>-items TO lw_items.
        IF lw_items-sipno IS INITIAL.
          "populate the new SIP created
          lw_items-sipno = iv_sipno.
        ENDIF.
        "Set the tolerance in header based on item
*        IF lw_header-o = abap_false.
*          IF lw_items-outoftolerance = abap_true.
*            lw_header-outoftolerance = abap_true.
*          ENDIF.
*        ENDIF.

        APPEND lw_items TO lt_items.
        CLEAR : lw_items.
      ENDIF.

      "Inactive Items
      IF <ls_deep_item>-items_inactive IS NOT INITIAL.
*        lw_items_inactive = <ls_deep_item>-items_inactive .
        MOVE-CORRESPONDING <ls_deep_item>-items_inactive TO  lw_items_inactive.
        IF lw_items_inactive-sipno IS INITIAL.
          "populate the new SIP created
          lw_items_inactive-sipno = iv_sipno.
        ENDIF.

        APPEND lw_items_inactive TO lt_items_inactive.
        CLEAR : lw_items_inactive.
      ENDIF.

      "FPC Items
      IF <ls_deep_item>-fpc_item IS NOT INITIAL.
        MOVE-CORRESPONDING <ls_deep_item>-fpc_item TO  lw_fpcitems.
        IF lw_fpcitems-sipno IS INITIAL.
          "populate the new SIP created
          lw_fpcitems-sipno = iv_sipno.
        ENDIF.
        APPEND lw_fpcitems TO lt_fpcitems.
        CLEAR : lw_fpcitems.
      ENDIF.

      "Attachment
      IF <ls_deep_item>-attachheader IS NOT INITIAL.
        lw_attach = <ls_deep_item>-attachheader.
        IF <ls_deep_item>-attachheader-uniqueno IS INITIAL.
          lw_attach-uniqueno = iv_sipno.
        ENDIF.
        APPEND lw_attach TO lt_attach.
        CLEAR : lw_attach.
      ENDIF.

      "Approval flow
      IF <ls_deep_item>-routing IS NOT INITIAL AND lw_routing IS INITIAL.
*        lw_routing = <ls_deep_item>-routing.
        MOVE-CORRESPONDING <ls_deep_item>-routing TO lw_routing.
        IF <ls_deep_item>-routing-uniqueno IS INITIAL.
          lw_routing-sipno = iv_sipno.
        ENDIF.
        APPEND lw_routing TO lt_routing.
        CLEAR : lw_routing.
      ENDIF.

      "Joint Use header(to update poleno and Mcode)
      IF <ls_deep_item>-header_ju IS NOT INITIAL.
        lw_header-poleno = <ls_deep_item>-header_ju-poleno.
        lw_header-mcode = <ls_deep_item>-header_ju-mcode.
      ENDIF.
    ENDLOOP.

    IF lw_header IS NOT INITIAL OR lt_items IS NOT INITIAL.
      "update header and item
      CALL METHOD zclcu_w073_utility=>set_header_items
        EXPORTING
          is_header         = lw_header
          it_items          = lt_items
          it_items_inactive = lt_items_inactive
          iv_new            = lv_new
        IMPORTING
          es_header_ins     = DATA(ls_header_ins)
          es_header_upd     = DATA(ls_header_upd)
          et_item_ins       = DATA(lt_item_ins)
          et_item_upd       = DATA(lt_item_upd)
          et_item_del       = DATA(lt_item_del).

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

    "FPC Items
    IF lt_fpcitems IS NOT INITIAL.
      CALL METHOD zclcu_w073_utility=>set_sip_fpctickets
        EXPORTING
          it_fpcitem     = lt_fpcitems
        IMPORTING
          et_fpcitem_ins = DATA(lt_fpc_items).

    ENDIF.

*    IF lw_header-validate = abap_true.
    CALL METHOD zclcu_sip_utility=>call_invoice_bapi
      EXPORTING
        is_header      = ls_header_ins
        it_items       = lt_item_ins
        iv_testrun     = abap_true
        iv_submittedby = ls_header_ins-submittedby
      IMPORTING
        et_return      = DATA(lt_return).
*    ENDIF.

    READ TABLE lt_return TRANSPORTING NO FIELDS
    WITH KEY type = zif_cu_sip=>gc_error.
    IF sy-subrc <> 0.
      "Call Update task to update the tables
      CALL FUNCTION 'ZCU_UPDATE_SIP'
        EXPORTING
          iv_sipno       = lw_header-sipno
          is_header_ins  = ls_header_ins
          is_header_upd  = ls_header_upd
          it_item_ins    = lt_item_ins
          it_item_upd    = lt_item_upd
          it_item_del    = lt_item_del
          it_routing_ins = lt_routing_ins
          it_routing_upd = lt_routing_upd
          it_routing_del = lt_routing_del
          it_fpcitem_ins = lt_fpc_items
          iv_delete      = abap_true.

      "Create_stream for attachments
      IF it_media_slug IS NOT INITIAL.
        IF it_key_tab IS INITIAL.
          DATA(lt_temp_key_tab) = it_key_tab.
          lw_key_tab-name = 'SipNo'.
          IF lw_header-sipno IS INITIAL.
            lw_key_tab-value = iv_sipno.
          ELSE.
            lw_key_tab-value = lw_header-sipno.
          ENDIF.

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
    ELSE.
      LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<ls_return>)
        WHERE type = zif_cu_sip=>gc_error.
        APPEND INITIAL LINE TO ct_return ASSIGNING FIELD-SYMBOL(<ls_error>).
        <ls_error> = <ls_return>.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD get_fpcitems.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 02.09.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the FPCs related to SIP
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA : lv_sip   TYPE z_sipno,
           lw_items TYPE zclcu_sip_mpc=>ts_item.

    CLEAR: et_fpcitem.

    "If SIPNo is passed
    IF is_fpcitem-sipno IS NOT INITIAL.
      lv_sip = is_fpcitem-sipno.
      CALL METHOD zclcu_w073_utility=>get_sip_fpctickets
        EXPORTING
          iv_sipno  = lv_sip
        IMPORTING
          et_sipfpc = et_fpcitem.
    ELSE.
      MOVE-CORRESPONDING is_fpcitem TO lw_items ##ENH_OK.
      CALL METHOD zclcu_w076_utility=>get_approved_tktitems
        EXPORTING
          is_item  = lw_items
        IMPORTING
          et_items = DATA(lt_item).

      LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
        APPEND INITIAL LINE TO et_fpcitem ASSIGNING FIELD-SYMBOL(<ls_fpc>).
        CLEAR : <ls_fpc>.
        MOVE-CORRESPONDING <ls_item> TO <ls_fpc> ##ENH_OK.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_header.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the header details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_header.

    IF is_header-sipno IS NOT INITIAL.
      " CALL METHOD GET from sip header
      CALL METHOD zclcu_w073_utility=>get_sipheader
        EXPORTING
          iv_sipno  = is_header-sipno
        IMPORTING
          et_header = et_header.

    ELSE.
      IF is_header-appindicator = 'I'.
        " Get Header details based om SIP category
        CALL METHOD zclcu_sip_utility=>get_header
          EXPORTING
            is_header = is_header
          IMPORTING
            et_header = et_header.

      ENDIF.
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
    DATA lt_item_output TYPE zclcu_sip_mpc=>tt_item.

    CLEAR et_items.

    IF is_item-sipno IS NOT INITIAL.
      "Get Item details From SIP Item table
      CALL METHOD zclcu_w073_utility=>get_sipitem
        EXPORTING
          is_item  = is_item
        IMPORTING
          et_items = lt_item_output.


      SELECT SINGLE sipstatus, fpcflag
        FROM ztcu_sipheader INTO @DATA(lw_fpc)
            WHERE sipno = @is_item-sipno.

      IF lw_fpc-fpcflag = abap_true AND lw_fpc-sipstatus = 'D'
        AND lt_item_output IS NOT INITIAL.

        DATA(ls_item) = is_item.
        CLEAR : ls_item-sipno.
        "GET_TICKETS method
        CALL METHOD zclcu_w076_utility=>get_approved_tktitems
          EXPORTING
            is_item  = ls_item
          IMPORTING
            et_items = DATA(lt_items).

        LOOP AT lt_items INTO DATA(ls_items).
          READ TABLE lt_item_output ASSIGNING FIELD-SYMBOL(<fs_items>) WITH KEY
                                material = ls_items-material.
          IF sy-subrc = 0.
            <fs_items>-ACTUALQTY = <fs_items>-ACTUALQTY + ls_items-ACTUALQTY.
            <fs_items>-originalqty = <fs_items>-ACTUALQTY.
            CONTINUE.
          ELSE.
            ls_items-counter = '1'.
            SHIFT ls_items-counter LEFT DELETING LEADING '0'.
            APPEND ls_items TO lt_item_output.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ELSE.
      " Get Item details from Source
      IF is_item-appindicator = 'I'.
        CALL METHOD zclcu_sip_utility=>get_items
          EXPORTING
            is_item  = is_item
          IMPORTING
            et_items = lt_item_output.

        "Price will be calculated based on tiered prices in UI
        LOOP AT lt_item_output ASSIGNING FIELD-SYMBOL(<ls_item_output>).
          CLEAR: <ls_item_output>-netprice,
                 <ls_item_output>-totalprice.
        ENDLOOP.

        "Get Item details from Ticketing table
      ELSEIF is_item-appindicator = 'T'.
        "GET_TICKETS method
        CALL METHOD zclcu_w076_utility=>get_approved_tktitems
          EXPORTING
            is_item  = is_item
          IMPORTING
            et_items = lt_item_output.

      ENDIF.
    ENDIF.
    DATA(lt_itm) = lt_item_output.
    "Check the materials has JU materials linked and get unit type (sy/se/bo)
    CALL METHOD zclcu_sip_utility=>get_judetails
      EXPORTING
        it_items = lt_itm
      IMPORTING
        et_items = lt_item_output.

    "Classify Active and Inactive Materials
    CALL METHOD zclcu_sip_utility=>classify_materials(
      EXPORTING
        iv_sipno    = is_item-sipno
        iv_contract = is_item-contract
        iv_spno     = is_item-spno
      CHANGING
        ct_items    = lt_item_output ).

    IF iv_material_type = zif_cu_sip=>gc_active_materials. "Active Materials
      DELETE lt_item_output WHERE inactive IS NOT INITIAL.
    ELSEIF iv_material_type = zif_cu_sip=>gc_inactive_materials. "Inactive Materials
      DELETE lt_item_output WHERE inactive IS INITIAL.
    ENDIF.

    et_items = lt_item_output.

  ENDMETHOD.


  METHOD get_sipheader.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the header details from SIP table
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lt_param TYPE zttca_param.

    CONSTANTS: lc_code_group TYPE qmsm-mngrp VALUE 'MX-M',
               lc_task_code  TYPE qmsm-mncod VALUE 'PROJ'.

    CLEAR et_header.

    SELECT  a~sipno,
            a~sipdescr,
            a~wrno,
            c~wrdesc,
            c~source,
            c~woid,
            c~novellid,
            c~projectowner,
            c~pmoperation,
            c~township,
            c~permit_no,
            c~wrtype,
            c~wosubtype,
            c~bussunit,
            a~spno,
            d~spdescr,
            a~ticketno,
            e~tktdescr,
            a~wrdate,
            a~supplier,
            a~supplierid,
            a~suppliercompany,
            b~name1,
            b~regio,
            b~txjcd,
            a~contract,
            a~planneddate,
            a~completiondate,
            a~submittedby,
            a~amount,
            a~sipstatus,
            a~invoice,
            a~final,
            a~plant,
            f~name1 AS plantdesc,
            a~addrline1,
            a~addrline2,
            a~city,
            a~state,
            a~country,
            a~postalcode,
            a~project,
            a~projdesc,
            a~coflag,
            a~costobject,
            a~fpcflag,
            a~tolerance,
            a~category,
            a~totalextendprice,
            a~nontaxableamt,
            a~taxableamt,
            a~totaltax,
            a~invoiceamt,
            a~juflag,
            a~extwrno
        FROM ztcu_sipheader AS a
        LEFT OUTER JOIN lfa1 AS b
        ON a~suppliercompany = b~lifnr
        LEFT OUTER JOIN ztcu_wrheader AS c
        ON a~wrno = c~wrno
        LEFT OUTER JOIN ztcu_spheader AS d
        ON a~spno = d~spno
        LEFT OUTER JOIN ztcu_tktheader AS e
        ON a~ticketno = e~ticketno
        LEFT OUTER JOIN t001w AS f "#EC CI_CMPLX_WHERE "#EC CI_BUFFJOIN
        ON a~plant = f~werks
        UP TO 1 ROWS
        INTO @DATA(lw_sipheader)
        WHERE a~sipno = @iv_sipno.
    ENDSELECT.
    IF sy-subrc = 0.
      "Get the vendor name
      IF lw_sipheader-suppliercompany IS INITIAL.
        SELECT a~lifnr,
               a~name1,
               a~regio,
               a~txjcd
          FROM lfa1 AS a
          INNER JOIN ekko AS b
                    ON a~lifnr = b~lifnr
                    INTO @DATA(lw_vend_name)
          UP TO 1 ROWS
          WHERE b~ebeln = @lw_sipheader-contract.
        ENDSELECT.
        IF sy-subrc <> 0.
          CLEAR lw_vend_name.
        ENDIF.
      ELSE.
        lw_vend_name-lifnr = lw_sipheader-suppliercompany.
        lw_vend_name-name1 = lw_sipheader-name1.
        lw_vend_name-regio = lw_sipheader-regio.
        lw_vend_name-txjcd = lw_sipheader-txjcd.
      ENDIF.

      IF lw_sipheader-category = 'W' AND
         ( lw_sipheader-source = zif_cu_sip=>gc_source-maximo OR
           lw_sipheader-source = zif_cu_sip=>gc_source-maximo_lower ).
        "Get Project WO for Maximo
        SELECT a~qmnum,
               b~matxt
          UP TO 1 ROWS
          FROM qmel AS a
          INNER JOIN qmsm AS b
          ON a~qmnum = b~qmnum
          INTO @DATA(ls_matxt)
          WHERE a~aufnr = @lw_sipheader-woid AND
                b~mngrp = @lc_code_group AND
                b~mncod = @lc_task_code.
        ENDSELECT.
        IF sy-subrc = 0.
          "Get Project Description and Project Phase
          SELECT SINGLE aufnr,
                 ktext
*                 zzsmp_phase
            FROM aufk
            INTO @DATA(ls_aufk)
            WHERE aufnr = @ls_matxt-matxt.
          IF sy-subrc <> 0.
            CLEAR ls_aufk.
          ENDIF.
        ENDIF.

        "Get company code for which Dig fields will be visible
        NEW zcl_ca_utility( )->get_parameter(
        EXPORTING
          i_busproc           = 'CU'             " Business Process
          i_busact            = 'TECH'           " Business Activity
          i_validdate         = sy-datum         " Parameter Validity Start Date
          i_param             = 'CCODE_MAXIMO'
        CHANGING
          t_param             = lt_param         " Parameter value
        EXCEPTIONS
          invalid_busprocess  = 1                " Invalid Business Process
          invalid_busactivity = 2                " Invalid Business Activity
          OTHERS              = 3
       ).
      ENDIF.

      APPEND INITIAL LINE TO et_header ASSIGNING FIELD-SYMBOL(<ls_header>).
      MOVE-CORRESPONDING lw_sipheader TO <ls_header> ##ENH_OK.
      <ls_header>-suppliercompany     = lw_vend_name-lifnr.
      <ls_header>-suppliercompanyname = lw_vend_name-name1.
*      <ls_header>-regio               = lw_vend_name-regio.
*      <ls_header>-txjcd               = lw_vend_name-txjcd.
      <ls_header>-coflag              = lw_sipheader-coflag.
      IF <ls_header>-contract IS NOT INITIAL.
        CALL METHOD zclcu_sip_utility=>get_contract_description
          EXPORTING
            iv_contract    = <ls_header>-contract
          IMPORTING
            ev_description = DATA(lv_descr).
        <ls_header>-contractdescr = lv_descr.
      ENDIF.
      IF <ls_header>-novelid IS NOT INITIAL.
        CALL METHOD zclcu_sip_utility=>get_name
          EXPORTING
            iv_userid = <ls_header>-novelid
          IMPORTING
            ev_name   = <ls_header>-novelidname.
      ENDIF.
      IF <ls_header>-supplier IS NOT INITIAL.
        CALL METHOD zclcu_sip_utility=>get_name
          EXPORTING
            iv_userid = <ls_header>-supplier
          IMPORTING
            ev_name   = <ls_header>-suppliername.
      ENDIF.

      "WR - Maximo fields
      IF lw_sipheader-source = zif_cu_sip=>gc_source-maximo OR
         lw_sipheader-source = zif_cu_sip=>gc_source-maximo_lower.

        <ls_header>-maximo       = abap_true.
        <ls_header>-projectwo    = ls_matxt-matxt.
        <ls_header>-projectdescr = ls_aufk-ktext.
*        <ls_header>-projectphase = ls_aufk-zzsmp_phase.

        IF <ls_header>-projectowner IS NOT INITIAL.
          CALL METHOD zclcu_sip_utility=>get_name
            EXPORTING
              iv_userid = <ls_header>-projectowner
            IMPORTING
              ev_name   = <ls_header>-projectownername.
        ENDIF.

        IF lw_sipheader-wrtype = zif_cu_sip=>gc_restoration-restor_lower OR
           lw_sipheader-wrtype = zif_cu_sip=>gc_restoration-restor_upper.
          <ls_header>-restoration = abap_true.

          READ TABLE lt_param TRANSPORTING NO FIELDS
          WITH KEY value = lw_sipheader-bussunit.
          IF sy-subrc = 0.
            <ls_header>-digvisible = abap_true.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_sipitem.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Item details from SIP table
*&  Transport Request No   : D10K934677
*****************************************************************************
    TYPES: BEGIN OF ty_accumqty,
             itemcode TYPE ztcu_sipitem-itemcode,
             accumqty TYPE z_accumalatedqty,
           END OF ty_accumqty.

    DATA: lt_accumqty TYPE STANDARD TABLE OF ty_accumqty,
          lt_param    TYPE zttca_param,
          ls_accumqty TYPE ty_accumqty,
          ls_spitem   TYPE zcl_zcu_u115_sp_mpc=>ts_item,
          ls_writem   TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_item,
          lv_clause   TYPE string,
          lv_netpr    TYPE zscu_item-netprice,
          lv_counter  TYPE boolean.

    CONSTANTS: lc_quote TYPE char1 VALUE ''''.

    CLEAR et_items.

    " dynamic where condition
    CASE is_item-category.
      WHEN 'C'.
        "Call method contract item
        CALL METHOD zclcu_sip_utility=>get_contractitem
          EXPORTING
            iv_contract     = is_item-contract
            iv_appindicator = is_item-appindicator
          IMPORTING
            et_items        = DATA(lt_items).
        SORT lt_items BY itemcode.
      WHEN 'S' .
        ls_spitem-spno         = is_item-spno.
        ls_spitem-appindicator = is_item-appindicator.
        CALL METHOD zclcu_u115_utility=>get_items
          EXPORTING
            is_item  = ls_spitem
          IMPORTING
            et_items = DATA(lt_spitems).
        IF lt_spitems IS NOT INITIAL.
          DELETE lt_spitems WHERE parentlineno IS NOT INITIAL.
          SORT lt_spitems BY spno material.
        ENDIF.
      WHEN 'W'.
        ls_writem-wrno         = is_item-workrequestno.
        ls_writem-contract     = is_item-contract.
        ls_writem-appindicator = is_item-appindicator.
*        Comment Om
*        CALL METHOD zclcu_sip_sourcewr=>get_wr_item
*          EXPORTING
*            is_item = ls_writem
*          IMPORTING
*            et_data = DATA(lt_writems).
*        IF lt_writems IS NOT INITIAL.
*          DELETE lt_writems WHERE parentlineno IS NOT INITIAL.
*          SORT lt_writems BY wrno itemcode.
*        ENDIF.
    ENDCASE.

    "Get the date from which tiered pricing changes are effective
    NEW zcl_ca_utility( )->get_parameter(
     EXPORTING
       i_busproc           = 'CU'             " Business Process
       i_busact            = 'TECH'           " Business Activity
       i_validdate         = sy-datum         " Parameter Validity Start Date
       i_param             = 'TIER_EFFECT'
     CHANGING
       t_param             = lt_param         " Parameter value
     EXCEPTIONS
       invalid_busprocess  = 1                " Invalid Business Process
       invalid_busactivity = 2                " Invalid Business Activity
       OTHERS              = 3
    ).

    "Get the tiered pricing info from contract
    zclcu_sip_utility=>get_tier_prices(
      EXPORTING
        iv_contract   = is_item-contract                 " Purchasing Document Number
      IMPORTING
        et_tier_price = DATA(lt_tier_price)              " Tier Price - Table type
    ).

    IF lt_param IS NOT INITIAL.
      DATA(lv_tier_effective) = lt_param[ 1 ]-value.
    ENDIF.

    "Fetch all the SIP's for the contract
    SELECT a~sipno,
      a~sipstatus,
      a~createdon,
      a~changedon,
      b~linenum,
      b~type,
      b~itemcode,
      b~actqty,
      b~costobject,
      b~counter,
      b~originalqty,
      b~netprice,
      b~totalprice,
      b~activity1,
      b~activity2,
      b~coflag,
      b~tax,
      b~inactive,
      a~category
*      b~splitindicator
      FROM ztcu_sipheader AS a
      INNER JOIN ztcu_sipitem AS b                     "#EC CI_DYNWHERE
      ON a~sipno = b~sipno
      INTO TABLE @DATA(lt_sipitem)
      WHERE a~sipno = @is_item-sipno.
    IF sy-subrc = 0.
      SORT lt_sipitem BY sipno linenum counter.

      IF is_item-category NE 'C'.
        CALL METHOD zclcu_sip_utility=>get_contractitem
          EXPORTING
            iv_contract     = is_item-contract
            iv_wrno         = is_item-workrequestno
            iv_spno         = is_item-spno
            iv_appindicator = is_item-appindicator
          IMPORTING
            et_items        = DATA(lt_contract).
        SORT lt_contract BY itemcode.
      ENDIF.

      "Build the output table
      LOOP AT lt_sipitem ASSIGNING FIELD-SYMBOL(<ls_sipitem>).
        APPEND INITIAL LINE TO et_items ASSIGNING FIELD-SYMBOL(<ls_item>).
        <ls_item>-sipno            = <ls_sipitem>-sipno.
        <ls_item>-type             = <ls_sipitem>-type.
        <ls_item>-material         = <ls_sipitem>-itemcode.
        <ls_item>-actualqty           = <ls_sipitem>-actqty.
        <ls_item>-tax              = <ls_sipitem>-tax.
        <ls_item>-counter          = <ls_sipitem>-counter.
        <ls_item>-inactive         = <ls_sipitem>-inactive.
*        <ls_item>-splitindicator   = <ls_sipitem>-splitindicator.
        SHIFT  <ls_item>-counter LEFT DELETING LEADING '0'.
        <ls_item>-linenum          = <ls_sipitem>-linenum.
        IF <ls_item>-linenum IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = <ls_item>-linenum
            IMPORTING
              output = <ls_item>-linenum.
        ENDIF.
        SHIFT <ls_item>-linenum LEFT DELETING LEADING '0'.

        "Tiered Price
        IF <ls_sipitem>-changedon IS INITIAL.
          DATA(lv_modif) = <ls_sipitem>-createdon.
        ELSE.
          lv_modif = <ls_sipitem>-changedon.
        ENDIF.

        "Calculate tiered price from contract for SIP's in draft or
        "SIP's created befor param entry
        IF lv_modif LE lv_tier_effective OR
           <ls_sipitem>-sipstatus = 'D'.
          IF <ls_sipitem>-counter = 1.
            CLEAR: lv_netpr,
                   lv_counter.

            LOOP AT lt_tier_price ASSIGNING FIELD-SYMBOL(<ls_tier_price>)
            WHERE itemcode = <ls_sipitem>-itemcode.
              IF lv_counter IS INITIAL..
                <ls_item>-netprice = <ls_tier_price>-amount.
              ENDIF.

              IF <ls_tier_price>-scalequantity = '0.00'.
                EXIT.
              ELSE.
                IF <ls_sipitem>-originalqty LT <ls_tier_price>-scalequantity.
                  EXIT.
                ELSE.
                  <ls_item>-netprice = <ls_tier_price>-amount.
                ENDIF.
              ENDIF.

              lv_counter = abap_true.
            ENDLOOP.

            "Store the netprice for counter 1 or parent line items
            lv_netpr = <ls_item>-netprice.
          ELSE.

            "For split items get netprice of parent line item
            <ls_item>-netprice = lv_netpr.
          ENDIF.
        ELSE.

          "For items other than draft and SIP's created after param entry
          "get netprice directly from SIPITEM table
          <ls_item>-netprice = <ls_sipitem>-netprice.
        ENDIF.

        <ls_item>-totalprice       = <ls_item>-netprice * <ls_item>-actualqty.
        <ls_item>-category         = is_item-category.
        <ls_item>-contract         = is_item-contract.
        IF <ls_sipitem>-activity1 IS NOT INITIAL AND
           <ls_sipitem>-activity2 IS NOT INITIAL.
          CONCATENATE <ls_sipitem>-activity1 <ls_sipitem>-activity2
          INTO <ls_item>-activity SEPARATED BY '-'.
        ENDIF.
        <ls_item>-costobject       = <ls_sipitem>-costobject.
        <ls_item>-cotype           = <ls_sipitem>-coflag.  "Cost object type
        IF <ls_sipitem>-counter = '1'.
          <ls_item>-originalqty = <ls_sipitem>-originalqty.
        ENDIF.

        CASE is_item-category.
          WHEN 'C'.
            READ TABLE lt_items ASSIGNING FIELD-SYMBOL(<ls_ekpo>)
            WITH KEY itemcode = <ls_sipitem>-itemcode
                     loekz    = space.
            IF sy-subrc <> 0.
              READ TABLE lt_items ASSIGNING <ls_ekpo>
              WITH KEY itemcode = <ls_sipitem>-itemcode BINARY SEARCH.
              IF sy-subrc <> 0.
                UNASSIGN <ls_ekpo>.
              ENDIF.
            ENDIF.
            IF <ls_ekpo> IS ASSIGNED.
              <ls_item>-materialdescr      = <ls_ekpo>-itemdescr.
              <ls_item>-designedqty      = <ls_ekpo>-designqty.
*              <ls_item>-d   = <ls_ekpo>-designqtyuom.
              <ls_item>-accumalatedqty = <ls_ekpo>-accumalatedqty.
            ENDIF.
          WHEN 'S'.
            READ TABLE lt_spitems ASSIGNING FIELD-SYMBOL(<ls_spitems>)
            WITH KEY spno = is_item-spno
                     material = <ls_sipitem>-itemcode BINARY SEARCH.
            IF sy-subrc = 0.
              <ls_item>-materialdescr      = <ls_spitems>-material.
              <ls_item>-designedqty      = <ls_spitems>-designedqty .                 "actqty.
*              <ls_item>-designqtyuom   = <ls_spitems>-designqtyuom.              "actqtyuom.
              <ls_item>-accumalatedqty = <ls_spitems>-accumalatedqty.
            ELSE.
              DATA(lv_contract)        = abap_true.
              <ls_item>-deletionind    = abap_true.
            ENDIF.
          WHEN 'W'.
*            Comment Om
*            READ TABLE lt_writems ASSIGNING FIELD-SYMBOL(<ls_writems>)
*            WITH KEY wrno = is_item-wrno
*                     material = <ls_sipitem>-itemcode BINARY SEARCH.
*            IF sy-subrc = 0.
*              <ls_item>-itemdescr      = <ls_writems>-itemdescr.
*              <ls_item>-designqty      = <ls_writems>-designqty.
*              <ls_item>-designqtyuom   = <ls_writems>-designqtyuom.
*              <ls_item>-accumalatedqty = <ls_writems>-accumalatedqty.
*              <ls_item>-maximo         = <ls_writems>-maximo.
*            ELSE.
*              lv_contract              = abap_true.
*              <ls_item>-deletionind    = abap_true.
*            ENDIF.
        ENDCASE.

        IF lv_contract = abap_true.
          READ TABLE lt_contract ASSIGNING <ls_ekpo>
          WITH KEY itemcode = <ls_sipitem>-itemcode
                   loekz    = space.
          IF sy-subrc <> 0.
            READ TABLE lt_contract
             ASSIGNING <ls_ekpo>
            WITH KEY itemcode = <ls_sipitem>-itemcode BINARY SEARCH.
            IF sy-subrc <> 0.
              UNASSIGN <ls_ekpo>.
            ENDIF.
          ENDIF.
          IF <ls_ekpo> IS ASSIGNED.
            <ls_item>-materialdescr     = <ls_ekpo>-itemdescr.
*            <ls_item>-designqtyuom   = <ls_ekpo>-designqtyuom.
            <ls_item>-accumalatedqty = <ls_ekpo>-accumalatedqty.
          ENDIF.
        ENDIF.
        CLEAR lv_contract.
      ENDLOOP.

      SORT et_items BY linenum counter ASCENDING.
    ENDIF.

  ENDMETHOD.


  METHOD get_sips.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi K
*&  Created On             : 02.09.2020
*&  Functional Design Name : W073 - SIP Application
*&  Purpose                : Get previous SIP's for a Contract or WR or SP
*&  Transport Request No   : D10K934677
*****************************************************************************
    IF is_sip-category = 'C' AND
       is_sip-contract IS NOT INITIAL.
      SELECT * FROM ztcu_sipheader
        INTO TABLE @DATA(et_sip1)
        WHERE contract = @is_sip-contract AND
              category = @is_sip-category.
      IF sy-subrc <> 0.
        CLEAR et_sip.
      ENDIF.

    ELSEIF is_sip-category = 'S' AND
           is_sip-spno IS NOT INITIAL.
      SELECT * FROM ztcu_sipheader
        INTO TABLE @et_sip1
        WHERE spno     = @is_sip-spno AND
              category = @is_sip-category.
      IF sy-subrc <> 0.
        CLEAR et_sip.
      ENDIF.

    ELSEIF is_sip-category = 'W' AND
           is_sip-wrno IS NOT INITIAL.
      SELECT * FROM ztcu_sipheader
        INTO TABLE @et_sip1
        WHERE wrno = @is_sip-wrno AND
              category = @is_sip-category.
      IF sy-subrc <> 0.
        CLEAR et_sip.
      ENDIF.

    ELSEIF is_sip-createdby IS NOT INITIAL AND
           is_sip-sipstatus IS NOT INITIAL.
      SELECT * FROM ztcu_sipheader
      INTO TABLE @et_sip1
      WHERE sipstatus = @is_sip-sipstatus AND
            submittedby = @is_sip-createdby.
      IF sy-subrc <> 0.
        CLEAR et_sip.
      ENDIF.

    ELSEIF is_sip-sipno IS NOT INITIAL.
      SELECT * FROM ztcu_sipheader
      INTO TABLE @et_sip1
      WHERE sipno = @is_sip-sipno.
      IF sy-subrc <> 0.
        CLEAR et_sip.
      ENDIF.
    ENDIF.

    MOVE-CORRESPONDING et_sip1 TO et_sip.


  ENDMETHOD.


  METHOD get_sip_fpctickets.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 02.09.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the FPCs related to SIP
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR: et_sipfpc.

    "Get the FPCs related to SIP
    SELECT a~sipno,
           a~ticketno,
           b~tktdescr,  "ticket desc
           b~completiondate,
           b~sipstatus
      FROM ztcu_sip_fpcmap AS a
      INNER JOIN ztcu_tktheader AS b
      ON a~ticketno = b~ticketno
      INTO TABLE @DATA(lt_sipfpc)
      WHERE a~sipno = @iv_sipno.

    IF sy-subrc EQ 0.
      SORT lt_sipfpc BY sipno ticketno.
      LOOP AT lt_sipfpc ASSIGNING FIELD-SYMBOL(<ls_siptkt>).
        APPEND INITIAL LINE TO et_sipfpc ASSIGNING FIELD-SYMBOL(<ls_data>).
        CLEAR : <ls_data>.
        MOVE-CORRESPONDING <ls_siptkt> TO <ls_data>.
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
    DATA ls_header TYPE zclcu_sip_mpc=>ts_headersipwr.

    CLEAR: es_header_ins,
           es_header_upd.

    "population
    MOVE-CORRESPONDING is_header TO ls_header ##ENH_OK.

    IF ls_header-status IS INITIAL.
      IF is_header-operation = zif_cu_sip=>gc_operation-insert.
        ls_header-status     = zif_cu_sip=>gc_sipstatus-inprogress.
      ENDIF.
    ELSE.
      "If 'C', change it to 'I' as it will be marked to completed in BPM
      IF ls_header-status = zif_cu_sip=>gc_sipstatus-completed.
        ls_header-status  = zif_cu_sip=>gc_sipstatus-inprogress.
      ENDIF.
    ENDIF.

    IF is_header-appindicator = 'I'.
      CASE is_header-category .
        WHEN zif_cu_sip~gc_wr.
          ls_header-workrequestno        = is_header-workrequestno.
          ls_header-wrdate      = is_header-wrdate.

          "Populate vendor from contract if initial
          IF ls_header-suppliercompany IS INITIAL.
            SELECT SINGLE lifnr
              FROM ekko
              INTO @ls_header-suppliercompany
              WHERE ebeln = @ls_header-contract.
            IF sy-subrc <> 0.
              CLEAR ls_header-suppliercompany.
            ENDIF.
          ENDIF.
        WHEN zif_cu_sip~gc_sp.
          ls_header-spno        = is_header-spno.
      ENDCASE.
    ELSEIF is_header-appindicator = 'T'.
      ls_header-ticketno = is_header-ticketno.
    ENDIF.

    IF iv_new = abap_true.
*      ls_header-created = is_header-submittedby.
*      ls_header-createdon = sy-datum.
    ELSE.
      SELECT createdby,
             createdon
        UP TO 1 ROWS
        FROM ztcu_sipheader
        INTO @DATA(lw_created)
        WHERE sipno = @ls_header-sipno.
      ENDSELECT.
      IF sy-subrc = 0.
*        ls_header-createdby = lw_created-createdby.
*        ls_header-createdon = lw_created-createdon.
      ENDIF.
*      ls_header-changedby = is_header-submittedby.
*      ls_header-changedon = sy-datum.

    ENDIF.

    IF is_header-operation = zif_cu_sip=>gc_operation-insert.
      es_header_ins = ls_header.
    ELSEIF is_header-operation = zif_cu_sip=>gc_operation-update.
      es_header_upd = ls_header.
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
    DATA: lv_amount       TYPE z_sipamount,
          lv_total_amount TYPE z_sipamount,
          lv_linenum      TYPE z_linenum,
          lv_prevlinenum  TYPE z_linenum.

    CLEAR: et_item_ins,
           et_item_upd,
           et_item_del.

    "Units tab
    LOOP AT it_items ASSIGNING FIELD-SYMBOL(<ls_items>).
      IF <ls_items>-operation = zif_cu_sip=>gc_operation-insert.
        APPEND INITIAL LINE TO et_item_ins ASSIGNING FIELD-SYMBOL(<ls_items_sip>).
      ELSEIF <ls_items>-operation = zif_cu_sip=>gc_operation-update.
        APPEND INITIAL LINE TO et_item_upd ASSIGNING <ls_items_sip>.
      ELSEIF <ls_items>-operation = zif_cu_sip=>gc_operation-delete.
        APPEND INITIAL LINE TO et_item_del ASSIGNING <ls_items_sip>.
      ENDIF.
      IF <ls_items_sip> IS ASSIGNED.
        MOVE-CORRESPONDING <ls_items> TO <ls_items_sip> ##ENH_OK.
        IF <ls_items_sip>-counter = '1'.
          <ls_items_sip>-originalqty = <ls_items>-originalqty.
        ELSE.
          CLEAR: <ls_items_sip>-originalqty.
        ENDIF.

        lv_amount              = <ls_items>-netprice * <ls_items>-actualqty.
        lv_total_amount        = lv_total_amount + lv_amount.

        IF <ls_items>-activity IS NOT INITIAL.
          SPLIT <ls_items>-activity AT '-' INTO <ls_items_sip>-activity <ls_items_sip>-activity.
        ENDIF.
        <ls_items_sip>-type      = 'S'.
        <ls_items_sip>-operation = <ls_items>-operation.
*        <ls_items_sip>-changedby = iv_submittedby.
*        <ls_items_sip>-changedon = sy-datum.
      ENDIF.
      CLEAR: lv_amount.
    ENDLOOP.

    IF it_items_inactive IS NOT INITIAL.
      IF it_items IS NOT INITIAL.
        DATA(lt_itemsactive) = it_items.
        SORT lt_itemsactive BY linenum DESCENDING.
        lv_linenum = lt_itemsactive[ 1 ]-linenum.
      ENDIF.
      lv_linenum = lv_linenum + 10.

      DATA(lt_itemsinactive) = it_items_inactive.
      SORT lt_itemsinactive BY linenum counter.
      "Inactive tab
      LOOP AT lt_itemsinactive ASSIGNING FIELD-SYMBOL(<ls_items_inactive>).
        IF <ls_items_inactive>-operation = zif_cu_sip=>gc_operation-insert.
          APPEND INITIAL LINE TO et_item_ins ASSIGNING <ls_items_sip>.
        ELSEIF <ls_items_inactive>-operation = zif_cu_sip=>gc_operation-update.
          APPEND INITIAL LINE TO et_item_upd ASSIGNING <ls_items_sip>.
        ELSEIF <ls_items_inactive>-operation = zif_cu_sip=>gc_operation-delete.
          APPEND INITIAL LINE TO et_item_del ASSIGNING <ls_items_sip>.
        ENDIF.
        IF <ls_items_sip> IS ASSIGNED.
          MOVE-CORRESPONDING <ls_items_inactive> TO <ls_items_sip> ##ENH_OK.
          IF <ls_items_sip>-counter = 1.
            <ls_items_sip>-linenum   = lv_linenum.
          ELSE.
            <ls_items_sip>-linenum   = lv_prevlinenum.
          ENDIF.
          <ls_items_sip>-type      = 'S'.
          <ls_items_sip>-operation = <ls_items>-operation.
*          <ls_items_sip>-changedby = iv_submittedby.
*          <ls_items_sip>-changedon = sy-datum.
        ENDIF.

        lv_prevlinenum = <ls_items_sip>-linenum.
        lv_linenum     = lv_prevlinenum + 10.
      ENDLOOP.
    ENDIF.

    ev_amount = lv_total_amount.
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
    CALL METHOD zclcu_w073_utility=>process_header
      EXPORTING
        is_header     = is_header
        iv_new        = iv_new
      IMPORTING
        es_header_ins = es_header_ins
        es_header_upd = es_header_upd.

    lv_submittedby = is_header-submittedby.

    " populate item fields.
    CALL METHOD zclcu_w073_utility=>process_items
      EXPORTING
        it_items          = it_items
        it_items_inactive = it_items_inactive
        iv_submittedby    = lv_submittedby
      IMPORTING
        et_item_ins       = et_item_ins
        et_item_upd       = et_item_upd
        et_item_del       = et_item_del
        ev_amount         = DATA(lv_amount).

    " populate amount to the header
    IF is_header-operation = zif_cu_sip=>gc_operation-insert.
      es_header_ins-amount = lv_amount.
    ELSEIF is_header-operation = zif_cu_sip=>gc_operation-update.
      es_header_upd-amount = lv_amount.
    ENDIF.

  ENDMETHOD.


  METHOD set_sip_fpctickets.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 02.09.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Update FPC mapping table
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR: et_fpcitem_ins.

    "process FPC items

    LOOP AT it_fpcitem ASSIGNING FIELD-SYMBOL(<ls_fpc>).
      APPEND INITIAL LINE TO et_fpcitem_ins ASSIGNING FIELD-SYMBOL(<ls_item>).
      CLEAR : <ls_item>.
      MOVE-CORRESPONDING <ls_fpc> to <ls_item>.
      <ls_item>-createdby = sy-uname.
*      <ls_item>-createdon = sy-datum.
*      <ls_item>-changedon = sy-datum.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
