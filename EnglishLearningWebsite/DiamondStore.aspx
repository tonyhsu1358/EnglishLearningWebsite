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
            right: 115px;
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
            cursor: pointer; /* ✅ 滑鼠變手指 */
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

        /* 商品詳細面板樣式*/
        .product-detail-panel {
            background-color: #fff;
            border-radius: 16px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.1);
            max-width: 1000px;
            margin: 30px auto;
            padding: 25px;
        }

        /* 💎 詳細頁：價格顯示樣式 */
        .detail-price {
            display: flex;
            align-items: center;
            font-size: 18px;
            color: #007bff;
        }

            .detail-price .diamond-icon {
                width: 22px;
                height: 22px;
                object-fit: contain;
            }

        .detail-main-image {
            width: 100%;
            max-height: 400px;
            object-fit: contain;
            border-radius: 10px;
            border: 1px solid #ddd;
            background-color: #f8f8f8;
        }

        #specContainer .btn-spec {
            border: 1.5px solid #aaa;
            background-color: #fafafa;
            padding: 6px 14px;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.2s ease;
        }

            #specContainer .btn-spec:hover {
                background-color: #e6f0ff;
                border-color: #66B3FF;
            }

            #specContainer .btn-spec.active {
                background-color:#4D98D1;
                color: white;
                border-color:#4D98D1;
            }

        #detailDesc {
            white-space: pre-line; /* ✅ 支援 \n 換行符號解析 */
        }

        /* 主按鈕樣式（兌換去） */
        .btn-redeem {
            background: linear-gradient(135deg, #66B3FF, #4da3ff);
            color: #fff;
            border: none;
            border-radius: 10px;
            padding: 10px 26px;
            font-weight: 700;
            font-size: 17px;
            transition: all 0.3s ease;
            box-shadow: 0 3px 10px rgba(102, 179, 255, 0.4);
        }

            .btn-redeem:hover {
                background: linear-gradient(135deg, #5aa9ff, #3797ff);
                transform: translateY(-2px);
                box-shadow: 0 5px 14px rgba(102, 179, 255, 0.5);
            }

            /* 禁用時的樣式 */
            .btn-redeem:disabled {
                background: #b0c4de;
                color: #fff;
                cursor: not-allowed;
                box-shadow: none;
            }

        /* 返回商城按鈕樣式 */
        .btn-back {
            display: block; /* 讓它佔整行可置中 */
            margin: 20px auto 0 auto; /* 上方留距離並自動水平置中 */
            width: 50%; /* 寬度 80% */
            text-align: center; /* 文字置中 */
            background-color: transparent;
            color: #66B3FF;
            font-weight: 600;
            font-size: 18px; /* 稍微加大字體 */
            border: 2px solid #66B3FF;
            border-radius: 10px;
            padding: 10px 0; /* 🔹 高度增加關鍵：加大上下 padding */
            transition: all 0.3s ease;
            text-decoration: none;
        }

            .btn-back:hover {
                background-color: #66B3FF;
                color: white;
                text-decoration: none;
                transform: translateY(-2px); /* 微浮起感 */
                box-shadow: 0 4px 10px rgba(102, 179, 255, 0.3);
            }


            .btn-back:hover {
                background-color: #66B3FF;
                color: white;
                text-decoration: none;
            }

        /* ✨ 訂單確認面板樣式與動畫*/
        .order-confirm-panel {
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            max-width: 900px;
            margin: 40px auto;
            padding: 25px;
            opacity: 0;
            transform: translateX(100%);
            transition: all 0.6s ease;
        }

            /* 顯示動畫（右滑進場） */
            .order-confirm-panel.show {
                opacity: 1;
                transform: translateX(0);
            }

        /* 隱藏時動畫（左滑出） */
        .product-detail-panel.hide-left {
            transform: translateX(-100%);
            opacity: 0;
            transition: all 0.6s ease;
        }

        /* 美化按鈕 */
        #btnConfirmOrder {
            background: linear-gradient(135deg, #66B3FF, #4da3ff);
            border: none;
            font-weight: 600;
            box-shadow: 0 3px 10px rgba(102, 179, 255, 0.4);
        }

            #btnConfirmOrder:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 14px rgba(102, 179, 255, 0.5);
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

        <!-- =====🧩 商品詳細面板（初始隱藏） ===== -->
        <div id="pnlProductDetail" class="product-detail-panel" style="display: none;">
            <div class="detail-content container py-4">
                <div class="row">
                    <!-- 左側：商品主圖 -->
                    <div class="col-md-6 text-center">
                        <img id="detailImage" src="" alt="商品主圖" class="detail-main-image">
                    </div>

                    <!-- 右側：商品資訊 -->
                    <div class="col-md-6">
                        <h3 id="detailName" class="fw-bold mb-3"></h3>
                        <!-- 💎 新增這段：顯示目前所需鑽石 -->
                        <div id="detailPriceDisplay" class="detail-price mb-3 text-primary fw-bold">
                            <img src="images/diamond.svg" class="diamond-icon me-1" alt="diamond" />
                            <span id="detailPriceText">請選擇規格</span>
                        </div>
                        <p id="detailDesc" class="text-muted mb-3"></p>

                        <div class="mb-2 fw-bold">庫存：<span id="detailStock">0</span> 件</div>

                        <!-- 規格按鈕區 -->
                        <div id="specContainer" class="d-flex flex-wrap gap-2 my-3"></div>

                        <!-- 數量與兌換按鈕 -->
                        <div class="d-flex align-items-center gap-3 mt-4">
                            <!-- 🌟 新增這行：數量標籤 -->
                            <span class="fw-bold" style="font-size: 16px;">數量:</span>

                            <div class="quantity-control d-flex align-items-center">
                                <button type="button" class="btn btn-outline-secondary" id="btnMinus" disabled>-</button>
                                <input type="number" id="inputQty" class="form-control text-center" value="1" min="1" style="width: 70px;" disabled>
                                <button type="button" class="btn btn-outline-secondary" id="btnPlus" disabled>+</button>
                            </div>
                            <button type="button" id="btnRedeem" class="btn-redeem" disabled>兌換去</button>
                        </div>

                    </div>
                    <hr class="mt-4 mb-3" />
                    <button type="button" class="btn-back" id="btnBackToStore">← 返回商城</button>
                </div>
            </div>
        </div>

        <!-- =====🧾 訂單確認面板（初始隱藏）===== -->
        <div id="pnlOrderConfirm" class="order-confirm-panel" style="display: none;">
            <div class="container py-4">
                <h3 class="fw-bold text-center mb-4 text-primary">訂單確認</h3>

                <!-- 商品摘要 -->
                <div class="d-flex align-items-center border rounded p-3 mb-4 bg-light shadow-sm">
                    <img id="confirmImage" src="images/placeholder.png" class="me-3 rounded"
                        style="width: 120px; height: 120px; object-fit: contain;">
                    <div>
                        <h5 id="confirmName" class="fw-bold mb-1">商品名稱</h5>
                        <div class="text-muted mb-1">規格：<span id="confirmSpec">星空灰</span></div>
                        <div class="text-muted mb-1">數量：<span id="confirmQty">1</span></div>
                        <div class="text-muted mb-1">單價：💎<span id="confirmPrice">120</span></div>
                        <div class="fw-bold text-danger">小計：💎<span id="confirmTotal">120</span></div>
                    </div>
                </div>

                <!-- 配送資訊 -->
                <h5 class="fw-bold mb-3">配送資訊</h5>
                <div class="mb-3">
                    <label class="form-label fw-semibold">收件姓名 <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="inputName" placeholder="請輸入姓名">
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">聯絡電話 <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="inputPhone" placeholder="例如：0912345678">
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">配送地址 <span class="text-danger">*</span></label>
                    <textarea class="form-control" id="inputAddress" rows="2" placeholder="請輸入收件地址（限台灣本島地址，以內政部戶政司門牌資料為主。）"></textarea>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">備註（可選）</label>
                    <input type="text" class="form-control" id="inputRemark" placeholder="例如：特殊需求（※註：若您兌換的為虛擬商品無須備註，待客服聯絡後送出。）">
                </div>

                <!-- 訂單摘要 -->
                <div class="border-top pt-3 mt-4">
                    <div class="d-flex justify-content-between">
                        <span>可用鑽石</span><span id="lblUserDiamonds">300</span>
                    </div>
                    <div class="d-flex justify-content-between">
                        <span>預計扣除</span><span class="text-danger" id="lblCost">120</span>
                    </div>
                    <div class="d-flex justify-content-between fw-bold">
                        <span>兌換後剩餘</span><span id="lblRemain" class="text-success">180</span>
                    </div>
                </div>

                <!-- 按鈕列 -->
                <div class="text-center mt-4">
                    <button type="button" class="btn btn-outline-secondary me-3" id="btnBackToDetail">← 返回商品</button>
                    <button type="button" class="btn btn-primary px-4" id="btnConfirmOrder">✅ 確認送出訂單</button>
                </div>
            </div>
        </div>

    </form>

    <!-- ✅ Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        //==========================================
        //========== 第零章：載入後顯示商品圖邏輯 ==
        //==========================================

        let productsById = {}; // { [product_id]: { product_id, name, description, main_image, minPrice, maxPrice, totalStock, variants: [...] } }
        let products = [];     // 給卡片渲染用的精簡陣列

        async function fetchActiveProducts() {
            const res = await fetch('DiamondStoreService.asmx/GetActiveProducts', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: '{}',
                credentials: 'include' // 若要帶 ASP.NET Session
            });

            // ASMX 會回傳 { d: "JSON字串" }
            const raw = await res.json();
            const payload = typeof raw.d === 'string' ? JSON.parse(raw.d) : raw;

            if (!payload.success) {
                throw new Error(payload.message || 'GetActiveProducts failed');
            }
            return payload.data; // ← 這是資料表 JOIN 出來的「扁平列表」
        }

        // 把扁平列表分組成 productsById 與 cards 用的 products
        function buildProductStructures(rows) {
            productsById = {};
            rows.forEach(row => {
                const pid = Number(row.product_id);
                if (!productsById[pid]) {
                    productsById[pid] = {
                        product_id: pid,
                        name: row.name,
                        description: row.description || '',
                        main_image: row.main_image || '',
                        minPrice: row.price,
                        maxPrice: row.price,
                        totalStock: row.stock || 0,
                        variants: []
                    };
                } else {
                    // 累加庫存
                    productsById[pid].totalStock += (row.stock || 0);
                    // 更新 min/max 價格
                    productsById[pid].minPrice = Math.min(productsById[pid].minPrice, row.price);
                    productsById[pid].maxPrice = Math.max(productsById[pid].maxPrice, row.price);
                }

                // 塞入規格
                productsById[pid].variants.push({
                    variant_id: row.variant_id,
                    spec_name: row.spec_name,
                    price: row.price,
                    spec_image: row.spec_image,
                    stock: row.stock
                });
            });

            // 轉成卡片渲染用陣列
            products = Object.values(productsById).map(p => ({
                product_id: p.product_id,
                name: p.name,
                image: p.main_image, // ← 主圖
                minPrice: p.minPrice,
                maxPrice: p.maxPrice
            }));
        }

        // 生成商品卡片（你原來的 renderProducts 可沿用，只有確保 src 會拿到 main_image）
        function renderProducts(list) {
            const container = document.getElementById("productContainer");
            const template = document.querySelector(".product-card-template");
            container.innerHTML = "";

            list.forEach(p => {
                const clone = template.cloneNode(true);
                clone.classList.remove("product-card-template");
                const priceDisplay = p.minPrice === p.maxPrice ? `${p.minPrice}` : `${p.minPrice} ~ ${p.maxPrice}`;
                const img = clone.querySelector(".product-image");
                img.src = p.image || '';
                img.alt = p.name;
                // 若圖片壞掉顯示預設
                img.onerror = () => { img.src = 'images/placeholder.png'; };

                clone.querySelector(".product-name").textContent = p.name;
                clone.querySelector(".price-text").textContent = priceDisplay;

                // 點商品 → 詳細頁
                clone.querySelector(".product-card").addEventListener("click", () => openProductDetail(p.product_id));

                container.appendChild(clone);
            });
        }

        // 排序事件保留
        document.getElementById("sortSelect").addEventListener("change", function () {
            const value = this.value;
            const sorted = [...products].sort((a, b) =>
                value === "asc" ? a.minPrice - b.minPrice : b.maxPrice - a.maxPrice
            );
            renderProducts(sorted);
        });

        // 回頂
        function scrollToTop() { window.scrollTo({ top: 0, behavior: "smooth" }); }

        // 🚀 預設載入：改成實際 AJAX
        window.onload = async function () {
            try {
                const flatRows = await fetchActiveProducts();
                buildProductStructures(flatRows);

                // 預設用價格由少到多
                const sorted = [...products].sort((a, b) => a.minPrice - b.minPrice);
                renderProducts(sorted);
            } catch (err) {
                console.error(err);
                alert("載入商品失敗，請稍後再試。");
            }
        };
    </script>

    <script>
        //==========================================
        /* ==== 第一章：商品詳情顯示邏輯（含庫存限制） === */
        //==========================================

        let currentVariantStock = 0; // 🔹記錄目前選取規格的庫存上限

        function openProductDetail(productId) {
            const product = productsById[productId];
            if (!product) {
                alert("⚠️ 無法找到商品資料。");
                return;
            }

            // 🔹 DOM 快取
            const imgEl = document.getElementById("detailImage");
            const nameEl = document.getElementById("detailName");
            const descEl = document.getElementById("detailDesc");
            const stockEl = document.getElementById("detailStock");
            const priceTextEl = document.getElementById("detailPriceText");
            const specContainer = document.getElementById("specContainer");

            // Step 1️⃣ 初始化頁面內容
            imgEl.src = product.main_image || "";
            imgEl.onerror = () => { imgEl.src = "images/placeholder.png"; };
            nameEl.textContent = product.name;
            descEl.innerHTML = (product.description || "")
                .replace(/\\n/g, "<br>")
                .replace(/\n/g, "<br>");
            stockEl.textContent = product.totalStock || 0;

            if (product.variants && product.variants.length > 0) {
                const minPrice = Math.min(...product.variants.map(v => v.price));
                priceTextEl.textContent = `${minPrice.toLocaleString()} 起`;
            } else {
                priceTextEl.textContent = "尚無定價";
            }

            specContainer.innerHTML = "";
            resetDetailControls();

            // Step 2️⃣ 動態建立規格按鈕
            product.variants.forEach(v => {
                const btn = document.createElement("button");
                btn.type = "button";
                btn.textContent = `${v.spec_name}`;
                btn.classList.add("btn-spec");

                btn.onclick = () => {
                    const isActive = btn.classList.contains("active");

                    // 🧹 再點一次 → 取消選取
                    if (isActive) {
                        btn.classList.remove("active");
                        imgEl.src = product.main_image || "";
                        priceTextEl.textContent = "請選擇規格";
                        currentVariantStock = 0;
                        resetDetailControls();
                        return;
                    }

                    // ✅ 切換新規格
                    document.querySelectorAll(".btn-spec").forEach(b => b.classList.remove("active"));
                    btn.classList.add("active");

                    // ✅ 更新顯示價格與圖片
                    priceTextEl.textContent = v.price.toLocaleString();
                    fadeImage(imgEl, v.spec_image || product.main_image);

                    // ✅ 設定當前庫存上限
                    currentVariantStock = v.stock || 0;

                    // ✅ 顯示該規格庫存
                    stockEl.textContent = v.stock;

                    // ✅ 啟用互動控制
                    enableDetailControls();
                };

                specContainer.appendChild(btn);
            });

            // ✅✨ 加這段：自動選取第一個規格（若存在）
            if (product.variants.length > 0) {
                const firstBtn = specContainer.querySelector(".btn-spec");
                if (firstBtn) {
                    firstBtn.click(); // ← 模擬點擊第一個規格
                }
            }

            // Step 3️⃣ 顯示詳情面板以及自動捲動到最上方
            document.querySelector(".store-container").style.display = "none";
            document.getElementById("pnlProductDetail").style.display = "block";
            window.scrollTo(0, 0);
        }

        /* ============================================================
           ⚙️ 狀態控制輔助函式
           ============================================================ */
        function enableDetailControls() {
            document.getElementById("btnPlus").disabled = false;
            document.getElementById("btnMinus").disabled = false;
            document.getElementById("inputQty").disabled = false;
            document.getElementById("btnRedeem").disabled = false;
            document.getElementById("btnRedeem").classList.remove("btn-secondary");
            document.getElementById("btnRedeem").classList.add("btn-primary");
        }

        function resetDetailControls() {
            document.getElementById("btnPlus").disabled = true;
            document.getElementById("btnMinus").disabled = true;
            document.getElementById("inputQty").disabled = true;
            document.getElementById("inputQty").value = 1;
            document.getElementById("btnRedeem").disabled = true;
            document.getElementById("btnRedeem").classList.remove("btn-primary");
            document.getElementById("btnRedeem").classList.add("btn-secondary");
            currentVariantStock = 0;
        }

        /*💫 圖片淡入切換效果*/
        function fadeImage(imgEl, newSrc) {
            imgEl.style.transition = "opacity 0.3s ease";
            imgEl.style.opacity = 0;
            setTimeout(() => {
                imgEl.src = newSrc;
                imgEl.onload = () => (imgEl.style.opacity = 1);
            }, 300);
        }

        /* ↩️ 返回商城（自動重置狀態）*/
        document.getElementById("btnBackToStore").addEventListener("click", () => {
            document.querySelector(".store-container").style.display = "block";
            document.getElementById("pnlProductDetail").style.display = "none";
            resetDetailControls();
        });

        /*➕➖ 數量控制（含上限判斷）*/
        document.getElementById("btnPlus").addEventListener("click", () => {
            const qtyEl = document.getElementById("inputQty");
            let currentQty = parseInt(qtyEl.value);
            if (currentVariantStock > 0 && currentQty < currentVariantStock) {
                qtyEl.value = currentQty + 1;
            } else if (currentVariantStock > 0 && currentQty >= currentVariantStock) {
                alert(`⚠️ 數量不可超過庫存 (${currentVariantStock} 件)！`);
                qtyEl.value = currentVariantStock;
            }
        });

        document.getElementById("btnMinus").addEventListener("click", () => {
            const qtyEl = document.getElementById("inputQty");
            let currentQty = parseInt(qtyEl.value);
            if (currentQty > 1) qtyEl.value = currentQty - 1;
        });

        /*💎 模擬兌換事件*/
        document.getElementById("btnRedeem").addEventListener("click", () => {
            const activeSpec = document.querySelector(".btn-spec.active");
            if (!activeSpec) {
                alert("⚠️ 請先選擇規格！");
                return;
            }
            const qty = parseInt(document.getElementById("inputQty").value);
            if (currentVariantStock > 0 && qty > currentVariantStock) {
                alert(`⚠️ 超出庫存數量 (${currentVariantStock})，請重新選擇。`);
                return;
            }
        });
    </script>

    <script>
        //==========================================
        /* ==== 第二章：訂單確認邏輯 === */
        //==========================================

        const orderPanel = document.getElementById("pnlOrderConfirm");
        const detailPanel = document.getElementById("pnlProductDetail");

        // 🟢 點擊兌換 → 動畫左滑 + 顯示訂單確認
        document.getElementById("btnRedeem").addEventListener("click", () => {
            const activeSpec = document.querySelector(".btn-spec.active");
            if (!activeSpec) {
                alert("⚠️ 請先選擇規格！");
                return;
            }

            const qty = parseInt(document.getElementById("inputQty").value);
            const productName = document.getElementById("detailName").textContent;
            let priceText = document.getElementById("detailPriceText").textContent;
            let price = parseFloat(priceText.replace(/[^\d.]/g, "")) || 0;
            const total = price * qty;
            const specName = activeSpec.textContent;
            const imgSrc = document.getElementById("detailImage").src;

            // 🪄 填入訂單摘要資料
            document.getElementById("confirmName").textContent = productName;
            document.getElementById("confirmSpec").textContent = specName;
            document.getElementById("confirmQty").textContent = qty;
            document.getElementById("confirmPrice").textContent = price.toLocaleString();
            document.getElementById("confirmTotal").textContent = total.toLocaleString();
            document.getElementById("confirmImage").src = imgSrc;

            // 💎 從 ASP.NET 後端取得真實鑽石餘額
            let userDiamondsText = document.getElementById("lblDiamonds").textContent || document.getElementById("lblDiamonds").innerText;
            let userDiamonds = parseInt(userDiamondsText.replace(/[^\d]/g, "")) || 0;

            // 🧮 更新訂單摘要
            document.getElementById("lblUserDiamonds").textContent = userDiamonds.toLocaleString();
            document.getElementById("lblCost").textContent = total.toLocaleString();
            document.getElementById("lblRemain").textContent = (userDiamonds - total).toLocaleString();

            // ✅ 判斷鑽石是否足夠兌換
            const btnConfirm = document.getElementById("btnConfirmOrder");
            const inputFields = ["inputName", "inputPhone", "inputAddress", "inputRemark"];

            if (userDiamonds < total) {
                // ❌ 鑽石不足：禁用按鈕 + 禁用輸入欄位 + 改樣式
                btnConfirm.disabled = true;
                btnConfirm.textContent = "💎 鑽石數量不足，無法兌換";
                btnConfirm.style.background = "#b0c4de";
                btnConfirm.style.cursor = "not-allowed";
                btnConfirm.style.boxShadow = "none";

                inputFields.forEach(id => {
                    const el = document.getElementById(id);
                    if (el) {
                        el.disabled = true;
                        el.style.backgroundColor = "#f2f2f2";
                        el.style.cursor = "not-allowed";
                    }
                });

            } else {
                // ✅ 鑽石足夠：恢復可用
                btnConfirm.disabled = false;
                btnConfirm.textContent = "✅ 確認送出訂單";
                btnConfirm.style.background = "linear-gradient(135deg, #66B3FF, #4da3ff)";
                btnConfirm.style.cursor = "pointer";
                btnConfirm.style.boxShadow = "0 3px 10px rgba(102, 179, 255, 0.4)";

                inputFields.forEach(id => {
                    const el = document.getElementById(id);
                    if (el) {
                        el.disabled = false;
                        el.style.backgroundColor = "#fff";
                        el.style.cursor = "text";
                    }
                });
            }

            // 🎞️ 動畫處理
            detailPanel.classList.add("hide-left");
            setTimeout(() => {
                detailPanel.style.display = "none";
                orderPanel.style.display = "block";
                setTimeout(() => orderPanel.classList.add("show"), 50);
            }, 600);
        });

        // 🔙 返回商品詳情（確保恢復顯示與清除動畫殘留）
        document.getElementById("btnBackToDetail").addEventListener("click", () => {
            orderPanel.classList.remove("show");

            setTimeout(() => {
                // 關閉訂單面板
                orderPanel.style.display = "none";

                // 顯示商品詳情面板
                detailPanel.style.display = "block";

                // ⚠️ 關鍵：移除動畫 class，否則會保持透明狀態
                detailPanel.classList.remove("hide-left");

                // ⚠️ 再次確保不透明與可互動
                detailPanel.style.opacity = "1";
                detailPanel.style.transform = "translateX(0)";
            }, 600);
        });

        // ✅ 確認送出訂單
        document.getElementById("btnConfirmOrder").addEventListener("click", async () => {
            const btn = document.getElementById("btnConfirmOrder");
            if (btn.disabled) {
                alert("⚠️ 鑽石不足，無法兌換此商品！");
                return;
            }

            // 🩸 驗證必填欄位
            const requiredFields = [
                { id: "inputName", label: "收件姓名" },
                { id: "inputPhone", label: "聯絡電話" },
                { id: "inputAddress", label: "配送地址" }
            ];

            let missingFields = [];

            requiredFields.forEach(f => {
                const el = document.getElementById(f.id);
                if (!el || el.value.trim() === "") {
                    missingFields.push(f.label);
                    el.style.border = "2px solid #dc3545"; // 🔴 紅框提示
                } else {
                    el.style.border = ""; // ✅ 清除紅框
                }
            });

            if (missingFields.length > 0) {
                alert(`⚠️ 以下欄位為必填，請完整填寫：\n\n${missingFields.join("、")}`);
                return; // ⛔ 阻止提交
            }

            alert("✅ 模擬送出訂單成功！之後這裡會串接 AJAX。");

            orderPanel.classList.remove("show");
            setTimeout(() => {
                orderPanel.style.display = "none";
                document.querySelector(".store-container").style.display = "block";
                //重置 detailPanel 狀態
                detailPanel.classList.remove("hide-left");
                detailPanel.style.opacity = "1";
                detailPanel.style.transform = "translateX(0)";
            }, 600);
        });
    </script>

</body>
</html>
