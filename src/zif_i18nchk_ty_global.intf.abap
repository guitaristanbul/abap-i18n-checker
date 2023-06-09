"! <p class="shorttext synchronized" lang="en">Global types for i18n check</p>
INTERFACE zif_i18nchk_ty_global
  PUBLIC .

  TYPES:
    ty_i18n_languages    TYPE string_table,
    ty_ignore_uuid_range TYPE RANGE OF sysuuid_x16,
    ty_bsp_range         TYPE RANGE OF o2applname,
    ty_bsp_names         TYPE STANDARD TABLE OF o2applname WITH EMPTY KEY,
    ty_comment_patterns  TYPE RANGE OF string,
    "! <p class="shorttext synchronized" lang="en">Type of message in i18n check</p>
    ty_message_type      TYPE syst_msgv,

    BEGIN OF ty_i18n_text,
      key   TYPE string,
      value TYPE string,
    END OF ty_i18n_text,

    ty_i18n_texts TYPE STANDARD TABLE OF ty_i18n_text WITH KEY key,

    "! <p class="shorttext synchronized" lang="en">Information about BSP</p>
    BEGIN OF ty_bsp_info,
      bsp_name TYPE o2applname,
      git_url  TYPE string,
    END OF ty_bsp_info,

    ty_bsP_infos TYPE STANDARD TABLE OF ty_bsp_info WITH EMPTY KEY,

    "! <p class="shorttext synchronized" lang="en">UI5 repository data</p>
    BEGIN OF ty_ui5_repo,
      name               TYPE o2appl-applname,
      description        TYPE o2applt-text,
      id                 TYPE string,
      i18n_map_entries   TYPE /ui5/ui5_rep_path_map_t,
      manifest_map_entry TYPE /ui5/ui5_rep_path_map_s,
      library_map_entry  TYPE /ui5/ui5_rep_path_map_s,
      is_app             TYPE abap_bool,
    END OF ty_ui5_repo,

    "! <p class="shorttext synchronized" lang="en">Describes i18n translation file</p>
    BEGIN OF ty_i18n_file,
      path     TYPE string,
      name     TYPE string,
      language TYPE string,
    END OF ty_i18n_file,

    "! <p class="shorttext synchronized" lang="en">Check result for specific i18n file</p>
    BEGIN OF ty_i18n_check_result,
      file           TYPE ty_i18n_file,
      ign_entry_uuid TYPE sysuuid_x16,
      message        TYPE string,
      message_type   TYPE ty_message_type,
      sy_msg_type    TYPE sy-msgty,
      key            TYPE string,
      value          TYPE string,
      default_value  TYPE string,
    END OF ty_i18n_check_result,
    ty_i18n_check_results TYPE SORTED TABLE OF ty_i18n_check_result WITH NON-UNIQUE KEY file message_type,

    "! <p class="shorttext synchronized" lang="en">Check result for a single BSP (UI5 Repository)</p>
    BEGIN OF ty_check_result,
      bsp_name      TYPE o2applname,
      git_url       TYPE string,
      is_app        TYPE abap_bool,
      description   TYPE o2descr,
      status        TYPE sy-msgty,
      checked_files TYPE i,
      i18n_results  TYPE ty_i18n_check_results,
    END OF ty_check_result,

    ty_check_results TYPE STANDARD TABLE OF ty_check_result WITH KEY bsp_name.

  TYPES BEGIN OF ty_i18n_ignored_entry.
  INCLUDE TYPE zi18nchk_ignr.
  TYPES ignored TYPE abap_bool.
  TYPES END OF ty_i18n_ignored_entry.

  TYPES BEGIN OF ty_i18n_file_int.
  INCLUDE TYPE zif_i18nchk_ty_global=>ty_i18n_file.
  TYPES rep_map TYPE /ui5/ui5_rep_path_map_s.
  TYPES END OF ty_i18n_file_int.

  TYPES:
    ty_i18n_files_int       TYPE STANDARD TABLE OF ty_i18n_file_int WITH EMPTY KEY,
    ty_i18n_ignored_entries TYPE SORTED TABLE OF ty_i18n_ignored_entry WITH NON-UNIQUE KEY file_path file_name message_type i18n_key.
ENDINTERFACE.
