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
            margin-bottom: 0px;
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
            margin-top: -30px;
            width: 100%;
            max-width: 1000px;
            background: linear-gradient(145deg, #ffffff, #f0f0f0);
            border: 5px solid #4a90e2;
            border-radius: 20px;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
            padding: 20px;
            text-align: center;
            font-family: "Segoe UI", sans-serif;
            display: none; /* ✅ 預設隱藏 */
        }

        /* 頂部工具列 */
        .game-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 15px;
        }

        /* 倒數 ICON 外層 */
        .timer {
            position: relative; /* 讓內部定位生效 */
            width: 40px; /* 和圖片一樣大 */
            height: 40px;
        }

            /* 圓圈 */
            .timer img {
                width: 100%;
                height: 100%;
                display: block;
            }

            /* 數字覆蓋在圓圈正中間 */
            .timer span {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                font-weight: bold;
                font-size: 17px;
                color: #333; /* 可換白色 #fff 看對比 */
                pointer-events: none;
            }

        /* 進度條 */
        .progress-bar-container {
            flex-grow: 1;
            margin: 0 15px;
            height: 20px;
            background: #eee;
            border-radius: 10px;
            overflow: hidden;
        }

        .progress-bar-fill {
            height: 100%;
            width: 100%;
            background: linear-gradient(90deg, #4a90e2, #66aef5);
            transition: width 1s linear;
        }

        /* 右側關閉 */
        .close-btn {
            width: 28px;
            height: 28px;
            cursor: pointer;
            transition: transform 0.2s ease;
        }

            .close-btn:hover {
                transform: scale(1.2);
            }

        /* 🚩 提示是否中斷遊戲Modal 共用樣式 */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.45);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 9999;
        }

        .modal-panel {
            background: #fff;
            border-radius: 18px;
            padding: 30px 26px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.2);
            text-align: center;
            min-width: 320px;
            max-width: 90vw;
            animation: fadeIn 0.2s;
        }

        .modal-title {
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 10px;
            color: #222;
        }

        .modal-subtitle {
            font-size: 15px;
            color: #666;
            margin-bottom: 22px;
        }

        .modal-actions {
            display: flex;
            flex-direction: column;
            gap: 12px;
            align-items: center;
        }

        .exit-yes, .exit-no {
            width: 220px;
            padding: 12px 0;
            border: none;
            border-radius: 14px;
            font-size: 17px;
            font-weight: bold;
            cursor: pointer;
        }

        .exit-yes {
            background: #fa2e50;
            color: #fff;
        }

            .exit-yes:hover {
                background: #d0203b;
            }

        .exit-no {
            background: #f5f5f5;
            color: #777;
        }

            .exit-no:hover {
                background: #e1e1e1;
            }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: scale(0.95);
            }

            to {
                opacity: 1;
                transform: scale(1);
            }
        }
        /* 單字配對容器：維持 grid 兩欄 */
        .matching-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px 20px;
        }

        /* 左側英文 */
        .word-box {
            background: #fff;
            border: 2px solid #4a90e2;
            border-radius: 8px;
            padding: 2px;
            min-height: 42px;
            text-align: center;
            font-weight: bold;
            font-size: 18px;
            cursor: grab;
            display: flex;
            align-items: center;
            justify-content: center;
        }

            .word-box:active {
                cursor: grabbing;
            }

        /* 已使用的左側英文（被拖曳走後） */
        .word-used {
            border: 2px solid #ccc !important;
            color: #aaa !important;
            background: #f5f5f5 !important;
            cursor: not-allowed !important;
        }

        /* 右側中文容器 */
        .meaning-box {
            display: flex;
            gap: 10px; /* 答案框和中文的間距 */
            align-items: center;
        }

        /* 答案框（待填入區） */
        .answer-slot {
            flex: 1;
            min-height: 42px;
            border: 2px dashed #2ecc71; /* 綠色虛線框 */
            border-radius: 6px;
            background: #f9fff9; /* 淡綠背景 */
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            font-weight: bold;
            color: #333;
        }

        /* 中文意思 */
        .meaning-text {
            flex: 1;
            min-height: 42px;
            background: #2ecc71;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 18px;
            font-weight: bold;
        }

        /* 提交答案按鈕（跟開始挑戰一樣樣式） */
        .submit-btn {
            background-color: #4a90e2;
            color: #fff;
            font-size: 1.2rem;
            font-weight: bold;
            padding: 12px 30px;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 15px; /* ✅ 與遊戲面板保持間距 */
            display: none; /* ✅ 預設隱藏 */
        }

            .submit-btn:hover {
                background-color: #66aef5;
                transform: scale(1.05);
            }

            .submit-btn:active {
                background-color: #3a78c2;
                transform: scale(0.98);
                box-shadow: 0 4px 10px rgba(0, 0, 0, 0.25);
            }

        /* 答對樣式 */
        .answer-correct {
            border: 2px solid #1e8449 !important; /* 深綠實線 */
            background: #eafaf1 !important; /* 淡綠背景 */
            color: #1e8449 !important;
        }

        /* 答錯樣式 */
        .answer-wrong {
            border: 2px solid #e74c3c !important; /* 紅色實線 */
            background: #fdecea !important; /* 淡紅背景 */
            color: #e74c3c !important;
        }

        /* 未作答樣式 */
        .answer-unanswered {
            border: 2px solid #7f8c8d !important;
            background: #ecf0f1 !important;
            color: #7f8c8d !important;
        }

        /* ✅ 外層容器：置中整塊「查看結果 + 統計」 */
        .result-wrapper {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: 20px;
            margin-left: 335px;
            gap: 15px;
        }

        /* ✅ 查看結果按鈕 */
        .result-btn {
            background: linear-gradient(135deg, #FFD700, #FFA500);
            border: none;
            color: #fff;
            font-weight: bold;
            font-size: 18px;
            border-radius: 10px;
            padding: 12px 24px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 0 8px rgba(255, 215, 0, 0.6);
        }

            .result-btn:hover {
                transform: scale(1.05);
                box-shadow: 0 0 12px rgba(255, 215, 0, 0.9);
            }

        /* ✅ 統計資訊區塊（加外框 + 底色） */
        .result-summary {
            font-size: 16px;
            font-weight: bold;
            display: flex;
            gap: 20px;
            padding: 8px 15px;
            border: 2px solid #ccc; /* 外框 */
            border-radius: 10px; /* 圓角 */
            background: #fafafa; /* 淡灰底色 */
            box-shadow: 0 2px 6px rgba(0,0,0,0.1); /* 小陰影 */
        }

            /* ✅ 正確 = 綠色 */
            .result-summary .correct {
                color: #27ae60;
            }

            /* ✅ 錯誤 = 紅色 */
            .result-summary .wrong {
                color: #e74c3c;
            }

            /* ✅ 未作答 = 灰色 */
            .result-summary .unanswered {
                color: #7f8c8d;
            }

        /* ==================== 查看結果 PANEL ==================== */
        .result-panel {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background: linear-gradient(145deg, #ffffff, #f4f6fa);
            border: 5px solid #4a90e2;
            border-radius: 20px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.25);
            padding: 40px 30px;
            width: 100%;
            max-width: 800px;
            text-align: center;
            font-family: "Segoe UI", "Microsoft JhengHei", sans-serif;
            margin-top: 140px;
        }

        /* 標題樣式 */
        .result-title {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 20px;
            color: #333;
        }

            /* 勝利與失敗顏色 */
            .result-title.success {
                color: #27ae60;
            }

            .result-title.fail {
                color: #e74c3c;
            }

        /* 中間訊息 */
        .result-message {
            font-size: 1.2rem;
            margin-bottom: 20px;
            color: #444;
        }

        /* 統計資訊 */
        .result-stats {
            font-size: 1.2rem;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 30px;
        }

        /* 結束挑戰按鈕 */
        .end-btn {
            background: linear-gradient(135deg, #4a90e2, #66aef5);
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 1.2rem;
            font-weight: bold;
            padding: 12px 30px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

            .end-btn:hover {
                background: #3a78c2;
                transform: scale(1.05);
            }

        /* 結束挑戰淡出動畫 */
        #pnlResult {
            opacity: 1;
            transform: scale(1);
            transition: opacity 0.3s ease, transform 0.3s ease;
        }

            #pnlResult.hide {
                opacity: 0;
                transform: scale(0.95);
                pointer-events: none;
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
        <asp:Panel ID="pnlChallenge" runat="server" CssClass="panel-container" Style="display: flex;" EnableViewState="false">
            <div class="panel-card">
                <!-- 左上角返回首頁 ICON -->
                <img src="images/back-arrow-blue.svg" class="icon-left"
                    alt="返回首頁" onclick="window.location.href='HomePage.aspx'" />
                <!-- 右上角資訊 ICON -->
                <img src="images/info-icon-blue.svg" class="icon-right"
                    alt="遊戲資訊" data-bs-toggle="modal" data-bs-target="#infoModal" />

                <h2 class="challenge-title">🎯 連連看挑戰</h2>
                <p class="challenge-description">
                    請選擇下注鑽石數量、難度與時間後開始挑戰！
                </p>
                <p class="challenge-description" style="margin-bottom: 15px;" >
                    成功將獲得額外鑽石獎勵！
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
                        <option value="1.1" data-seconds="60">60 秒 (x1.1)</option>
                        <option value="1.2" data-seconds="40">40 秒 (x1.2)</option>
                        <option value="1.3" data-seconds="30">30 秒 (x1.3)</option>
                        <option value="1.4" data-seconds="20">20 秒 (x1.4)</option>
                        <option value="1.5" data-seconds="15">15 秒 (x1.5)</option>
                    </select>
                </div>

                <!-- 動態資訊 -->
                <div class="diamond-info">
                    <p id="rateInfo">賠率試算：x1.21</p>
                    <p id="rewardInfo">勝利後可得：0 顆鑽石(答對率高於80%才算勝利喔)</p>
                </div>

                <!-- 開始挑戰按鈕 -->
                <button type="button" class="start-btn" onclick="startChallenge()">開始挑戰</button>
            </div>
        </asp:Panel>

        <!-- ==================== PANEL：挑戰進行中 ==================== -->
        <asp:Panel ID="pnlGame" runat="server" CssClass="panel-container">
            <div class="panel-game">
                <!-- 頂部工具列 -->
                <div class="game-header">
                    <div class="timer">
                        <img src="images/circle-svgrepo.svg" alt="timer" />
                        <span id="timeLeft">60</span>
                    </div>
                    <div class="progress-bar-container">
                        <div id="progressBar" class="progress-bar-fill"></div>
                    </div>
                    <!-- 🚩 改為呼叫 showExitModal() -->
                    <img src="images/close-blue.svg" class="close-btn" alt="close" onclick="showExitModal()" />
                </div>

                <!-- 單字配對內容 -->
                <div class="matching-container"></div>

                <!-- ✅ 提交答案按鈕 -->
                <button id="btnSubmit" type="button" class="submit-btn" onclick="submitAnswers()">提交答案</button>
                <!-- ✅ 外層容器：包住按鈕與統計 -->
                <div id="resultWrapper" class="result-wrapper" style="display: none;">
                    <!-- 查看結果按鈕 -->
                    <button id="btnViewResult" type="button" class="result-btn" onclick="goToResult()" style="display: none;">
                        查看結果
                    </button>

                    <!-- 統計資訊 -->
                    <div id="resultSummary" class="result-summary" style="display: none;">
                        <span id="correctCount" class="correct">正確：0 題</span>
                        <span id="wrongCount" class="wrong">錯誤：0 題</span>
                        <span id="unansweredCount" class="unanswered">未作答：0 題</span>
                    </div>
                </div>

            </div>
        </asp:Panel>

        <!-- ==================== 查看結果 PANEL ==================== -->
        <asp:Panel ID="pnlResult" runat="server" CssClass="panel-container" Style="display: none;">
            <div class="result-panel">
                <h2 id="resultTitle" class="result-title">挑戰結果</h2>
                <div id="resultMessage" class="result-message"></div>

                <div id="resultStats" class="result-stats">
                    <p id="resultRate"></p>
                    <p id="resultReward"></p>
                </div>

                <button type="button" class="end-btn" onclick="endChallenge()">結束挑戰</button>
            </div>
        </asp:Panel>


        <!-- 🚩 離開確認 Modal -->
        <div id="exitGameModal" class="modal-overlay" style="display: none;">
            <div class="modal-panel">
                <div class="modal-title">是否確定離開挑戰？</div>
                <div class="modal-subtitle">(本次作答將不會被記錄)</div>
                <div class="modal-actions">
                    <button type="button" class="exit-yes" onclick="abortGame()">是，離開挑戰</button>
                    <button type="button" class="exit-no" onclick="hideExitModal()">否，繼續挑戰</button>
                </div>
            </div>
        </div>

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
                        <li>難度越高、時間越短，獎勵倍率也會更高。</li>
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

            // 🧩 取得目前玩家擁有的鑽石數
            const lblDiamonds = document.getElementById("lblDiamonds");
            let currentDiamonds = parseInt(lblDiamonds?.textContent.trim()) || 0;

            // ======= ✅ 驗證下注金額 =======
            if (isNaN(betAmount) || betAmount <= 0) {
                showErrorModal("下注金額必須大於 0！");
                return;
            }
            if (betAmount > 100) {
                showErrorModal("下注金額不能超過 100 顆鑽石！");
                return;
            }
            if (betAmount > currentDiamonds) {
                showErrorModal(`下注金額 (${betAmount} 顆) 不可超過您目前持有的 ${currentDiamonds} 顆鑽石！`);
                return;
            }

            // 1) 關掉設定面板
            const pnlChallenge = document.getElementById("<%= pnlChallenge.ClientID %>");
            if (pnlChallenge) pnlChallenge.style.display = "none";

            // 2) **關鍵**：把外層 ASP:Panel 顯示回來（第二輪一定要做）
            const pnlGameOuter = document.getElementById("<%= pnlGame.ClientID %>");
            if (pnlGameOuter) pnlGameOuter.style.display = "flex"; // 和 .panel-container 一致

            // 3) 內層遊戲面板顯示
            const pnlGameInner = document.querySelector("[id$='pnlGame'] .panel-game");
            if (pnlGameInner) pnlGameInner.style.display = "block";

            // 4) 顯示提交與關閉
            const btnSubmit = document.getElementById("btnSubmit");
            if (btnSubmit) btnSubmit.style.display = "inline-block";
            const closeBtn = document.querySelector(".close-btn");
            if (closeBtn) closeBtn.style.display = "block";

            // 5) 載入題目 + 倒數
            loadChallengeWords();

            const durationSelect = document.getElementById("duration");
            const totalSeconds = parseInt(durationSelect.selectedOptions[0].dataset.seconds);
            startCountdown(totalSeconds);
        }
    </script>

    <script>
        //==========================================
        //========== 第一章：挑戰開始邏輯 ==========
        //==========================================
        let shuffledMeanings = [];  //用來存放打亂後的對應 
        let isPaused = false; // ✅ 紀錄倒數是否暫停
        let pausedTimeLeft = 0; // ✅ 暫存剩餘秒數

        /* ✅ 改為從後端撈資料（取代 mockWords） */
        let mockWords = []; //先宣告空陣列，後續由後端填入

        /* ✅ 修改這裡：載入挑戰時改用 fetch 後端資料 */
        function loadChallengeWords() {
            let container = document.querySelector(".matching-container");
            container.innerHTML = "";

            // 取得使用者選擇的難度（初級/中級/中高級）
            const difficultySelect = document.getElementById("difficulty");
            const difficultyValue = difficultySelect.options[difficultySelect.selectedIndex].text.split(" ")[0];
            // e.g. "初級 (x1.1)" → 取 "初級"

            // 🔸 從後端撈取單字資料
            fetch("MatchingGameService.asmx/GetMatchingWords", {
                method: "POST",
                headers: { "Content-Type": "application/json; charset=utf-8" },
                body: JSON.stringify({ difficulty: difficultyValue })
            })
                .then(res => res.json())
                .then(data => {
                    // ✅ 驗證回傳狀態
                    if (data.d.status !== "OK") {
                        alert("題目載入失敗：" + (data.d.message || "未知錯誤"));
                        return;
                    }

                    // ✅ 將資料儲存進 mockWords
                    mockWords = data.d.data.map(item => ({
                        word: item.word,
                        part: "n.", // ❗暫時給固定詞性（後端若要可一併傳）
                        meaning: item.meaning
                    }));

                    // ✅ 打亂右側中文，但保留正確索引
                    shuffledMeanings = mockWords
                        .map((w, idx) => ({ ...w, originalIndex: idx }))
                        .sort(() => Math.random() - 0.5);

                    // ✅ 用撈到的資料生成畫面
                    mockWords.forEach((w, i) => {
                        // ================== 左側：單字 ==================
                        let wordDiv = document.createElement("div");
                        wordDiv.className = "word-box";
                        wordDiv.textContent = `${w.word} (${w.part})`;
                        wordDiv.draggable = true;
                        wordDiv.dataset.index = i;

                        wordDiv.addEventListener("dragstart", e => {
                            if (wordDiv.classList.contains("word-used")) {
                                e.preventDefault();
                                return;
                            }
                            e.dataTransfer.setData("wordIndex", i);
                            e.dataTransfer.setData("from", "wordList");
                        });

                        // ================== 右側：答案區 + 中文 ==================
                        let meaningDiv = document.createElement("div");
                        meaningDiv.className = "meaning-box";

                        let answerSlot = document.createElement("div");
                        answerSlot.className = "answer-slot";
                        answerSlot.dataset.index = i;
                        answerSlot.draggable = true;

                        answerSlot.addEventListener("dragstart", e => {
                            if (answerSlot.textContent.trim() !== "") {
                                e.dataTransfer.setData("wordText", answerSlot.textContent);
                                e.dataTransfer.setData("wordIndex", answerSlot.dataset.wordIndex || "");
                                e.dataTransfer.setData("from", "answerSlot");
                                e.dataTransfer.setData("slotIndex", i);
                            }
                        });

                        answerSlot.addEventListener("dragover", e => e.preventDefault());

                        answerSlot.addEventListener("drop", e => {
                            e.preventDefault();
                            let from = e.dataTransfer.getData("from");
                            let draggedIndex = e.dataTransfer.getData("wordIndex");
                            let draggedText = e.dataTransfer.getData("wordText");
                            let slotIndex = e.dataTransfer.getData("slotIndex");

                            if (from === "wordList") {
                                let draggedWord = mockWords[draggedIndex];
                                answerSlot.textContent = `${draggedWord.word} (${draggedWord.part})`;
                                answerSlot.dataset.wordIndex = draggedIndex;

                                let usedWord = document.querySelector(`.word-box[data-index='${draggedIndex}']`);
                                if (usedWord) {
                                    usedWord.classList.add("word-used");
                                    usedWord.setAttribute("draggable", "false");
                                }
                            }

                            if (from === "answerSlot") {
                                let fromSlot = document.querySelector(`.answer-slot[data-index='${slotIndex}']`);
                                if (!fromSlot || fromSlot === answerSlot) return;

                                let tempText = answerSlot.textContent;
                                let tempIndex = answerSlot.dataset.wordIndex;

                                answerSlot.textContent = draggedText;
                                answerSlot.dataset.wordIndex = draggedIndex;
                                fromSlot.textContent = tempText;
                                fromSlot.dataset.wordIndex = tempIndex;
                            }

                            document.querySelectorAll(".word-box").forEach(box => {
                                let index = box.dataset.index;
                                let stillUsed = Array.from(document.querySelectorAll(".answer-slot"))
                                    .some(s => s.dataset.wordIndex === index);

                                if (stillUsed) {
                                    box.classList.add("word-used");
                                    box.setAttribute("draggable", "false");
                                } else {
                                    box.classList.remove("word-used");
                                    box.setAttribute("draggable", "true");
                                }
                            });
                        });

                        // ✅ 使用打亂後的中文意思
                        let meaningText = document.createElement("div");
                        meaningText.className = "meaning-text";
                        meaningText.textContent = shuffledMeanings[i].meaning;

                        meaningDiv.appendChild(answerSlot);
                        meaningDiv.appendChild(meaningText);
                        container.append(wordDiv, meaningDiv);
                    });
                })
                .catch(err => {
                    console.error("Fetch Error:", err);
                    alert("載入挑戰資料失敗，請稍後再試。");
                });
        }

        /* ==================== 倒數計時 + 進度條 ==================== */
        let countdown;
        let endTime; // ✅ 記錄結束時間 (毫秒)

        function startCountdown(totalSeconds) {
            let timeDisplay = document.getElementById("timeLeft");
            let progressBar = document.getElementById("progressBar");
            progressBar.dataset.total = totalSeconds;

            // 1️⃣ 初始化結束時間
            endTime = Date.now() + totalSeconds * 1000;
            isPaused = false;

            // 2️⃣ 清除舊倒數
            clearInterval(countdown);
            timeDisplay.textContent = totalSeconds;
            progressBar.style.width = "100%";

            // 3️⃣ 啟動倒數（每 0.1 秒更新）
            countdown = setInterval(() => {
                if (isPaused) return;

                let remainingMs = endTime - Date.now();
                let remainingSeconds = Math.max(0, Math.ceil(remainingMs / 1000));
                let percent = Math.max(0, (remainingMs / (totalSeconds * 1000)) * 100);

                // 更新顯示
                timeDisplay.textContent = remainingSeconds;
                progressBar.style.width = percent + "%";

                // ✅ 時間到 → 自動提交
                if (remainingMs <= 0) {
                    clearInterval(countdown);
                    if (document.getElementById("btnSubmit").style.display !== "none") {
                        submitAnswers(true);
                    }
                }
            }, 100);
        }

        /* ==================== 提交答案檢查 ==================== */
        function submitAnswers(auto = false) {
            let answerSlots = document.querySelectorAll(".answer-slot");
            let filledCount = Array.from(answerSlots).filter(s => s.textContent.trim() !== "").length;

            if (!auto && filledCount < mockWords.length) {
                if (!confirm("仍有未配對的單字，確定要交卷嗎？")) return;
            }

            clearInterval(countdown); // 停止倒數
            document.querySelector(".close-btn").style.display = "none"; // 隱藏叉叉

            let correctCount = 0;
            let wrongCount = 0;
            let unansweredCount = 0;

            answerSlots.forEach((slot, i) => {
                let chosenIndex = slot.dataset.wordIndex;
                let correctIndex = shuffledMeanings[i].originalIndex;
                let correctWord = mockWords[correctIndex];

                if (!chosenIndex || slot.textContent.trim() === "") {
                    // 🔸 未作答 → 灰色 + 顯示正確答案
                    slot.classList.remove("answer-correct", "answer-wrong");
                    slot.classList.add("answer-unanswered");
                    slot.textContent = `${correctWord.word} (${correctWord.part})`;
                    slot.dataset.wordIndex = correctIndex;
                    unansweredCount++;
                } else if (parseInt(chosenIndex) === correctIndex) {
                    // ✅ 答對
                    slot.classList.remove("answer-wrong", "answer-unanswered");
                    slot.classList.add("answer-correct");
                    correctCount++;
                } else {
                    // ❌ 答錯
                    slot.classList.remove("answer-correct", "answer-unanswered");
                    slot.classList.add("answer-wrong");
                    slot.textContent = `${correctWord.word} (${correctWord.part})`;
                    slot.dataset.wordIndex = correctIndex;
                    wrongCount++;
                }
            });

            // 隱藏提交按鈕
            document.getElementById("btnSubmit").style.display = "none";

            // 禁止拖曳但不破壞 DOM 結構
            document.querySelectorAll(".word-box, .answer-slot").forEach(el => {
                el.setAttribute("draggable", "false");
            });

            // 顯示統計
            setTimeout(() => {
                const wrapper = document.getElementById("resultWrapper");
                const btnResult = document.getElementById("btnViewResult");
                const summary = document.getElementById("resultSummary");

                document.getElementById("correctCount").textContent = `正確：${correctCount} 題`;
                document.getElementById("wrongCount").textContent = `錯誤：${wrongCount} 題`;
                document.getElementById("unansweredCount").textContent = `未作答：${unansweredCount} 題`;

                wrapper.style.display = "flex";
                btnResult.style.display = "inline-block";
                summary.style.display = "inline-flex";
            }, 500);
        }

        /* ==================== 查看結果（切換面板） ==================== */
        function goToResult() {
            // ✅ 只關內層，不關外層 Panel（避免第二輪還要再把外層救回來）
            const pnlGameInner = document.querySelector("[id$='pnlGame'] .panel-game");
            if (pnlGameInner) pnlGameInner.style.display = "none";

            // 顯示結果面板
            const pnlResult = document.getElementById("<%= pnlResult.ClientID %>");
            if (pnlResult) pnlResult.style.display = "flex";

            // 取統計結果
            const correctText = document.getElementById("correctCount").textContent;
            const total = mockWords.length;
            const correctCount = parseInt(correctText.replace(/\D/g, "")) || 0;
            const accuracy = (correctCount / total) * 100;

            // 計算獎勵
            let bet = document.getElementById("bet").value;
            let betAmount = (bet === "custom")
                ? parseInt(document.getElementById("customBet").value) || 0
                : parseInt(bet);
            let difficulty = parseFloat(document.getElementById("difficulty").value);
            let duration = parseFloat(document.getElementById("duration").value);
            let rate = 1.0 * difficulty * duration;
            let reward = Math.floor(betAmount * rate);

            // 更新結果內容
            const title = document.getElementById("resultTitle");
            const msg = document.getElementById("resultMessage");
            const rateText = document.getElementById("resultRate");
            const rewardText = document.getElementById("resultReward");

            if (accuracy >= 80) {
                if (title) { title.textContent = "🎉 恭喜勝利！"; title.className = "result-title success"; }
                if (msg) msg.textContent = "您的答對率超過 80%，贏得本次挑戰！";
                if (rateText) rateText.textContent = `答對率：${accuracy.toFixed(1)}%`;
                if (rewardText) rewardText.innerHTML =
                    `<img src="images/diamond.svg" alt="diamond" style="width:24px; height:24px; vertical-align:middle; margin-right:6px;">
             獲得獎勵：${reward} 顆鑽石（您原先下注的鑽石為：${betAmount}顆）`;
            } else {
                if (title) { title.textContent = "❌ 挑戰失敗"; title.className = "result-title fail"; }
                if (msg) msg.textContent = "未達 80% 答對率，下次再接再厲吧！";
                if (rateText) rateText.textContent = `答對率：${accuracy.toFixed(1)}%`;
                if (rewardText) rewardText.innerHTML =
                    `<img src="images/diamond.svg" alt="diamond" 
            style="width:24px; height:24px; filter: grayscale(100%); vertical-align:middle; margin-right:6px;">
         無法獲得獎勵，並扣除原先下注的 ${betAmount} 顆鑽石。`;
            }

            // ✅ 呼叫後端 Web API 更新鑽石
            fetch("MatchingGameService.asmx/UpdateMatchingResult", {
                method: "POST",
                headers: { "Content-Type": "application/json; charset=utf-8" },
                body: JSON.stringify({
                    betAmount: betAmount,
                    rate: rate,
                    accuracy: accuracy
                })
            })
                .then(res => res.json())
                .then(resData => {
                    if (resData.d.status === "OK") {
                        console.log("💎 鑽石更新成功：", resData.d);

                        // ✅ 即時更新頁首顯示（優先顯示 newDiamonds，否則 fallback 為 newTotal）
                        const lblDiamonds = document.getElementById("lblDiamonds");
                        if (lblDiamonds) {
                            lblDiamonds.textContent = resData.d.newDiamonds ?? resData.d.newTotal ?? "—";
                        }

                        // ✅ 顯示在 console 以方便除錯或驗證下注結果
                        const outcomeText = accuracy >= 80 ? "🏆 勝利" : "💀 失敗";
                        console.log(
                            `🎯 ${outcomeText}｜下注：${betAmount} 顆｜回報倍率：x${rate.toFixed(2)}｜當前鑽石餘額：${resData.d.newDiamonds ?? resData.d.newTotal}`
                        );

                    } else if (resData.d.status === "NOT_LOGGED_IN") {
                        alert("⚠️ 使用者尚未登入，無法更新鑽石。");
                    } else {
                        console.warn("❗更新失敗：", resData.d.message || resData.d.status);
                    }
                })
                .catch(err => {
                    console.error("🚨 Fetch Error:", err);
                    alert("伺服器連線異常，請稍後再試。");
                });
        }

        /* ==================== 結束挑戰（原邏輯保留，小補強） ==================== */
        function endChallenge() {
            const pnl = document.getElementById("<%= pnlResult.ClientID %>");
            if (!pnl) return;

            pnl.classList.add("hide");

            setTimeout(() => {
                pnl.classList.remove("hide");
                pnl.style.display = "none";

                // 回設定面板
                const pnlChallenge = document.querySelector("[id$='pnlChallenge']");
                if (pnlChallenge) pnlChallenge.style.display = "flex";

                // 關內層遊戲面板（外層是否關閉都可，但你現在第二輪會自己開外層了）
                const pnlGameInner = document.querySelector("[id$='pnlGame'] .panel-game");
                if (pnlGameInner) pnlGameInner.style.display = "none";

                const btnSubmit = document.getElementById("btnSubmit");
                if (btnSubmit) btnSubmit.style.display = "none";
                const closeBtn = document.querySelector(".close-btn");
                if (closeBtn) closeBtn.style.display = "none";
                const resultWrapper = document.getElementById("resultWrapper");
                if (resultWrapper) resultWrapper.style.display = "none";

                const container = document.querySelector(".matching-container");
                if (container) container.innerHTML = "";

                const progressBar = document.getElementById("progressBar");
                const timeLeft = document.getElementById("timeLeft");
                if (progressBar) progressBar.style.width = "100%";
                if (timeLeft) timeLeft.textContent = "—";

                document.querySelectorAll(".answer-slot").forEach(slot => {
                    slot.textContent = "";
                    slot.className = "answer-slot";
                    delete slot.dataset.wordIndex;
                });
                document.querySelectorAll(".word-box").forEach(word => {
                    word.classList.remove("word-used");
                    word.setAttribute("draggable", "true");
                });

                const title = document.getElementById("resultTitle");
                const msg = document.getElementById("resultMessage");
                const rate = document.getElementById("resultRate");
                const reward = document.getElementById("resultReward");
                if (title) title.textContent = "";
                if (msg) msg.textContent = "";
                if (rate) rate.textContent = "";
                if (reward) reward.textContent = "";

                shuffledMeanings = [];
                pausedTimeLeft = 0;
                clearInterval(countdown);
                isPaused = false;

                window.scrollTo({ top: 0, behavior: "smooth" });
            }, 300);
        }

    </script>

    <script>
        /* 🚩 暫停倒數（例如按叉叉） */
        function showExitModal() {
            if (!isPaused) {
                isPaused = true;
                clearInterval(countdown);
                // 暫存剩餘時間（以秒為單位）
                pausedTimeLeft = Math.max(0, Math.ceil((endTime - Date.now()) / 1000));
            }
            document.getElementById("exitGameModal").style.display = "flex";
        }

        /* 🚩 隱藏退出確認 Modal */
        function hideExitModal() {
            document.getElementById("exitGameModal").style.display = "none";
            if (isPaused && pausedTimeLeft > 0) resumeCountdown();
        }

        /* 🚩 Modal 點擊背景關閉 */
        document.getElementById("exitGameModal").addEventListener("click", e => {
            if (e.target.id === "exitGameModal") hideExitModal();
        });

        /* 🚩 恢復倒數（統一用 endTime 控制） */
        function resumeCountdown() {
            let timeDisplay = document.getElementById("timeLeft");
            let progressBar = document.getElementById("progressBar");
            const totalSeconds = parseInt(progressBar.dataset.total) || pausedTimeLeft;

            // 重新設定結束時間
            endTime = Date.now() + pausedTimeLeft * 1000;
            isPaused = false;

            clearInterval(countdown);
            countdown = setInterval(() => {
                if (isPaused) return;

                let remainingMs = endTime - Date.now();
                let remainingSeconds = Math.max(0, Math.ceil(remainingMs / 1000));
                let percent = Math.max(0, (remainingMs / (totalSeconds * 1000)) * 100);

                pausedTimeLeft = remainingSeconds;
                timeDisplay.textContent = remainingSeconds;
                progressBar.style.width = percent + "%";

                if (remainingMs <= 0) {
                    clearInterval(countdown);
                    if (document.getElementById("btnSubmit").style.display !== "none") {
                        submitAnswers(true);
                    }
                }
            }, 100);
        }

        /* 🚩 中斷挑戰邏輯（確認離開 → 回到主畫面） */
        function abortGame() {
            hideExitModal();
            clearInterval(countdown);
            isPaused = false;
            pausedTimeLeft = 0;

            document.getElementById("timeLeft").textContent = "0";
            document.getElementById("progressBar").style.width = "0%";

            // 清空所有遊戲內容
            const container = document.querySelector(".matching-container");
            if (container) container.innerHTML = "";

            // 隱藏挑戰面板
            const gamePanel = document.querySelector(".panel-game");
            if (gamePanel) gamePanel.style.display = "none";

            // 顯示挑戰設定面板
            const pnlChallenge = document.getElementById("<%= pnlChallenge.ClientID %>");
            if (pnlChallenge) {
                pnlChallenge.style.removeProperty("display"); // 移除 ASP.NET 強加的 inline style
                pnlChallenge.style.display = "flex";
            }

        }
    </script>

</body>
</html>
