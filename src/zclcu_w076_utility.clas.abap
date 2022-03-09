class ZCLCU_W076_UTILITY definition
  public
  final
  create public .

public section.

  interfaces ZIF_CU_SIP .

  types:
    gtt_tktitem TYPE STANDARD TABLE OF ztcu_tktitem .

  class-methods GET_HEADER
    importing
      !IS_HEADER type ZCL_ZSIP_W076_MPC=>TS_HEADER
    exporting
      !ET_HEADER type ZCL_ZSIP_W076_MPC=>TT_HEADER .
  class-methods GET_ITEMS
    importing
      !IS_ITEM type ZCL_ZSIP_W076_MPC=>TS_ITEM
      !IV_MATERIAL_TYPE type CHAR1 optional
    exporting
      !ET_ITEMS type ZCL_ZSIP_W076_MPC=>TT_ITEM .
  class-methods SET_HEADER_ITEMS
    importing
      !IS_HEADER type ZCL_ZCU_W076_SIP_TICKE_MPC=>TS_HEADER optional
      !IT_ITEMS type ZCL_ZCU_W076_SIP_TICKE_MPC=>TT_ITEM optional
      !IT_ITEMS_INACTIVE type ZCL_ZCU_W076_SIP_TICKE_MPC=>TT_ITEMINACTIVE optional
      !IV_NEW type BOOLEAN
    exporting
      !ES_HEADER_INS type ZTCU_TKTHEADER
      !ES_HEADER_UPD type ZTCU_TKTHEADER
      !ET_ITEMS_INS type ZTTCU_TKTITEM
      !ET_ITEMS_UPD type ZTTCU_TKTITEM
      !ET_ITEMS_DEL type ZTTCU_TKTITEM .
  class-methods BATCH_PROCESS
    importing
      !IT_DEEP_STRUC type ZTTCU_DEEP_STRUC
      !IV_TKTNO type Z_TICKETNO optional
      !IT_MEDIA_SLUG type ZCLCU_SIP_UTILITY=>TY_T_MEDIA_SLUG optional
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR optional
    changing
      !CT_ATTACH_CS type ZCL_ZCU_W076_SIP_TICKE_MPC=>TT_ATTACHDOCUMENT optional
      !CT_RETURN type BAPIRET2_T optional .
  class-methods GET_TKTHEADER
    importing
      !IS_HEADER type ZCL_ZCU_W076_SIP_TICKE_MPC=>TS_HEADER
    exporting
      !ET_HEADER type ZCL_ZCU_W076_SIP_TICKE_MPC=>TT_HEADER .
  class-methods GET_TKTITEMS
    importing
      !IS_ITEM type ZCL_ZCU_W076_SIP_TICKE_MPC=>TS_ITEM
    exporting
      !ET_ITEMS type ZCL_ZCU_W076_SIP_TICKE_MPC=>TT_ITEM .
  class-methods PROCESS_HEADER
    importing
      !IS_HEADER type ZCL_ZCU_W076_SIP_TICKE_MPC=>TS_HEADER
      !IV_NEW type BOOLEAN
    exporting
      !ES_HEADER_INS type ZTCU_TKTHEADER
      !ES_HEADER_UPD type ZTCU_TKTHEADER .
  class-methods PROCESS_ITEM
    importing
      !IT_ITEMS type ZCL_ZCU_W076_SIP_TICKE_MPC=>TT_ITEM
      !IT_ITEMS_INACTIVE type ZCL_ZCU_W076_SIP_TICKE_MPC=>TT_ITEMINACTIVE optional
      !IV_SUBMITTEDBY type UNAME
    exporting
      !ET_ITEMS_INS type ZTTCU_TKTITEM
      !ET_ITEMS_UPD type ZTTCU_TKTITEM
      !ET_ITEMS_DEL type ZTTCU_TKTITEM
      !EV_AMOUNT type Z_SIPAMOUNT .
  class-methods GET_TKT_ITEMS_INVOICE
    importing
      !IS_ITEM type ZCL_ZCU_W076_SIP_TICKE_MPC=>TS_ITEM
      !IV_W073 type XFELD
    exporting
      !ET_ITEMS type ZCL_ZCU_W076_SIP_TICKE_MPC=>TT_ITEM .
  class-methods GET_APPROVED_TICKETS
    importing
      !IS_FPCITEM type ZCLCU_SIP_MPC=>TS_FPCITEM
    exporting
      !ET_FPCITEM type ZCLCU_SIP_MPC=>TT_FPCITEM .
  class-methods GET_APPROVED_TKTITEMS
    importing
      !IS_ITEM type ZCLCU_SIP_MPC=>TS_ITEM
    exporting
      !ET_ITEMS type ZCLCU_SIP_MPC=>TT_ITEM .
  class-methods GET_TICKETS
    importing
      !IS_TICKET type ZCL_ZSIP_W076_MPC=>TS_TICKETSEARCHHELP
    exporting
      !ET_TICKETS type ZCL_ZSIP_W076_MPC=>TT_TICKETSEARCHHELP .
protected section.
private section.
ENDCLASS.



CLASS ZCLCU_W076_UTILITY IMPLEMENTATION.


  METHOD batch_process.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 24.06.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Save the changes of all tabs
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA : lw_items          TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_item,
           lw_items_inactive TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_iteminactive,
           lw_header         TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_header,
           lw_key_tab        TYPE /iwbep/s_mgw_name_value_pair,
           lw_attach_cs      TYPE zclcu_sip_mpc=>ts_attachdocument,
           lt_items          TYPE zcl_zcu_w076_sip_ticke_mpc=>tt_item,
           lt_items_inactive TYPE zcl_zcu_w076_sip_ticke_mpc=>tt_iteminactive,
           lw_attach         TYPE zscu_sip_attach,
           lt_attach         TYPE zttcu_sip_attach,
           lw_routing        TYPE zcl_zcu_w076_sip_ticke_mpc=>ts_approvalflow,
           lt_routing        TYPE zcl_zcu_w076_sip_ticke_mpc=>tt_approvalflow.


    LOOP AT it_deep_struc ASSIGNING FIELD-SYMBOL(<ls_deep_item>).
      IF <ls_deep_item>-header_tk IS NOT INITIAL AND lw_header IS INITIAL.
        "Header
        lw_header = <ls_deep_item>-header_tk.
        IF lw_header-ticketno IS INITIAL.
          "populate the new ticket created
          lw_header-ticketno = iv_tktno.
          DATA(lv_new) = abap_true.
        ENDIF.
      ENDIF.

      "Items
      IF <ls_deep_item>-items_tk IS NOT INITIAL.
        lw_items = <ls_deep_item>-items_tk .
        IF lw_items-ticketno IS INITIAL.
          "populate the new SIP created
          lw_items-ticketno = iv_tktno.
        ENDIF.
        APPEND lw_items TO lt_items.
        CLEAR : lw_items.
      ENDIF.

      "Inactive Items
      IF <ls_deep_item>-items_tk_inactive IS NOT INITIAL.
        lw_items_inactive = <ls_deep_item>-items_tk_inactive .
        IF lw_items_inactive-ticketno IS INITIAL.
          "populate the new SIP created
          lw_items_inactive-ticketno = iv_tktno.
        ENDIF.
        APPEND lw_items_inactive TO lt_items_inactive.
        CLEAR : lw_items_inactive.
      ENDIF.

      "Approval flow
      IF <ls_deep_item>-routing IS NOT INITIAL AND lw_routing IS INITIAL.
        lw_routing = <ls_deep_item>-routing.
        IF <ls_deep_item>-routing-uniqueno IS INITIAL.
          lw_routing-uniqueno = iv_tktno.
        ENDIF.
        APPEND lw_routing TO lt_routing.
        CLEAR : lw_routing.
      ENDIF.

      "Attachment
      IF <ls_deep_item>-attachheader IS NOT INITIAL.
        lw_attach = <ls_deep_item>-attachheader.
        IF <ls_deep_item>-attachheader-uniqueno IS INITIAL.
          lw_attach-uniqueno = iv_tktno.
        ENDIF.
        APPEND lw_attach TO lt_attach.
        CLEAR : lw_attach.
      ENDIF.
    ENDLOOP.

    "Update header and item
    IF lw_header IS NOT INITIAL OR lt_items IS NOT INITIAL.
      CALL METHOD zclcu_w076_utility=>set_header_items
        EXPORTING
          is_header         = lw_header
          it_items          = lt_items
          it_items_inactive = lt_items_inactive
          iv_new            = lv_new
        IMPORTING
          es_header_ins     = DATA(ls_header_ins)
          es_header_upd     = DATA(ls_header_upd)
          et_items_ins      = DATA(lt_item_ins)
          et_items_upd      = DATA(lt_item_upd)
          et_items_del      = DATA(lt_item_del).
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

    "delete Attachment
    IF lt_attach IS NOT INITIAL.
      CALL METHOD zclcu_sip_utility=>create_attachment_header
        EXPORTING
          it_sip_attach = lt_attach.
    ENDIF.


    CALL FUNCTION 'ZCU_UPDATE_TKT'
      EXPORTING
        iv_tktno       = lw_header-ticketno
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
        lw_key_tab-name = 'SipNo'.
        IF iv_tktno IS INITIAL.
          lw_key_tab-value = lw_header-ticketno.
        ELSE.
          lw_key_tab-value = iv_tktno.
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
  ENDMETHOD.


  METHOD get_approved_tickets.
*****************************************************************************
*&  Created By             : Kripa S P
*&  Created On             : 02.09.2020
*&  Functional Design Name : W073 - SWR Application
*&  Purpose                : Get APPROVED tickets
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR: et_fpcitem.
    DATA : lv_dom_val  TYPE dd07v-domvalue_l,
           lv_dom_text TYPE dd07v-ddtext.

    "if WRNo is passed
    IF is_fpcitem-wrno IS NOT INITIAL.
      SELECT a~ticketno,
             a~spno,
             a~wrno,
             a~contract,
             a~completiondate,
             a~submittedby,
             a~sipstatus,
             b~itemcode,
             b~actqty
        FROM ztcu_tktheader AS a
        INNER JOIN ztcu_tktitem AS b
        ON a~ticketno = b~ticketno
        INTO TABLE @DATA(lt_fpc)
        WHERE a~wrno = @is_fpcitem-wrno
        AND a~sipstatus <> @zif_cu_sip=>gc_sipstatus-draft.
      "if SPNo is passed
    ELSEIF is_fpcitem-spno IS NOT INITIAL.
      SELECT a~ticketno,
             a~spno,
             a~wrno,
             a~contract,
             a~completiondate,
             a~submittedby,
             a~sipstatus,
             b~itemcode,
             b~actqty
        FROM ztcu_tktheader AS a
        INNER JOIN ztcu_tktitem AS b
        ON a~ticketno = b~ticketno
        INTO TABLE @lt_fpc
        WHERE a~spno = @is_fpcitem-spno
              AND a~sipstatus <> @zif_cu_sip=>gc_sipstatus-draft.
      "If contract is passed
    ELSEIF is_fpcitem-contract IS NOT INITIAL.
      SELECT  a~ticketno,
              a~spno,
              a~wrno,
              a~contract,
              a~completiondate,
              a~submittedby,
              a~sipstatus,
              b~itemcode,
              b~actqty
         FROM ztcu_tktheader AS a
         INNER JOIN ztcu_tktitem AS b
         ON a~ticketno = b~ticketno
         INTO TABLE @lt_fpc
         WHERE a~contract = @is_fpcitem-contract
             AND a~spno = '' AND a~wrno = ''
             AND a~sipstatus <> @zif_cu_sip=>gc_sipstatus-draft.
    ENDIF.
    IF sy-subrc EQ 0.
      SORT lt_fpc BY ticketno itemcode.

      "Get the list of tickets already assigned to a invoice
      SELECT sipno,                                     "#EC CI_NOFIRST
             ticketno
        FROM ztcu_sip_fpcmap
        INTO TABLE @DATA(lt_fpcmap)
        FOR ALL ENTRIES IN @lt_fpc
        WHERE ticketno = @lt_fpc-ticketno.
      IF sy-subrc  = 0.
        DELETE lt_fpcmap WHERE sipno IS INITIAL. " Temp fix , later need to be analyzed why we have entries without SIP No
        SORT lt_fpcmap BY ticketno.
      ENDIF.
    ENDIF.
    LOOP AT lt_fpc ASSIGNING FIELD-SYMBOL(<ls_fpc>).
      READ TABLE lt_fpcmap ASSIGNING FIELD-SYMBOL(<ls_fpc_map>)
      WITH KEY ticketno = <ls_fpc>-ticketno BINARY SEARCH.
      IF sy-subrc <> 0.
        DATA(lv_add)   = abap_true.
        DATA(lv_check) = abap_false.
      ELSEIF <ls_fpc_map>-sipno = is_fpcitem-sipno.
        lv_add   = abap_true.
        lv_check = abap_true.
      ENDIF.
      IF lv_add = abap_true.
        APPEND INITIAL LINE TO et_fpcitem ASSIGNING FIELD-SYMBOL(<ls_data>).
        CLEAR : <ls_data>.
        MOVE-CORRESPONDING <ls_fpc> TO <ls_data>.
        IF lv_check = abap_true.
          <ls_data>-involved = abap_true.
        ENDIF.
        lv_dom_val = <ls_fpc>-sipstatus.
        CALL FUNCTION 'DOMAIN_VALUE_GET'
          EXPORTING
            i_domname  = 'Z_SIPSTATUS'
            i_domvalue = lv_dom_val
          IMPORTING
            e_ddtext   = lv_dom_text
          EXCEPTIONS
            not_exist  = 1
            OTHERS     = 2.
        IF sy-subrc = 0.
          <ls_data>-statusdesc = lv_dom_text.
        ENDIF.

      ENDIF.
      CLEAR : lv_add, lv_check.
    ENDLOOP.
    SORT et_fpcitem BY sipstatus involved ASCENDING AS TEXT.

  ENDMETHOD.


  METHOD get_approved_tktitems.
*****************************************************************************
*&  Created By             : Kripa S P
*&  Created On             : 02.09.2020
*&  Functional Design Name : W073 - SWR Application
*&  Purpose                : Get approved tickets item detals
*&  Transport Request No   : D10K934677
*****************************************************************************
    TYPES : BEGIN OF ty_fpc,
              itemcode TYPE z_itemcode,
              actqty   TYPE z_actqty,
            END OF ty_fpc.
    DATA : lw_fpcitem  TYPE zclcu_sip_mpc=>ts_fpcitem,
           lt_matnr    TYPE TABLE OF ty_fpc,
           lw_matnr    TYPE ty_fpc,
           lv_netprice TYPE bwert,
           lv_counter  TYPE boolean.

    MOVE-CORRESPONDING is_item TO lw_fpcitem ##ENH_OK.
    "Get approved tkts
    CALL METHOD zclcu_w076_utility=>get_approved_tickets
      EXPORTING
        is_fpcitem = lw_fpcitem
      IMPORTING
        et_fpcitem = DATA(lt_fpcitem).

    DELETE lt_fpcitem WHERE sipstatus <> zif_cu_sip=>gc_sipstatus-completed.

    IF lw_fpcitem-sipno IS INITIAL.

      IF lt_fpcitem IS NOT INITIAL.
        SORT lt_fpcitem BY material.
        LOOP AT lt_fpcitem ASSIGNING FIELD-SYMBOL(<ls_fpc>).
          lw_matnr-itemcode = <ls_fpc>-material.
*          lw_matnr-actqty = <ls_fpc>-actqty.
          COLLECT lw_matnr INTO lt_matnr.
        ENDLOOP.
      ENDIF.

      "Get the item details based on contract/WR/SP
      CALL METHOD zclcu_sip_utility=>get_items
        EXPORTING
          is_item  = is_item
        IMPORTING
          et_items = DATA(lt_items).

      "Get the contarct item details for items not in SP/WR
*      IF is_item-category <> 'C'. Comment Om
        CALL METHOD zclcu_sip_utility=>get_contractitem
          EXPORTING
            iv_contract     = is_item-contract
            iv_wrno         = is_item-workrequestno
            iv_spno         = is_item-spno
            iv_appindicator = is_item-appindicator
          IMPORTING
            et_items        = DATA(lt_contract).
*      ENDIF. Comment Om

      SORT lt_matnr BY itemcode.
      SORT lt_items BY material counter.

      "Get the tiered pricing info from contract
      zclcu_sip_utility=>get_tier_prices(
        EXPORTING
          iv_contract   = is_item-contract                 " Purchasing Document Number
        IMPORTING
          et_tier_price = DATA(lt_tier_price)              " Tier Price - Table type
      ).

      LOOP AT lt_matnr ASSIGNING FIELD-SYMBOL(<ls_fpcitem>).
        READ TABLE lt_items TRANSPORTING NO FIELDS
        WITH KEY material = <ls_fpcitem>-itemcode.
        IF sy-subrc = 0.
          DATA(lv_index) = sy-tabix.
          "Populate item details for items in Contract/SP/WR
          LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_items>) FROM lv_index.
            IF <ls_fpcitem>-itemcode = <ls_items>-material.
              DATA(lv_matnr_exists) = abap_true.

              APPEND INITIAL LINE TO et_items ASSIGNING FIELD-SYMBOL(<ls_data>).
              MOVE-CORRESPONDING <ls_items> TO <ls_data>.
              IF <ls_items>-counter = 1.
*                <ls_data>-actqty = <ls_fpcitem>-actqty. Comment Om
                <ls_data>-originalqty = <ls_fpcitem>-actqty.

                "Calculate Net price
                CLEAR: lv_netprice,
                       lv_counter.

                LOOP AT lt_tier_price ASSIGNING FIELD-SYMBOL(<ls_tier_price>)
                WHERE itemcode = <ls_data>-material.
                  IF lv_counter IS INITIAL.
                    <ls_data>-netprice = <ls_tier_price>-amount.
                  ENDIF.

                  IF <ls_tier_price>-scalequantity = '0.00'.
                    EXIT.
                  ELSE.
*                    IF <ls_data>-actqty LT <ls_tier_price>-scalequantity.
*                      EXIT.
*                    ELSE.
                      <ls_data>-netprice = <ls_tier_price>-amount.
*                    ENDIF.
                  ENDIF.

                  lv_counter = abap_true.
                ENDLOOP.

                lv_netprice = <ls_data>-netprice.
              ENDIF.

              READ TABLE lt_fpcitem ASSIGNING <ls_fpc>
              WITH KEY material = <ls_fpcitem>-itemcode BINARY SEARCH.
              IF sy-subrc = 0.
                <ls_data>-sipstatus = <ls_fpc>-sipstatus.
              ENDIF.

              "Get the netprice from the parent line item
              <ls_data>-netprice = lv_netprice.
            ELSE.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.

        "Populate item details from contract (Not in SP/WR)
        IF lv_matnr_exists <> abap_true.
          READ TABLE lt_contract ASSIGNING FIELD-SYMBOL(<ls_ekpo>)
                   WITH KEY itemcode = <ls_fpcitem>-itemcode
                               loekz = space.
          IF sy-subrc <> 0.
            READ TABLE lt_contract ASSIGNING <ls_ekpo>
            WITH KEY itemcode = <ls_fpcitem>-itemcode.
            IF sy-subrc <> 0.
              UNASSIGN <ls_ekpo>.
            ENDIF.
          ENDIF.
          IF <ls_ekpo> IS ASSIGNED.
            APPEND INITIAL LINE TO et_items ASSIGNING <ls_data>.
            MOVE-CORRESPONDING <ls_ekpo> TO <ls_data>.
*            <ls_data>-actqty = <ls_fpcitem>-actqty. Comment Om
            <ls_data>-originalqty = <ls_fpcitem>-actqty.

            "Calculate Tier Price
            CLEAR: lv_counter.
            LOOP AT lt_tier_price ASSIGNING <ls_tier_price>
            WHERE itemcode = <ls_data>-Material.
              IF lv_counter IS INITIAL.
                <ls_data>-netprice = <ls_tier_price>-amount.
              ENDIF.

              IF <ls_tier_price>-scalequantity = '0.00'.
                EXIT.
              ELSE.
*                IF <ls_data>-actqty LT <ls_tier_price>-scalequantity.
*                  EXIT.
*                ELSE.
                  <ls_data>-netprice = <ls_tier_price>-amount.
*                ENDIF.
              ENDIF.

              lv_counter = abap_true.
            ENDLOOP.
          ENDIF.
        ENDIF.

        CLEAR: lv_matnr_exists.
      ENDLOOP.

      DELETE ADJACENT DUPLICATES FROM et_items COMPARING Material designedqty contract.

    ELSE.
      MOVE-CORRESPONDING lt_fpcitem TO et_items.
    ENDIF.
  ENDMETHOD.


  METHOD get_header.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Header details
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA ls_header TYPE zclcu_sip_mpc=>ts_headersipwr.

    CLEAR et_header.

    IF is_header-ticketno IS NOT INITIAL.
      "Get Header details from Ticketing table
      CALL METHOD zclcu_w076_utility=>get_tktheader
        EXPORTING
          is_header = is_header
        IMPORTING
          et_header = et_header.

    ELSE.
      "Get Header details from SAP contract table
      MOVE-CORRESPONDING is_header TO ls_header ##ENH_OK.
      CALL METHOD zclcu_sip_utility=>get_header
        EXPORTING
          is_header = ls_header
        IMPORTING
          et_header = DATA(lt_header).
      LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<ls_header>).
        APPEND INITIAL LINE TO et_header ASSIGNING FIELD-SYMBOL(<ls_etheader>).
        MOVE-CORRESPONDING <ls_header> TO <ls_etheader> ##ENH_OK. "#EC CI_CONV_OK
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
    DATA: lw_item        TYPE zclcu_sip_mpc=>ts_item,
          lt_item_output TYPE zcl_zcu_w076_sip_ticke_mpc=>tt_item.

    CLEAR et_items.


    IF is_item-ticketno IS NOT INITIAL.
      "Get From Ticketing Item table
      CALL METHOD zclcu_w076_utility=>get_tktitems
        EXPORTING
          is_item  = is_item
        IMPORTING
          et_items = lt_item_output.

    ELSE.
      "Get From SAP contract table
      MOVE-CORRESPONDING is_item TO lw_item ##ENH_OK.
      CALL METHOD zclcu_sip_utility=>get_items
        EXPORTING
          is_item  = lw_item
        IMPORTING
          et_items = DATA(lt_items).
      LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_items>)
      WHERE parentlineno IS INITIAL.
        APPEND INITIAL LINE TO lt_item_output ASSIGNING FIELD-SYMBOL(<ls_etitems>).
        MOVE-CORRESPONDING <ls_items> TO <ls_etitems> ##ENH_OK.
      ENDLOOP.
    ENDIF.

    "Classify Active and Inactive Materials
    CALL METHOD zclcu_sip_utility=>classify_materials_fpc(
      EXPORTING
        iv_tktno    = is_item-ticketno
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


  METHOD get_tickets.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi K
*&  Created On             : 02.09.2020
*&  Functional Design Name : W076 - TKT Application
*&  Purpose                : Get previous FPC's for a Contract or WR or SP
*&  Transport Request No   : D10K934677
*****************************************************************************
    IF is_ticket-category = 'C' AND
       is_ticket-contract IS NOT INITIAL.
      SELECT * FROM ztcu_tktheader
        INTO TABLE @et_tickets
        WHERE contract = @is_ticket-contract AND
              category = @is_ticket-category.
      IF sy-subrc <> 0.
        CLEAR et_tickets.
      ENDIF.

    ELSEIF is_ticket-category = 'S' AND
           is_ticket-spno IS NOT INITIAL.
      SELECT * FROM ztcu_tktheader
        INTO TABLE @et_tickets
        WHERE spno = @is_ticket-spno AND
              category = @is_ticket-category.
      IF sy-subrc <> 0.
        CLEAR et_tickets.
      ENDIF.

    ELSEIF is_ticket-category = 'W' AND
           is_ticket-wrno IS NOT INITIAL.
      SELECT * FROM ztcu_tktheader
        INTO TABLE @et_tickets
        WHERE wrno = @is_ticket-wrno AND
              category = @is_ticket-category.
      IF sy-subrc <> 0.
        CLEAR et_tickets.
      ENDIF.

    ELSEIF is_ticket-createdby IS NOT INITIAL AND
           is_ticket-sipstatus IS NOT INITIAL.
      SELECT * FROM ztcu_tktheader
      INTO TABLE @et_tickets
      WHERE sipstatus = @is_ticket-sipstatus AND
            submittedby = @is_ticket-createdby.
      IF sy-subrc <> 0.
        CLEAR et_tickets.
      ENDIF.

    ELSEIF is_ticket-ticketno IS NOT INITIAL.
      SELECT * FROM ztcu_tktheader
      INTO TABLE @et_tickets
      WHERE ticketno = @is_ticket-ticketno.
      IF sy-subrc <> 0.
        CLEAR et_tickets.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_tktheader.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Header details from Ticketing table
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lt_param TYPE zttca_param.

    CONSTANTS: lc_code_group TYPE qmsm-mngrp VALUE 'MX-M',
               lc_task_code  TYPE qmsm-mncod VALUE 'PROJ'.

    CLEAR et_header.

    SELECT a~ticketno,
           a~tktdescr,
           a~wrno,
           b~wrdesc,
           b~source,
           b~woid,
           b~projectowner,
           b~pmoperation,
           b~township,
           b~permit_no,
           b~wrtype,
           b~wosubtype,
           b~bussunit,
           a~wrdate,
           a~supplier,
           a~supplierid,
           a~suppliercompany,
           c~name1,
           a~contract,
           a~spno,
           d~spdescr,
           a~planneddate,
           a~completiondate,
           a~createdon,
           a~submittedon,
           a~submittedby,
           a~sipstatus,
           a~category,
           a~project,
           a~addrline1,
           a~addrline2,
           a~state,
           a~country,
           a~postalcode,
           a~city,
           a~plant,
           a~projdesc,
           a~cjobno,
           a~permitno,
           a~area,
           a~addrline1_2,
           a~addrline2_2,
           a~state_2,
           a~country_2,
           a~postalcode_2,
           a~city_2,
           a~bukrs,
           a~novellid,
           a~extwrno
    FROM ztcu_tktheader AS a
    LEFT OUTER JOIN ztcu_wrheader AS b
    ON a~wrno = b~wrno
    LEFT OUTER JOIN lfa1 AS c
    ON a~suppliercompany = c~lifnr
    LEFT OUTER JOIN ztcu_spheader AS d              "#EC CI_CMPLX_WHERE
    ON a~spno = d~spno
    UP TO 1 ROWS
    INTO @DATA(lw_tktheader)
    WHERE ticketno = @is_header-ticketno.
    ENDSELECT.
    IF sy-subrc = 0.
      IF lw_tktheader-suppliercompany IS INITIAL.
        SELECT a~lifnr,
               a~name1
          FROM lfa1 AS a
          INNER JOIN ekko AS b
          ON a~lifnr = b~lifnr
          UP TO 1 ROWS
          INTO @DATA(lw_vend_name)
          WHERE ebeln = @lw_tktheader-contract.
        ENDSELECT.
        IF sy-subrc <> 0.
          CLEAR lw_vend_name.
        ENDIF.
      ELSE.
        lw_vend_name-lifnr = lw_tktheader-suppliercompany.
        lw_vend_name-name1 = lw_tktheader-name1.
      ENDIF.

      IF lw_tktheader-category = 'W' AND
      ( lw_tktheader-source = zif_cu_sip=>gc_source-maximo OR
        lw_tktheader-source = zif_cu_sip=>gc_source-maximo_lower ).
        "Get Project WO for Maximo
        SELECT a~qmnum,
               b~matxt
          UP TO 1 ROWS
          FROM qmel AS a
          INNER JOIN qmsm AS b
          ON a~qmnum = b~qmnum
          INTO @DATA(ls_matxt)
          WHERE a~aufnr = @lw_tktheader-woid AND
                b~mngrp = @lc_code_group AND
                b~mncod = @lc_task_code.
        ENDSELECT.
        IF sy-subrc = 0.
          "Get Project Description and Project Phase
          SELECT SINGLE aufnr,
                 ktext,
                 zzsmp_phase
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
      MOVE-CORRESPONDING lw_tktheader TO <ls_header> ##ENH_OK. "#EC CI_CONV_OK
      <ls_header>-suppliercompany     = lw_vend_name-lifnr.
      <ls_header>-suppliercompanyname = lw_vend_name-name1.

      IF <ls_header>-contract IS NOT INITIAL.
        CALL METHOD zclcu_sip_utility=>get_contract_description
          EXPORTING
            iv_contract    = <ls_header>-contract
          IMPORTING
            ev_description = DATA(lv_descr).
        <ls_header>-contractdescr = lv_descr.
      ENDIF.

      IF <ls_header>-novellid IS NOT INITIAL.
        CALL METHOD zclcu_sip_utility=>get_name
          EXPORTING
            iv_userid = <ls_header>-novellid
          IMPORTING
            ev_name   = <ls_header>-novellidname.
      ENDIF.

      "WR - Maximo fields
      IF lw_tktheader-source = zif_cu_sip=>gc_source-maximo OR
         lw_tktheader-source = zif_cu_sip=>gc_source-maximo_lower.

        <ls_header>-maximo       = abap_true.
        <ls_header>-projectwo    = ls_matxt-matxt.
        <ls_header>-projectdescr = ls_aufk-ktext.
        <ls_header>-projectphase = ls_aufk-zzsmp_phase.

        IF <ls_header>-projectowner IS NOT INITIAL.
          CALL METHOD zclcu_sip_utility=>get_name
            EXPORTING
              iv_userid = <ls_header>-projectowner
            IMPORTING
              ev_name   = <ls_header>-projectowner_name.
        ENDIF.

        IF lw_tktheader-wrtype = zif_cu_sip=>gc_restoration-restor_lower OR
           lw_tktheader-wrtype = zif_cu_sip=>gc_restoration-restor_upper.
          <ls_header>-restoration = abap_true.

          READ TABLE lt_param TRANSPORTING NO FIELDS
          WITH KEY value = lw_tktheader-bussunit.
          IF sy-subrc = 0.
            <ls_header>-digvisible = abap_true.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_tktitems.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 23.06.2020
*&  Functional Design Name : W076 - Ticketing Application
*&  Purpose                : Get the item details
*&  Transport Request No   : D10K934677
*****************************************************************************

    TYPES: BEGIN OF ty_accumqty,
             itemcode TYPE ztcu_tktitem-itemcode,
             accumqty TYPE z_accumalatedqty,
           END OF ty_accumqty.

    DATA: lt_accumqty TYPE STANDARD TABLE OF ty_accumqty,
          lw_accumqty TYPE ty_accumqty,
          lv_clause   TYPE string,
          ls_spitem   TYPE zcl_zcu_u115_sp_mpc=>ts_item.

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
                                                            "c145085.
        IF lt_items IS NOT INITIAL.
          SORT lt_items BY itemcode loekz.
        ENDIF.

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
          SORT lt_spitems BY spno itemcode.
        ENDIF.

      WHEN 'W'.
        CALL METHOD zclcu_sip_sourcewr=>get_wr_item
          EXPORTING
            is_item = is_item
          IMPORTING
            et_data = DATA(lt_writems).
        IF lt_writems IS NOT INITIAL.
          DELETE lt_writems WHERE parentlineno IS NOT INITIAL.
          SORT lt_writems BY wrno itemcode.
        ENDIF.
    ENDCASE.

    "Fetch all the SIP's for the contract
    SELECT a~ticketno,
      b~linenum,
      b~type,
      b~itemcode,
      b~actqty,
      b~actqtyuom,
      b~costobject,
      b~inactive
      FROM ztcu_tktheader AS a
      INNER JOIN ztcu_tktitem AS b                     "#EC CI_DYNWHERE
      ON a~ticketno = b~ticketno
      INTO TABLE @DATA(lt_tktitem)
      WHERE a~ticketno = @is_item-ticketno.
    IF sy-subrc = 0.

      IF is_item-category NE 'C'.
        CALL METHOD zclcu_sip_utility=>get_contractitem
          EXPORTING
            iv_contract     = is_item-contract
            iv_wrno         = is_item-wrno
            iv_spno         = is_item-spno
            iv_appindicator = is_item-appindicator
          IMPORTING
            et_items        = DATA(lt_contract).
        SORT lt_contract BY itemcode loekz.
      ENDIF.

      "Build the output table
      LOOP AT lt_tktitem ASSIGNING FIELD-SYMBOL(<ls_tktitem>).
        APPEND INITIAL LINE TO et_items ASSIGNING FIELD-SYMBOL(<ls_item>).
        <ls_item>-ticketno         = <ls_tktitem>-ticketno.
        <ls_item>-linenum          = <ls_tktitem>-linenum.
        IF <ls_item>-linenum IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = <ls_item>-linenum
            IMPORTING
              output = <ls_item>-linenum.
        ENDIF.
        <ls_item>-type             = <ls_tktitem>-type.
        <ls_item>-itemcode         = <ls_tktitem>-itemcode.
        <ls_item>-actqty           = <ls_tktitem>-actqty.
        <ls_item>-inactive         = <ls_tktitem>-inactive.
        <ls_item>-category         = is_item-category.
        <ls_item>-contract         = is_item-contract.

        CASE is_item-category.
          WHEN 'C'.
            READ TABLE lt_items ASSIGNING FIELD-SYMBOL(<ls_ekpo>)
                      WITH KEY itemcode = <ls_tktitem>-itemcode
                                  loekz = space BINARY SEARCH.
            IF sy-subrc <> 0.
              READ TABLE lt_items ASSIGNING <ls_ekpo>
              WITH KEY itemcode = <ls_tktitem>-itemcode.
              IF sy-subrc <> 0.
                UNASSIGN <ls_ekpo>.
              ENDIF.
            ENDIF.
            IF <ls_ekpo> IS ASSIGNED.
              <ls_item>-itemdescr      = <ls_ekpo>-itemdescr.
              <ls_item>-designqty      = <ls_ekpo>-designqty.
              <ls_item>-designqtyuom   = <ls_ekpo>-designqtyuom.
              <ls_item>-accumalatedqty = <ls_ekpo>-accumalatedqty.
            ENDIF.
          WHEN 'S'.
            READ TABLE lt_spitems ASSIGNING FIELD-SYMBOL(<ls_spitems>)
            WITH KEY spno = is_item-spno
                     itemcode = <ls_tktitem>-itemcode BINARY SEARCH.
            IF sy-subrc = 0.
              <ls_item>-itemdescr      = <ls_spitems>-itemdescr.
              <ls_item>-designqty      = <ls_spitems>-designqty.
              <ls_item>-designqtyuom   = <ls_spitems>-designqtyuom.
              <ls_item>-accumalatedqty = <ls_spitems>-accumalatedqty.
            ELSE.
              DATA(lv_contract)        = abap_true.
              <ls_item>-deletionind    = abap_true.
            ENDIF.
          WHEN 'W'.
            READ TABLE lt_writems ASSIGNING FIELD-SYMBOL(<ls_writems>)
            WITH KEY wrno = is_item-wrno
                     itemcode = <ls_tktitem>-itemcode BINARY SEARCH.
            IF sy-subrc = 0.
              <ls_item>-itemdescr      = <ls_writems>-itemdescr.
              <ls_item>-designqty      = <ls_writems>-designqty.
              <ls_item>-designqtyuom   = <ls_writems>-designqtyuom.
              <ls_item>-accumalatedqty = <ls_writems>-accumalatedqty.
              <ls_item>-maximo         = <ls_writems>-maximo.
            ELSE.
              lv_contract              = abap_true.
              <ls_item>-deletionind    = abap_true.
            ENDIF.
        ENDCASE.

        IF lv_contract = abap_true.
          READ TABLE lt_contract ASSIGNING <ls_ekpo>
          WITH KEY itemcode = <ls_tktitem>-itemcode
                      loekz = space BINARY SEARCH.
          IF sy-subrc <> 0.
            READ TABLE lt_contract ASSIGNING <ls_ekpo>
            WITH KEY itemcode = <ls_tktitem>-itemcode.
            IF sy-subrc <> 0.
              UNASSIGN <ls_ekpo>.
            ENDIF.
          ENDIF.
          IF <ls_ekpo> IS ASSIGNED.
            <ls_item>-itemdescr      = <ls_ekpo>-itemdescr.
            <ls_item>-designqtyuom   = <ls_ekpo>-designqtyuom.
            <ls_item>-accumalatedqty = <ls_ekpo>-accumalatedqty.
          ENDIF.
        ENDIF.


        CLEAR lv_contract.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.


  METHOD get_tkt_items_invoice.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Item details
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA lw_item TYPE zclcu_sip_mpc=>ts_item.

    CLEAR et_items.

    IF is_item-ticketno IS NOT INITIAL.
      "Get From Ticketing Item table
      CALL METHOD zclcu_w076_utility=>get_tktitems
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


  METHOD process_header.
***************************************************************************
*&  Program Name           : PROCESS_HEADER
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 09.07.2020
*&  Functional Design Name : W076 - Ticketing Application
*&  Purpose                : Update Ticketing Header details
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lw_header TYPE ztcu_tktheader.

    CLEAR: es_header_ins,
           es_header_upd.

    MOVE-CORRESPONDING is_header TO lw_header ##ENH_OK.

    SELECT  a~bname
            FROM usr21 AS a
            INNER JOIN adrp AS b
            ON a~persnumber = b~persnumber
            UP TO 1 ROWS
            INTO @lw_header-novellid
            WHERE b~name_text = @is_header-novellidname.
    ENDSELECT.

    CASE is_header-category .
      WHEN zif_cu_sip~gc_wr.
        lw_header-wrno        = is_header-wrno.
        lw_header-wrdate      = is_header-wrdate.

        "Populate vendor from contract if initial
        IF lw_header-suppliercompany IS INITIAL.
          SELECT SINGLE lifnr
            FROM ekko
            INTO @lw_header-suppliercompany
            WHERE ebeln = @lw_header-contract.
          IF sy-subrc <> 0.
            CLEAR lw_header-suppliercompany.
          ENDIF.
        ENDIF.
      WHEN zif_cu_sip~gc_sp.
        lw_header-spno        = is_header-spno.
    ENDCASE.

    IF iv_new = abap_true.
      lw_header-createdby = is_header-submittedby.
      lw_header-createdon = sy-datum.
    ELSE.
      SELECT createdby,
             createdon
        UP TO 1 ROWS
        FROM ztcu_tktheader
        INTO @DATA(lw_created)
        WHERE ticketno = @lw_header-ticketno.
      ENDSELECT.
      IF sy-subrc = 0.
        lw_header-createdby = lw_created-createdby.
        lw_header-createdon = lw_created-createdon.
      ENDIF.

      lw_header-changedby = is_header-submittedby.
      lw_header-changedon = sy-datum.
    ENDIF.

    IF is_header-operation = zif_cu_sip=>gc_operation-insert.
      es_header_ins = lw_header.
    ELSEIF is_header-operation = zif_cu_sip=>gc_operation-update.
      es_header_upd = lw_header.
    ENDIF.
  ENDMETHOD.


  METHOD process_item.
*****************************************************************************
*&  Program Name           : PROCESS_ITEM
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 08.07.2020
*&  Functional Design Name : W076 - Ticketing Application
*&  Purpose                : Process Item details of Ticket
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lv_linenum      TYPE z_linenum.

    CLEAR: et_items_ins,
           et_items_upd,
           et_items_del,
           ev_amount.

    "Units tab
    LOOP AT it_items ASSIGNING FIELD-SYMBOL(<ls_items>).
      IF <ls_items>-operation = zif_cu_sip=>gc_operation-insert.
        APPEND INITIAL LINE TO et_items_ins ASSIGNING FIELD-SYMBOL(<ls_items_sip>).
      ELSEIF <ls_items>-operation = zif_cu_sip=>gc_operation-update.
        APPEND INITIAL LINE TO et_items_upd ASSIGNING <ls_items_sip>.
      ELSEIF <ls_items>-operation = zif_cu_sip=>gc_operation-delete.
        APPEND INITIAL LINE TO et_items_del ASSIGNING <ls_items_sip>.
      ENDIF.
      IF <ls_items_sip> IS ASSIGNED.
        MOVE-CORRESPONDING <ls_items> TO <ls_items_sip> ##ENH_OK.
        <ls_items_sip>-changedby = iv_submittedby.
        <ls_items_sip>-changedon = sy-datum.
      ENDIF.
    ENDLOOP.

    IF it_items_inactive IS NOT INITIAL.
      IF it_items IS NOT INITIAL.
        DATA(lt_itemsactive) = it_items.
        SORT lt_itemsactive BY linenum DESCENDING.
        lv_linenum = lt_itemsactive[ 1 ]-linenum.
      ENDIF.
      lv_linenum = lv_linenum + 10.

      "Inactive tab
      LOOP AT it_items_inactive ASSIGNING FIELD-SYMBOL(<ls_items_inactive>).
        IF <ls_items_inactive>-operation = zif_cu_sip=>gc_operation-insert.
          APPEND INITIAL LINE TO et_items_ins ASSIGNING <ls_items_sip>.
        ELSEIF <ls_items_inactive>-operation = zif_cu_sip=>gc_operation-update.
          APPEND INITIAL LINE TO et_items_upd ASSIGNING <ls_items_sip>.
        ELSEIF <ls_items_inactive>-operation = zif_cu_sip=>gc_operation-delete.
          APPEND INITIAL LINE TO et_items_del ASSIGNING <ls_items_sip>.
        ENDIF.
        IF <ls_items_sip> IS ASSIGNED.
          MOVE-CORRESPONDING <ls_items_inactive> TO <ls_items_sip> ##ENH_OK.
          <ls_items_sip>-linenum   = lv_linenum.
          <ls_items_sip>-changedby = iv_submittedby.
          <ls_items_sip>-changedon = sy-datum.
        ENDIF.

        lv_linenum = lv_linenum + 10.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD set_header_items.
*****************************************************************************
*&  Program Name           : SET_HEADER_ITEMS
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 23.06.2020
*&  Functional Design Name : W076 - Ticketing Application
*&  Purpose                : Save the changes of header and items
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA lv_submittedby TYPE uname.

    CLEAR: es_header_ins,
           es_header_upd,
           et_items_ins,
           et_items_upd,
           et_items_del.

    IF is_header IS  NOT INITIAL.
      "Update the header table with the completion date
      CALL METHOD zclcu_w076_utility=>process_header
        EXPORTING
          is_header     = is_header
          iv_new        = iv_new
        IMPORTING
          es_header_ins = es_header_ins
          es_header_upd = es_header_upd.
    ENDIF.

    lv_submittedby = is_header-submittedby.

    IF it_items IS NOT INITIAL.
      "Update item data
      CALL METHOD zclcu_w076_utility=>process_item
        EXPORTING
          it_items          = it_items
          it_items_inactive = it_items_inactive
          iv_submittedby    = lv_submittedby
        IMPORTING
          et_items_ins      = et_items_ins
          et_items_upd      = et_items_upd
          et_items_del      = et_items_del.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
