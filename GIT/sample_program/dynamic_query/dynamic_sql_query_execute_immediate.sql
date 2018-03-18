DECLARE
    collist         CLOB;
    with_clause     CLOB;
    select_clause   CLOB;
    sql_query       CLOB;
    table_name      VARCHAR2 (30) := 'CUSTOMERS';
    PROCEDURE pr_collist (pi_table_name   IN     VARCHAR2,
                          collist1           OUT CLOB,
                          my_str             OUT CLOB)
    AS
        v_sql            CLOB;
        TYPE cv_typ IS REF CURSOR;
        CV               cv_typ;
        select_clause1   CLOB;
    BEGIN
        v_sql :=
               'select  LISTAGG(column_name, '','') WITHIN GROUP (ORDER BY column_name) collist
                from user_tab_cols
                where table_name='''|| pi_table_name|| '''';

        EXECUTE IMMEDIATE v_sql INTO collist1;

        --dbms_output.put_line('inside procedure collist:'||collist);
        OPEN CV FOR
            SELECT    'select '
                   || CASE
                          WHEN data_type NOT IN ('CHAR', 'VARCHAR2')
                          THEN
                              'to_char(' || column_name || ')'
                          ELSE
                              column_name
                      END
                   || ',count(1) from all_recs group by '
                   || column_name
                   || ' union all '
              FROM user_tab_cols
             WHERE table_name = pi_table_name;

        LOOP
            FETCH CV INTO select_clause1;

            EXIT WHEN CV%NOTFOUND;
            my_str := my_str || select_clause1;
        END LOOP;

        CLOSE CV;
    END;
BEGIN
    pr_collist (table_name, collist, select_clause);
    with_clause := 'SELECT ' || collist || ' from ' || table_name;
    sql_query := 'with all_recs as(' || with_clause || ')' || select_clause;
--    select substr(sql_query,1,length()
dbms_output.put_line(substr(sql_query,1,length(sql_query)-10));
END;