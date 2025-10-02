<%@ Page Language="C#" AutoEventWireup="true" CodeFile="MatchingGame.aspx.cs" Inherits="MatchingGame" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <title>Matching Game</title>
    <style>
        /* ==================== 全局設定 ==================== */
        html, body {
            margin: 0;
            padding: 0;
            height: 100%;
        }

        /* 背景圖鋪滿 */
        body {
            background: url("images/SurfUpBackground.jpg") no-repeat center center fixed;
            background-size: cover;
        }

        /* ==================== 導覽列 ==================== */
        #navbar {
            background: rgba(255, 255, 255, 0);
            padding: 8px 20px;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            z-index: 100;
        }

        /* 鑽石數量樣式 */
        .resource {
            font-weight: bold;
            font-family: "Segoe UI", "Microsoft JhengHei", Arial, sans-serif; /* ✅ 強制字型 */
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

        /* ==================== PANEL：外層容器 ==================== */
        .panel-container {
            display: flex;
            justify-content: center;
            align-items: center;
        }

        /* ==================== PANEL：挑戰卡片 ==================== */
        .panel-card {
            width: 100%;
            max-width: 450px;
            background: linear-gradient(145deg, #f7f7f7, #eaeaea);
            border: 5px solid #4a90e2;
            border-radius: 20px;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
            padding: 25px;
            text-align: center;
            font-family: "Segoe UI", sans-serif;
            position: relative; /* ✅ 讓內部絕對定位生效 */
        }

        /* 左上角返回 ICON */
        .icon-left {
            position: absolute;
            top: 10px;
            left: 15px;
            width: 40px;
            height: 40px;
            cursor: pointer;
            transition: transform 0.2s ease, filter 0.2s ease;
        }

            .icon-left:hover {
                transform: scale(1.2);
                filter: brightness(1.2);
            }

        /* 右上角資訊 ICON */
        .icon-right {
            position: absolute;
            top: 10px;
            right: 15px;
            width: 38px;
            height: 38px;
            cursor: pointer;
            transition: transform 0.2s ease, filter 0.2s ease;
        }

            .icon-right:hover {
                transform: scale(1.2);
                filter: brightness(1.2);
            }

        /* 自訂遊戲資訊卡外觀 */
        .custom-warning-modal {
            border: 4px solid #f1c40f; /* 黃金邊框 */
            border-radius: 16px;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.3);
            background: linear-gradient(135deg, #fff8e1, #fff);
            font-family: "Microsoft JhengHei", sans-serif;
        }

        /* Footer 按鈕 */
        .custom-warning-btn {
            background: #f1c40f;
            color: #000;
            font-weight: bold;
            border-radius: 8px;
            padding: 12px 24px; /* ⬆️ 加大 padding */
            font-size: 1.2rem; /* ⬆️ 放大字體 */
            display: block; /* ✅ 讓它獨占一行 */
            margin: 0 auto; /* ✅ 水平置中 */
            transition: 0.3s;
        }

            .custom-warning-btn:hover {
                background: #f39c12;
                color: #fff;
                transform: scale(1.05); /* ✅ hover 時稍微放大 */
            }

        /* 標題 */
        .challenge-title {
            font-size: 1.8rem;
            margin-bottom: 10px;
            color: #3b3b3b;
        }

        /* 描述文字 */
        .challenge-description {
            font-size: 1rem;
            margin-bottom: 25px;
            color: #555;
        }

        /* 表單群組 */
        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }

            /* 表單標籤 */
            .form-group label {
                display: block;
                font-weight: bold;
                margin-bottom: 5px;
                color: #444;
            }

            /* 下拉選單 */
            .form-group select {
                width: 100%;
                padding: 10px;
                border-radius: 8px;
                border: 1px solid #ccc;
                font-size: 1rem;
            }

        /* 鑽石與賠率資訊 */
        .diamond-info {
            margin: 25px 0;
            color: #a94442;
            font-weight: bold;
        }

        /* 開始挑戰按鈕 */
        .start-btn {
            background-color: #4a90e2; /* 與 Panel 邊框一致的藍色 */
            color: #fff;
            font-size: 1.2rem;
            font-weight: bold;
            padding: 12px 30px;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s ease; /* 平滑動畫 */
        }

            /* Hover 效果（提亮 + 放大） */
            .start-btn:hover {
                background-color: #66aef5; /* 比原本更亮的藍色 */
                transform: scale(1.05); /* 放大 1.05 倍 */
            }

            /* 按下 (Active) 效果（微縮 + 深色） */
            .start-btn:active {
                background-color: #3a78c2; /* 稍微深藍，模擬壓下去 */
                transform: scale(0.98); /* 微縮，像真實按鈕 */
                box-shadow: 0 4px 10px rgba(0, 0, 0, 0.25);
            }

        /* 自訂下注輸入框 */
        .custom-bet {
            width: 100%;
            padding: 8px;
            border-radius: 8px;
            border: 1px solid #ccc;
            margin-top: 8px;
            font-size: 1rem;
        }
        /* ==================== 錯誤提示 MODAL ==================== */
        .error-modal {
            display: none; /* 預設隱藏 */
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6); /* 半透明黑色背景 */
            justify-content: center;
            align-items: center;
            z-index: 2000;
        }

        /* 內層框 */
        .error-modal-content {
            background: #fff;
            padding: 20px 30px;
            border-radius: 12px;
            text-align: center;
            max-width: 350px;
            box-shadow: 0 6px 15px rgba(0,0,0,0.3);
            border: 3px solid #e74c3c; /* 紅色邊框 */
        }

            /* 標題 */
            .error-modal-content h3 {
                color: #e74c3c;
                margin-bottom: 15px;
                font-size: 1.3rem;
            }

        /* 關閉按鈕（放大版） */
        .error-close-btn {
            margin-top: 20px;
            background: #e74c3c;
            color: #fff;
            border: none;
            padding: 12px 24px; /* ✅ 加大 padding */
            font-size: 1.1rem; /* ✅ 放大字體 */
            border-radius: 10px;
            cursor: pointer;
            transition: background 0.3s, transform 0.2s;
        }

            .error-close-btn:hover {
                background: #c0392b;
                transform: scale(1.05); /* ✅ hover 時稍微放大 */
            }

        /* ==================== PANEL：挑戰進行中 ==================== */
        .panel-game {
            width: 100%;
            max-width: 800px;
            background: linear-gradient(145deg, #ffffff, #f0f0f0);
            border: 5px solid #4a90e2;
            border-radius: 20px;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
            padding: 20px;
            text-align: center;
            font-family: "Segoe UI", sans-serif;
            display: none; /* ✅ 預設隱藏 */
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- 導覽列 -->
        <div id="navbar">
            <span class="resource">
                <img src="images/diamond.svg" alt="魔法鑽石"
                    style="width: 24px; height: 24px; vertical-align: middle;" />
                <asp:Label ID="lblDiamonds" runat="server" Text="0"></asp:Label>
            </span>
        </div>

        <!-- ==================== PANEL：挑戰模式 ==================== -->
        <asp:Panel ID="pnlChallenge" runat="server" CssClass="panel-container">
            <div class="panel-card">
                <!-- 左上角返回首頁 ICON -->
                <img src="images/back-arrow-blue.svg" class="icon-left"
                    alt="返回首頁" onclick="window.location.href='HomePage.aspx'" />
                <!-- 右上角資訊 ICON -->
                <img src="images/info-icon-blue.svg" class="icon-right"
                    alt="遊戲資訊" data-bs-toggle="modal" data-bs-target="#infoModal" />

                <h2 class="challenge-title">🎯 連連看挑戰</h2>
                <p class="challenge-description">
                    請選擇下注鑽石數量、難度與時間後開始挑戰！成功將獲得額外鑽石獎勵！
                </p>

                <!-- 下注金額選擇 -->
                <div class="form-group">
                    <label for="bet">下注鑽石數量：</label>
                    <select id="bet">
                        <option value="1">1 顆</option>
                        <option value="10">10 顆</option>
                        <option value="50">50 顆</option>
                        <option value="100">100 顆</option>
                        <option value="custom">自訂</option>
                    </select>
                    <!-- ✅ placeholder 也改成 ≤100 -->
                    <input type="number" id="customBet" class="custom-bet" placeholder="輸入自訂金額 (≤100)" style="display: none;" />
                </div>

                <!-- 難度選擇 -->
                <div class="form-group">
                    <label for="difficulty">選擇難度：</label>
                    <select id="difficulty">
                        <option value="1.1">初級 (x1.1)</option>
                        <option value="1.2">中級 (x1.2)</option>
                        <option value="1.3">中高級 (x1.3)</option>
                    </select>
                </div>

                <!-- 時間選擇 -->
                <div class="form-group">
                    <label for="duration">挑戰時間：</label>
                    <select id="duration">
                        <option value="1.1">60 秒 (x1.1)</option>
                        <option value="1.2">40 秒 (x1.2)</option>
                        <option value="1.3">30 秒 (x1.3)</option>
                        <option value="1.4">20 秒 (x1.4)</option>
                        <option value="1.5">15 秒 (x1.5)</option>
                    </select>
                </div>

                <!-- 動態資訊 -->
                <div class="diamond-info">
                    <p id="rateInfo">賠率試算：x1.21</p>
                    <p id="rewardInfo">勝利後可得：0 顆鑽石(答對率高於90%才算勝利喔)</p>
                </div>

                <!-- 開始挑戰按鈕 -->
                <button type="button" class="start-btn" onclick="startChallenge()">開始挑戰</button>
            </div>
        </asp:Panel>

        <!-- ==================== PANEL：挑戰進行中 ==================== -->
        <asp:Panel ID="pnlGame" runat="server" CssClass="panel-container">
            <div class="panel-game">
                <h2 class="challenge-title">🔥 挑戰開始！</h2>
                <p class="challenge-description">這裡將顯示遊戲內容...</p>
            </div>
        </asp:Panel>

    </form>

    <!-- 🔹 錯誤提示 MODAL -->
    <div id="errorModal" class="error-modal">
        <div class="error-modal-content">
            <h3>⚠️ 輸入錯誤</h3>
            <p id="errorMessage">請輸入有效的下注金額！</p>
            <button class="error-close-btn" onclick="closeErrorModal()">確定</button>
        </div>
    </div>

    <!-- ==================== Info Modal ==================== -->
    <div class="modal fade" id="infoModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content custom-warning-modal">
                <!-- Modal Header -->
                <div class="modal-header">
                    <h5 class="modal-title">ℹ️ 遊戲玩法說明</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <!-- Modal Body -->
                <div class="modal-body text-start">
                    <p><strong>🎯 遊戲流程：</strong></p>
                    <ul>
                        <li>選擇下注鑽石數量、挑戰難度與時間限制。</li>
                        <li>按下「開始挑戰」即可進入連連看遊戲。</li>
                        <li>成功完成挑戰後，將依照答對率獲得額外鑽石獎勵。</li>
                    </ul>

                    <p><strong>💎 獎勵規則：</strong></p>
                    <ul>
                        <li>難度越大、時間越短，獎勵倍率也會更高。</li>
                        <li>僅答對率達標才會獲得獎勵，否則失去下注的鑽石。</li>
                    </ul>

                    <p><strong>⚠️ 注意事項：</strong></p>
                    <ul>
                        <li>挑戰過程中若中斷，將視同失敗，不退回鑽石。</li>
                        <li>請保持專注，並確保網路與裝置穩定。</li>
                    </ul>
                </div>

                <!-- Modal Footer -->
                <div class="modal-footer">
                    <button type="button" class="custom-warning-btn" data-bs-dismiss="modal">
                        我明白了，開始挑戰！ 🚀
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        //==========================================
        //========== 第零章：選擇挑戰內容 ==========
        //==========================================

        /* ==================== 更新賠率與獎勵 ==================== */
        function updateRate() {
            let bet = document.getElementById("bet").value;
            let customBetInput = document.getElementById("customBet");
            let betAmount = parseInt(bet);

            if (bet === "custom") {
                customBetInput.style.display = "block";
                betAmount = parseInt(customBetInput.value) || 0;
            } else {
                customBetInput.style.display = "none";
            }

            // ✅ 限制最大只能 100
            if (betAmount > 100) betAmount = 100;

            let difficulty = parseFloat(document.getElementById("difficulty").value);
            let duration = parseFloat(document.getElementById("duration").value);

            let rate = 1.0 * difficulty * duration;
            let reward = Math.floor(betAmount * rate);

            document.getElementById("rateInfo").innerText = "賠率試算：x" + rate.toFixed(2);
            document.getElementById("rewardInfo").innerText = "勝利後可得：" + reward + " 顆鑽石";
        }

        /* ==================== 綁定事件 ==================== */
        document.getElementById("bet").addEventListener("change", updateRate);
        document.getElementById("customBet").addEventListener("input", updateRate);
        document.getElementById("difficulty").addEventListener("change", updateRate);
        document.getElementById("duration").addEventListener("change", updateRate);

        /* ==================== 顯示錯誤提示 ==================== */
        function showErrorModal(message) {
            document.getElementById("errorMessage").innerText = message;
            document.getElementById("errorModal").style.display = "flex";
        }

        /* ==================== 關閉錯誤提示 ==================== */
        function closeErrorModal() {
            document.getElementById("errorModal").style.display = "none";
        }

        /* ✅ 點擊遮罩也能關閉 Modal */
        document.getElementById("errorModal").addEventListener("click", function (e) {
            if (e.target === this) { // 只允許點擊背景關閉
                closeErrorModal();
            }
        });

        /* ==================== 按下開始挑戰 ==================== */
        function startChallenge() {
            let bet = document.getElementById("bet").value;
            let betAmount = (bet === "custom")
                ? parseInt(document.getElementById("customBet").value) || 0
                : parseInt(bet);

            // ❌ 檢查不合法輸入
            if (isNaN(betAmount) || betAmount <= 0) {
                showErrorModal("下注金額必須大於 0！");
                return;
            }
            if (betAmount > 100) {
                showErrorModal("下注金額不能超過 100 顆鑽石！");
                return;
            }

            // ✅ 合法才繼續
            // alert("開始挑戰！後端將檢查鑽石是否足夠並進行扣款。");

            // 隱藏挑戰設定的 Panel
            document.getElementById("<%= pnlChallenge.ClientID %>").style.display = "none";

            // 顯示挑戰進行中的 Panel
            document.querySelector(".panel-game").style.display = "block";

            // 🚀 呼叫第一章邏輯 → 載入挑戰單字
            loadChallengeWords();
        }
    </script>

    <script>
        //==========================================
        //========== 第一章：挑戰開始邏輯 ==========
        //==========================================

        /* ==================== 假資料（模擬從資料庫撈出） ==================== */
        const mockWords = [
            { word: "black", part: "n.", meaning: "黑色" },
            { word: "bottom", part: "n.", meaning: "底部" },
            { word: "haircut", part: "n.", meaning: "理髮" },
            { word: "newspaper", part: "n.", meaning: "報紙" },
            { word: "November", part: "n.", meaning: "十一月" },
            { word: "pencil", part: "n.", meaning: "鉛筆" },
            { word: "ride", part: "v.", meaning: "騎" },
            { word: "spread", part: "n.", meaning: "範圍" },
            { word: "stomach", part: "n.", meaning: "胃" },
            { word: "team", part: "n.", meaning: "隊伍" }
        ];

        /* ==================== 載入挑戰單字 ==================== */
        function loadChallengeWords() {
            let container = document.querySelector(".panel-game");

            let html = "<h2 class='challenge-title'>🔥 挑戰開始！</h2>";
            html += "<p class='challenge-description'>以下是本次挑戰的 10 個單字：</p>";
            html += "<ul style='text-align:left; font-size:1.1rem; line-height:1.8;'>";

            mockWords.forEach(w => {
                html += `<li><strong>${w.word}</strong> (${w.part}) — ${w.meaning}</li>`;
            });

            html += "</ul>";
            container.innerHTML = html;
        }
    </script>
</body>
</html>
