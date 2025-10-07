<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DiamondStore.aspx.cs" Inherits="DiamondStore" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>鑽石兌換商城</title>

    <!-- ✅ 引入 Bootstrap 與 Font Awesome -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

    <!-- ===============================
         🎨 頁面樣式
         =============================== -->
    <style>
        /* 🌿 主體設定 */
        body {
            background-color: #f4f6f8;
            font-family: "Microsoft JhengHei", sans-serif;
        }

        /* 🌈 導覽列設定（不固定在上方） */
        .navbar {
            background-color: transparent !important;
            box-shadow: none !important;
            padding: 15px 50px;
            position: static;
            z-index: 1000;
        }

        /* 🌈 導覽列標題 */
        .store-title {
            font-weight: 800;
            font-size: 40px;
            color: #66B3FF !important;
            letter-spacing: 1px;
            margin-top: 12px;
            align-self: flex-start;
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
            gap: 6px;
            position: absolute;
            right: 50px;
        }

        .resource img {
            width: 22px;
            height: 22px;
        }

        /* 🏪 商城主容器 */
        .store-container {
            max-width: 1200px;
            margin: 40px auto;
        }

        /* 🔽 排序列 */
        .sort-bar {
            display: flex;
            align-items: center;
            justify-content: flex-start;
            margin-bottom: 25px;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            padding: 10px 18px;
        }

        .sort-bar label {
            font-weight: 700;
            margin-right: 12px;
            font-size: 17px;
            color: #555;
        }

        .sort-bar select {
            border-radius: 10px;
            padding: 8px 32px 8px 14px;
            border: 1.5px solid #cdd6e0;
            background-color: #f9fafc;
            color: #333;
            font-weight: 500;
            font-size: 15px;
            cursor: pointer;
            transition: all 0.25s ease;
        }

        .sort-bar select:hover {
            background-color: #f1f3f5;
            border-color: #a9b4c3;
        }

        .sort-bar select:focus {
            outline: none;
            border-color: #66b3ff;
            box-shadow: 0 0 6px rgba(102, 179, 255, 0.6);
        }

        /* 🧱 商品卡片外觀 */
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

        /* ✅ 商品圖片樣式 */
        .product-image {
            width: 100%;
            height: 180px;
            object-fit: contain;
            background-color: #fff;
            border-radius: 10px 10px 0 0;
            display: block;
            margin: 0 auto;
        }

        /* ✅ 商品資訊 */
        .product-info {
            padding: 12px 15px;
        }

        /* ✅ 商品名稱一行省略 */
        .product-name {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 8px;
            color: #333;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* ✅ 價格區塊 */
        .product-price {
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 15px;
            font-weight: 600;
            color: #333;
            gap: 10px;
        }

        .diamond-icon {
            width: 20px !important;
            height: 20px !important;
            object-fit: contain;
            display: inline-block;
        }

        /* ✅ 模板卡片（JS 用來複製） */
        .product-card-template {
            display: none;
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
        <nav class="navbar navbar-expand-lg justify-content-center">
            <div class="container-fluid d-flex justify-content-center align-items-center position-relative">
                <span class="store-title">鑽石兌換商城</span>

                <div class="resource">
                    <img src="images/diamond.svg" alt="Diamond" />
                    <asp:Label ID="lblDiamonds" runat="server" Text="0"></asp:Label>
                </div>
            </div>
        </nav>

        <!-- 🏪 商城內容 -->
        <div class="store-container">
            <!-- 排序列 -->
            <div class="sort-bar">
                <label for="sortSelect">排序：</label>
                <select id="sortSelect" class="form-select w-auto">
                    <option value="asc">鑽石：由少到多</option>
                    <option value="desc">鑽石：由多到少</option>
                </select>
            </div>

            <!-- 🧩 商品卡模板 -->
            <div class="product-card-template col-12 col-sm-6 col-md-4 col-lg-3 mb-4">
                <div class="product-card">
                    <img src="" alt="" class="product-image">
                    <div class="product-info">
                        <div class="product-name"></div>
                        <div class="product-price">
                            <img src="images/diamond.svg" class="diamond-icon" alt="diamond" />
                            <span class="price-text"></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 📦 商品顯示區 -->
            <div class="row" id="productContainer"></div>
        </div>

        <!-- ⬆️ 回頂按鈕 -->
        <button id="btnScrollTop" type="button" onclick="scrollToTop()">
            <i class="fa-solid fa-arrow-up"></i>
        </button>
    </form>

    <!-- ✅ Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <!-- ===============================
         ⚙️ JavaScript 區塊
         =============================== -->
    <script>
        // 💎 模擬資料
        const variants = [
            { product_id: 1, name: "【傳說對決】710點券造型兌換券", image: "DiamondStore_Images/AOVskin710.jpg", price: 10500 },
            { product_id: 2, name: "【傳說對決】1200點券造型兌換券", image: "DiamondStore_Images/AOVskin1200.jpg", price: 17500 },
            { product_id: 3, name: "【茶裏王】系列飲品(600ml*4入)", image: "DiamondStore_Images/ChaiLiWon.jpg", price: 1200 },
            { product_id: 4, name: "【NISSIN 日清】合味道杯麵系列71g/杯", image: "DiamondStore_Images/CupNoodle.jpg", price: 550 },
            { product_id: 5, name: "【春風】皇室典藏袖珍包面紙(10抽/36包/1串)", image: "DiamondStore_Images/PocketTissue.jpg", price: 1300 },
            { product_id: 6, name: "【御茶園】系列茶飲550ml*4瓶", image: "DiamondStore_Images/RoyalTeaGarden.jpg", price: 1500 },
            { product_id: 7, name: "【購物袋】環保防水可收納購物袋*1", image: "DiamondStore_Images/ShoppingBag.jpg", price: 750 },
            { product_id: 8, name: "【SOTHING 向物】折疊冰敷高速手持風扇 - 渦輪Ice", image: "DiamondStore_Images/sothingICEfan.jpg", price: 17000 },
            { product_id: 9, name: "【SOTHING 向物】桌面風扇數顯搖頭版(Type-C充電)", image: "DiamondStore_Images/sothingTABLEfan.jpg", price: 18000 },
            { product_id: 10, name: "【原萃】系列茶飲580mlx4瓶", image: "DiamondStore_Images/TeaRealLeaf.jpg", price: 1500 }
        ];

        // 🧮 整理成商品資料（若未來同商品多規格）
        const products = Object.values(
            variants.reduce((acc, v) => {
                if (!acc[v.product_id]) {
                    acc[v.product_id] = {
                        name: v.name,
                        image: v.image,
                        minPrice: v.price,
                        maxPrice: v.price
                    };
                } else {
                    acc[v.product_id].minPrice = Math.min(acc[v.product_id].minPrice, v.price);
                    acc[v.product_id].maxPrice = Math.max(acc[v.product_id].maxPrice, v.price);
                }
                return acc;
            }, {})
        );

        // 🧱 生成商品卡片（基於模板）
        function renderProducts(list) {
            const container = document.getElementById("productContainer");
            const template = document.querySelector(".product-card-template");
            container.innerHTML = "";

            list.forEach(p => {
                const clone = template.cloneNode(true);
                clone.classList.remove("product-card-template"); // 顯示用
                const priceDisplay = p.minPrice === p.maxPrice ? `${p.minPrice}` : `${p.minPrice} ~ ${p.maxPrice}`;
                clone.querySelector(".product-image").src = p.image;
                clone.querySelector(".product-image").alt = p.name;
                clone.querySelector(".product-name").textContent = p.name;
                clone.querySelector(".price-text").textContent = priceDisplay;
                container.appendChild(clone);
            });
        }

        // 🔁 排序功能
        document.getElementById("sortSelect").addEventListener("change", function () {
            const value = this.value;
            const sorted = [...products].sort((a, b) =>
                value === "asc" ? a.minPrice - b.minPrice : b.maxPrice - a.maxPrice
            );
            renderProducts(sorted);
        });

        // ⬆️ 回頂按鈕
        function scrollToTop() {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        // 🚀 預設載入
        window.onload = () => renderProducts(products.sort((a, b) => a.minPrice - b.minPrice));
    </script>
</body>
</html>
