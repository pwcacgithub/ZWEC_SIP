class ZCLCU_SIP_DPC_EXT definition
  public
  inheriting from ZCLCU_SIP_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_BEGIN
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_PROCESS
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM
    redefinition .
protected section.

  methods ACTIVITYSET_GET_ENTITYSET
    redefinition .
  methods APPROVALFLOWSET_GET_ENTITYSET
    redefinition .
  methods ATTACHMENTHEADER_GET_ENTITYSET
    redefinition .
  methods CONTRACTSEARCHHE_GET_ENTITYSET
    redefinition .
  methods FPCITEMSET_GET_ENTITYSET
    redefinition .
*  methods FCPITEMSET_GET_ENTITYSET
*    redefinition .
  methods HEADERSIPWRSET_GET_ENTITY
    redefinition .
  methods HEADERSIPWRSET_GET_ENTITYSET
    redefinition .
  methods INTERNALORDERSET_GET_ENTITYSET
    redefinition .
  methods ITEMMAXIMOSET_GET_ENTITYSET
    redefinition .
  methods ITEMSET_GET_ENTITYSET
    redefinition .
  methods MATERIALSEARCHHE_GET_ENTITYSET
    redefinition .
  methods PLANTSEARCHHELPS_GET_ENTITYSET
    redefinition .
  methods PMORDERSET_GET_ENTITYSET
    redefinition .
  methods ROLEBASEDUSERIDS_GET_ENTITYSET
    redefinition .
  methods SIPSEARCHHELPSET_GET_ENTITYSET
    redefinition .
  methods STATESET_GET_ENTITYSET
    redefinition .
  methods SURROGATESUPERVI_GET_ENTITYSET
    redefinition .
  methods TIEREDPRICINGSET_GET_ENTITYSET
    redefinition .
  methods WRSPSEARCHHELPSE_GET_ENTITYSET
    redefinition .
  methods UICONFIGSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCLCU_SIP_DPC_EXT IMPLEMENTATION.


  METHOD wrspsearchhelpse_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 21.08.2020
*&  Functional Design Name : SWR App
*&  Purpose                : Get WR and SPs
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.

    DATA : lw_wrsp TYPE zscu_wr_sp,
           lv_user TYPE uname.

*    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
*      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
*      IF sy-subrc IS INITIAL.
*        CASE lw_filter_opt-property.
*          WHEN 'Flag'.
*            lw_wrsp-flag = lw_filter_val-low.
*          WHEN 'WRSPNo'.
*            lw_wrsp-wr_spno = lw_filter_val-low.
*          WHEN 'Submittedby'.
*            lv_user = lw_filter_val-low.
*          WHEN OTHERS.
*        ENDCASE.
*      ENDIF.
*    ENDLOOP.

    "Get the routing details
    CALL METHOD zclcu_sip_utility=>wr_sp_searchhelp
      EXPORTING
        is_input       = lw_wrsp
        iv_submittedby = lv_user
      IMPORTING
        et_data        = et_entityset.

  ENDMETHOD.


  method UICONFIGSET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->UICONFIGSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
    DATA : lv_appindicator TYPE C,
           lv_scenario(2) TYPE C,
           lv_role TYPE C.
     LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Appindicator'.
            lv_appindicator = lw_filter_val-low.
          WHEN 'Scenario'.
            lv_scenario = lw_filter_val-low.
          WHEN 'Role'.
            lv_role = lw_filter_val-low.
        ENDCASE.
      ENDIF.
    ENDLOOP.
    select * from ztcu_sipconfig
      into TABLE @data(lt_config)
      WHERE APPINDICATOR = @lv_appindicator
      AND SCENARIO = @lv_scenario
      AND ROLE = @lv_role.

       LOOP AT lt_config ASSIGNING FIELD-SYMBOL(<ls_t001w>).
        APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<ls_plant>).
        <ls_plant>-appindicator = <ls_t001w>-appindicator.
        <ls_plant>-companycode = <ls_t001w>-bukrs.
        <ls_plant>-scenario = <ls_t001w>-scenario.
        <ls_plant>-role = <ls_t001w>-role.
        <ls_plant>-fieldname = <ls_t001w>-fieldname.
        <ls_plant>-property = <ls_t001w>-property.

        ENDLOOP.
  endmethod.


  METHOD tieredpricingset_get_entityset.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 28.01.2021
*&  Functional Design Name : SWR App
*&  Purpose                : Get Tiered Pricing Info
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset.

    DATA : lw_tier_price TYPE zclcu_sip_mpc=>ts_tieredpricing.

    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Contract'.
            lw_tier_price-contract = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get the Tiered pricing details
    CALL METHOD zclcu_sip_utility=>get_tier_prices
      EXPORTING
        iv_contract   = lw_tier_price-contract
      IMPORTING
        et_tier_price = et_entityset.
  ENDMETHOD.


  METHOD surrogatesupervi_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 26.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the supervisor/surrogate details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.

    DATA : lv_userid TYPE sldstring.

    "get the SIP number from UI
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'LoginUser'.
            lv_userid = lw_filter_val-low.
        ENDCASE.
      ENDIF.
    ENDLOOP.
    "Get supsur details
    CALL METHOD zclcu_sip_utility=>get_surrogate_supervisor
      EXPORTING
        iv_userid = lv_userid
        iv_wftype = 'W073'
      IMPORTING
        et_data   = et_entityset.


    IF et_entityset IS INITIAL.
*      RAISE EXCEPTION
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.

  ENDMETHOD.


  method STATESET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->STATESET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
      CALL METHOD zclcu_sip_utility=>get_states

      IMPORTING
        et_data        = et_entityset.

  endmethod.


  METHOD sipsearchhelpset_get_entityset.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi K
*&  Created On             : 02.09.2020
*&  Functional Design Name : W076 - TKT Application
*&  Purpose                : Get previous FPC's for a Contract or WR or SP
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA ls_sip TYPE zclcu_sip_mpc=>ts_sipsearchhelp.

    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Category'.
            ls_sip-category = lw_filter_val-low.
          WHEN 'Wrno'.
            ls_sip-wrno = lw_filter_val-low.
          WHEN 'Contract'.
            ls_sip-contract = lw_filter_val-low.
          WHEN 'Spno'.
            ls_sip-spno = lw_filter_val-low.
          WHEN 'Createdby'.
            ls_sip-createdby = lw_filter_val-low.
          WHEN 'Sipstatus'.
            ls_sip-sipstatus = lw_filter_val-low.
          WHEN 'SIPNo'.
            ls_sip-sipno = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    CALL METHOD zclcu_w073_utility=>get_sips
      EXPORTING
        is_sip = ls_sip
      IMPORTING
        et_sip = et_entityset.

    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.
  ENDMETHOD.


  METHOD rolebaseduserids_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 26.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get user ids based on role
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR :et_entityset, es_response_context.
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Role'.
            DATA(lv_role) = lw_filter_val-low.
            IF lv_role = 'AP'. "Approver
              DATA(lv_approver) = abap_true.
            ELSE.
              DATA(lv_verifier) = abap_true.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.
    "Get the roles based on approver/verifier
    CALL METHOD zclcu_sip_utility=>get_approver_verifier
      EXPORTING
        iv_approvers           = lv_approver
        iv_verifiers           = lv_verifier
      IMPORTING
        et_approvers_verifiers = DATA(lt_appr_verif).

    LOOP AT lt_appr_verif ASSIGNING FIELD-SYMBOL(<ls_ap_vr>).
      APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<ls_ent>).
      CLEAR : <ls_ent>.
      <ls_ent>-name = <ls_ap_vr>-name.
      <ls_ent>-roldesc = <ls_ap_vr>-role_descr.
      <ls_ent>-role = <ls_ap_vr>-role_id.
      <ls_ent>-userid = <ls_ap_vr>-usrid.
    ENDLOOP.
  ENDMETHOD.


  method PMORDERSET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->PMORDERSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
    CALL METHOD zclcu_sip_utility=>get_pm_orders

      IMPORTING
        et_data        = et_entityset.

  endmethod.


  METHOD plantsearchhelps_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 21.08.2020
*&  Functional Design Name : SWR Application
*&  Purpose                : Get plants
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR :et_entityset, es_response_context.

    zclcu_sip_utility=>plant_searchhelp(
      EXPORTING
        iv_application     = 'W073'
      IMPORTING
        et_plantsearchhelp = et_entityset
    ).
  ENDMETHOD.


  METHOD materialsearchhe_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 21.08.2020
*&  Functional Design Name : SWR Application
*&  Purpose                : Get contracts
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR :et_entityset, es_response_context.

    DATA : lw_mat   TYPE zscu_itemf4.
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Contract'.
            lw_mat-ebeln = lw_filter_val-low.
          WHEN 'Material'.
            lw_mat-matnr = lw_filter_val-low.
          WHEN 'WRNo'.
            lw_mat-wrno = lw_filter_val-low.
          WHEN 'SPNo'.
            lw_mat-spno = lw_filter_val-low.
          WHEN 'Plant'.
            lw_mat-werks = lw_filter_val-low.
          WHEN 'CompCode'.
            lw_mat-compcode = lw_filter_val-low.
          WHEN 'PlantRegion'.
            lw_mat-plantregion = lw_filter_val-low.
          WHEN 'PlantJurisd'.
            lw_mat-plantjurisd = lw_filter_val-low.
          WHEN 'VendorRegion'.
            lw_mat-vendorregion = lw_filter_val-low.
          WHEN 'VendorJurisd'.
            lw_mat-vendorjurisd = lw_filter_val-low.
          WHEN 'Category'.
            lw_mat-category = lw_filter_val-low.
          WHEN 'SipNo'.
            lw_mat-sipno = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get the item F4
    CALL METHOD zclcu_sip_utility=>item_searchhelp
      EXPORTING
        is_item         = lw_mat
        iv_appindicator = 'I'
      IMPORTING
        et_data         = DATA(lt_data).

    "Netprice will be calulated at the UI level based on tiered pricing
    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
      APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<ls_entityset>).
     " MOVE-CORRESPONDING <ls_data> TO <ls_entityset>.
      <ls_entityset>-MATERIAL = <ls_data>-matnr.
      <ls_entityset>-MATDESC = <ls_data>-maktx.
      <ls_entityset>-CONTRACT = <ls_data>-ebeln.
      <ls_entityset>-UOM = <ls_data>-meins.
      <ls_entityset>-NETPRICE = <ls_data>-netpr.
      <ls_entityset>-UNITPRICE = <ls_data>-peinh.
      <ls_entityset>-NEWITEM = 'X'.


*      CLEAR <ls_entityset>-netpr.
    ENDLOOP.

    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.
  ENDMETHOD.


  METHOD itemset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 18.06.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the item details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.

    DATA : lw_item  TYPE zclcu_sip_mpc=>ts_item.

    CONSTANTS : lc_sip TYPE string VALUE 'SIPNo'.

    "get the SIP number from UI
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN lc_sip.
            lw_item-sipno = lw_filter_val-low.
          WHEN 'Scenario'.
            lw_item-category = lw_filter_val-low.
          WHEN 'AppIndicator'.
            lw_item-appindicator = lw_filter_val-low.
          WHEN 'Contract'.
            lw_item-contract = lw_filter_val-low.
          WHEN 'WorkRequestNo'.
            lw_item-workrequestno = lw_filter_val-low.
          WHEN 'SPNo'.
            lw_item-spno = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.
    "Get Item details
    CALL METHOD zclcu_w073_utility=>get_items
      EXPORTING
        is_item  = lw_item
*       iv_material_type = zif_cu_sip=>gc_active_materials
      IMPORTING
        et_items = et_entityset.

    IF lw_item-category = 'S' OR lw_item-category = 'W'.
      SORT et_entityset BY linenum counter ASCENDING.
    ENDIF.

  ENDMETHOD.


  METHOD itemmaximoset_get_entityset.
*****************************************************************************
*&  Created By             : Vignesh Sunkasi
*&  Created On             : 18.06.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the Maximo item details
*&  Transport Request No   : D10K934677
*****************************************************************************
*    CLEAR : et_entityset, es_response_context.
*
*    DATA : lv_wrno TYPE z_wrno.
*
*    "get the SIP number from UI
*    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
*      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
*      IF sy-subrc IS INITIAL.
*        CASE lw_filter_opt-property.
*          WHEN 'WorkRequestNo'.
*            lv_wrno = lw_filter_val-low.
*        ENDCASE.
*      ENDIF.
*    ENDLOOP.
*
*    "Get Item details
*    CALL METHOD zclcu_sip_utility=>get_wr_maximo
*      EXPORTING
*        iv_wrno   = lv_wrno
*      IMPORTING
*        et_maximo = et_entityset.
*
*    SORT et_entityset BY linenum ASCENDING.

  ENDMETHOD.


  method INTERNALORDERSET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->INTERNALORDERSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
    CALL METHOD zclcu_sip_utility=>get_internal_orders

      IMPORTING
        et_data        = et_entityset.

  endmethod.


  METHOD headersipwrset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 22.06.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the header details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.
    DATA : lw_header TYPE zclcu_sip_mpc=>ts_headersipwr.

    CONSTANTS : lc_sip  TYPE string VALUE 'SIPNo',
                lc_sip1 TYPE string VALUE 'SIPNO'.

    "get the SIP number from UI
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN lc_sip OR lc_sip1.
            lw_header-sipno = lw_filter_val-low.
          WHEN 'Scenario'.
            lw_header-category = lw_filter_val-low.
          WHEN 'AppIndicator'.
            lw_header-appindicator = lw_filter_val-low.
          WHEN 'Contract'.
            lw_header-contract = lw_filter_val-low.
          WHEN 'WorkRequestNo'.
            lw_header-workrequestno = lw_filter_val-low.
          WHEN 'SPNo'.
            lw_header-spno = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get the header details .
    CALL METHOD zclcu_w073_utility=>get_header
      EXPORTING
        is_header = lw_header
      IMPORTING
        et_header = et_entityset.

    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.

  ENDMETHOD.


  METHOD headersipwrset_get_entity.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 21.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the header details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : er_entity, es_response_context.
    DATA : lw_header TYPE ZCLCU_SIP_MPC=>Ts_HEADERSIPWR,
           lt_header TYPE ZCLCU_SIP_MPC=>TT_HEADERSIPWR.

    CONSTANTS : lc_sip  TYPE string VALUE 'SIPNo'.

    "get the SIP number from UI
    READ TABLE it_key_tab INTO DATA(lw_key_tab) WITH KEY name = lc_sip.
    IF sy-subrc IS INITIAL.
      lw_header-sipno = lw_key_tab-value.
    ENDIF.
    READ TABLE it_key_tab INTO lw_key_tab WITH KEY name = text-008. "'Scenario'.
    IF sy-subrc IS INITIAL.
      lw_header-category = lw_key_tab-value.
    ENDIF.
    READ TABLE it_key_tab INTO lw_key_tab WITH KEY name = text-009.
    IF sy-subrc IS INITIAL.
      lw_header-appindicator = lw_key_tab-value.
    ENDIF.
    READ TABLE it_key_tab INTO lw_key_tab WITH KEY name = text-010. "'Contract'.
    IF sy-subrc IS INITIAL.
      lw_header-contract = lw_key_tab-value.
    ENDIF.

    "Get the header details .
    CALL METHOD zclcu_w073_utility=>get_header
      EXPORTING
        is_header = lw_header
      IMPORTING
        et_header = lt_header.

      READ TABLE lt_header INTO er_entity INDEX 1.
      IF sy-subrc <> 0.
        CLEAR : er_entity.
      ENDIF.


  ENDMETHOD.


  method FPCITEMSET_GET_ENTITYSET.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 02.09.2020
*&  Functional Design Name : SWR Application
*&  Purpose                : Get the FPC item details
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.
    DATA : lw_fcpitem TYPE ZCLCU_SIP_MPC=>Ts_FPCITEM.

    "get the SIP number from UI
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'SIPNo'.
            lw_fcpitem-sipno = lw_filter_val-low.
          WHEN 'Scenario'.
*            lw_fcpitem-category = lw_filter_val-low.
          WHEN 'AppIndicator'.
            lw_fcpitem-appindicator = lw_filter_val-low.
          WHEN 'Contract'.
            lw_fcpitem-contract = lw_filter_val-low.
          WHEN 'WRNo'.
            lw_fcpitem-wrno = lw_filter_val-low.
          WHEN 'SPNo'.
            lw_fcpitem-spno = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get approved tkts
    CALL METHOD zclcu_w076_utility=>get_approved_tickets
      EXPORTING
        is_fpcitem = lw_fcpitem
      IMPORTING
        et_fpcitem = DATA(lt_item).

    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
      APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<ls_fpc>).
      CLEAR : <ls_fpc>.
      MOVE-CORRESPONDING <ls_item> TO <ls_fpc>.
*      <ls_fpc>-category = lw_fcpitem-category.
      <ls_fpc>-appindicator = lw_fcpitem-appindicator.
    ENDLOOP.
  endmethod.


  METHOD contractsearchhe_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 26.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get contracts
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR :et_entityset, es_response_context.

    DATA : lv_contract TYPE ebeln,
           lv_user     TYPE uname.

*    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
*      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
*      IF sy-subrc IS INITIAL.
*        CASE lw_filter_opt-property.
*          WHEN 'Contract'.
*            lv_contract = lw_filter_val-low.
*            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*              EXPORTING
*                input  = lv_contract
*              IMPORTING
*                output = lv_contract.
*          WHEN 'SubmittedBy'.
*            lv_user = lw_filter_val-low.
*          WHEN OTHERS.
*        ENDCASE.
*      ENDIF.
*    ENDLOOP.

    "Get contracts
    CALL METHOD zclcu_sip_utility=>get_contractsf4
      EXPORTING
        iv_contract    = lv_contract
        iv_submittedby = lv_user
      IMPORTING
        et_data        = et_entityset.

  ENDMETHOD.


  METHOD attachmentheader_get_entityset.
************************************************************************
* Program ID:      ATTACHMENTHEADER_GET_ENTITYSET
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
    CLEAR : et_entityset, es_response_context
    .
    DATA : lv_sip   TYPE z_sipno,
           lv_docid TYPE saeardoid.

    CONSTANTS : lc_sip   TYPE string VALUE 'SipNo',
                lc_docid TYPE string VALUE 'DocId'.

    "get the SIP as filter
    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN lc_sip .
            lv_sip = lw_filter_val-low.
          WHEN lc_docid.
            lv_docid = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

***Call Utility class for data
    zclcu_sip_utility=>get_atachment_header(
      EXPORTING
        iv_sipno  =   lv_sip  " SIP Number
        iv_docid  =   lv_docid
      IMPORTING
        et_output =  et_entityset  ).  " TT for SIP Attachment header details

    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.
  ENDMETHOD.


  METHOD approvalflowset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 15.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the header details
*&  Transport Request No   : D10K934677
*****************************************************************************
*    CLEAR : et_entityset, es_response_context.
*    DATA : lw_approvalflow TYPE zscu_approvalflow,
*           lv_contract     TYPE ebeln.
*
*    CONSTANTS : lc_sipno       TYPE char20 VALUE 'SIPNo'.
*
*    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
*      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
*      IF sy-subrc IS INITIAL.
*        CASE lw_filter_opt-property.
*          WHEN lc_sipno.
*            lw_approvalflow-uniqueno = lw_filter_val-low.
*          WHEN 'Scenario'.
*            lw_approvalflow-category = lw_filter_val-low.
*          WHEN 'AppIndicator'.
*            lw_approvalflow-appindicator = lw_filter_val-low.
*          WHEN 'Contract'.
*            lv_contract = lw_filter_val-low.
*            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*              EXPORTING
*                input  = lv_contract
*              IMPORTING
*                output = lw_approvalflow-contract.
*          WHEN 'Plant'.
*            lw_approvalflow-plant = lw_filter_val-low.
*          WHEN OTHERS.
*        ENDCASE.
*      ENDIF.
*    ENDLOOP.
*
*    "Get the routing details
*    CALL METHOD zclcu_sip_utility=>get_approvalflow
*      EXPORTING
*        is_approvalflow = lw_approvalflow
*      IMPORTING
*        et_data         = et_entityset.
*
*         SORT et_entityset ASCENDING BY uniqueno ordernum.

  ENDMETHOD.


  METHOD activityset_get_entityset.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 18.08.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Get the activities based on material and plant
*&  Transport Request No   : D10K934677
*****************************************************************************
    CLEAR : et_entityset, es_response_context.
    DATA : lv_matnr TYPE matnr,
           lv_plant TYPE werks_d.

    LOOP AT it_filter_select_options INTO DATA(lw_filter_opt).
      READ TABLE lw_filter_opt-select_options INTO DATA(lw_filter_val) INDEX 1.
      IF sy-subrc IS INITIAL.
        CASE lw_filter_opt-property.
          WHEN 'Material'.
            lv_matnr = lw_filter_val-low.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_matnr
              IMPORTING
                output = lv_matnr.
          WHEN 'Plant'.
            lv_plant = lw_filter_val-low.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    "Get the activity details
    CALL METHOD zclcu_sip_utility=>get_activities
      EXPORTING
        iv_matnr = lv_matnr
        iv_plant = lv_plant
      IMPORTING
        et_data  = et_entityset.

    IF et_entityset IS INITIAL.
* Raise Exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = TEXT-006.

    ENDIF.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.
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

**----------------------------------------------------------------------*
**Local Structures
**----------------------------------------------------------------------*
    CLEAR : er_stream, es_response_context.
    DATA : lw_stream         TYPE ty_s_media_resource,
           lw_converted_keys TYPE zscu_sip_attach,
           lv_error_flag     TYPE boolean,
           lw_header         TYPE ihttpnvp.

* Get key table information
    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values  = lw_converted_keys ).

* Get Doc Type based on Doc ID
    SELECT  filename, "#EC CI_NOFIELD
            doctype FROM ztcu_sip_attach
                INTO @DATA(lw_sip_attach)
                UP TO 1 ROWS
      WHERE docid = @lw_converted_keys-docid.
    ENDSELECT.
    IF sy-subrc <> 0.
      CLEAR: lw_converted_keys-doctype.
    ELSE.
      lw_converted_keys-doctype = lw_sip_attach-doctype.
      lw_converted_keys-filename = lw_sip_attach-filename.
      TRANSLATE lw_converted_keys-doctype TO UPPER CASE.
    ENDIF.

***Call Utility class for data
    zclcu_sip_utility=>get_document(
      IMPORTING
        ev_error_flag    =   lv_error_flag               " Single-Character Flag
        es_stream        =   lw_stream               " Media Resource information
        es_header        =   lw_header               " HTTP Framework (iHTTP) Name/Value Pair
      CHANGING
        cs_attachdeatils =  lw_converted_keys   ).     " SIP Attachment header details

    set_header( is_header = lw_header ).
    IF lv_error_flag = abap_false.
****passing DATA to entity
      copy_data_to_ref( EXPORTING is_data = lw_stream
                        CHANGING  cr_data = er_stream ).
    ENDIF.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 06.07.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Validations
*&  Transport Request No   : D10K934677
*****************************************************************************
    DATA: lv_msg       TYPE bapi_msg,
          lv_datakey   TYPE z_workflowid,
          lw_userid    TYPE zclcu_sip_mpc=>ts_rolebaseduserid,
          lw_return    TYPE zclcu_sip_mpc=>ts_return,
          lt_userid    TYPE zclcu_sip_mpc=>tt_rolebaseduserid,
          lw_approvers TYPE zclcu_sip_mpc=>ts_auditlog_approvers,
          lt_return    TYPE zclcu_sip_mpc=>tt_return.

    CONSTANTS: lc_val_mat        TYPE string VALUE 'ValidateMaterial',
               lc_contract       TYPE string VALUE 'ValidateContract',
               lc_userid         TYPE string VALUE 'ValidateApprVerifier',
               lc_invoice        TYPE string VALUE 'ValidateInvoice',
               lc_pricedisplay   TYPE string VALUE 'ValidatePriceDisplay',
               lc_updatestatus   TYPE string VALUE 'UpdateStatus',
               lc_valmatstate    TYPE string VALUE 'ValidateMatState',
               lc_getapprovers   TYPE string VALUE 'GetApprovers',
               lc_validateaccess TYPE string VALUE 'ValidateAccess',
               lc_success        TYPE string VALUE 'S'.

    CLEAR: er_data.

    "Function Imports
    CASE iv_action_name.
      WHEN lc_val_mat.
        IF it_parameter IS NOT INITIAL.
          "Validate material
          CALL METHOD zclcu_sip_utility=>validate_material
            EXPORTING
              it_input  = it_parameter
            IMPORTING
              es_return = lw_return.
        ENDIF.

      WHEN lc_contract.
        "Validate Contract
        CALL METHOD zclcu_sip_utility=>validate_contract
          EXPORTING
            it_input  = it_parameter
          IMPORTING
            es_return = lw_return.

      WHEN lc_validateaccess.
        "Validate Access
        CALL METHOD zclcu_sip_utility=>validate_access
          EXPORTING
            it_input  = it_parameter
          IMPORTING
            es_return = lw_return.

        APPEND lw_return TO lt_return.
        "Valid
        copy_data_to_ref( EXPORTING is_data = lt_return
                      CHANGING cr_data = er_data ).

        DATA(lv_validateaccess) = abap_true.

      WHEN lc_invoice.
        "Validate Contract
        CALL METHOD zclcu_sip_utility=>validate_invoice
          EXPORTING
            it_input  = it_parameter
          IMPORTING
            es_return = lw_return.

        APPEND lw_return TO lt_return.

        copy_data_to_ref( EXPORTING is_data = lt_return
                          CHANGING cr_data  = er_data ).

        DATA(lv_validateinvoice) = abap_true.

      WHEN lc_pricedisplay.
        "Validate Price Display Authorization
        CALL METHOD zclcu_sip_utility=>validate_price_display
          EXPORTING
            it_input  = it_parameter
          IMPORTING
            es_return = lw_return.

      WHEN lc_userid.
        CALL METHOD zclcu_sip_utility=>validate_userid
          EXPORTING
            it_input  = it_parameter
          IMPORTING
            es_return = lw_userid.

        IF lw_userid-type = lc_success.
          APPEND lw_userid TO lt_userid.
          "Valid
          copy_data_to_ref( EXPORTING is_data = lt_userid
                        CHANGING cr_data = er_data ).
        ELSE.
          "Invalid
          lv_msg = lw_userid-message.
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
              textid  = /iwbep/cx_mgw_busi_exception=>business_error
              message = lv_msg.
        ENDIF.

      WHEN lc_updatestatus.
        CALL METHOD zclcu_sip_utility=>update_status
          EXPORTING
            it_input  = it_parameter
          IMPORTING
            es_return = lw_return.

      WHEN lc_valmatstate.
        CALL METHOD zclcu_sip_utility=>validate_mat_state
          EXPORTING
            it_input  = it_parameter
          IMPORTING
            es_return = lw_return.

      WHEN lc_getapprovers.
        READ TABLE it_parameter ASSIGNING FIELD-SYMBOL(<ls_parameter>) WITH KEY name = 'SIPNo'. "#EC CI_STDSEQ
        IF sy-subrc EQ 0.
          lv_datakey = <ls_parameter>-value.
        ENDIF.

        IF lv_datakey IS NOT INITIAL.
          CALL METHOD zclcu_sip_utility=>get_approvers_auditlog
            EXPORTING
              iv_datakey   = lv_datakey
            IMPORTING
              ev_approvers = DATA(lv_approvers).

          lw_approvers-sipno = lv_datakey.
          lw_approvers-approvers = lv_approvers.

          copy_data_to_ref( EXPORTING is_data = lw_approvers
                CHANGING cr_data = er_data ).

        ELSE.
          MESSAGE e005(zcu_msg) INTO lv_msg.
          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
              textid  = /iwbep/cx_mgw_busi_exception=>business_error
              message = lv_msg.
        ENDIF.

      WHEN OTHERS.
        MESSAGE e005(zcu_msg) INTO lv_msg.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid  = /iwbep/cx_mgw_busi_exception=>business_error
            message = lv_msg.
    ENDCASE.

    IF lw_userid         IS INITIAL AND
       lv_datakey        IS INITIAL AND
       lv_validateaccess IS INITIAL AND
       lv_validateinvoice IS INITIAL.

      IF lw_return-type = lc_success.
        APPEND lw_return TO lt_return.
        CLEAR : lw_return.
        "Valid
        copy_data_to_ref( EXPORTING is_data = lt_return
                      CHANGING cr_data = er_data ).
      ELSE.
        "Invalid
        lv_msg = lw_return-message.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid  = /iwbep/cx_mgw_busi_exception=>business_error
            message = lv_msg.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~changeset_process.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 23.06.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Save/Submit
*&  Transport Request No   : D10K934677
*****************************************************************************


    CLEAR : ct_changeset_response.
    DATA : lo_request_context    TYPE REF TO /iwbep/if_mgw_req_entity_c,
           lv_sip                TYPE z_sipno,
*           lv_sip                TYPE char20,
           lw_changeset_response TYPE /iwbep/if_mgw_appl_types=>ty_s_changeset_response, "Change set Response
           lw_header             TYPE zscu_header,
           lw_items              TYPE zscu_item,
           lw_items_inactive     TYPE zscu_item,
           lw_fcpitems           TYPE zscu_sip_fpc,
           lw_deep_struc         TYPE zscu_deep_struc,
           lw_attachheader       TYPE zscu_sip_attach,
           lt_attach_cs          TYPE ZTTCU_ATTACH,
           lw_media_slug         TYPE zclcu_sip_utility=>ty_s_media_slug,
           lw_delete             TYPE REF TO /iwbep/if_mgw_req_entity_d ##NEEDED,
           lt_key_tab            TYPE /iwbep/t_mgw_name_value_pair,
           lw_routing            TYPE zscu_approvalflow,
           lt_return             TYPE bapiret2_t,
           lt_deep_struc         TYPE zttcu_deep_struc,
           lt_media_slug         TYPE zclcu_sip_utility=>ty_t_media_slug.

    TRY.
        " START Processing changeset process operations
        IF it_changeset_request IS NOT INITIAL.
          " Handle consecutive operations with the same operation types
          LOOP AT it_changeset_request ASSIGNING FIELD-SYMBOL(<ls_request>)
                                        GROUP BY ( operation_type = <ls_request>-operation_type ) DESCENDING
                                        REFERENCE INTO DATA(lr_changeset_group).
            CASE lr_changeset_group->operation_type.
                "Post
              WHEN /iwbep/if_mgw_appl_types=>gcs_operation_type-create_entity.
                UNASSIGN:<ls_request>.

                LOOP AT  GROUP lr_changeset_group ASSIGNING <ls_request>.
                  DATA(lv_entity_type) = CAST /iwbep/if_mgw_req_entity_c( <ls_request>-request_context )->get_entity_type_name( ).
                  CASE lv_entity_type.
                      "HeaderSet
                    WHEN TEXT-001.
                      <ls_request>-entry_provider->read_entry_data(
                                                              IMPORTING es_data = lw_header ).
                      "Append to deep structure
                      lw_deep_struc-header = lw_header.
                      "Check if the SIP no is already created
                      IF lw_header-sipno IS INITIAL.
                        DATA(lv_create_sip) = abap_true.
                      ENDIF.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR : lw_deep_struc-header.
                      "ItemSet
                    WHEN TEXT-002.
                      <ls_request>-entry_provider->read_entry_data(
                                                             IMPORTING es_data = lw_items ).
                      "Append to deep structure
                      lw_deep_struc-items = lw_items.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR: lw_deep_struc-items.
                      "Inactive Itemset
                    WHEN TEXT-013.
                      <ls_request>-entry_provider->read_entry_data(
                                                             IMPORTING es_data = lw_items_inactive ).
                      "Append to deep structure
                      lw_deep_struc-items_inactive = lw_items_inactive.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR: lw_deep_struc-items_inactive.
                      "FPC item
                    WHEN TEXT-012.
                      <ls_request>-entry_provider->read_entry_data(
                                                             IMPORTING es_data = lw_fcpitems ).
                      "Append to deep structure
                      lw_deep_struc-fpc_item = lw_fcpitems.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR: lw_deep_struc-fpc_item.
                      "Approval Flow
                    WHEN TEXT-004.
                      <ls_request>-entry_provider->read_entry_data( IMPORTING es_data = lw_routing ).
                      lw_deep_struc-routing = lw_routing.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR: lw_deep_struc-routing.
                      "Attachment Header
                    WHEN TEXT-011.
                      <ls_request>-entry_provider->read_entry_data( IMPORTING es_data = lw_attachheader ).
                      lw_deep_struc-attachheader = lw_attachheader.
                      APPEND lw_deep_struc TO lt_deep_struc.
                      CLEAR: lw_deep_struc-attachheader.

                    WHEN OTHERS.
                      "Operation not supported
                      RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
                        EXPORTING
                          textid = /iwbep/cx_mgw_tech_exception=>operation_not_supported.
                  ENDCASE.
                ENDLOOP.
              WHEN /iwbep/if_mgw_appl_types=>gcs_operation_type-create_stream.
                UNASSIGN:<ls_request>.

                LOOP AT  GROUP lr_changeset_group ASSIGNING <ls_request>.
                  lv_entity_type = CAST /iwbep/if_mgw_req_entity_c( <ls_request>-request_context )->get_entity_type_name( ).
                  CASE lv_entity_type.
                    WHEN TEXT-005.      "Attachment Document
                      lw_media_slug-media_resource = <ls_request>-media_resource.
                      lw_media_slug-slug = <ls_request>-slug.
                      APPEND lw_media_slug TO lt_media_slug.
                      CLEAR : lw_media_slug.
                    WHEN OTHERS.
                      "Operation not supported
                      RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
                        EXPORTING
                          textid = /iwbep/cx_mgw_tech_exception=>operation_not_supported.
                  ENDCASE.
                ENDLOOP.
            ENDCASE.
          ENDLOOP.


          "Save all tabs
          IF lt_deep_struc IS NOT INITIAL.
            IF lv_create_sip = abap_true.
              CALL METHOD zclcu_sip_utility=>populate_uniqueid
                EXPORTING
                  iv_appindicator = 'I'
                IMPORTING
                  ev_uniqueid     = DATA(lv_uniqueno).

              lv_sip = lv_uniqueno.

            ENDIF.
            "Save/Submit
            CALL METHOD zclcu_w073_utility=>batch_process
              EXPORTING
                it_deep_struc = lt_deep_struc
                iv_sipno      = lv_sip
                it_media_slug = lt_media_slug
                it_key_tab    = lt_key_tab
              CHANGING
                ct_return     = lt_return
                ct_attach_cs  = lt_attach_cs.

            IF lt_return IS INITIAL.
              LOOP AT it_changeset_request INTO DATA(lw_changeset_request).
                lo_request_context ?= lw_changeset_request-request_context.
                lv_entity_type = lo_request_context->get_entity_type_name( ).

                CASE lv_entity_type.
                  WHEN TEXT-001.  "Header
                    IF lv_create_sip = abap_true.
                      lw_header-sipno = lv_sip.
                    ENDIF.
                    copy_data_to_ref(
                      EXPORTING
                        is_data = lw_header
                      CHANGING
                        cr_data = lw_changeset_response-entity_data ).

                    lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                    INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                  WHEN TEXT-002. "Item
                    IF lv_create_sip = abap_true.
                      lw_items-sipno = lv_sip.
                    ENDIF.
                    copy_data_to_ref(
                    EXPORTING
                      is_data = lw_items
                    CHANGING
                      cr_data = lw_changeset_response-entity_data ).

                    lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                    INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                  WHEN TEXT-013. "Inactive Item
                    IF lv_create_sip = abap_true.
                      lw_items_inactive-sipno = lv_sip.
                    ENDIF.
                    copy_data_to_ref(
                    EXPORTING
                      is_data = lw_items_inactive
                    CHANGING
                      cr_data = lw_changeset_response-entity_data ).

                    lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                    INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                  WHEN TEXT-005. "Attach Document
                    copy_data_to_ref(
                    EXPORTING
                      is_data = lt_attach_cs
                    CHANGING
                      cr_data = lw_changeset_response-entity_data ).

                    lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                    INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                  WHEN TEXT-004. "Routing
                    IF lv_create_sip = abap_true.
                      lw_routing-uniqueno = lv_sip.
                    ENDIF.
                    copy_data_to_ref(
                    EXPORTING
                      is_data = lw_routing
                    CHANGING
                      cr_data = lw_changeset_response-entity_data ).

                    lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                    INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                  WHEN TEXT-012. "FPC Item
                    IF lv_create_sip = abap_true.
                      lw_fcpitems-sipno = lv_sip.
                    ENDIF.
                    copy_data_to_ref(
                    EXPORTING
                      is_data = lw_fcpitems
                    CHANGING
                      cr_data = lw_changeset_response-entity_data ).

                    lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                    INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                  WHEN TEXT-011. "Attachment Header
                    IF lv_create_sip = abap_true.
                      lw_routing-uniqueno = lv_sip.
                    ENDIF.

                    copy_data_to_ref(
                    EXPORTING
                      is_data = lw_attachheader
                    CHANGING
                      cr_data = lw_changeset_response-entity_data ).

                    lw_changeset_response-operation_no = lw_changeset_request-operation_no.
                    INSERT lw_changeset_response INTO TABLE ct_changeset_response.

                  WHEN OTHERS.
                    "Operation not supported
                    RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception
                      EXPORTING
                        textid = /iwbep/cx_mgw_tech_exception=>operation_not_supported.
                ENDCASE.
              ENDLOOP.
            ELSE.
              "any errors
              mo_context->get_message_container( )->add_messages_from_bapi(
                  it_bapi_messages         = lt_return
                  iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first
                  iv_add_to_response_header = abap_true ).
**Raise exception
              RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
                EXPORTING
                  textid            = /iwbep/cx_mgw_busi_exception=>business_error
                  message_container = mo_context->get_message_container( ).
            ENDIF.
          ENDIF.
        ENDIF.
      CATCH /iwbep/cx_mgw_busi_exception  ##NO_HANDLER.
      CATCH /iwbep/cx_mgw_tech_exception  ##NO_HANDLER.

    ENDTRY.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~changeset_begin.
*****************************************************************************
*&  Created By             : Kripa S Patil
*&  Created On             : 22.06.2020
*&  Functional Design Name : SIP and Work Request Application
*&  Purpose                : Initiate the batch processing
*&  Transport Request No   : D10K934677
*****************************************************************************
    cv_defer_mode = abap_true.

  ENDMETHOD.
ENDCLASS.
