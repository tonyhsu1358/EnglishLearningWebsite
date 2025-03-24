<%@ Page Language="C#" AutoEventWireup="true" CodeFile="HomePage.aspx.cs" Inherits="HomePage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>English Learning - Home</title>

    <!-- Bootstrap 5 & FontAwesome -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" />

    <style>
        /* 全局設定（Global Styles） */
        body {
            font-family: 'Arial', sans-serif; /* 設定全站字體 */
            margin: 0; /* 移除頁面邊距 */
            padding: 0; /* 移除內邊距 */
        }

        /* 導覽列（Navigation Bar） */
        .navbar {
            background-color: #002B5B; /* 設定深藍色背景 */
            padding: 12px 0; /* 上下內邊距12px */
        }

        .navbar-brand {
            color: white !important; /* 強制設定品牌名稱顏色為白色 */
            font-weight: bold; /* 設定字體加粗 */
            font-size: 22px; /* 設定字體大小為22px */
        }

        /* 美化導覽列文字 */
        .navbar-nav .nav-link {
            font-size: 17px; /* 增加字體大小，讓字更清楚 */
            font-weight: bold; /* 加粗，提高可讀性 */
            color: white !important; /* 確保文字顏色為白色 */
            padding: 10px 20px; /* 增加內邊距，讓按鈕更大氣 */
            border-radius: 6px; /* 讓邊角更圓滑 */
            transition: all 0.3s ease-in-out; /* 設定動畫，使變化更順滑 */
        }

            /* 滑鼠懸停時，字體顏色變化 */
            .navbar-nav .nav-link:hover {
                color: #FFC107 !important; /* 文字變成金黃色 */
                transform: translateY(-2px); /* 讓按鈕稍微上移，提升互動感 */
            }

            /* 按下時的效果 */
            .navbar-nav .nav-link:active {
                background: rgba(255, 193, 7, 0.4); /* 按下時背景變更明顯 */
                color: white !important; /* 文字仍然保持清晰 */
                transform: translateY(1px); /* 按下時讓按鈕稍微下壓 */
            }

        /* 用戶資訊區（User Info） */
        .user-info {
            display: flex; /* 使用彈性盒子布局 */
            align-items: center; /* 垂直方向居中對齊 */
            gap: 15px; /* 設定子元素之間的間距為15px */
        }

            .user-info img {
                width: 24px; /* 設定圖片寬度為24px */
                height: 24px; /* 設定圖片高度為24px */
            }

        /* 體力 & 鑽石數值顯示 */
        .resource-container {
            display: flex; /* 使用彈性盒子布局 */
            align-items: center; /* 垂直方向居中對齊 */
            gap: 10px; /* 設定子元素之間的間距為10px */
        }

        .energy, .diamonds {
            display: flex; /* 使用彈性盒子布局 */
            align-items: center; /* 垂直方向居中對齊 */
            font-size: 16px; /* 設定字體大小為16px */
            font-weight: bold; /* 設定字體加粗 */
            color: white; /* 設定字體顏色為白色 */
        }

            .energy img, .diamonds img {
                width: 22px; /* 設定圖片寬度為22px */
                height: 22px; /* 設定圖片高度為22px */
                margin-right: 5px; /* 設定右側間距為5px */
            }

        /* 統一資源圖標大小 */
        .resource-icon {
            width: 28px; /* 設定圖標寬度為28px */
            height: 28px; /* 設定圖標高度為28px */
            margin-right: 5px; /* 設定右側間距為5px */
            vertical-align: middle; /* 設定垂直對齊方式為middle */
            filter: drop-shadow(0px 0px 6px rgba(173, 216, 230, 0.8)) drop-shadow(0px 0px 12px rgba(173, 216, 230, 0.5)); /* 添加陰影效果 */
        }

        /* 提示框（Tooltip） */
        .tooltip-container {
            position: relative; /* 設定為相對定位 */
            display: inline-block; /* 設定顯示類型為行內塊級元素 */
            cursor: pointer; /* 設定鼠標樣式為手型 */
        }

            /* 懸停時顯示 Tooltip */
            .tooltip-container::after {
                content: attr(data-tooltip); /* 設定 Tooltip 內容為 data-tooltip 屬性值 */
                position: absolute; /* 設定為絕對定位 */
                background-color: rgba(0, 0, 0, 0.8); /* 設定背景顏色為半透明黑色 */
                color: #fff; /* 設定文字顏色為白色 */
                font-size: 13px; /* 設定字體大小為13px */
                padding: 6px 10px; /* 設定內邊距為6px 10px */
                border-radius: 5px; /* 設定邊框圓角為5px */
                white-space: nowrap; /* 禁止換行 */
                top: 120%; /* 設定 Tooltip 與元素的間距 */
                left: 50%; /* 設定 Tooltip 水平居中 */
                transform: translateX(-50%); /* 使其完全居中 */
                opacity: 0; /* 初始時設為透明 */
                visibility: hidden; /* 初始時設為隱藏 */
                transition: opacity 0.2s ease-in-out; /* 設定透明度變化動畫 */
                pointer-events: none; /* 禁止事件觸發 */
                z-index: 1000; /* 設定層級較高，確保顯示在最前方 */
            }

            .tooltip-container:hover::after {
                opacity: 1; /* 懸停時顯示 Tooltip */
                visibility: visible; /* 使其可見 */
            }

        /* 美化登入/註冊按鈕 */
        .btn-login {
            font-size: 16px; /* 增加字體大小 */
            font-weight: bold; /* 字體加粗 */
            padding: 10px 20px; /* 設定內邊距，讓按鈕更大氣 */
            border-radius: 8px; /* 設定圓角 */
            border: none; /* 移除邊框 */
            cursor: pointer; /* 設定鼠標樣式為手型 */
            text-transform: uppercase; /* 設定文字為全大寫，讓它更突出 */
            letter-spacing: 1px; /* 增加字距，提高可讀性 */
            /* 背景漸變，使按鈕更有質感 */
            background: linear-gradient(135deg, #FFC107, #FFA000); /* 金黃色漸變 */
            color: white; /* 文字顏色設為白色 */
            /* 添加陰影，讓按鈕更立體 */
            box-shadow: 0 4px 6px rgba(255, 193, 7, 0.3), 0 2px 3px rgba(0, 0, 0, 0.2);
            /* 設定動畫，使變化更順滑 */
            transition: all 0.3s ease-in-out;
        }

            /* 滑鼠懸停時 */
            .btn-login:hover {
                background: linear-gradient(135deg, #FFD54F, #FFB300); /* 變亮 */
                box-shadow: 0 6px 12px rgba(255, 193, 7, 0.4), 0 3px 6px rgba(0, 0, 0, 0.3); /* 增加陰影 */
                transform: translateY(-2px); /* 按鈕稍微上移 */
            }

            /* 按鈕被點擊時 */
            .btn-login:active {
                background: linear-gradient(135deg, #FFB300, #FF8F00); /* 變深 */
                box-shadow: 0 2px 6px rgba(255, 193, 7, 0.5); /* 陰影縮小 */
                transform: translateY(1px); /* 按下時按鈕略微下壓 */
            }
        /* ✅ HERO 區塊設計 */
        .hero-section {
            width: 100%; /* 設定寬度為100% */
            max-width: 1200px; /* 設定最大寬度為1200px，避免過大 */
            margin: 0 auto; /* 設定水平居中 */
            padding-top: 20px; /* 設定頂部內邊距為20px */
        }

            .hero-section img {
                width: 100%; /* 讓圖片填滿容器 */
                height: 230px; /* 設定固定高度為230px */
                display: block; /* 設定為區塊級元素 */
                border-radius: 12px; /* 設定圖片圓角 */
            }


        /* 左側分類區（Side Category） */
        .category-box {
            background: #FFFAF3;
            border: 2px solid #FFCC80;
            border-radius: 10px;
            padding: 15px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }

        /* 個人紀錄區塊 */
        .personal-record {
            background: #E3F2FD; /* 柔和的淡藍色背景，使其與其他區塊區分開來 */
            border: 2px solid #2196F3; /* 設定深藍色邊框，提高區塊辨識度 */
            box-shadow: 0 3px 8px rgba(33, 150, 243, 0.3); /* 添加陰影，使區塊更有立體感 */
            border-radius: 10px; /* 設定圓角，使區塊邊緣更柔和 */
            padding: 15px; /* 設定內邊距，確保內容與邊框有間距 */
        }

            /* 個人紀錄標題 */
            .personal-record .category-title {
                background: #1976D2; /* 設定標題的背景色為深藍 */
                color: #FFFFFF; /* 設定標題文字顏色為白色 */
                padding: 8px; /* 設定標題內邊距，讓文字更清晰 */
                border-radius: 6px; /* 設定標題的圓角 */
                font-weight: bold; /* 設定標題字體加粗 */
                text-align: center; /* 讓標題文字置中 */
            }

            /* 個人紀錄列表 */
            .personal-record .category-list {
                list-style: none; /* 移除預設列表的黑點 */
                padding: 0; /* 移除內邊距 */
            }

                /* 個人紀錄列表項目 */
                .personal-record .category-list li {
                    display: flex; /* 使用彈性盒子對齊圖標與文字 */
                    align-items: center; /* 垂直置中 */
                    padding: 8px 0; /* 設定間距，讓每個項目間有適當距離 */
                }

                    /* 圖標樣式 */
                    .personal-record .category-list li i {
                        color: #1976D2; /* 設定圖標顏色為深藍 */
                        font-size: 18px; /* 設定圖標大小 */
                        margin-right: 8px; /* 讓圖標與文字之間有間距 */
                    }

                    /* 連結文字樣式 */
                    .personal-record .category-list li a {
                        text-decoration: none; /* 移除底線 */
                        color: #1976D2; /* 設定連結文字預設為深藍 */
                        font-weight: bold; /* 設定字體加粗 */
                        transition: color 0.3s ease-in-out; /* 設定顏色變化的過渡動畫 */
                    }

                        /* 懸停時變色 */
                        .personal-record .category-list li a:hover {
                            color: #FFC107; /* 滑鼠懸停時，文字變為金色 */
                        }

        /* 相關資源區塊 */
        .category-box:not(.personal-record) {
            background: #FFF3E0; /* 柔和的橘色背景 */
            border: 2px solid #FF9800; /* 設定橘色邊框 */
            border-radius: 10px; /* 設定圓角 */
            padding: 15px; /* 設定內邊距 */
            box-shadow: 0 3px 8px rgba(255, 152, 0, 0.3); /* 添加陰影，使區塊更有立體感 */
        }

            /* 相關資源標題 */
            .category-box:not(.personal-record) .category-title {
                background: #FF9800; /* 設定標題背景顏色為橘色 */
                color: #FFFFFF; /* 設定標題文字為白色 */
                padding: 8px; /* 設定內邊距 */
                border-radius: 6px; /* 設定標題圓角 */
                font-weight: bold; /* 設定字體加粗 */
                text-align: center; /* 讓標題置中 */
            }

            /* 相關資源列表 */
            .category-box:not(.personal-record) .category-list {
                list-style: none; /* 移除列表黑點 */
                padding: 0; /* 移除內邊距 */
            }

                /* 相關資源列表項目 */
                .category-box:not(.personal-record) .category-list li {
                    display: flex; /* 使用彈性盒子對齊圖標與文字 */
                    align-items: center; /* 垂直置中 */
                    padding: 8px 0; /* 設定間距 */
                }

                    /* 相關資源圖標 */
                    .category-box:not(.personal-record) .category-list li i {
                        color: #FF9800; /* 設定圖標顏色為橘色 */
                        font-size: 18px; /* 設定圖標大小 */
                        margin-right: 8px; /* 讓圖標與文字有間距 */
                    }

                    /* 相關資源連結 */
                    .category-box:not(.personal-record) .category-list li a {
                        text-decoration: none; /* 移除底線 */
                        color: #FF9800;
                        font-weight: bold; /* 設定字體加粗 */
                        transition: color 0.3s ease-in-out; /* 設定顏色變化的過渡動畫 */
                    }

                        /* 相關資源懸停時變色 */
                        .category-box:not(.personal-record) .category-list li a:hover {
                            color: #D35400; /* 懸停時變成深橘色 */
                        }

        /* 課程卡片 */
        .course-card {
            position: relative; /* 設定相對定位 */
            overflow: hidden; /* 隱藏超出部分 */
            border-radius: 12px; /* 設定圓角 */
            box-shadow: 0 3px 8px rgba(0, 0, 0, 0.12); /* 添加陰影效果 */
            transition: transform 0.3s ease; /* 設定縮放動畫 */
            background: #ffffff; /* 設定背景顏色為白色 */
            width: 100%; /* 設定寬度填滿 */
            margin: 0 auto; /* 水平居中 */
            margin-bottom: 20px; /* 設定底部間距 */
        }

            /* 滑鼠懸停時放大 */
            .course-card:hover {
                transform: scale(1.04); /* 滑鼠懸停時放大 1.04 倍 */
            }

        /* 課程圖片 */
        .course-img {
            width: 100%; /* 設定圖片寬度填滿 */
            height: 180px; /* 設定圖片固定高度 */
            object-fit: cover; /* 讓圖片完整填滿，不變形 */
            border-radius: 12px 12px 0 0; /* 設定圖片上方圓角 */
            transition: transform 0.3s ease-in-out; /* 設定縮放動畫 */
        }

        /* 滑鼠懸停時圖片放大 */
        .course-card:hover .course-img {
            transform: scale(1.1); /* 滑鼠懸停時圖片放大 1.1 倍 */
        }

        /* 課程內容 */
        .course-card-body {
            padding: 14px; /* 設定內邊距 */
            text-align: center; /* 文字置中 */
            background: white; /* 設定背景為白色 */
            border-radius: 0 0 12px 12px; /* 設定下方圓角 */
        }

        /* 美化課程按鈕 */
        .btn-course {
            font-size: 14px; /* 略微增大字體，提高可讀性 */
            padding: 10px 16px; /* 增加內邊距，使按鈕更大氣 */
            border-radius: 8px; /* 設定圓角，讓按鈕更柔和 */
            font-weight: bold; /* 設定字體加粗 */
            text-transform: uppercase; /* 讓按鈕文字變成全大寫，增加可讀性 */
            border: none; /* 移除按鈕邊框 */
            cursor: pointer; /* 設定鼠標樣式為手型 */
            /* 設定按鈕的漸變背景，使其更有質感 */
            background: linear-gradient(135deg, #007BFF, #0056b3); /* 從淺藍到深藍的漸變 */
            color: white; /* 設定文字顏色為白色 */
            /* 添加陰影，使按鈕更有立體感 */
            box-shadow: 0 4px 6px rgba(0, 123, 255, 0.3), 0 1px 3px rgba(0, 0, 0, 0.2);
            /* 添加動畫，使按鈕變化更順滑 */
            transition: all 0.3s ease-in-out;
        }

            .btn-course:hover {
                background: linear-gradient(135deg, #0056b3, #003d80); /* 深色漸變，提高對比 */
                box-shadow: 0 6px 12px rgba(0, 123, 255, 0.4), 0 3px 6px rgba(0, 0, 0, 0.3); /* 增加陰影，讓按鈕更突出 */
                transform: translateY(-2px); /* 懸停時按鈕稍微上移，增加動態感 */
            }

            /* 按下按鈕時的效果 */
            .btn-course:active {
                background: linear-gradient(135deg, #004080, #002f60); /* 點擊時顏色更深 */
                box-shadow: 0 2px 6px rgba(0, 123, 255, 0.5); /* 按下時陰影變小，增加按壓感 */
                transform: translateY(1px); /* 按下時按鈕略微下壓，提升真實感 */
            }
    </style>
</head>

<body>
    <form runat="server">
        <!-- 導覽列 -->
        <nav class="navbar navbar-expand-lg navbar-dark">
            <div class="container">
                <a class="navbar-brand" href="HomePage.aspx">
                    <i class="fa-solid fa-book-open"></i>English Learning
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav ms-auto">
                        <li class="nav-item"><a class="nav-link" href="HomePage.aspx">首頁</a></li>
                        <li class="nav-item"><a class="nav-link" href="Courses.aspx">課程</a></li>
                        <li class="nav-item"><a class="nav-link" href="About.aspx">關於網站</a></li>
                        <li class="nav-item"><a class="nav-link" href="Contact.aspx">聯絡我們</a></li>

                        <!-- 🔹 用戶未登入時顯示登入按鈕 -->
                        <li class="nav-item">
                            <asp:Button ID="btnLogin" runat="server" CssClass="btn btn-login ms-2" Text="登入 / 註冊" PostBackUrl="UserLogin.aspx" />
                        </li>

                        <!-- 🔹 用戶登入後顯示資訊 -->
                        <li class="nav-item d-flex align-items-center user-info">
                            <asp:Label ID="lblUserName" runat="server" CssClass="text-white fw-bold me-2"></asp:Label>

                            <!-- 體力 -->
                            <div id="energyContainer" runat="server" class="energy">
                                <span class="tooltip-container" data-tooltip="魔法能量：可用於參加學習挑戰">
                                    <img src="images/energy.svg" class="resource-icon" alt="Energy">
                                </span>
                                <asp:Label ID="lblEnergy" runat="server" CssClass="text-white fw-bold"></asp:Label>
                            </div>

                            <!-- 鑽石 -->
                            <div id="diamondsContainer" runat="server" class="diamonds">
                                <span class="tooltip-container" data-tooltip="魔法鑽石：可用於兌換特殊物品">
                                    <img src="images/diamond.svg" class="resource-icon" alt="Diamonds">
                                </span>
                                <asp:Label ID="lblDiamonds" runat="server" CssClass="text-white fw-bold"></asp:Label>
                            </div>
                </div>

                <asp:Button ID="btnLogout" runat="server" CssClass="btn btn-danger ms-2" Text="登出" OnClick="btnLogout_Click" Visible="false" />
                </li>
                    </ul>
            </div>
            </div>
        </nav>

        <!-- Hero 區域 -->
        <section class="hero-section">
            <div class="container">
                <div class="text-center">
                    <img src="images\herosection.jpg" class="d-block w-100 course-img" alt="Hero 圖片">
                </div>
            </div>
        </section>

        <section class="container my-5">
            <div class="row">
                <!-- 🔹 左側分類區 (col-md-3) -->
                <div class="col-md-3">
                    <div class="category-box personal-record">
                        <h5 class="category-title">📌 個人紀錄</h5>
                        <ul class="category-list">
                            <li><i class="fa-solid fa-book"></i><a href="#">作答紀錄</a></li>
                            <li><i class="fa-solid fa-chart-line"></i><a href="#">每日統計</a></li>
                            <li><i class="fa-solid fa-list-check"></i><a href="#">進度列表</a></li>
                        </ul>
                    </div>

                    <div class="category-box">
                        <h5 class="category-title">📌 相關資源</h5>
                        <ul class="category-list">
                            <li><i class="fa-solid fa-language"></i><a href="#">中英翻譯</a></li>
                            <li><i class="fa-solid fa-newspaper"></i><a href="#">精選新聞</a></li>
                            <li><i class="fa-solid fa-play-circle"></i><a href="#">優質頻道</a></li>
                        </ul>
                    </div>
                </div>
                <!-- ✅ 關閉 col-md-3 -->

                <!-- 🔸 右側課程區 (col-md-9) -->
                <div class="col-md-9">
                    <h2 class="text-center mb-4">熱門課程</h2>
                    <div class="row">
                        <!-- 背單字 -->
                        <div class="col-md-4">
                            <div class="course-card">
                                <img src="images/cat.png" alt="背單字" class="course-img">
                                <div class="course-card-body">
                                    <h5>背單字</h5>
                                    <p>趣味單字養成！輕鬆掌握7000單！</p>
                                    <asp:Button ID="btnVocabulary" runat="server" CssClass="btn btn-primary btn-course" Text="開始遊玩" OnClick="btnCourse_Click" CommandArgument="1" />
                                </div>
                            </div>
                        </div>

                        <!-- 聽力測驗 -->
                        <div class="col-md-4">
                            <div class="course-card">
                                <img src="images/owl.png" alt="聽力測驗" class="course-img">
                                <div class="course-card-body">
                                    <h5>聽力測驗</h5>
                                    <p>專業語音測驗，提升聽力理解能力！</p>
                                    <asp:Button ID="btnListening" runat="server" CssClass="btn btn-primary btn-course" Text="開始遊玩" OnClick="btnCourse_Click" CommandArgument="2" />
                                </div>
                            </div>
                        </div>

                        <!-- 連連看 -->
                        <div class="col-md-4">
                            <div class="course-card">
                                <img src="images/rabbit.png" alt="連連看" class="course-img">
                                <div class="course-card-body">
                                    <h5>連連看</h5>
                                    <p>透過趣味連線遊戲，學習英語詞彙！</p>
                                    <asp:Button ID="btnMatching" runat="server" CssClass="btn btn-primary btn-course" Text="開始遊玩" OnClick="btnCourse_Click" CommandArgument="3" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- ✅ 關閉 col-md-9 -->
            </div>
            <!-- ✅ 關閉 row -->
        </section>
    </form>
</body>
<!-- ✅ 確保載入 Bootstrap 5 JavaScript (解決輪播無法運行的問題) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function showEnergyTooltip() {
        console.log("🔹 showEnergyTooltip() 被執行！");

        // ✅ 先確保 energyContainer 存在
        var energyContainer = document.getElementById("energyContainer");
        if (!energyContainer) {
            console.log("❌ 找不到 energyContainer");
            return;
        }

        // ✅ 創建 Tooltip
        var tooltip = document.createElement("div");
        tooltip.classList.add("tooltip-message"); // 使用 CSS 內定義的 class
        tooltip.innerText = "🎉 今日已獲得 10 點魔法能量！";
        document.body.appendChild(tooltip);

        // ✅ 讓 Tooltip 顯示
        setTimeout(() => {
            tooltip.style.opacity = "1"; // 顯示 Tooltip
        }, 50);

        // ✅ 3 秒後自動消失
        setTimeout(() => {
            tooltip.style.opacity = "0";
            setTimeout(() => document.body.removeChild(tooltip), 500);
        }, 3000);
    }
    // ✅ Tooltip 樣式
    var style = document.createElement('style');
    style.innerHTML = `
 .tooltip-message {
    position: fixed; /* 固定位置，不受滾動影響 */
    left: 50%; /* 設定在螢幕 50% 的位置 */
    top: 50%; /* 設定在螢幕 50% 的位置 */
    transform: translate(-50%, -50%); /* 讓 Tooltip 完全居中 */
    background: rgba(0, 0, 0, 0.9); /* 背景半透明 */
    color: white; /* 文字顏色 */
    padding: 12px 20px; /* 內邊距 */
    border-radius: 8px; /* 圓角 */
    font-size: 16px; /* 文字大小 */
    font-weight: bold; /* 字體加粗 */
    text-align: center; /* 文字置中 */
    opacity: 0; /* 初始為透明 */
    transition: opacity 0.5s ease-in-out; /* 動畫 */
    z-index: 9999; /* 確保在最前方 */
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3); /* 陰影 */
}
    `;
    document.head.appendChild(style);
</script>

</html>
