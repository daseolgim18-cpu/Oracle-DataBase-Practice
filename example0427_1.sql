SET SERVEROUTPUT ON;

DECLARE
    V_NUM NUMBER := 0;
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE('현재 V_NUM : ' || V_NUM);
        V_NUM := V_NUM + 1;
        EXIT WHEN V_NUM > 4;
    END LOOP;
END;

DECLARE
    V_NUM NUMBER := 0;
BEGIN
    WHILE V_NUM < 4 LOOP
         DBMS_OUTPUT.PUT_LINE('현재 V_NUM : ' || V_NUM);
         V_NUM := V_NUM + 1;
    END LOOP;
END;

BEGIN
    FOR i IN 0..4 LOOP
        DBMS_OUTPUT.PUT_LINE('현재 i의 값 : ' || i);
    END LOOP;
END;

BEGIN
    FOR i IN 0..4 LOOP
        CONTINUE WHEN MOD(i, 2) = 1;
        DBMS_OUTPUT.PUT_LINE('현재 i의 값 : ' || i);
    END LOOP;
END;

CREATE OR REPLACE PROCEDURE pro_noparam
IS
    V_EMPNO NUMBER(4) := 7788;
    V_ENAME VARCHAR2(10);
BEGIN
    V_ENAME := 'SCOTT';
    DBMS_OUTPUT.PUT_LINE('V_EMPNO : ' || V_EMPNO);
    DBMS_OUTPUT.PUT_LINE('V_ENAME : ' || V_ENAME);
END;

EXECUTE pro_noparam;

CREATE OR REPLACE PROCEDURE pro_param_in
(
    param1 IN NUMBER,
    param2 in NUMBER,
    param3 NUMBER := 3,
    param4 NUMBER DEFAULT 4
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('param1 : ' || param1);
    DBMS_OUTPUT.PUT_LINE('param2 : ' || param2);
    DBMS_OUTPUT.PUT_LINE('param3 : ' || param3);
    DBMS_OUTPUT.PUT_LINE('param4 : ' || param4);
END;

EXECUTE pro_param_in(1,2,9,8);
EXECUTE pro_param_in(1, 2);
EXECUTE pro_param_in(1); -- param2 값을 입력받지 않았음
EXECUTE pro_param_in(param1 => 10, param2 => 20);

CREATE OR REPLACE PROCEDURE pro_param_in
(
    param1 IN NUMBER,
    param2 NUMBER
)
IS
    param3 NUMBER := 3;
    param4 NUMBER DEFAULT 4;
BEGIN
    DBMS_OUTPUT.PUT_LINE('param1 : ' || param1);
    DBMS_OUTPUT.PUT_LINE('param2 : ' || param2);
    DBMS_OUTPUT.PUT_LINE('param3 : ' || param3);
    DBMS_OUTPUT.PUT_LINE('param4 : ' || param4);
END;

EXECUTE pro_param_in(1,2,9,8); -- 매개변수 입력받는 개수 초과
EXECUTE pro_param_in(1, 2);
EXECUTE pro_param_in(1);
EXECUTE pro_param_in(param1 => 10, param2 => 20);

CREATE OR REPLACE PROCEDURE pro_param_out
(
    in_empno IN EMP.EMPNO%TYPE,
    out_ename OUT EMP.ENAME%TYPE,
    out_sal OUT EMP.SAL%TYPE
)
IS
BEGIN
    SELECT ENAME, SAL INTO out_ename, out_sal
    FROM EMP
    WHERE EMPNO = in_empno;
END pro_param_out;

DECLARE
    v_ename EMP.ENAME%TYPE;
    v_sal EMP.SAL%TYPE;
BEGIN
    pro_param_out(7788, v_ename, v_sal);
    DBMS_OUTPUT.PUT_LINE('ENAME : ' || v_ename);
    DBMS_OUTPUT.PUT_LINE('SAL : ' || v_sal);
END;
/

CREATE OR REPLACE PROCEDURE pro_param_inout
(
    inout_no IN OUT NUMBER
)
IS
BEGIN
    inout_no := inout_no * 2;
END pro_param_inout;

DECLARE
    no NUMBER;
BEGIN
    no := 5;
    pro_param_inout(no);
    DBMS_OUTPUT.PUT_LINE('no : ' || no);
END;

CREATE OR REPLACE FUNCTION func_aftertax(
    sal IN NUMBER
)
RETURN NUMBER
IS
    tax NUMBER := 0.05;
BEGIN
    RETURN (ROUND(sal - (sal * tax)));
END func_aftertax;

DECLARE
    aftertax NUMBER;
BEGIN
    aftertax := func_aftertax(3000);
    DBMS_OUTPUT.PUT_LINE('after-tax income : ' || aftertax);
END;

SELECT EMPNO, ENAME, SAL, func_aftertax(SAL) AS AFTERTAX
FROM EMP;

CREATE TABLE EMP_TRG AS SELECT * FROM EMP;

CREATE OR REPLACE TRIGGER trg_emp_nodml_weekend
BEFORE
INSERT OR UPDATE OR DELETE ON EMP_TRG
BEGIN
    IF TO_CHAR(sysdate, 'DY') IN ('토', '일') THEN
        IF INSERTING THEN
            raise_application_error(-20000, '주말 사원정보 추가 불가');
        ELSIF UPDATING THEN
            raise_application_error(-20001, '주말 사원정보 수정 불가');
        ELSIF DELETING THEN
            raise_application_error(-20002, '주말 사원정보 삭제 불가');
        ELSE
            raise_application_error(-20003, '주말 사원정보 변경 불가');
        END IF;
    END IF;
END;
/

SELECT * FROM  EMP_TRG_LOG;

SELECT * FROM EMP_TRG;

CREATE OR REPLACE TRIGGER trg_emp_log
AFTER
INSERT OR UPDATE OR DELETE ON EMP_TRG
FOR EACH ROW

BEGIN
    IF INSERTING THEN
        INSERT INTO emp_trg_log
        VALUES ('EMP_TRG', 'INSERT', :new.empno,
            SYS_CONTEXT('USERENV', 'SESSION_USER'), sysdate);
    ELSIF UPDATING THEN
        INSERT INTO emp_trg_log
        VALUES ('EMP_TRG', 'UPDATE', :old.empno,
         SYS_CONTEXT('USERENV', 'SESSION_USER'), sysdate);
    ELSIF DELETING THEN
        INSERT INTO emp_trg_log
        VALUES ('EMP_TRG', 'DELETE', :old.empno,
            SYS_CONTEXT('USERENV', 'SESSION_USER'), sysdate);
    END IF;
END;

INSERT INTO EMP_TRG
VALUES(9999, 'TestEmp', 'CLERK', 7788,
    TO_DATE('2018-03-03', 'YYYY-MM-DD'), 1200, null, 20);
    
COMMIT;

SELECT * FROM EMP_TRG;

SELECT * FROM EMP_TRG_LOG;

UPDATE EMP_TRG SET SAL = 1300 WHERE MGR = 7788;

COMMIT;

SELECT TRIGGER_NAME, TRIGGER_TYPE, TRIGGERING_EVENT, TABLE_NAME, STATUS
FROM USER_TRIGGERS;