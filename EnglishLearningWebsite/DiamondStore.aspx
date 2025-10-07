<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DiamondStore.aspx.cs" Inherits="DiamondStore" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>鑽石兌換商城</title>

    <!-- ✅ 引入 Bootstrap 與 Font Awesome -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

    <style>
        /* 🎨 主體背景與字型 */
        body {
            background-color: #f4f6f8;
            font-family: "Microsoft JhengHei", sans-serif;
        }

        /* 🌈 導覽列設定 */
        .navbar {
            background-color: transparent !important;
            box-shadow: none !important;
            padding: 15px 50px;
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        /* 🌈 導覽列標題置中、水藍色、粗體 */
        .store-title {
            font-weight: 800;
            font-size: 40px;
            color: #66B3FF !important;
            letter-spacing: 1px;
            margin-top: 12px; /* 🎯 下移標題 */
            align-self: flex-start; /* ✅ 讓它不受 align-items-center 控制 */
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

        /* 🔽 排序欄 */
        .sort-bar {
            display: flex;
            align-items: center;
            justify-content: flex-start;
            margin-bottom: 25px;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            padding: 10px 18px;
            transition: all 0.3s ease;
        }

            /* 🎨 標籤樣式 */
            .sort-bar label {
                font-weight: 700;
                margin-right: 12px;
                font-size: 17px;
                color: #555;
            }

            /* 🎨 下拉選單樣式 */
            .sort-bar select {
                border-radius: 10px;
                padding: 8px 32px 8px 14px; /* ✅ 增加右側空間，避免箭頭壓文字 */
                border: 1.5px solid #cdd6e0;
                background-color: #f9fafc;
                background-position: right 10px center; /* ✅ 控制箭頭位置 */
                color: #333;
                font-weight: 500;
                font-size: 15px;
                cursor: pointer;
                transition: all 0.25s ease;
                box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.05);
            }

                /* ✨ hover 效果：輕灰變色＋陰影 */
                .sort-bar select:hover {
                    background-color: #f1f3f5;
                    border-color: #a9b4c3;
                    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
                }

                /* 🔘 focus 效果（點擊選單時） */
                .sort-bar select:focus {
                    outline: none;
                    border-color: #66b3ff;
                    box-shadow: 0 0 6px rgba(102, 179, 255, 0.6);
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

        /* ❌ 原本這段會害所有 img（包含鑽石圖）都被設為 block + margin auto
   ✅ 改成只套用在商品主圖，並新增 class 名為 product-image */
        .product-image {
            width: 100%;
            height: 180px; /* ✅ 固定高度，避免卡片大小不一致 */
            object-fit: contain; /* ✅ 保持完整圖片不被裁切 */
            background-color: #fff;
            border-radius: 10px 10px 0 0;
            display: block;
            margin: 0 auto; /* ✅ 僅商品主圖置中，不影響鑽石 */
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

        /* ✅ 加 gap 控制圖與文字間距，不靠 margin-right */
        .product-price {
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 15px;
            font-weight: 600;
            color: #333;
            margin-top: 6px;
            gap: 10px; /* ✅ 關鍵：這取代 margin-right 的功能 */
        }

        /* ✅ 拔掉 margin-right，交給 flex gap 控制 */
        .diamond-icon {
            width: 20px !important;
            height: 20px !important;
            object-fit: contain;
            vertical-align: middle;
            display: inline-block; /* ✅ 改為 inline-block，不受 block 影響 */
            margin: 0;
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
                <!-- 導覽標題置中 -->
                <span class="store-title">鑽石兌換商城</span>

                <!-- 鑽石數量顯示區 -->
                <div class="resource">
                    <img src="images/diamond.svg" alt="Diamond" />
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
                <!-- ✅ 新增 class="product-image" 只給主圖 -->
                <img src="${p.image}" alt="${p.name}" class="product-image">
                <div class="product-info">
                    <div class="product-name">${p.name}</div>
                    <div class="product-price">
                        <img src="images/diamond.svg" class="diamond-icon" alt="diamond" />
                        ${p.price}
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
