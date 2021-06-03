SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE find_customer (customer_id IN NUMBER, found OUT NUMBER) AS
    m_name	VARCHAR2(255 BYTE);
    m_cusId	NUMBER;
BEGIN
    found := 1;
    SELECT customer_id, name
    INTO m_cusId, m_name
    FROM customers
    WHERE customer_id = find_customer.customer_id;
    DBMS_OUTPUT.PUT_LINE('CUS name: ' || m_name);
    DBMS_OUTPUT.PUT_LINE('CUS id: ' || m_cusId);
    EXCEPTION
    WHEN no_data_found THEN
     found := 0;
     WHEN 
        TOO_MANY_ROWS 
    THEN
        DBMS_OUTPUT.PUT_LINE('Too many rows returned! ');
    WHEN 
        OTHERS 
    THEN
        DBMS_OUTPUT.PUT_LINE('Error! '); 
END;

 /

 CREATE OR REPLACE PROCEDURE find_product(product_id IN NUMBER , price OUT products.list_price%TYPE) AS 
    m_price NUMBER(9,2);
    found NUMBER;
 BEGIN

    SELECT p.list_price
    INTO m_price
    FROM products p
    WHERE p.product_id = find_product.product_id;
    found:=1;
     DBMS_OUTPUT.PUT_LINE('Price' ||m_price);
     price := m_price;
  EXCEPTION
    WHEN no_data_found THEN
     found := 0;
     WHEN 
        TOO_MANY_ROWS 
    THEN
        DBMS_OUTPUT.PUT_LINE('Too many rows returned! ');
    WHEN 
        OTHERS 
    THEN
        DBMS_OUTPUT.PUT_LINE('Error! '); 
END;

/

 DECLARE
  total NUMBER(9,2);
  mid NUMBER := 112;
  BEGIN find_product(mid, total);
   DBMS_OUTPUT.PUT_LINE('Total ' || total);
  END;

/ 

 CREATE OR REPLACE PROCEDURE add_order(customer_id IN NUMBER , new_order_id OUT NUMBER) AS 
 BEGIN 
    SELECT MAX(order_id)
    INTO new_order_id
    FROM orders;
    
    INSERT INTO orders
    VALUES (new_order_id + 1 , customer_id , 'Shipped' , 56 , SYSDATE);
    
    new_order_id := new_order_id + 1;
 END;

 /

 CREATE OR REPLACE PROCEDURE add_order_item ( orderId IN order_items.order_id%type,
                                             itemId IN order_items.item_id%type,
                                             productId IN order_items.product_id%type,
                                             quantity IN order_items.quantity%type,
                                             price IN order_items.unit_price%type) AS
 BEGIN 
    INSERT INTO order_items
    VALUES (orderId , itemId , productId , quantity , price);
 END;   
/