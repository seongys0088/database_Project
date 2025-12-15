-- 테이블 생성
-- 1. 최상위 부모 테이블 (독립적인 정보)

CREATE TABLE ROLE (
    RoleID   VARCHAR2(10) PRIMARY KEY,     -- 권한 ID (PK)
    RoleName VARCHAR2(50) NOT NULL         -- 권한 명
);

CREATE TABLE BRAND (
    BrandID   VARCHAR2(10) PRIMARY KEY,     -- 브랜드 ID (PK)
    BrandName VARCHAR2(100) NOT NULL       -- 브랜드 명
);

CREATE TABLE CATEGORY (
    CategoryID   VARCHAR2(10) PRIMARY KEY, -- 카테고리 ID (PK)
    CategoryName VARCHAR2(100) NOT NULL     -- 카테고리 명
);

CREATE TABLE STORE (
    StoreID   VARCHAR2(10) PRIMARY KEY,     -- 매장 ID (PK)
    StoreName VARCHAR2(100) NOT NULL,       -- 매장 명
    Phone     VARCHAR2(15)                  -- 매장 전화번호
);

CREATE TABLE CUSTOMER (
    CustomerID   VARCHAR2(10) PRIMARY KEY, -- 고객 ID (PK)
    CustomerName VARCHAR2(50) NOT NULL,    -- 고객 이름
    ContactInfo  VARCHAR2(100)             -- 연락처/주소 등
);


-- 2. 중간 부모 테이블 (1단계 테이블을 참조)

CREATE TABLE MANAGER (
    ManagerID VARCHAR2(10) PRIMARY KEY,   -- 관리자 ID (PK)
    StoreID   VARCHAR2(10) NOT NULL,      -- 매장 ID (FK)
    RoleID    VARCHAR2(10) NOT NULL,      -- 권한 ID (FK)
    Name      VARCHAR2(50) NOT NULL,      -- 관리자 이름
    Phone     VARCHAR2(15),
    CONSTRAINT FK_MGR_STORE FOREIGN KEY (StoreID) REFERENCES STORE(StoreID),
    CONSTRAINT FK_MGR_ROLE FOREIGN KEY (RoleID) REFERENCES ROLE(RoleID)
);

CREATE TABLE WAREHOUSE (
    WarehouseID   VARCHAR2(10) PRIMARY KEY, -- 창고 ID (PK)
    StoreID       VARCHAR2(10) NOT NULL,    -- 매장 ID (FK)
    WarehouseName VARCHAR2(100) NOT NULL,   -- 창고 명
    Location      VARCHAR2(200),            -- 창고 위치 상세
    CONSTRAINT FK_WH_STORE FOREIGN KEY (StoreID) REFERENCES STORE(StoreID)
);

CREATE TABLE PRODUCT (
    ProductID    VARCHAR2(10) PRIMARY KEY,  -- 상품 ID (PK)
    BrandID      VARCHAR2(10) NOT NULL,     -- 브랜드 ID (FK)
    CategoryID   VARCHAR2(10) NOT NULL,     -- 카테고리 ID (FK)
    ProductName  VARCHAR2(100) NOT NULL,    -- 상품 명
    Price        NUMBER NOT NULL,           -- 판매 가격
    CONSTRAINT FK_PROD_BRAND FOREIGN KEY (BrandID) REFERENCES BRAND(BrandID),
    CONSTRAINT FK_PROD_CAT FOREIGN KEY (CategoryID) REFERENCES CATEGORY(CategoryID)
);


-- 3. 핵심 참조 테이블 (옵션, 재고)

CREATE TABLE PRODUCT_OPTION (
    ProductID   VARCHAR2(10) NOT NULL,      -- 상품 ID (PK, FK)
    SeqNum      NUMBER NOT NULL,            -- 옵션 순번 (PK) - 약한 엔터티의 식별자
    Color       VARCHAR2(50) NOT NULL,
    ItemSize    VARCHAR2(10) NOT NULL,      -- **컬럼명 수정: Size -> ItemSize**
    CONSTRAINT PK_PROD_OPT PRIMARY KEY (ProductID, SeqNum),
    CONSTRAINT FK_OPT_PROD FOREIGN KEY (ProductID) REFERENCES PRODUCT(ProductID)
);

CREATE TABLE INVENTORY (
    ProductID   VARCHAR2(10) NOT NULL,      -- 상품 ID (PK, FK)
    SeqNum      NUMBER NOT NULL,            -- 옵션 순번 (PK, FK)
    WarehouseID VARCHAR2(10) NOT NULL,      -- 창고 ID (PK, FK)
    CurrentStock NUMBER DEFAULT 0 NOT NULL, -- 현재 재고 수량
    SafetyStock  NUMBER DEFAULT 10,         -- 안전 재고 수량
    CONSTRAINT PK_INVENTORY PRIMARY KEY (ProductID, SeqNum, WarehouseID),
    CONSTRAINT FK_INV_OPT FOREIGN KEY (ProductID, SeqNum) REFERENCES PRODUCT_OPTION(ProductID, SeqNum),
    CONSTRAINT FK_INV_WH FOREIGN KEY (WarehouseID) REFERENCES WAREHOUSE(WarehouseID)
);


-- 4. 트랜잭션 테이블 (DETAIL 테이블 참조를 위해 순서 조정)

CREATE TABLE INBOUND (
    InboundID     VARCHAR2(10) PRIMARY KEY, -- 입고 ID (PK)
    ManagerID     VARCHAR2(10) NOT NULL,    -- 처리 관리자 (FK)
    InboundDate   DATE NOT NULL,            -- 입고 일자
    SourceStoreID VARCHAR2(10) NOT NULL,    -- 입고처 매장/물류 ID (FK)
    CONSTRAINT FK_INB_MGR FOREIGN KEY (ManagerID) REFERENCES MANAGER(ManagerID),
    CONSTRAINT FK_INB_STORE FOREIGN KEY (SourceStoreID) REFERENCES STORE(StoreID)
);

CREATE TABLE OUTBOUND (
    OutboundID   VARCHAR2(10) PRIMARY KEY,  -- 출고/주문 ID (PK)
    CustomerID   VARCHAR2(10) NOT NULL,     -- 고객 ID (FK)
    ManagerID    VARCHAR2(10),              -- 처리 관리자 (FK, NULL 허용)
    OutboundDate DATE NOT NULL,             -- 출고/주문 일자
    Status       VARCHAR2(20) NOT NULL,     -- 주문 상태 (예: '결제 완료')
    CONSTRAINT FK_OUTB_CUST FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID),
    CONSTRAINT FK_OUTB_MGR FOREIGN KEY (ManagerID) REFERENCES MANAGER(ManagerID)
);


-- 5. 상세 및 이력 테이블 (트랜잭션 테이블 참조)

CREATE TABLE INBOUND_DETAIL (
    InboundID VARCHAR2(10) NOT NULL,        -- 입고 ID (PK, FK)
    ProductID VARCHAR2(10) NOT NULL,        -- 상품 ID (PK, FK)
    SeqNum    NUMBER NOT NULL,              -- 옵션 순번 (PK, FK)
    Quantity  NUMBER NOT NULL,              -- 입고 수량
    CONSTRAINT PK_INDETAIL PRIMARY KEY (InboundID, ProductID, SeqNum),
    CONSTRAINT FK_INDT_INB FOREIGN KEY (InboundID) REFERENCES INBOUND(InboundID),
    CONSTRAINT FK_INDT_OPT FOREIGN KEY (ProductID, SeqNum) REFERENCES PRODUCT_OPTION(ProductID, SeqNum)
);

CREATE TABLE OUTBOUND_DETAIL (
    OutboundID VARCHAR2(10) NOT NULL,       -- 출고 ID (PK, FK)
    ProductID  VARCHAR2(10) NOT NULL,       -- 상품 ID (PK, FK)
    SeqNum     NUMBER NOT NULL,             -- 옵션 순번 (PK, FK)
    Quantity   NUMBER NOT NULL,             -- 출고 수량
    CONSTRAINT PK_OUTDETAIL PRIMARY KEY (OutboundID, ProductID, SeqNum),
    CONSTRAINT FK_OUTDT_OUTB FOREIGN KEY (OutboundID) REFERENCES OUTBOUND(OutboundID),
    CONSTRAINT FK_OUTDT_OPT FOREIGN KEY (ProductID, SeqNum) REFERENCES PRODUCT_OPTION(ProductID, SeqNum)
);

CREATE TABLE ADJUSTMENT_HISTORY (
    AdjustmentID   VARCHAR2(10) PRIMARY KEY, -- 조정 이력 ID (PK)
    ManagerID      VARCHAR2(10) NOT NULL,    -- 처리 관리자 (FK)
    AdjustmentDate DATE NOT NULL,            -- 조정 일자
    ProductID      VARCHAR2(10) NOT NULL,    -- 상품 ID (FK)
    SeqNum         NUMBER NOT NULL,          -- 옵션 순번 (FK)
    WarehouseID    VARCHAR2(10) NOT NULL,    -- 창고 ID (FK)
    Reason         VARCHAR2(200) NOT NULL,   -- 조정 사유 (예: 도난, 파손, 오류)
    DifferenceQty  NUMBER NOT NULL,          -- 조정된 차이 수량 (+ 또는 -)
    CONSTRAINT FK_ADJ_MGR FOREIGN KEY (ManagerID) REFERENCES MANAGER(ManagerID),
    CONSTRAINT FK_ADJ_OPT FOREIGN KEY (ProductID, SeqNum) REFERENCES PRODUCT_OPTION(ProductID, SeqNum),
    CONSTRAINT FK_ADJ_WH FOREIGN KEY (WarehouseID) REFERENCES WAREHOUSE(WarehouseID)
);

COMMIT;


-- 더미 데이터 삽입 (INSERT)
-- 1. 기초 데이터 삽입
INSERT INTO ROLE (RoleID, RoleName) VALUES ('R001', '재고 관리자');
INSERT INTO ROLE (RoleID, RoleName) VALUES ('R002', '슈퍼 관리자');
INSERT INTO ROLE (RoleID, RoleName) VALUES ('R003', '단순 업무직');
INSERT INTO ROLE (RoleID, RoleName) VALUES ('R004', '창고 담당자');

INSERT INTO BRAND (BrandID, BrandName) VALUES ('B001', '나이키');
INSERT INTO BRAND (BrandID, BrandName) VALUES ('B002', '아디다스');
INSERT INTO BRAND (BrandID, BrandName) VALUES ('B003', '퓨마');
INSERT INTO BRAND (BrandID, BrandName) VALUES ('B004', '뉴발란스');

INSERT INTO CATEGORY (CategoryID, CategoryName) VALUES ('C001', '상의');
INSERT INTO CATEGORY (CategoryID, CategoryName) VALUES ('C002', '하의');
INSERT INTO CATEGORY (CategoryID, CategoryName) VALUES ('C003', '신발');
INSERT INTO CATEGORY (CategoryID, CategoryName) VALUES ('C004', '액세서리');

INSERT INTO STORE (StoreID, StoreName, Phone) VALUES ('S001', '강남 본점', '02-1111-1111');
INSERT INTO STORE (StoreID, StoreName, Phone) VALUES ('S002', '부산 서면점', '051-2222-2222');
INSERT INTO STORE (StoreID, StoreName, Phone) VALUES ('S003', '물류센터A', '070-1000-1000');
INSERT INTO STORE (StoreID, StoreName, Phone) VALUES ('S004', '온라인 본부', '070-2000-2000');

INSERT INTO CUSTOMER (CustomerID, CustomerName, ContactInfo) VALUES ('C001', '홍길동', '010-1234-5678');
INSERT INTO CUSTOMER (CustomerID, CustomerName, ContactInfo) VALUES ('C002', '김철수', '010-9876-5432');
INSERT INTO CUSTOMER (CustomerID, CustomerName, ContactInfo) VALUES ('C003', '이영희', '010-3333-3333');
INSERT INTO CUSTOMER (CustomerID, CustomerName, ContactInfo) VALUES ('C004', '박지성', '010-4444-4444');
INSERT INTO CUSTOMER (CustomerID, CustomerName, ContactInfo) VALUES ('C005', '최수영', '010-5555-5555');

INSERT INTO MANAGER (ManagerID, StoreID, RoleID, Name, Phone) VALUES ('M001', 'S001', 'R002', '성윤수', '010-9999-9999');
INSERT INTO MANAGER (ManagerID, StoreID, RoleID, Name, Phone) VALUES ('M002', 'S001', 'R001', '나이키알바생', '010-1234-5678');
INSERT INTO MANAGER (ManagerID, StoreID, RoleID, Name, Phone) VALUES ('M003', 'S002', 'R001', '부산 담당자', '010-5555-5555');
INSERT INTO MANAGER (ManagerID, StoreID, RoleID, Name, Phone) VALUES ('M004', 'S004', 'R004', '온라인 담당', '010-6666-6666');

INSERT INTO WAREHOUSE (WarehouseID, StoreID, WarehouseName, Location) VALUES ('W001', 'S001', '본점 지하창고', 'S001 지하시설');
INSERT INTO WAREHOUSE (WarehouseID, StoreID, WarehouseName, Location) VALUES ('W002', 'S002', '서면 2층창고', 'S002 2층 스탁룸');
INSERT INTO WAREHOUSE (WarehouseID, StoreID, WarehouseName, Location) VALUES ('W003', 'S003', '메인 물류창고', 'S003 중앙');
INSERT INTO WAREHOUSE (WarehouseID, StoreID, WarehouseName, Location) VALUES ('W004', 'S004', '온라인 스탁', 'S004 본사 스탁룸');

INSERT INTO PRODUCT (ProductID, BrandID, CategoryID, ProductName, Price) VALUES ('P001', 'B001', 'C001', '나이키 맨투맨', 50000);
INSERT INTO PRODUCT (ProductID, BrandID, CategoryID, ProductName, Price) VALUES ('P002', 'B002', 'C002', '아디다스 트레이닝 팬츠', 75000);
INSERT INTO PRODUCT (ProductID, BrandID, CategoryID, ProductName, Price) VALUES ('P003', 'B003', 'C003', '퓨마 러닝화', 120000);
INSERT INTO PRODUCT (ProductID, BrandID, CategoryID, ProductName, Price) VALUES ('P004', 'B001', 'C002', '나이키 조거팬츠', 65000);
INSERT INTO PRODUCT (ProductID, BrandID, CategoryID, ProductName, Price) VALUES ('P005', 'B004', 'C004', '뉴발란스 양말 3족', 15000);

-- PRODUCT_OPTION 삽입 (ItemSize 반영)
INSERT INTO PRODUCT_OPTION (ProductID, SeqNum, Color, ItemSize) VALUES ('P001', 1, '블랙', 'M');
INSERT INTO PRODUCT_OPTION (ProductID, SeqNum, Color, ItemSize) VALUES ('P001', 2, '블랙', 'L');
INSERT INTO PRODUCT_OPTION (ProductID, SeqNum, Color, ItemSize) VALUES ('P001', 3, '그레이', 'S');
INSERT INTO PRODUCT_OPTION (ProductID, SeqNum, Color, ItemSize) VALUES ('P002', 1, '네이비', 'S');
INSERT INTO PRODUCT_OPTION (ProductID, SeqNum, Color, ItemSize) VALUES ('P003', 1, '화이트', '250');
INSERT INTO PRODUCT_OPTION (ProductID, SeqNum, Color, ItemSize) VALUES ('P003', 2, '블랙', '260');
INSERT INTO PRODUCT_OPTION (ProductID, SeqNum, Color, ItemSize) VALUES ('P004', 1, '블랙', 'L');
INSERT INTO PRODUCT_OPTION (ProductID, SeqNum, Color, ItemSize) VALUES ('P005', 1, '화이트', '단일');
INSERT INTO PRODUCT_OPTION (ProductID, SeqNum, Color, ItemSize) VALUES ('P005', 2, '블랙', '단일');

-- 2. 핵심 재고 데이터 삽입 (INVENTORY)
INSERT INTO INVENTORY (ProductID, SeqNum, WarehouseID, CurrentStock, SafetyStock) VALUES ('P001', 1, 'W001', 50, 20); -- 강남_블랙M: 50
INSERT INTO INVENTORY (ProductID, SeqNum, WarehouseID, CurrentStock, SafetyStock) VALUES ('P001', 2, 'W001', 30, 20); -- 강남_블랙L: 30
INSERT INTO INVENTORY (ProductID, SeqNum, WarehouseID, CurrentStock, SafetyStock) VALUES ('P001', 3, 'W001', 15, 10); -- 강남_그레이S: 15
INSERT INTO INVENTORY (ProductID, SeqNum, WarehouseID, CurrentStock, SafetyStock) VALUES ('P004', 1, 'W001', 5, 10);  -- 강남_조거팬츠: 5 (안전재고 미달)

INSERT INTO INVENTORY (ProductID, SeqNum, WarehouseID, CurrentStock, SafetyStock) VALUES ('P002', 1, 'W002', 40, 15); -- 부산_네이비S: 40
INSERT INTO INVENTORY (ProductID, SeqNum, WarehouseID, CurrentStock, SafetyStock) VALUES ('P003', 1, 'W003', 100, 30); -- 물류_러닝화250: 100
INSERT INTO INVENTORY (ProductID, SeqNum, WarehouseID, CurrentStock, SafetyStock) VALUES ('P003', 2, 'W003', 80, 30);  -- 물류_러닝화260: 80

INSERT INTO INVENTORY (ProductID, SeqNum, WarehouseID, CurrentStock, SafetyStock) VALUES ('P005', 1, 'W004', 8, 10); -- 온라인_양말화이트: 8 (안전재고 미달)
INSERT INTO INVENTORY (ProductID, SeqNum, WarehouseID, CurrentStock, SafetyStock) VALUES ('P005', 2, 'W004', 25, 10); -- 온라인_양말블랙: 25

-- 3. 트랜잭션 데이터 삽입 (입고, 출고, 재고 조정)

-- 입고 I001: M001 처리, S002(부산) -> S001(강남) 이동
INSERT INTO INBOUND (InboundID, ManagerID, InboundDate, SourceStoreID) VALUES ('I001', 'M001', DATE '2025-12-10', 'S002');
INSERT INTO INBOUND_DETAIL (InboundID, ProductID, SeqNum, Quantity) VALUES ('I001', 'P001', 1, 10);
UPDATE INVENTORY SET CurrentStock = CurrentStock + 10 WHERE ProductID = 'P001' AND SeqNum = 1 AND WarehouseID = 'W001'; -- 재고 갱신

-- 입고 I002: M001 처리, S003(물류) -> S001(강남) 이동 (P004 조거팬츠 재고 복구 시나리오)
INSERT INTO INBOUND (InboundID, ManagerID, InboundDate, SourceStoreID) VALUES ('I002', 'M001', DATE '2025-12-12', 'S003');
INSERT INTO INBOUND_DETAIL (InboundID, ProductID, SeqNum, Quantity) VALUES ('I002', 'P004', 1, 50);
UPDATE INVENTORY SET CurrentStock = CurrentStock + 50 WHERE ProductID = 'P004' AND SeqNum = 1 AND WarehouseID = 'W001'; -- 재고 갱신

-- 입고 I003: M004 처리, S003(물류) -> S004(온라인) 이동
INSERT INTO INBOUND (InboundID, ManagerID, InboundDate, SourceStoreID) VALUES ('I003', 'M004', DATE '2025-12-05', 'S003');
INSERT INTO INBOUND_DETAIL (InboundID, ProductID, SeqNum, Quantity) VALUES ('I003', 'P005', 1, 100);
UPDATE INVENTORY SET CurrentStock = CurrentStock + 100 WHERE ProductID = 'P005' AND SeqNum = 1 AND WarehouseID = 'W004'; -- 재고 갱신

-- 출고 O001: C001(홍길동) 주문, M002 처리 (강남 본점)
INSERT INTO OUTBOUND (OutboundID, CustomerID, ManagerID, OutboundDate, Status) VALUES ('O001', 'C001', 'M002', DATE '2025-12-14', '결제 완료');
INSERT INTO OUTBOUND_DETAIL (OutboundID, ProductID, SeqNum, Quantity) VALUES ('O001', 'P001', 1, 5);
UPDATE INVENTORY SET CurrentStock = CurrentStock - 5 WHERE ProductID = 'P001' AND SeqNum = 1 AND WarehouseID = 'W001'; -- 재고 갱신

-- 출고 O002: C003(이영희) 주문, M002 처리 (강남 본점)
INSERT INTO OUTBOUND (OutboundID, CustomerID, ManagerID, OutboundDate, Status) VALUES ('O002', 'C003', 'M002', DATE '2025-12-14', '배송 중');
INSERT INTO OUTBOUND_DETAIL (OutboundID, ProductID, SeqNum, Quantity) VALUES ('O002', 'P003', 1, 2);
UPDATE INVENTORY SET CurrentStock = CurrentStock - 2 WHERE ProductID = 'P003' AND SeqNum = 1 AND WarehouseID = 'W003'; -- 재고 갱신

-- 출고 O003: C004(박지성) 대량 주문, M001 처리 (강남 본점)
INSERT INTO OUTBOUND (OutboundID, CustomerID, ManagerID, OutboundDate, Status) VALUES ('O003', 'C004', 'M001', DATE '2025-12-14', '결제 완료');
INSERT INTO OUTBOUND_DETAIL (OutboundID, ProductID, SeqNum, Quantity) VALUES ('O003', 'P001', 2, 10);
INSERT INTO OUTBOUND_DETAIL (OutboundID, ProductID, SeqNum, Quantity) VALUES ('O003', 'P004', 1, 5);
UPDATE INVENTORY SET CurrentStock = CurrentStock - 10 WHERE ProductID = 'P001' AND SeqNum = 2 AND WarehouseID = 'W001'; -- 재고 갱신
UPDATE INVENTORY SET CurrentStock = CurrentStock - 5 WHERE ProductID = 'P004' AND SeqNum = 1 AND WarehouseID = 'W001'; -- 재고 갱신

-- 출고 O004: C005(최수영) 온라인 주문, M004 처리 (온라인 본부)
INSERT INTO OUTBOUND (OutboundID, CustomerID, ManagerID, OutboundDate, Status) VALUES ('O004', 'C005', 'M004', DATE '2025-12-15', '배송 대기');
INSERT INTO OUTBOUND_DETAIL (OutboundID, ProductID, SeqNum, Quantity) VALUES ('O004', 'P005', 2, 5);
UPDATE INVENTORY SET CurrentStock = CurrentStock - 5 WHERE ProductID = 'P005' AND SeqNum = 2 AND WarehouseID = 'W004'; -- 재고 갱신

-- 재고 조정 이력 (A001~A003)
INSERT INTO ADJUSTMENT_HISTORY (AdjustmentID, ManagerID, AdjustmentDate, ProductID, SeqNum, WarehouseID, Reason, DifferenceQty)
VALUES ('A001', 'M002', DATE '2025-12-13', 'P002', 1, 'W002', '도난 발생', -3);
UPDATE INVENTORY SET CurrentStock = CurrentStock - 3 WHERE ProductID = 'P002' AND SeqNum = 1 AND WarehouseID = 'W002'; -- 재고 갱신

INSERT INTO ADJUSTMENT_HISTORY (AdjustmentID, ManagerID, AdjustmentDate, ProductID, SeqNum, WarehouseID, Reason, DifferenceQty)
VALUES ('A002', 'M004', DATE '2025-12-01', 'P001', 1, 'W004', '전산 입력 오류 발견', +10);
INSERT INTO INVENTORY (ProductID, SeqNum, WarehouseID, CurrentStock, SafetyStock) VALUES ('P001', 1, 'W004', 10, 20); -- W004에 P001/1 재고가 없었으므로 INSERT

INSERT INTO ADJUSTMENT_HISTORY (AdjustmentID, ManagerID, AdjustmentDate, ProductID, SeqNum, WarehouseID, Reason, DifferenceQty)
VALUES ('A003', 'M003', DATE '2025-12-02', 'P003', 1, 'W003', '파손/폐기', -5);
UPDATE INVENTORY SET CurrentStock = CurrentStock - 5 WHERE ProductID = 'P003' AND SeqNum = 1 AND WarehouseID = 'W003'; -- 재고 갱신

COMMIT;