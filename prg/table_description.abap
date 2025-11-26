*&---------------------------------------------------------------------*
*& Report ZDEMO_DESCRIPTION_TABLE
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
REPORT ZDEMO_DESCRIPTION_TABLE.

PARAMETERS: p_tab TYPE tabname OBLIGATORY.

DATA: lo_struct     TYPE REF TO cl_abap_structdescr,
      lo_table      TYPE REF TO cl_abap_tabledescr,
      lo_table2      TYPE REF TO cl_abap_tabledescr,
      lo_data       TYPE REF TO data,
      lt_components TYPE cl_abap_structdescr=>component_table,
      ls_comp       LIKE LINE OF lt_components,
      lo_alv        TYPE REF TO cl_salv_table.

FIELD-SYMBOLS: <fs_table> TYPE STANDARD TABLE,
               <fs_table2> TYPE STANDARD TABLE,
               <fs_wa>    TYPE ANY.

*** Describe structure by table name***
TRY.
    lo_struct ?= cl_abap_typedescr=>describe_by_name( p_tab ).
 CATCH cx_sy_struct_creation.
    MESSAGE 'Table/Structure does not exist!' TYPE 'E'.
ENDTRY.

***Create dynamic internal table***
lo_table = cl_abap_tabledescr=>create( lo_struct ).
CREATE DATA lo_data TYPE HANDLE lo_table.
ASSIGN lo_data->* TO <fs_table>.

SELECT * FROM (p_tab) INTO TABLE <fs_table> UP TO 200 ROWS.

IF <fs_table> IS INITIAL.
  MESSAGE 'No data found in the table' TYPE 'I'.
  EXIT.
ENDIF.

***Display ALV dynamically***
TRY.
    cl_salv_table=>factory(
      IMPORTING r_salv_table = lo_alv
      CHANGING t_table       = <fs_table>
    ).
    lo_alv->display( ).
  CATCH cx_salv_msg.
    MESSAGE 'ALV Display error' TYPE 'E'.
ENDTRY.
