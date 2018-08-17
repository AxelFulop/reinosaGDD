use GD2018C2;

--Practica SQL

--1)Mostrar el c�digo, raz�n social de todos los clientes cuyo l�mite de cr�dito sea
--  mayor o igual a $ 1000 ordenado por c�digo de cliente.

SELECT clie_codigo,clie_razon_social,clie_limite_credito
FROM Cliente 
WHERE clie_limite_credito >= 1000
ORDER BY clie_codigo;

--2)Mostrar el c�digo, detalle de todos los art�culos vendidos en el a�o 2012 ordenados
--  por cantidad vendida

SELECT DISTINCT prod_codigo, prod_detalle,SUM(I_F.item_cantidad) cantVendida,F.fact_fecha
FROM Producto P
JOIN Item_Factura I_F ON  (I_F.item_producto =P.prod_codigo)
JOIN Factura F ON (F.fact_tipo = I_F.item_tipo)
WHERE F.fact_fecha > '2012'
GROUP BY prod_codigo,prod_detalle,F.fact_fecha
ORDER BY SUM(I_F.item_cantidad) DESC

--3)
--Realizar una consulta que muestre c�digo de producto, nombre de producto y el
--stock total, sin importar en que deposito se encuentre, los datos deben ser ordenados
--por nombre del art�culo de menor a mayor.


SELECT DISTINCT prod_codigo,prod_detalle,SUM(S.stoc_cantidad) totalStock 
 FROM Producto P
JOIN STOCK S ON (S.stoc_producto = P.prod_codigo)
GROUP BY prod_codigo,prod_detalle
ORDER BY prod_detalle DESC


--4)Realizar una consulta que muestre para todos los art�culos c�digo, detalle y cantidad
--  de art�culos que lo componen. Mostrar solo aquellos art�culos para los cuales el
--  stock promedio por dep�sito sea mayor a 100.

SELECT f.fami_id,F.fami_detalle,SUM(comp_cantidad) cantComp FROM Producto P
JOIN Familia F ON (P.prod_familia = F.fami_id)
JOIN Composicion C ON (C.comp_producto = P.prod_codigo)
JOIN STOCK S ON (S.stoc_producto = C.comp_producto)
JOIN DEPOSITO D ON (D.depo_codigo = S.stoc_deposito)
GROUP BY f.fami_id,F.fami_detalle
HAVING ((SUM(S.stoc_cantidad) / COUNT(S.stoc_cantidad))* COUNT(D.depo_codigo)) > 100




--5)
--Realizar una consulta que muestre c�digo de art�culo, detalle y cantidad de egresos
--de stock que se realizaron para ese art�culo en el a�o 2012 (egresan los productos
--que fueron vendidos). Mostrar solo aquellos que hayan tenido m�s egresos que en el
--2011.

SELECT rubr_id,rubr_detalle,COUNT(I_F.item_producto) cantEgresos2012
FROM Producto P
JOIN Rubro R ON (R.rubr_id = P.prod_rubro)
JOIN Item_Factura I_F ON (P.prod_codigo = I_F.item_producto)
JOIN Factura F ON (F.fact_tipo = I_F.item_tipo)
WHERE YEAR(f.fact_fecha) = '2012'
GROUP BY rubr_id,rubr_detalle
HAVING (COUNT(I_F.item_producto)) > (SELECT COUNT(I_F.item_producto) cantEgresos2011
FROM Producto P
JOIN Rubro R ON (R.rubr_id = P.prod_rubro)
JOIN Item_Factura I_F ON (P.prod_codigo = I_F.item_producto)
JOIN Factura F ON (F.fact_tipo = I_F.item_tipo)
WHERE YEAR(f.fact_fecha) = '2011')


--6) Mostrar para todos los rubros de art�culos c�digo, detalle, cantidad de art�culos de
--   ese rubro y stock total de ese rubro de art�culos. Solo tener en cuenta aquellos
--  art�culos que tengan un stock mayor al del art�culo �00000000� en el dep�sito �00�.

SELECT rubr_id,rubr_detalle,COUNT(P.prod_rubro) cantArtRubro,SUM(S.stoc_cantidad) stockTotal
FROM Producto P
JOIN Rubro R ON (R.rubr_id = p.prod_rubro)
JOIN Stock S ON (S.stoc_producto = P.prod_codigo)
GROUP BY rubr_id,rubr_detalle
HAVING ( SUM(S.stoc_cantidad) ) > (SELECT SUM(stoc_cantidad) FROM STOCK WHERE stoc_producto = '00000000' and stoc_deposito = '00')


--7) Generar una consulta que muestre para cada art�culo c�digo, detalle, mayor precio
--   menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio
--   = 10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos art�culos que
--   posean stock.

 SELECT  F.fami_detalle,MAX(P.prod_precio) precioMaximo,MIN(P.prod_precio)precioMinimo,
 (CAST(((MAX(P.prod_precio) -  MIN(P.prod_precio)) * 10) AS VARCHAR(15)) + '%') porcentaje
 FROM Producto P,Producto P1,Familia F,STOCK S     
 WHERE P.prod_codigo != P1.prod_codigo AND
 P.prod_precio > P1.prod_precio
 AND P.prod_familia = F.fami_id AND 
 P1.prod_familia = F.fami_id AND
 S.stoc_producto = P.prod_codigo  AND 
 S.stoc_cantidad > 0
 GROUP BY F.fami_detalle
 ORDER BY precioMaximo DESC

--8)  Mostrar para el o los art�culos que tengan stock en todos los dep�sitos, nombre del
--    art�culo, stock del dep�sito que m�s stock tiene.

SELECT   DISTINCT fami_detalle,S.stoc_deposito
FROM Familia F
JOIN Producto P ON ( P.prod_familia = F.fami_id)
JOIN Composicion C ON (C.comp_producto = P.prod_codigo)
JOIN Stock S ON (S.stoc_producto = C.comp_producto)
JOIN STOCK S2 ON (S2.stoc_producto = C.comp_producto)
JOIN DEPOSITO D ON (D.depo_codigo = S.stoc_deposito)
GROUP BY fami_detalle,S.stoc_deposito
HAVING (SUM (S.stoc_cantidad)) > (SUM(S2.stoc_cantidad))

                                       
--9)Mostrar el c�digo del jefe, c�digo del empleado que lo tiene como jefe, nombre del
-- mismo y la cantidad de dep�sitos que ambos tienen asignados.

SELECT  E1.empl_codigo CodigoJefe,E2.empl_codigo CodigoSubordinado,E2.empl_nombre NombreSubordinado,
COUNT(DJ.depo_encargado) cantDepJefe,COUNT(DE.depo_encargado) cantDepSub
FROM Empleado E1
JOIN Empleado E2 ON (E1.empl_codigo != E2.empl_codigo AND E1.empl_codigo = E2.empl_jefe)
LEFT JOIN DEPOSITO DE ON (DE.depo_encargado = E2.empl_codigo)
LEFT JOIN DEPOSITO DJ ON (DJ.depo_encargado = E1.empl_jefe)
GROUP BY E1.empl_codigo,E2.empl_codigo,E2.empl_nombre

SELECT COUNT(depo_encargado) cantDep FROM DEPOSITO WHERE depo_encargado = 2

--10)


SELECT * FROM Empleado
SELECT * FROM DEPOSITO 