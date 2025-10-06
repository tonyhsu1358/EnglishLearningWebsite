<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DiamondStore.aspx.cs" Inherits="DiamondStore" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>魔法兌換商城</title>

    <!-- ✅ 引入 Bootstrap 與 Font Awesome -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

    <style>
        /* 🎨 主體背景與字型 */
        body {
            background-color: #f4f6f8;
            font-family: "Microsoft JhengHei", sans-serif;
        }

        /* 🌈 透明導覽列 */
        .navbar {
            background-color: transparent !important;
            box-shadow: none !important;
            padding: 15px 50px;
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        .navbar-brand {
            font-weight: 700;
            font-size: 22px;
            color: #000 !important;
            letter-spacing: 1px;
        }

        /* 💎 鑽石數量顯示區 */
        .resource {
            font-weight: bold;
            font-family: "Segoe UI", "Microsoft JhengHei", Arial, sans-serif;
            font-size: 18px;
            background: rgba(255, 255, 255, 0.6);
            padding: 4px 10px;
            border-radius: 8px;
            color: #000;
            display: flex;
            align-items: center;
            margin-right: 150px;
            gap: 5px;
            z-index: 100;
        }

        /* 🏪 商城主容器 */
        .store-container {
            max-width: 1200px;
            margin: 40px auto;
        }

        /* 🔽 排序欄 */
        .sort-bar {
            display: flex;
            align-items: center;
            margin-bottom: 25px;
        }

        .sort-bar label {
            font-weight: bold;
            margin-right: 10px;
        }

        .sort-bar select {
            border-radius: 10px;
            padding: 6px 12px;
            border: 1px solid #ccc;
        }

        /* 🧱 商品卡片 */
        .product-card {
            background: #fff;
            border-radius: 15px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            transition: all 0.25s ease-in-out;
            text-align: center;
            overflow: hidden;
        }

        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.12);
        }

        .product-card img {
            width: 100%;
            aspect-ratio: 5 / 4;
            object-fit: cover;
            background: #fff;
        }

        .product-info {
            padding: 12px 15px;
        }

        .product-name {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 8px;
            color: #333;
        }

        .product-price {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 12px;
            font-size: 15px;
        }

        .product-price i {
            color: #0099ff;
        }

        /* ⬆️ 回頂按鈕 */
        #btnScrollTop {
            position: fixed;
            bottom: 35px;
            right: 35px;
            background-color: rgba(0, 0, 0, 0.45);
            border: none;
            color: white;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            font-size: 22px;
            cursor: pointer;
            transition: all 0.3s ease;
            z-index: 999;
        }

        #btnScrollTop:hover {
            background-color: rgba(0, 0, 0, 0.8);
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">

        <!-- 🌈 導覽列 -->
        <nav class="navbar navbar-expand-lg">
            <div class="container-fluid justify-content-between">
                <a class="navbar-brand" href="#">💎 魔法兌換商城</a>
                <div class="resource">
                    <i class="fa-solid fa-gem text-info"></i>
                    <asp:Label ID="lblDiamonds" runat="server" Text="0"></asp:Label>
                </div>
            </div>
        </nav>

        <!-- 🏪 商城內容 -->
        <div class="store-container">
            <div class="sort-bar">
                <label for="sortSelect">排序：</label>
                <select id="sortSelect" class="form-select w-auto">
                    <option value="asc">鑽石：由少到多</option>
                    <option value="desc">鑽石：由多到少</option>
                </select>
            </div>

            <div class="row" id="productContainer">
                <!-- 商品由 JS 產生 -->
            </div>
        </div>

        <!-- ⬆️ 回頂按鈕 -->
        <button id="btnScrollTop" type="button" onclick="scrollToTop()">
            <i class="fa-solid fa-arrow-up"></i>
        </button>
    </form>

    <!-- ✅ Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        // ===============================
        // 💎 假資料模擬（日後改 ASMX）
        // ===============================
        const products = [
            { name: "Ave Mujica 001", price: 175, image: "ListeningTest_Images/AveMujica_001.jpg" },
            { name: "Ave Mujica 002", price: 240, image: "ListeningTest_Images/AveMujica_002.jpg" },
            { name: "Ave Mujica 003", price: 325, image: "ListeningTest_Images/AveMujica_003.jpg" },
            { name: "Ave Mujica 004", price: 410, image: "ListeningTest_Images/AveMujica_004.jpg" },
            { name: "Ave Mujica 005", price: 480, image: "ListeningTest_Images/AveMujica_005.jpg" },
            { name: "Ave Mujica 006", price: 515, image: "ListeningTest_Images/AveMujica_006.jpg" },
            { name: "Ave Mujica 007", price: 550, image: "ListeningTest_Images/AveMujica_007.jpg" },
            { name: "Ave Mujica 008", price: 620, image: "ListeningTest_Images/AveMujica_008.jpg" },
            { name: "Ave Mujica 009", price: 680, image: "ListeningTest_Images/AveMujica_009.jpg" },
            { name: "Ave Mujica 010", price: 750, image: "ListeningTest_Images/AveMujica_010.jpg" }
        ];

        // 🧱 商品卡片生成
        function renderProducts(list) {
            const container = document.getElementById("productContainer");
            container.innerHTML = "";
            list.forEach(p => {
                const card = `
                    <div class="col-12 col-sm-6 col-md-4 col-lg-3 mb-4">
                        <div class="product-card">
                            <img src="${p.image}" alt="${p.name}">
                            <div class="product-info">
                                <div class="product-name">${p.name}</div>
                                <div class="product-price">
                                    <i class="fa-solid fa-gem"></i> ${p.price}
                                </div>
                            </div>
                        </div>
                    </div>`;
                container.insertAdjacentHTML("beforeend", card);
            });
        }

        // 🔁 排序
        document.getElementById("sortSelect").addEventListener("change", function () {
            const value = this.value;
            const sorted = [...products].sort((a, b) =>
                value === "asc" ? a.price - b.price : b.price - a.price
            );
            renderProducts(sorted);
        });

        // ⬆️ 回頂
        function scrollToTop() {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        // 🚀 預設載入
        window.onload = () => renderProducts(products.sort((a, b) => a.price - b.price));
    </script>
</body>
</html>
