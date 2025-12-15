-- DML 30문제

-- A. 기본 SELECT 및 조건 검색 (1-10)

-- 1. 모든 브랜드의 이름(BrandName)을 중복 없이 나열하시오.
SELECT DISTINCT BrandName 
FROM BRAND;

-- 2. 모든 고객의 이름(CustomerName), 전화번호(ContactInfo)를 조회하시오.
SELECT CustomerName, ContactInfo 
FROM CUSTOMER;

-- 3. 가격(Price)이 75000원 이상인 모든 상품의 상품명(ProductName)과 가격을 조회하시오.
SELECT ProductName, Price 
FROM PRODUCT 
WHERE Price >= 75000;

-- 4. 재고 조정 이력(ADJUSTMENT_HISTORY) 중 조정 수량(DifferenceQty)이 **음수(-)** 인 내역만 조회하시오.
SELECT AdjustmentID, AdjustmentDate, Reason, DifferenceQty 
FROM ADJUSTMENT_HISTORY 
WHERE DifferenceQty < 0;

-- 5. 2025년 12월 10일부터 2025년 12월 13일 사이에 입고된 트랜잭션(InboundID)을 조회하시오.
SELECT InboundID, InboundDate 
FROM INBOUND 
WHERE InboundDate BETWEEN DATE '2025-12-10' AND DATE '2025-12-13';

-- 6. 상품 ID('P001', 'P003')에 해당하는 상품 옵션의 색상(Color)과 사이즈(ItemSize)를 조회하시오.
SELECT Color, ItemSize 
FROM PRODUCT_OPTION 
WHERE ProductID IN ('P001', 'P003');

-- 7. '재고 관리자' 권한(R001)을 **가지지 않은** 관리자(ManagerID, Name) 목록을 조회하시오.
SELECT ManagerID, Name 
FROM MANAGER 
WHERE RoleID NOT IN 'R001';

-- 8. 이름(Name)에 '담당자'라는 단어가 포함된 관리자 목록을 조회하시오.
SELECT ManagerID, Name 
FROM MANAGER 
WHERE Name LIKE '%담당자%';

-- 9. '부산 서면점' 매장(StoreID)에 소속된 창고의 이름(WarehouseName)과 위치(Location)를 조회하시오.
SELECT WarehouseName, Location 
FROM WAREHOUSE 
WHERE StoreID = 'S002';

-- 10. 재고(INVENTORY) 테이블에서 현재 재고(CurrentStock)가 20인 옵션의 상품ID, 순번(SeqNum)을 조회하시오.
SELECT ProductID, SeqNum, WarehouseID 
FROM INVENTORY 
WHERE CurrentStock = 20;


-- B. JOIN, 집계 및 그룹화 (11-20)

-- 11. 고객('홍길동')이 주문한 상품의 **주문일자(OutboundDate)**와 **상품명(ProductName)**을 조회하시오.
SELECT O.OutboundDate, P.ProductName
FROM OUTBOUND O
JOIN CUSTOMER C ON O.CustomerID = C.CustomerID
JOIN OUTBOUND_DETAIL OD ON O.OutboundID = OD.OutboundID
JOIN PRODUCT P ON OD.ProductID = P.ProductID
WHERE C.CustomerName = '홍길동';

-- 12. 입고 트랜잭션 'I001'을 처리한 관리자의 **이름(Name)**과 해당 관리자의 **권한명(RoleName)**을 조회하시오.
SELECT M.Name, R.RoleName
FROM INBOUND I
JOIN MANAGER M ON I.ManagerID = M.ManagerID
JOIN ROLE R ON M.RoleID = R.RoleID
WHERE I.InboundID = 'I001';

-- 13. 상품을 한 번이라도 공급(입고)한 매장의 수는 총 몇 명인가?
SELECT COUNT(DISTINCT SourceStoreID) 
FROM INBOUND;

-- 14. '나이키 맨투맨'(P001) 상품 옵션의 **총 입고 수량**을 구하시오.
SELECT SUM(ID.Quantity)
FROM INBOUND_DETAIL ID
JOIN PRODUCT P ON ID.ProductID = P.ProductID
WHERE P.ProductName = '나이키 맨투맨';

-- 15. 전체 상품의 **평균 가격(Price)**을 계산하여 조회하시오.
SELECT AVG(Price) AS AveragePrice 
FROM PRODUCT;

-- 16. 각 카테고리(CategoryName)별로 등록된 상품의 **개수**를 조회하시오.
SELECT C.CategoryName, COUNT(P.ProductID) AS ProductCount
FROM CATEGORY C
LEFT JOIN PRODUCT P ON C.CategoryID = P.CategoryID
GROUP BY C.CategoryName;

-- 17. 모든 상품의 상품명(ProductName), 가격(Price)을 **가격이 비싼 것부터 저렴한 순서(내림차순)**로 나열하시오.
SELECT ProductName, Price 
FROM PRODUCT 
ORDER BY Price DESC;

-- 18. 가장 비싼 가격의 상품명과 가격을 조회하시오.
SELECT ProductName, Price 
FROM PRODUCT 
ORDER BY Price DESC 
FETCH FIRST 1 ROWS ONLY; -- 상위 레코드 개수만큼 가져오기

-- 19. 창고별 총 재고를 기준으로 가장 많은 재고를 보유한 창고의 ID와 총 재고량을 조회하시오.
SELECT WarehouseID, SUM(CurrentStock) AS TotalStock
FROM INVENTORY
GROUP BY WarehouseID
ORDER BY TotalStock DESC
FETCH FIRST 1 ROWS ONLY;

-- 20. 총 입고 수량(Quantity)이 **50개 이상** 공급된 **상품ID**를 선발하여 조회하시오.
SELECT ProductID
FROM INBOUND_DETAIL
GROUP BY ProductID
HAVING SUM(Quantity) >= 50;


-- C. 서브쿼리, 고급 JOIN 및 EXISTS (21-25)

-- 21. 입고 내역이 존재하는 매장(StoreID)의 이름(StoreName)을 조회하시오.
SELECT StoreName
FROM STORE S
WHERE EXISTS (
    SELECT 1 
    FROM INBOUND I 
    WHERE I.SourceStoreID = S.StoreID
);

-- 22. 한 번도 재고 조정(ADJUSTMENT_HISTORY)이 발생하지 않은 창고의 이름(WarehouseName)을 조회하시오.
SELECT WarehouseName
FROM WAREHOUSE W
WHERE NOT EXISTS (
    SELECT 1 
    FROM ADJUSTMENT_HISTORY A 
    WHERE A.WarehouseID = W.WarehouseID
);

-- 23. '퓨마 러닝화'가 포함된 주문(OutboundID)을 처리한 관리자의 이름(Name)을 조회하시오.
SELECT DISTINCT M.Name
FROM MANAGER M
WHERE M.ManagerID IN (
    SELECT O.ManagerID
    FROM OUTBOUND O
    JOIN OUTBOUND_DETAIL OD ON O.OutboundID = OD.OutboundID
    JOIN PRODUCT P ON OD.ProductID = P.ProductID
    WHERE P.ProductName = '퓨마 러닝화'
);

-- 24. 모든 상품명과 해당 상품이 **한 번도 판매되지 않았다면** '(미판매)'라고 표시하여 조회하시오. (LEFT JOIN 사용)
SELECT P.ProductName,
       CASE WHEN OD.ProductID IS NULL THEN '(미판매)' ELSE '판매 이력 있음' END AS SalesStatus
       -- 조건부 서식 (when 조건문 then 참일 때 반환값 else 거짓일 때 반환값 end)
FROM PRODUCT P
LEFT JOIN OUTBOUND_DETAIL OD ON P.ProductID = OD.ProductID -- PRODUCT 테이블 기준으로 JOIN
GROUP BY P.ProductName, OD.ProductID;

-- 25. 평균 가격(AVG)보다 비싼 상품들의 목록을 조회하시오.
SELECT ProductName, Price
FROM PRODUCT
WHERE Price > (
    SELECT AVG(Price) 
    FROM PRODUCT
);


-- D. 데이터 조작 (UPDATE, DELETE) (26-30)

-- 26. UPDATE: 고객 '최수영'(C005)의 연락처(ContactInfo)를 '010-9999-0000'으로 수정하시오.
UPDATE CUSTOMER
SET ContactInfo = '010-9999-0000'
WHERE CustomerID = 'C005';

-- 27. UPDATE: '부산 서면점'(S002)에서 처리한 모든 입고(INBOUND) 트랜잭션의 입고일자(InboundDate)를 **오늘 날짜(SYSDATE)**로 갱신하시오.
UPDATE INBOUND I
SET InboundDate = SYSDATE
WHERE I.ManagerID IN (
    SELECT ManagerID 
    FROM MANAGER 
    WHERE StoreID = 'S002'
);

-- 28. UPDATE: 현재 재고가 안전재고(SafetyStock)보다 적은 모든 상품 옵션의 안전재고 수량을 **2배**로 늘리시오.
UPDATE INVENTORY
SET SafetyStock = SafetyStock * 2
WHERE CurrentStock < SafetyStock;

-- 29. INSERT: 부품번호 'P006', 상품명 '스포츠 브라', 가격 30000원, 브랜드 'B001', 카테고리 'C001'인 새 상품을 **PRODUCT 테이블에 추가** 입력하시오.
INSERT INTO PRODUCT (ProductID, BrandID, CategoryID, ProductName, Price)
VALUES ('P006', 'B001', 'C001', '스포츠 브라', 30000);

-- 30. DELETE: 재고 조정 이력(ADJUSTMENT_HISTORY) 중 사유가 **'파손/폐기'**인 모든 레코드를 삭제하시오.
DELETE FROM ADJUSTMENT_HISTORY
WHERE Reason = '파손/폐기';

COMMIT;