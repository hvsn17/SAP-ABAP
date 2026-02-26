CLASS lcl_buffer DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.

    TYPES: BEGIN OF ty_buffer,
             flag    TYPE c LENGTH 1,
             lv_data TYPE Z22057_EMP,
           END OF ty_buffer.

    CLASS-DATA mt_buffer TYPE STANDARD TABLE OF ty_buffer WITH EMPTY KEY.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO lcl_buffer.

    METHODS add_to_buffer
      IMPORTING
        iv_flag     TYPE c
        is_employee TYPE Z22057_EMP.

  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO lcl_buffer.

ENDCLASS.



CLASS lcl_buffer IMPLEMENTATION.

  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW #( ).
    ENDIF.
    ro_instance = go_instance.
  ENDMETHOD.

  METHOD add_to_buffer.
    INSERT VALUE ty_buffer(
            flag    = iv_flag
            lv_data = is_employee )
      INTO TABLE mt_buffer.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_EMP DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR emp RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE emp.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE emp.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE emp.

    METHODS read FOR READ
      IMPORTING keys FOR READ emp RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK emp.

ENDCLASS.



CLASS lhc_EMP IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.


  METHOD create.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).

      DATA ls_employee TYPE Z22057_EMP.

      ls_employee-emp_id        = <ls_entity>-EmpId.
      ls_employee-first_name    = <ls_entity>-FirstName.
      ls_employee-last_name     = <ls_entity>-LastName.
      ls_employee-date_of_birth = <ls_entity>-DateOfBirth.
      ls_employee-email         = <ls_entity>-Email.
      ls_employee-hire_date     = <ls_entity>-HireDate.
      ls_employee-salary        = <ls_entity>-Salary.
      ls_employee-curry         = <ls_entity>-Curry.

      lo_buffer->add_to_buffer(
        iv_flag     = 'C'
        is_employee = ls_employee ).

      INSERT VALUE #(
        %cid  = <ls_entity>-%cid
        EmpId = ls_employee-emp_id )
        INTO TABLE mapped-emp.

    ENDLOOP.
  ENDMETHOD.


  METHOD update.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).

      DATA ls_db TYPE Z22057_EMP.

      SELECT SINGLE *
        FROM Z22057_EMP
        WHERE emp_id = @<ls_entity>-EmpId
        INTO @ls_db.

      IF <ls_entity>-FirstName IS NOT INITIAL.
        ls_db-first_name = <ls_entity>-FirstName.
      ENDIF.

      IF <ls_entity>-LastName IS NOT INITIAL.
        ls_db-last_name = <ls_entity>-LastName.
      ENDIF.

      IF <ls_entity>-DateOfBirth IS NOT INITIAL.
        ls_db-date_of_birth = <ls_entity>-DateOfBirth.
      ENDIF.

      IF <ls_entity>-Email IS NOT INITIAL.
        ls_db-email = <ls_entity>-Email.
      ENDIF.

      IF <ls_entity>-HireDate IS NOT INITIAL.
        ls_db-hire_date = <ls_entity>-HireDate.
      ENDIF.

      IF <ls_entity>-Salary IS NOT INITIAL.
        ls_db-salary = <ls_entity>-Salary.
      ENDIF.

      IF <ls_entity>-Curry IS NOT INITIAL.
        ls_db-curry = <ls_entity>-Curry.
      ENDIF.

      lo_buffer->add_to_buffer(
        iv_flag     = 'U'
        is_employee = ls_db ).

      INSERT VALUE #(
        %cid  = <ls_entity>-%pid
        EmpId = ls_db-emp_id )
        INTO TABLE mapped-emp.

    ENDLOOP.
  ENDMETHOD.


  METHOD delete.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      DATA ls_employee TYPE Z22057_EMP.
      ls_employee-emp_id = <ls_key>-EmpId.

      lo_buffer->add_to_buffer(
        iv_flag     = 'D'
        is_employee = ls_employee ).

      INSERT VALUE #(
        %cid  = <ls_key>-%pid
        EmpId = <ls_key>-EmpId )
        INTO TABLE mapped-emp.

    ENDLOOP.
  ENDMETHOD.


  METHOD read.
    SELECT *
      FROM Z22057_EMP
      FOR ALL ENTRIES IN @keys
      WHERE emp_id = @keys-EmpId
      INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.


  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z22057_I_EMP DEFINITION
  INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS adjust_numbers REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.



CLASS lsc_Z22057_I_EMP IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD adjust_numbers.
  ENDMETHOD.

  METHOD save.

    LOOP AT lcl_buffer=>mt_buffer ASSIGNING FIELD-SYMBOL(<ls_buf>).

      CASE <ls_buf>-flag.

        WHEN 'C'.
          INSERT Z22057_EMP FROM @<ls_buf>-lv_data.

        WHEN 'U'.
          UPDATE Z22057_EMP FROM @<ls_buf>-lv_data.

        WHEN 'D'.
          DELETE FROM Z22057_EMP
            WHERE emp_id = @<ls_buf>-lv_data-emp_id.

      ENDCASE.

    ENDLOOP.

    CLEAR lcl_buffer=>mt_buffer.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
