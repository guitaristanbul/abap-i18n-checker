*&---------------------------------------------------------------------*
*& Report zi18nchk_checker
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zi18nchk_checker.

DATA: bsp_name TYPE o2applname,
      language TYPE c LENGTH 15.

SELECTION-SCREEN BEGIN OF BLOCK base_crit WITH FRAME TITLE TEXT-b01.
  SELECT-OPTIONS: s_bspapp FOR bsp_name NO INTERVALS OBLIGATORY.
  PARAMETERS: p_basel TYPE c LENGTH 15 DEFAULT 'en' LOWER CASE.
  SELECT-OPTIONS: s_trgtl FOR language LOWER CASE NO INTERVALS OBLIGATORY.
SELECTION-SCREEN END OF BLOCK base_crit.


START-OF-SELECTION.
  TRY.
      DATA(i18n_checker) = NEW zcl_i18nchk_checker(
        bsp_name_range   = s_bspapp[]
        target_languages = VALUE #( FOR trgt_lang IN s_trgtl[] ( |{ trgt_lang-low }| ) ) ).
      i18n_checker->check_translations( ).
    CATCH zcx_i18nchk_error INTO DATA(error).
      WRITE: /  error->get_text( ).
  ENDTRY.

end-of-SELECTION.
  DATA(check_results) = i18n_checker->get_check_result( ).
  DATA(repos_without_errors_count) = 0.
  DATA(repos_with_errors_count) = 0.
  LOOP AT check_results ASSIGNING FIELD-SYMBOL(<check_result>).
    IF <check_result>-status = 'S'.
    ELSE.
      ADD 1 TO repos_with_errors_count.
    ENDIF.
  ENDLOOP.
  WRITE: / |Number of UI5 repositories with i18n errors: { repos_with_errors_count }| COLOR COL_NEGATIVE.
  WRITE: / |Number of UI5 repositories without i18n errors: { repos_with_errors_count }| COLOR COL_POSITIVE.
