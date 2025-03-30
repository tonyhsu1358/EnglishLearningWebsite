<%@ Page Language="C#" AutoEventWireup="true" CodeFile="VocabularyGame.aspx.cs" Inherits="VocabularyGame" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Vocabulary Game</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" />
    <style>
        /* ===== 全局樣式 ===== */
        body {
            background: url('images/grassland1.svg') no-repeat center center fixed; /* 設定背景圖片不重複、置中且固定 */
            background-size: cover; /* 背景圖填滿整個畫面 */
        }

        /* 狀態欄 */
        #navbar {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            padding: 10px;
            background: rgba(0, 0, 0, 0);
            color: white;
            position: absolute;
            top: 10px;
            right: 10px;
            border-radius: 10px;
            padding: 5px 15px;
        }

        .resource {
            margin: 0 10px;
            font-weight: bold;
            font-size: 18px;
            background: rgba(255, 255, 255, 0.6); /* 半透明白底 */
            padding: 4px 10px;
            border-radius: 8px;
            color: #000; /* 黑字看得清楚 */
            display: flex;
            align-items: center;
            gap: 5px;
        }


        /* 🎯 森林選擇按鈕容器 (可自由移動) */
        .forest-select-container {
            position: absolute; /* 讓容器能夠自由放置在頁面上的特定位置 */
            top: 300px; /* 距離頁面頂部 300px */
            left: 20px; /* 距離頁面左側 20px */
        }

        /* 🎯 森林選擇按鈕 (美化) */
        #forest-select {
            width: 120px; /* 設定按鈕的寬度 */
            height: 120px; /* 設定按鈕的高度 */
            cursor: pointer; /* 讓滑鼠懸停時變成手指 (點擊手勢) */
            transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out; /* 平滑動畫 */
        }

            /* 🟢 滑鼠懸停時讓按鈕有 "上浮" 效果 */
            #forest-select:hover {
                transform: translateY(-5px); /* 往上移動 5px */
                transform: translateY(-5px) scale(1.1); /* 🪄 加上 scale 放大效果 */
            }

        /* ===== 魔法祭壇 (主框架，可自由調整位置) ===== */
        .altar-container {
            position: absolute; /* ✅ 位置不變 */
            top: 290px;
            left: 200px;
            width: 1300px;
            height: 400px;
            background: radial-gradient(circle at top left, #fdf6e3, #f0dab1); /* ✨ 柔和奶油色漸層背景 */
            border: 3px solid #a07c4c; /* 🪄 更有魔法感的邊框 */
            border-radius: 20px;
            box-shadow: 0 0 20px rgba(160, 124, 76, 0.4); /* 🪄 柔和外陰影 */
            padding: 10px;
            display: grid;
            place-items: center;
        }

        /* 🎯 祭壇內的按鈕排列 (讓按鈕填滿空間) */
        .altar-grid {
            display: grid;
            grid-template-columns: repeat(20, 1fr); /* 固定 20 欄 */
            grid-template-rows: repeat(5, 1fr); /* 固定 5 列（總共 100 顆） */
            gap: 5px;
            width: 100%;
            height: 100%;
            padding: 10px;
            box-sizing: border-box;
        }

        .altar-button {
            transition: filter 0.3s ease-in-out, transform 0.3s ease-in-out;
            font-size: 20px; /* ← 加上這行即可變大，依需求可調整大小 */
            font-weight: bold;
        }

            .altar-button:hover {
                filter: brightness(1.3);
                transform: scale(1.03);
            }

            /* 🪨 初始狀態（未學習）*/
            .altar-button.locked {
                width: 100%;
                height: 100%;
                background: #a9a9a9; /* 石頭灰色 */
                color: #fff;
                border: 2px solid #555;
                box-shadow: inset 0 0 5px #333;
                border-radius: 10px;
            }

            /* 🌱 學習中狀態 */
            .altar-button.learning {
                width: 100%;
                height: 100%;
                background: linear-gradient(135deg, #b3d59c, #76b852); /* 淺綠 + 森林綠 */
                color: #fff;
                border: 2px solid #4e944f;
                box-shadow: 0 0 5px #76b852;
                animation: pulse 2s infinite;
                border-radius: 10px;
            }

            /* 🍂 乾枯狀態（提醒複習） */
            .altar-button.withered {
                width: 100%;
                height: 100%;
                background: linear-gradient(135deg, #c79857, #7e5f33); /* 褐色調 */
                color: #fffbe0;
                border: 2px dashed #5a3e1b;
                box-shadow: 0 0 5px rgba(255, 204, 0, 0.5);
                border-radius: 10px;
            }

            /* ✨ 完全狀態（完成） */
            .altar-button.completed {
                width: 100%;
                height: 100%;
                background: linear-gradient(135deg, #ffd700, #ffb400); /* 金黃色調 */
                color: #fff;
                border: 2px solid #c98c00;
                box-shadow: 0 0 10px rgba(255, 223, 0, 0.8);
                font-weight: bold;
                border-radius: 10px;
            }

        /* 💓 呼吸動畫 */
        @keyframes pulse {
            0% {
                transform: scale(1);
            }

            50% {
                transform: scale(1.05);
            }

            100% {
                transform: scale(1);
            }
        }

        /* ===== 告示牌 & 資訊按鈕 (綁定在一起，可自由調整位置) ===== */
        .billboard-container {
            position: absolute; /* 讓你可以自由移動 */
            top: -130px;
            left: 5px;
            display: flex;
            align-items: center;
        }

        #billboard {
            width: 140px;
            height: auto;
        }

        .forest-label {
            position: absolute;
            top: 40px;
            left: 11px;
            font-size: 30px;
            font-weight: bold;
            color: black;
            z-index: 10; /* 提高層級，確保文字在最上層 */
        }

        .info-button {
            position: absolute;
            right: 10px;
            top: 18px;
            width: 30px;
            height: 30px;
            background: white; /* 設定按鈕背景為白色 */
            font-weight: bold;
            text-align: center;
            border-radius: 50%; /* 讓按鈕變成圓形 */
            cursor: pointer;
            line-height: 30px; /* 讓文字垂直置中 */
            border: 2px solid black; /* 增加黑色邊框，讓按鈕更清楚 */
            transition: transform 0.3s ease-in-out;
        }

            .info-button:hover {
                transform: scale(1.1); /* 放大1.1倍 + 旋轉20度 */
            }
        /* ✅ 中央提示框外層（背景半透明） */
        .info-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: rgba(0,0,0,0.5);
            z-index: 10001;
        }
        /* ✅ 提示框本體 */
        .info-modal-content {
            background-color: #fff7e6;
            /*border: 3px solid red !important;*/
            border-radius: 15px;
            padding: 30px;
            width: 450px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.4);
            position: relative;
            text-align: left;
        }

        /* ❌ 右上角關閉按鈕 */
        .info-modal-close {
            position: absolute;
            top: 10px;
            right: 15px;
            font-size: 22px;
            font-weight: bold;
            color: #333;
            cursor: pointer;
            transition: 0.3s;
        }

            .info-modal-close:hover {
                color: #e74c3c;
                transform: scale(1.2);
            }

        .magic-forest-panel {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background-color: #fff7e6;
            border: 3px solid #d2b48c;
            border-radius: 15px;
            padding: 30px;
            z-index: 9999;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.4);
            width: 400px;
            text-align: center;
        }

        .forest-panel-content h3 {
            font-weight: bold;
            margin-bottom: 20px;
        }

        .forest-close {
            position: absolute;
            top: 10px;
            right: 15px;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            color: #444;
            font-size: 20px;
            font-weight: bold;
            display: flex;
            justify-content: center;
            align-items: center;
            cursor: pointer;
            transition: all 0.3s ease-in-out;
        }

            /* ✨ 滑鼠懸停時出現光暈效果 */
            .forest-close:hover {
                box-shadow: 0 0 12px rgba(255, 100, 100, 0.8); /* 紅色光暈，可自定顏色 */
                transform: scale(1.1);
            }

        /* ✅ 祭壇選擇儀表板（置中浮出） */
        .altar-options-panel {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 500px;
            background-color: #fffaf0;
            border: 3px solid #deb887;
            border-radius: 20px;
            box-shadow: 0 0 20px rgba(139, 69, 19, 0.4);
            padding: 30px;
            z-index: 10002;
            display: none;
        }

        /* 儀表板內部排版 */
        .altar-options-content {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 15px;
        }

        .altar-close {
            position: absolute;
            top: 10px;
            right: 15px;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            color: #444;
            font-size: 20px;
            font-weight: bold;
            display: flex;
            justify-content: center;
            align-items: center;
            cursor: pointer;
            transition: all 0.3s ease-in-out;
        }

            .altar-close:hover {
                box-shadow: 0 0 12px rgba(255, 100, 100, 0.8);
                transform: scale(1.1);
            }

        .altar-header {
            position: relative; /* 🔺 要配合子元素絕對定位 */
            width: 100%;
            height: 40px;
        }

        .altar-title-text {
            position: absolute;
            left: 50%;
            transform: translateX(-50%);
            font-weight: bold;
            font-size: 24px;
            color: #6b4226;
        }

        .altar-days-text {
            position: absolute;
            left: calc(50% + 110px); /* ✅ 往右再多偏移（原本 +70px） */
            top: 2px;
            font-size: 20px; /* ✅ 放大字體（原本 16px） */
            color: #999;
            font-weight: 500; /* ✅ 微加粗，讓它更清楚（可選） */
        }

        /* 南瓜進度列區塊 */
        .altar-progress {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-wrap: nowrap;
            margin: 20px auto;
            gap: 0px;
        }

        .altar-pumpkin {
            width: 36px;
            height: auto;
            transition: transform 0.3s;
        }

            .altar-pumpkin:hover {
                transform: scale(1.1);
            }

        .altar-line {
            width: 24px;
            height: auto;
            margin: 0 2px;
        }

        .altar-line, .altar-pumpkin {
            margin-left: -0.55px; /* 負 margin 把圖壓緊 */
            margin-right: -0.55px; /* 負 margin 把圖壓緊 */
        }

        /* 中央按鈕 */
        .altar-button-action {
            font-size: 20px;
            padding: 10px 30px;
            border-radius: 25px;
            background-color: #6b4226;
            border: none;
            color: white;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease-in-out;
        }

            .altar-button-action:hover {
                background-color: #8b5a2b; /* 深咖啡的加亮版 */
            }

        /* 單字圖標 */
        .vocab-icon {
            width: 50px;
            height: auto;
            cursor: pointer;
            transition: transform 0.3s ease-in-out;
        }

            .vocab-icon:hover {
                transform: scale(1.1);
            }

        /* ✅ 卷軸總容器（背景半透明，全畫面置中） */
        .scroll-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0, 0, 0, 0.5);
            z-index: 10003;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 2vh 2vw; /* 讓內容不會貼邊，2%~5%間都可 */
            box-sizing: border-box;
        }

        /* ✅ 卷軸本體（幾乎佔滿，但留邊） */
        .scroll-panel {
            width: 100%;
            height: 100%;
            background: linear-gradient(to bottom right, #f7f1e3, #e4dcc9, #d0c8a0); /* 🌿 魔法森林卷軸色調 */
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
            padding: 0 20px 20px 20px;
            overflow-y: auto;
            overflow-x: hidden;
            position: relative;
            box-sizing: border-box;
        }

        /* ✅ 上方標題 + 關閉 */
        .scroll-header {
            width: 450px; /* ✅ 跟單字卡一樣窄 */
            margin: 0 auto; /* ✅ 置中 */
            position: sticky;
            top: 0;
            background-color: #fefefe; /* ✅ 確保上面有背景會蓋住下方單字 */
            z-index: 10;
            height: 50px;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            padding: 0 20px;
            border-bottom: 2px solid #ddd;
            /* ✅ 加上圓角，讓它融合外框 */
            border-top-left-radius: 10px;
            border-top-right-radius: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .scroll-title {
            position: absolute;
            left: 50%;
            transform: translateX(-50%);
            font-size: 22px;
            font-weight: bold;
            color: #444;
        }

        .scroll-close {
            cursor: pointer;
            font-size: 28px;
            color: #555;
            transition: 0.3s;
        }

            .scroll-close:hover {
                color: red;
                transform: scale(1.1);
            }

        /* ✅ 單字卡片區域 */
        .scroll-words-container {
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin-top: 20px; /* ✅ 加這行！距離 scroll-header 多 20px */
        }

        /* ✅ 單字卡片 */
        .scroll-word-card {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border: 2px solid #ddd;
            border-radius: 12px;
            padding: 15px;
            position: relative;
            width: 450px; /* ✅ 收窄一點，讓左右不貼邊 */
            margin: 0 auto; /* ✅ 置中 */
            background-color: #ffffffee; /* ✅ 淡白底更清晰（可選） */
        }

        /* ✅ 左邊文字 */
        .word-left {
            display: flex;
            flex-direction: column;
        }

            .word-left .word {
                font-size: 20px;
                color: #6b4226;
                font-weight: bold;
            }

            .word-left .info {
                margin-top: 5px;
                font-size: 16px;
            }

        /* ✅ 右上角愛心 */
        .word-fav {
            position: absolute;
            top: 10px;
            right: 10px;
            width: 26px;
            height: auto;
            cursor: pointer;
            transition: transform 0.3s ease-in-out; /* ✅ 加這行 */
        }

            .word-fav:hover {
                transform: scale(1.1); /* ✅ 滑鼠懸停時放大 */
            }

        @keyframes fly-heart {
            0% {
                opacity: 1;
                transform: scale(1) translateY(0);
            }

            100% {
                opacity: 0;
                transform: scale(1.5) translateY(-80px);
            }
        }

        .fly-heart {
            position: fixed; /* ✅ 改這裡！用 fixed 才是以整個視窗為基準 */
            width: 26px;
            height: 26px;
            pointer-events: none;
            animation: fly-heart 0.8s ease-out forwards;
            z-index: 10010; /* ✅ 超過 .scroll-overlay（10003） */
        }


        /* ✅ 右下角圖示列 */
        .word-icons {
            position: absolute;
            right: 10px;
            bottom: 10px;
            display: flex;
            gap: 10px;
        }

            .word-icons img {
                width: 26px;
                height: auto;
                cursor: pointer;
                transition: 0.2s;
            }

                .word-icons img:hover {
                    transform: scale(1.1);
                }
    </style>
    <script>
        function showAltarOptions(altarId) {
            console.log("🎯 點到祭壇 ID:", altarId);

            // 存進 hidden 欄位
            document.getElementById("hiddenAltarId").value = altarId;

            // 從頁面抓 userId（Session 已存在）
            const userId = parseInt(document.getElementById("hiddenUserId").value);

            fetch("AltarService.asmx/GetAltarStatus", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                credentials: 'include',
                body: JSON.stringify({ altarId: altarId })
            })
                .then(response => response.json())
                .then(result => {
                    const data = result.d;

                    if (data.error === "NOT_LOGGED_IN") {
                        alert("請先登入！");
                        return;
                    }

                    // 傳給你原本的 showAltarPanel（✅ 不改你原本的參數）
                    showAltarPanel(altarId, data.learningStatus, data.nextReviewTime);
                })
                .catch(error => {
                    console.error("❌ AJAX 發生錯誤：", error);
                });
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />
        <asp:HiddenField ID="hiddenUserId" runat="server" ClientIDMode="Static" />
        <div class="container-fluid">
            <!-- 🔹 狀態列 (從資料庫讀取) -->
            <div class="row">
                <div class="col-12" id="navbar">
                    <span class="resource">
                        <img src="images/energy.svg" alt="魔法能量" data-toggle="tooltip" title="魔法能量" style="width: 24px; height: 24px; vertical-align: middle;" />
                        <asp:Label ID="lblEnergy" runat="server"></asp:Label>
                    </span>
                    <span class="resource">
                       <img src="images/diamond.svg" alt="魔法鑽石" data-toggle="tooltip" title="魔法鑽石" style="width: 24px; height: 24px; vertical-align: middle;" />
                        <asp:Label ID="lblDiamonds" runat="server"></asp:Label>
                    </span>
                    <span class="resource">
                       <img id="volumeIcon" src="images/volume.svg" alt="背景音樂" data-toggle="tooltip" title="背景音樂音量控制" style="width: 24px; height: 24px; vertical-align: middle;" />
                        <input type="range" id="volumeSlider" min="0" max="1" step="0.01" value="0.5" title="調整音量" />
                    </span>
                    <!-- 音效音量控制 -->
                    <span class="resource" id="soundEffectControl">
                        <img id="soundEffectIcon" src="images/music-note-beamed.svg" alt="音效音量" data-toggle="tooltip" title="調整音效(按鈕聲/發音等)" style="width: 24px; height: 24px;" />
                        <input type="range" id="soundEffectSlider" min="0" max="1" step="0.01" value="1.0" title="調整音效音量" />
                    </span>
                </div>
            </div>
            <!-- 🔹 第一行 (森林選擇 & 祭壇儀表板) -->
            <div class="row">
                <!-- 🔹 左側 (col-md-1) 森林切換按鈕 -->
                <div class="col-md-1 forest-select-container">
                    <img id="forest-select" src="images/forestselect.svg" alt="切換森林" onclick="toggleForestPanel();" />
                </div>

                <!-- 🔹 右側 (col-md-11) 放置祭壇 & 告示牌 -->
                <div class="col-md-11 d-flex justify-content-center">
                    <div class="altar-container">
                        <!-- 告示牌 + INFO -->
                        <div class="billboard-container">
                            <img id="billboard" src="images/billboard.svg" alt="森林看板" />
                            <div class="forest-label">
                                <asp:Label ID="lblForestName" runat="server"></asp:Label>
                            </div>
                            <span class="info-button" onclick="showInfoModal()">i</span>
                        </div>

                        <!-- ✅ 🔽 新增：森林功能儀表板 (會在點選圖示後浮出) -->
                        <div id="forestOverlay" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.4); z-index: 10000;">
                            <asp:Panel ID="pnlMagicForest" runat="server" ClientIDMode="Static" CssClass="magic-forest-panel">
                                <div class="forest-panel-content">
                                    <!-- 叉叉關閉 -->
                                    <span class="forest-close" onclick="closeForestPanel()">&times;</span>
                                    <!-- 面板標題 -->
                                    <h3>森林功能面板</h3>
                                    <!-- 三個按鈕 -->
                                    <asp:Button ID="btnSwitchForest" runat="server" Text="切換森林" CssClass="btn btn-primary m-2"
                                        OnClientClick="stopBGM();" OnClick="btnSwitchForest_Click" />
                                    <asp:Button ID="btnBackHome" runat="server" Text="返回首頁" CssClass="btn btn-secondary m-2"
                                        OnClientClick="stopBGM();" OnClick="btnBackHome_Click" />
                                    <asp:Button ID="btnViewStats" runat="server" Text="查看統計" CssClass="btn btn-info m-2"
                                        OnClientClick="stopBGM();" OnClick="btnViewStats_Click" />
                                </div>
                            </asp:Panel>
                        </div>


                        <!-- !-- ✅ 🔽 新增：祭壇儀表板 (永遠顯示在UI，每個LEVEL裡面都包含100顆按鈕) -->
                        <asp:Panel ID="pnlMagicAltar" runat="server" Visible="true" CssClass="altar-grid">
                            <asp:Literal ID="litAltarGrid" runat="server"></asp:Literal>
                        </asp:Panel>

                        <!-- ✅ 🔽 新增：祭壇選擇儀表板（點選祭壇按鈕後顯示） -->
                        <asp:UpdatePanel ID="UpdatePanelAltar" runat="server">
                            <ContentTemplate>
                                <div id="altarOptionsOverlay" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.3); z-index: 10001;">
                                    <asp:Panel ID="pnlAltarOptions" runat="server" ClientIDMode="Static" CssClass="altar-options-panel" Style="display: none;">
                                        <div class="altar-options-content">
                                            <!-- 🔴 右上角叉叉關閉按鈕 -->
                                            <span class="altar-close" onclick="closeAltarOptions()">×</span>
                                            <!-- 上方：祭壇資訊 -->
                                            <div class="altar-header">
                                                <span id="altarTitle" class="altar-title-text">祭壇209</span>
                                                <span id="daysSinceReview" class="altar-days-text">5 天未複習</span>
                                            </div>
                                            <!-- 中段：進度南瓜與連接線 -->
                                            <div class="altar-progress" id="pumpkinProgress">
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                                <img src="images/connectline.svg" class="altar-line" />
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                                <img src="images/connectline.svg" class="altar-line" />
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                                <img src="images/connectline.svg" class="altar-line" />
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                                <img src="images/connectline.svg" class="altar-line" />
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                                <img src="images/connectline.svg" class="altar-line" />
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                                <img src="images/connectline.svg" class="altar-line" />
                                                <img src="images/pumpkinwithnocolor.svg" class="altar-pumpkin" />
                                            </div>
                                            <!-- 下方：單字圖標 & 攻略按鈕 -->
                                            <div style="position: relative; width: 100%; height: 60px;">
                                                <img src="images/vocabulary.svg" class="vocab-icon" style="position: absolute; left: 10px; bottom: 0;" onclick="showAncientScrollPanel()" />
                                                <button class="altar-button-action" style="position: absolute; left: 130px; bottom: 0; width: 180px;" onclick="alert('點了攻略按鈕')">攻略</button>
                                            </div>

                                        </div>
                                    </asp:Panel>
                                </div>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                        <asp:HiddenField ID="hiddenAltarId" runat="server" ClientIDMode="Static" />
                    </div>
                </div>
            </div>
        </div>

        <!-- ✅ 🔽 新增：卷軸儀表板（預設隱藏） -->
        <div id="pnlAncientScroll" class="scroll-overlay" style="display: none;">
            <div class="scroll-panel">
                <!-- 上方區塊 -->
                <div class="scroll-header">
                    <div class="scroll-title">祭壇 1</div>
                    <span class="scroll-close" onclick="closeScrollPanel()">&times;</span>
                </div>
                <!-- 單字清單 -->
                <div id="pnlScrollWords" class="scroll-words-container">
                    <!-- 單字項目會由 JavaScript 動態插入 -->
                </div>
            </div>
        </div>

    </form>
    <!-- ✅ 遊戲介紹提示框 -->
    <div id="infoModal" class="info-modal d-none">
        <div class="info-modal-content">
            <span class="info-modal-close" onclick="closeInfoModal()">&times;</span>
            <h4>🌟 遊戲玩法說明</h4>
            <p>
                歡迎來到「森林詞彙魔法祭壇」！<br />
                <br />
                🔸 每座祭壇代表一組單字關卡。<br />
                🔸 點擊祭壇可選擇「學習單字」或「開始測驗」。<br />
                🔸 完成學習與測驗後會獲得魔法能量與鑽石！<br />
                <br />
                點擊左側的森林圖示可以切換不同詞彙主題 🌲。
            </p>
        </div>
    </div>
    <!-- jQuery（Bootstrap 4 相依） -->
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<!-- Popper.js（Tooltip 需要） -->
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
<!-- Bootstrap 4 JS -->
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

    <script>
        $(function () {
            $('[data-toggle="tooltip"]').tooltip();
        });
    </script>

    <script>
        // 顯示森林儀表板
        function toggleForestPanel() {
            const overlay = document.getElementById("forestOverlay");
            const altarPanel = document.getElementById("pnlAltarOptions");

            // 顯示森林面板與遮罩
            if (overlay) {
                overlay.style.display = "block";
            }

            // 同時關掉祭壇面板
            if (altarPanel) {
                altarPanel.style.display = "none";
            }
        }

        function closeForestPanel() {
            const overlay = document.getElementById("forestOverlay");
            if (overlay) {
                overlay.style.display = "none";
            }
        }
    </script>

    <audio id="bgm" src="musics/ScentOfForest.mp3" autoplay loop></audio>
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const audio = document.getElementById("bgm");
            const volumeSlider = document.getElementById("volumeSlider");
            const volumeIcon = document.getElementById("volumeIcon");

            // 1️⃣ 從 sessionStorage 取出記錄的音量與播放狀態
            const savedVolume = sessionStorage.getItem("bgmVolume");
            const shouldPlay = sessionStorage.getItem("bgmShouldPlay");

            // 設定音量
            if (savedVolume !== null) {
                audio.volume = parseFloat(savedVolume);
                volumeSlider.value = savedVolume;
            } else {
                audio.volume = 0.5; // 預設音量
                volumeSlider.value = 0.5;
            }

            // 初始化圖示
            function updateVolumeIcon(volume) {
                volumeIcon.src = volume == 0 ? "images/volume0.svg" : "images/volume.svg";
            }
            updateVolumeIcon(audio.volume);

            // 音量滑桿變動時
            volumeSlider.addEventListener("input", function () {
                const newVolume = parseFloat(this.value);
                audio.volume = newVolume;
                sessionStorage.setItem("bgmVolume", newVolume); // ⚠ 儲存音量
                updateVolumeIcon(newVolume);
            });

            // 2️⃣ 如果之前是播放狀態，則恢復播放
            if (shouldPlay === "true") {
                audio.play().catch(() => { });
            }

            // 3️⃣ 監聽播放與暫停事件，紀錄狀態
            audio.addEventListener("play", () => {
                sessionStorage.setItem("bgmShouldPlay", "true");
            });
            audio.addEventListener("pause", () => {
                sessionStorage.setItem("bgmShouldPlay", "false");
            });
        });
        function showInfoModal() {
            document.getElementById("infoModal").classList.remove("d-none");
        }

        function closeInfoModal() {
            document.getElementById("infoModal").classList.add("d-none");
        }
    </script>

    <script>
        function stopBGM() {
            const audio = document.getElementById("bgm");
            if (audio) {
                audio.pause();
                sessionStorage.setItem("bgmShouldPlay", "false"); // ❗ 確保狀態儲存
                audio.src = "";  // 關鍵：清掉音源，讓瀏覽器以為沒有聲音了
                audio.load();    // 強迫重新載入，觸發「音訊已停止」
            }
        }
    </script>

    <!-- ✅ ✅ ✅ 已整合語音音量控制邏輯 -->
    <script>
        // 全局音效音量變數（供所有音效 & TTS 使用）
        let soundEffectVolume = 1.0;

        document.addEventListener("DOMContentLoaded", function () {
            const sfxSlider = document.getElementById("soundEffectSlider");
            const sfxIcon = document.getElementById("soundEffectIcon");

            // 還原音量
            const savedSfxVolume = sessionStorage.getItem("sfxVolume");
            if (savedSfxVolume !== null) {
                soundEffectVolume = parseFloat(savedSfxVolume);
                sfxSlider.value = soundEffectVolume;
            }

            function updateSfxIcon(volume) {
                sfxIcon.src = volume == 0
                    ? "images/music-note-beamed-novolume.svg"
                    : "images/music-note-beamed.svg";
            }

            updateSfxIcon(soundEffectVolume);

            sfxSlider.addEventListener("input", function () {
                soundEffectVolume = parseFloat(this.value);
                sessionStorage.setItem("sfxVolume", soundEffectVolume);
                updateSfxIcon(soundEffectVolume);
            });
        });

        // ✅ 公用播放音效（包含 mp3 音效）
        function playSoundEffect(src) {
            const audio = new Audio(src);
            audio.volume = soundEffectVolume;
            audio.play().catch(err => {
                console.error("播放音效失敗：", err);
            });
        }
    </script>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            // 祭壇遮罩關閉
            const altarOverlay = document.getElementById("altarOptionsOverlay");
            altarOverlay?.addEventListener("click", function (e) {
                if (e.target === altarOverlay) {
                    closeAltarOptions();
                }
            });

            // 卷軸遮罩關閉
            const scrollOverlay = document.getElementById("pnlAncientScroll");
            scrollOverlay?.addEventListener("click", function (e) {
                if (e.target === scrollOverlay) {
                    closeScrollPanel();
                }
            });

            // ✅ 森林遮罩關閉（正確）
            const forestOverlay = document.getElementById("forestOverlay");
            forestOverlay?.addEventListener("click", function (e) {
                if (e.target === forestOverlay) {
                    closeForestPanel();
                }
            });

            // 遊戲說明關閉
            const infoModal = document.getElementById("infoModal");
            infoModal?.addEventListener("click", function (e) {
                if (e.target === infoModal) {
                    infoModal.classList.add("d-none");
                }
            });
        });
    </script>

    <script>
        function closeAltarOptions() {
            document.getElementById("altarOptionsOverlay").style.display = "none";
        }

        document.addEventListener("DOMContentLoaded", function () {
            // ✅ 點擊遮罩關閉祭壇儀表板
            const overlay = document.getElementById("altarOptionsOverlay");
            const panel = document.getElementById("pnlAltarOptions");

            overlay.addEventListener("click", function (e) {
                if (e.target === overlay) {
                    closeAltarOptions();
                }
            });

            // ✅ 防止攻略按鈕觸發表單提交（避免 BGM 中斷）
            const buttons = document.querySelectorAll(".altar-button-action");
            buttons.forEach(btn => {
                btn.addEventListener("click", function (event) {
                    event.preventDefault();
                });
            });
        });

        // ✅ 顯示祭壇儀表板（更新為顯示整個 overlay）
        function showAltarPanel(altarId, learningStatus, nextReviewTimeStr) {
            document.getElementById("altarOptionsOverlay").style.display = "block";
            document.getElementById("pnlAltarOptions").style.display = "block"; // 🟢 加這一行，顯示儀表板
            document.getElementById("altarTitle").textContent = "祭壇 " + altarId;

            const daysLabel = document.getElementById("daysSinceReview");
            if (!nextReviewTimeStr) {
                daysLabel.textContent = "尚未學習";
            } else {
                const nextTime = new Date(nextReviewTimeStr);
                const now = new Date();
                const diffMs = now - nextTime;

                if (diffMs < 0) {
                    const totalSeconds = Math.floor(-diffMs / 1000);
                    const hours = Math.floor(totalSeconds / 3600);
                    const minutes = Math.floor((totalSeconds % 3600) / 60);
                    daysLabel.textContent = `澆水：${hours}時${minutes}分`;
                } else {
                    const days = Math.floor(diffMs / (1000 * 60 * 60 * 24));
                    daysLabel.textContent = `${days} 天未複習`;
                }
            }

            const actionButton = document.querySelector(".altar-button-action");
            if (learningStatus === 0) {
                actionButton.textContent = "攻略";
            } else if (learningStatus >= 1 && learningStatus < 7) {
                actionButton.textContent = "充能";
            } else if (learningStatus === 999 || learningStatus >= 7) {
                actionButton.textContent = "複習";
            }
        }
    </script>


    <script>
        // ✅ 顯示卷軸面板
        function showAncientScrollPanel() {
            const altarId = parseInt(document.getElementById("hiddenAltarId").value);
            const panel = document.getElementById("pnlAncientScroll");
            const container = document.getElementById("pnlScrollWords");

            // ✅ 1️. 更新卷軸標題文字
            document.querySelector(".scroll-title").textContent = `祭壇 ${altarId}`;

            // ✅ 2️. 顯示卷軸面板
            panel.style.display = "flex";
            container.innerHTML = "";

            fetch("ScrollService.asmx/GetScrollWords", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                credentials: "include",
                body: JSON.stringify({ altarId: altarId })
            })
                .then(res => res.json())
                .then(result => {
                    const words = result.d;
                    if (words.length === 0) {
                        container.innerHTML = "<p>⚠ 尚無單字資料。</p>";
                        return;
                    }

                    words.forEach(w => {
                        const card = document.createElement("div");
                        card.className = "scroll-word-card";

                        const favImg = document.createElement("img");
                        favImg.className = "word-fav";
                        favImg.src = w.is_favorite ? "images/heartwithredcolor.svg" : "images/heartwithnocolor.svg";
                        favImg.onclick = () => toggleFavorite(w.scroll_id, favImg);
                        card.appendChild(favImg);

                        const left = document.createElement("div");
                        left.className = "word-left";
                        left.innerHTML = `
                <span class="word">${w.word}</span>
                <span class="info"><span class="badge badge-secondary">${w.part_of_speech}</span> ${w.meaning}</span>
            `;
                        card.appendChild(left);

                        const icons = document.createElement("div");
                        icons.className = "word-icons";

                        const infoIcon = document.createElement("img");
                        infoIcon.src = "images/list-bullet.svg?v=" + new Date().getTime();
                        infoIcon.title = "查看詳情";
                        icons.appendChild(infoIcon);

                        const volIcon = document.createElement("img");
                        volIcon.src = "images/volumewithnocolor.svg?v=" + new Date().getTime();
                        volIcon.title = "播放單字";

                        volIcon.onclick = () => {
                            volIcon.src = "images/volumewithlightcolor.svg";
                            const utter = new SpeechSynthesisUtterance(w.word);
                            utter.lang = "en-US";
                            utter.volume = soundEffectVolume; // ✅ 整合音效音量
                            speechSynthesis.speak(utter);
                            utter.onend = () => {
                                volIcon.src = "images/volumewithnocolor.svg";
                            };
                        };
                        icons.appendChild(volIcon);

                        card.appendChild(icons);
                        container.appendChild(card);
                    });
                })
                .catch(err => {
                    console.error("❌ 巻軸 AJAX 錯誤：", err);
                    container.innerHTML = "<p>⚠ 載入失敗。</p>";
                });
        }

        // ✅ 關閉卷軸面板
        function closeScrollPanel() {
            document.getElementById("pnlAncientScroll").style.display = "none";
        }

        // ✅ 愛心切換（前端變更）
        function toggleFavorite(scrollId, icon) {
            const isFav = icon.src.includes("red"); // ✅ 先定義

            if (!isFav) {
                showFlyingHeart(icon); // ✅ 點灰心 → 飛紅心
            }

            icon.src = isFav ? "images/heartwithnocolor.svg" : "images/heartwithredcolor.svg";

            fetch("ScrollService.asmx/UpdateFavorite", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    scrollId: scrollId,
                    isFavorite: !isFav
                })
            })
                .then(response => response.json())
                .then(data => {
                    console.log("後端回傳：", data.d);
                })
                .catch(err => {
                    console.error("更新收藏失敗：", err);
                });
        }

        function showFlyingHeart(targetIcon) {
            const heart = document.createElement("img");
            heart.src = "images/heartwithredcolor.svg";
            heart.className = "fly-heart";

            // 抓 icon 在畫面上的位置
            const rect = targetIcon.getBoundingClientRect();
            heart.style.left = `${rect.left + rect.width / 2 - 12}px`; // 調整中心點對齊
            heart.style.top = `${rect.top + rect.height / 2 - 12}px`;

            document.body.appendChild(heart);

            // 🚀 強制觸發一次 reflow，讓動畫確實執行
            void heart.offsetWidth;

            heart.style.animation = "fly-heart 0.8s ease-out forwards";

            // 動畫結束後自動移除
            setTimeout(() => {
                heart.remove();
            }, 800);
        }
    </script>
</body>
</html>
