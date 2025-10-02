USE QLDA;
GO

-- BÀI 1 LAB 4 --

-- 1. Xem xét tăng lương hay không
SELECT NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV AS TenNV,
       CASE 
            WHEN NV.LUONG < (SELECT AVG(LUONG) 
                             FROM NHANVIEN 
                             WHERE PHG = NV.PHG)
                 THEN 'TangLuong'
            ELSE 'KhongTangLuong'
       END AS XetTangLuong
FROM NHANVIEN NV;


-- 2. Phân loại nhân viên
SELECT NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV AS TenNV,
       CASE 
            WHEN NV.LUONG < (SELECT AVG(LUONG) 
                             FROM NHANVIEN 
                             WHERE PHG = NV.PHG)
                 THEN 'NhanVien'
            ELSE 'TruongPhong'
       END AS LoaiNV
FROM NHANVIEN NV;


-- 3. Hiển thị TenNV theo giới tính (PHÁI)
SELECT NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV AS TenNV,
       CASE NV.PHAI
            WHEN 'Nam' THEN N'Ông ' + NV.TENNV
            WHEN 'Nữ'  THEN N'Bà ' + NV.TENNV
       END AS TenTheoPhai
FROM NHANVIEN NV;


-- 4. Tính thuế thu nhập phải đóng
SELECT NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV AS TenNV,
       NV.LUONG,
       CASE 
            WHEN NV.LUONG < 25000 THEN NV.LUONG * 0.10
            WHEN NV.LUONG < 30000 THEN NV.LUONG * 0.12
            WHEN NV.LUONG < 40000 THEN NV.LUONG * 0.15
            WHEN NV.LUONG < 50000 THEN NV.LUONG * 0.20
            ELSE NV.LUONG * 0.25
       END AS ThuePhaiDong
FROM NHANVIEN NV;

-- BÀI 2 LAB 4 --

-- 1. Nhân viên có MaNV chẵn
DECLARE @Ma INT = 1;
WHILE @Ma <= (SELECT MAX(MANV) FROM NHANVIEN)
BEGIN
    IF @Ma % 2 = 0
        SELECT HONV, TENLOT, TENNV
        FROM NHANVIEN
        WHERE MANV = @Ma;

    SET @Ma = @Ma + 1;
END


-- 2. Nhân viên có MaNV chẵn, bỏ MaNV = 4
DECLARE @Ma2 INT = 1;
WHILE @Ma2 <= (SELECT MAX(MANV) FROM NHANVIEN)
BEGIN
    IF @Ma2 % 2 = 0 AND @Ma2 <> 4
        SELECT HONV, TENLOT, TENNV
        FROM NHANVIEN
        WHERE MANV = @Ma2;

    SET @Ma2 = @Ma2 + 1;
END


-- BÀI 3 LAB 4 --

-- 1. Chèn dữ liệu đúng để test TRY...CATCH
BEGIN TRY
    INSERT INTO PHONGBAN(MAPHG, TENPHG, TRPHG, NG_NHANCHUC)
    VALUES (99, N'Phòng Test', NULL, GETDATE());
    PRINT N'Thêm dữ liệu thành công';
END TRY
BEGIN CATCH
    PRINT N'Thêm dữ liệu thất bại';
END CATCH;


-- 1b. Chèn sai kiểu dữ liệu để test lỗi
-- (MAPHG là số nhưng đưa chuỗi 'ABC')
BEGIN TRY
    INSERT INTO PHONGBAN(MAPHG, TENPHG, TRPHG, NG_NHANCHUC)
    VALUES ('ABC', N'Phòng Sai', NULL, GETDATE());
    PRINT N'Thêm dữ liệu thành công';
END TRY
BEGIN CATCH
    PRINT N'Thêm dữ liệu thất bại';
END CATCH;


-- 2. RAISERROR khi chia cho 0
DECLARE @chia INT = 10, @mau INT = 0, @kq FLOAT;

BEGIN TRY
    SET @kq = @chia / @mau;   -- sẽ gây lỗi
END TRY
BEGIN CATCH
    RAISERROR('Loi: Chia cho 0 khong hop le', 16, 1);
END CATCH;
