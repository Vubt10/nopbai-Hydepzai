USE QLDA
GO
--lab6

--Bài 1: (3 điểm)
--Viết trigger DML:

-- Ràng buộc khi thêm mới nhân viên thì mức lương phải lớn hơn 15000,
--nếu vi phạm thì xuất thông báo “luong phải >15000’ 
CREATE OR ALTER TRIGGER KiemTraLuong ON NHANVIEN
FOR INSERT
AS
BEGIN
    -- Kiểm tra xem có nhân viên nào có lương <= 15000 không
    IF EXISTS (SELECT * FROM INSERTED WHERE LUONG <= 15000)
    BEGIN
        PRINT N'Lương phải > 15000';
        ROLLBACK TRANSACTION; -- Hủy thao tác thêm
    END
END
GO

 INSERT INTO NHANVIEN
 VALUES(
 'Phan', 'Viet', 'The', '114','1967-02-01 00:00:00.000',  'hcm', 'nam', 40000, '005', 4 )
 GO
  SELECT * FROM NHANVIEN
 GO

-- Ràng buộc khi thêm mới nhân viên
--thì độ tuổi phải nằm trong khoảng 18 <= tuổi <=65.
CREATE OR ALTER TRIGGER KiemTraDoTuoi_NV ON NHANVIEN
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE DATEDIFF(YEAR, NGSINH, GETDATE()) NOT BETWEEN 18 AND 65
    )
    BEGIN
        RAISERROR (N'Độ tuổi nhân viên phải nằm trong khoảng 18 đến 65.', 16, 1)
        ROLLBACK TRANSACTION
    END
END
GO


-- Ràng buộc khi cập nhật nhân viên thì không được cập nhật những nhân viên ở TP HCM 
CREATE OR ALTER TRIGGER KhongCapNhatNV_TPHCM ON NHANVIEN
FOR UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE DCHI LIKE N'%TP HCM%'  -- nhân viên có địa chỉ ở TP HCM
    )
    BEGIN
        RAISERROR (N'Không được phép cập nhật nhân viên ở TP HCM.', 16, 1)
        ROLLBACK TRANSACTION
    END
END
GO


--Bài 2: (3 điểm)************************************************* 
--Viết các Trigger AFTER:

-- Hiển thị tổng số lượng nhân viên nữ,
--tổng số lượng nhân viên nam
--mỗi khi có hành động thêm mới nhân viên. 
CREATE OR ALTER TRIGGER ThongKeGioiTinh_THEMMOI ON NHANVIEN
FOR INSERT
AS
BEGIN
    DECLARE @SoNam INT, @SoNu INT

    SELECT 
        @SoNam = COUNT(*) 
        FROM NHANVIEN 
        WHERE PHAI = N'Nam'

    SELECT 
        @SoNu = COUNT(*) 
        FROM NHANVIEN 
        WHERE PHAI = N'Nữ'

    PRINT N'Tổng số nhân viên Nam: ' + CAST(@SoNam AS NVARCHAR(10))
    PRINT N'Tổng số nhân viên Nữ: ' + CAST(@SoNu AS NVARCHAR(10))
END
GO


-- Hiển thị tổng số lượng nhân viên nữ,
--tổng số lượng nhân viên nam mỗi
--khi có hành động cập nhật phần giới tính nhân viên 
CREATE OR ALTER TRIGGER ThongKeGioiTinh_Update ON NHANVIEN
FOR UPDATE
AS
BEGIN
    -- Kiểm tra xem có cập nhật cột PHAI không
    IF UPDATE(PHAI)
    BEGIN
        DECLARE @SoNam INT, @SoNu INT;

        SELECT @SoNam = COUNT(*) 
        FROM NHANVIEN
        WHERE PHAI = N'Nam'

        SELECT @SoNu = COUNT(*) 
        FROM NHANVIEN
        WHERE PHAI = N'Nữ'

        PRINT N'Tổng số nhân viên Nam: ' + CAST(@SoNam AS NVARCHAR(10))
        PRINT N'Tổng số nhân viên Nữ: ' + CAST(@SoNu AS NVARCHAR(10))
    END
END
GO



-- Hiển thị tổng số lượng đề án mà mỗi nhân viên đã làm
--khi có hành động xóa trên bảng DEAN 
CREATE OR ALTER TRIGGER ThongKeDeAn_SauXoa ON DEAN
FOR DELETE
AS
BEGIN
    PRINT N'== Thống kê số lượng đề án mà mỗi nhân viên đã làm sau khi xóa đề án ==';

    SELECT 
        NV.MANV AS [Mã nhân viên],
        NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV AS [Họ tên nhân viên],
        COUNT(PC.MADA) AS [Số lượng đề án đã làm]
    FROM NHANVIEN NV
    LEFT JOIN PHANCONG PC ON NV.MANV = PC.MA_NVIEN
    GROUP BY NV.MANV, NV.HONV, NV.TENLOT, NV.TENNV
END
GO


--Bài 3: (3 điểm) *********************************************
--Viết các Trigger INSTEAD OF

-- Xóa các thân nhân trong bảng thân nhân có liên quan
--khi thực hiện hành động xóa nhân viên trong bảng nhân viên. 
USE QLDA;
GO

CREATE OR ALTER TRIGGER XOA_THANNHAN ON NHANVIEN
FOR DELETE
AS
BEGIN
    -- Xóa các thân nhân có mã nhân viên trùng với mã nhân viên vừa bị xóa
    DELETE FROM THANNHAN
    WHERE MA_NVIEN IN (SELECT MANV FROM deleted);

    PRINT N'Đã xóa các thân nhân liên quan đến nhân viên bị xóa.'
END
GO


-- Khi thêm một nhân viên mới thì tự động phân công cho
--nhân viên làm đề án có MADA là 1.
CREATE OR ALTER TRIGGER PhanCong_TuDong ON NHANVIEN
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;

    PRINT N'== Tự động phân công nhân viên mới vào đề án MADA = 1 ==';

    INSERT INTO PHANCONG(MA_NVIEN, MADA, STT, THOIGIAN)
    SELECT 
        i.MANV,   -- Lấy mã nhân viên vừa thêm
        1 AS MADA, 
        1 AS STT,       -- STT giả định = 1 (nếu cần, bạn có thể thay đổi cho phù hợp)
        0 AS THOIGIAN   -- Mặc định thời gian = 0, có thể chỉnh tùy yêu cầu
    FROM inserted i;
END;
GO