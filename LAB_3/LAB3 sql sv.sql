USE QLDA;
GO

-- 1. Mỗi đề án: Tên đề án + tổng số giờ

SELECT DA.TENDEAN, SUM(PC.THOIGIAN) AS TongGio
FROM DEAN DA, PHANCONG PC
WHERE DA.MADA = PC.MADA
GROUP BY DA.TENDEAN;

-- 2. Phòng ban: Tên phòng + lương trung bình
SELECT PB.TENPHG, AVG(NV.LUONG) AS LuongTB
FROM PHONGBAN PB, NHANVIEN NV
WHERE PB.MAPHG = NV.PHG
GROUP BY PB.TENPHG;

-- 3. Xuất lương trung bình kiểu chữ (VARCHAR) cho đơn giản
SELECT PB.TENPHG,
       CONVERT(VARCHAR, AVG(NV.LUONG)) AS LuongTB_Chu
FROM PHONGBAN PB, NHANVIEN NV
WHERE PB.MAPHG = NV.PHG
GROUP BY PB.TENPHG;
----- BÀI 2 -----

-- 1. Tổng số giờ làm việc theo từng đề án
-- CEILING: làm tròn lên
SELECT DA.TENDEAN, CEILING(SUM(PC.THOIGIAN)) AS TongGio
FROM DEAN DA, PHANCONG PC
WHERE DA.MADA = PC.MADA
GROUP BY DA.TENDEAN;

-- FLOOR: làm tròn xuống
SELECT DA.TENDEAN, FLOOR(SUM(PC.THOIGIAN)) AS TongGio
FROM DEAN DA, PHANCONG PC
WHERE DA.MADA = PC.MADA
GROUP BY DA.TENDEAN;

-- ROUND: làm tròn 2 số thập phân
SELECT DA.TENDEAN, ROUND(SUM(PC.THOIGIAN), 2) AS TongGio
FROM DEAN DA, PHANCONG PC
WHERE DA.MADA = PC.MADA
GROUP BY DA.TENDEAN;


-- 2. Danh sách nhân viên có lương > lương TB phòng "Nghiên cứu"
SELECT NV.HONV, NV.TENLOT, NV.TENNV, NV.LUONG
FROM NHANVIEN NV, PHONGBAN PB
WHERE NV.PHG = PB.MAPHG
  AND PB.TENPHG = N'Nghiên cứu'
  AND NV.LUONG > (
        SELECT AVG(N.LUONG)
        FROM NHANVIEN N, PHONGBAN P
        WHERE N.PHG = P.MAPHG
          AND P.TENPHG = N'Nghiên cứu'
  );


-- BÀI 3 --

-- 1. Danh sách nhân viên có trên 2 thân nhân
SELECT 
    UPPER(NV.HONV) AS HoNV,        -- in hoa hết
    LOWER(NV.TENLOT) AS TenLot,    -- in thường hết

    -- tên: ký tự đầu thường, ký tự 2 in hoa, còn lại in thường
    LOWER(LEFT(NV.TENNV,1)) 
        + UPPER(SUBSTRING(NV.TENNV,2,1)) 
        + LOWER(SUBSTRING(NV.TENNV,3,LEN(NV.TENNV))) AS TenNV,

    -- lấy tên đường (giản lược, cắt từ sau khoảng trắng tới dấu phẩy)
    SUBSTRING(NV.DCHI,
              CHARINDEX(' ', NV.DCHI) + 1,
              CHARINDEX(',', NV.DCHI) - CHARINDEX(' ', NV.DCHI) - 1) AS DiaChi

FROM NHANVIEN NV
WHERE (SELECT COUNT(*) 
       FROM THANNHAN TN 
       WHERE TN.MA_NVIEN = NV.MANV) > 2;

-- 2. Phòng ban đông nhân viên nhất + cột thay tên trưởng phòng thành 'Fpoly'
SELECT TOP 1 
       PB.TENPHG,
       NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV AS TruongPhong,
       'Fpoly' AS TenThayThe
FROM PHONGBAN PB, NHANVIEN NV
WHERE PB.TRPHG = NV.MANV
ORDER BY (SELECT COUNT(*) 
          FROM NHANVIEN N 
          WHERE N.PHG = PB.MAPHG) DESC;


-- BÀI 4 --

-- 1. Nhân viên sinh trong khoảng 1960-1965
SELECT *
FROM NHANVIEN
WHERE YEAR(NGSINH) >= 1960 AND YEAR(NGSINH) <= 1965;

-- 2. Tuổi của nhân viên (tính tới hiện tại)
SELECT HONV, TENLOT, TENNV,
       DATEDIFF(YEAR, NGSINH, GETDATE()) AS Tuoi
FROM NHANVIEN;

-- 3. Nhân viên sinh vào thứ mấy
SELECT HONV, TENLOT, TENNV,
       DATENAME(WEEKDAY, NGSINH) AS ThuSinh
FROM NHANVIEN;

-- 4. Số lượng nhân viên, tên trưởng phòng, ngày nhận chức (dd-mm-yy)
SELECT COUNT(NV.MANV) AS SoLuongNV,
       TP.HONV + ' ' + TP.TENLOT + ' ' + TP.TENNV AS TruongPhong,
       CONVERT(VARCHAR(10), PB.NG_NHANCHUC, 105) AS NgayNhanChuc
FROM PHONGBAN PB, NHANVIEN TP, NHANVIEN NV
WHERE PB.TRPHG = TP.MANV
  AND NV.PHG = PB.MAPHG
GROUP BY TP.HONV, TP.TENLOT, TP.TENNV, PB.NG_NHANCHUC;

