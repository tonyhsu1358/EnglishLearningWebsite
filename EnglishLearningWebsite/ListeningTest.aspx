<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ListeningTest.aspx.cs" Inherits="ListeningTest" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>聽力測驗</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        /** 導覽列 **/
        #navbar {
            background: rgba(255, 255, 255, 0.8);
            padding: 8px 20px;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            border-bottom: 2px solid #6b4226;
            z-index: 100;
        }

        /** 鑽石數量樣式 **/
        .resource {
            margin-right: 150px; /* 控制靠左或靠右 */
            font-weight: bold;
            font-size: 18px;
            background: rgba(255, 255, 255, 0.6);
            padding: 4px 10px;
            border-radius: 8px;
            color: #000;
            display: flex;
            align-items: center;
            gap: 5px;
            z-index: 100;
        }

        /** 外層遮罩 **/
        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(252, 244, 228, 1) !important; /* 淡米色背景 */
            display: flex;
            flex-direction: column; /* 讓 Panel 與按鈕垂直排列 */
            justify-content: flex-start; /* 從上往下排 */
            align-items: center; /* 水平置中 */
            z-index: 10;
        }

        /** ASP.NET Panel：承載內容 **/
        .panel-container {
            background: #fff;
            padding: 15px;
            border-radius: 15px;
            max-width: 800px;
            width: 80%;
            max-height: 80vh; /* 限制面板最高不要超過螢幕 */
            margin: 0 0 0 0;
            margin-top: 50px; /* 避開導覽列 */
            box-shadow: 0 8px 20px rgba(0,0,0,0.25);
            border: 5px solid #6b4226;
            overflow-y: auto; /* 超出時可滾動 */
        }

        /** 返回鍵樣式 **/
        .back-icon {
            width: 32px;
            height: 32px;
            cursor: pointer;
            transition: transform 0.2s ease, filter 0.2s ease;
        }

            /** 返回鍵 hover 效果 **/
            .back-icon:hover {
                transform: scale(1.2);
                filter: brightness(1.2);
            }

        /** 顯示資訊圖標 **/
        .info-icon {
            width: 32px;
            height: 32px;
            cursor: pointer;
            transition: transform 0.2s ease, filter 0.2s ease;
        }

            /** 資訊圖標 hover 效果 **/
            .info-icon:hover {
                transform: scale(1.2);
                filter: brightness(1.2);
            }

        /** 題數下拉標籤美化 **/
        label[for="ddlQuestionCount"] {
            font-weight: bold;
            color: #6b4226;
            font-size: 20px;
        }

        /** 題數下拉選單美化 **/
        .form-select {
            border: 2px solid #6b4226;
            border-radius: 8px;
            padding: 6px 12px;
            font-size: 20px;
            font-weight: bold;
            color: #6b4226;
            background-color: #fdfaf6;
            transition: all 0.2s ease-in-out;
        }

            /** 下拉選單 focus 效果 **/
            .form-select:focus {
                border-color: #8b5a2b;
                box-shadow: 0 0 6px rgba(107,66,38,0.5);
                outline: none;
            }

        /** 全選 checkbox 外層容器 **/
        .form-check {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 2px;
            font-size: 18px;
            font-weight: bold;
            color: #6b4226;
        }

        /** 全選標籤文字 **/
        .form-check-label {
            font-size: 18px;
            font-weight: bold;
            color: #6b4226;
        }

        /** 全選 checkbox 本體 **/
        .form-check-input[type=checkbox] {
            appearance: none !important;
            -webkit-appearance: none !important;
            -moz-appearance: none !important;
            width: 22px;
            height: 22px;
            border: 2px solid #6b4226;
            border-radius: 6px;
            cursor: pointer;
            background: #fff !important;
            background-image: none !important;
            transition: transform 0.2s ease, background-color 0.2s ease;
        }

            /** 全選 checkbox hover 效果 **/
            .form-check-input[type=checkbox]:hover {
                transform: scale(1.1);
            }

            /** 全選 checkbox 勾選狀態 **/
            .form-check-input[type=checkbox]:checked {
                background-color: #6b4226 !important;
                border-color: #6b4226 !important;
                background-image: url("images/tick.svg") !important;
                background-repeat: no-repeat;
                background-position: center;
                background-size: 16px 16px;
            }

        /** 主題卡片 **/
        .topic-card {
            cursor: pointer;
            transition: transform 0.3s ease;
            height: 100%;
            font-size: 14px;
        }

            /** 主題卡片 hover 效果 **/
            .topic-card:hover {
                transform: scale(1.05);
                box-shadow: 0 4px 12px rgba(0,0,0,0.25);
            }

            /** 主題卡片圖片 **/
            .topic-card img {
                width: 100%;
                aspect-ratio: 5 / 4;
                object-fit: cover;
                border-radius: 12px 12px 0 0;
            }

        /** 主題卡片文字區 **/
        .topic-card-body {
            padding: 12px;
            text-align: center;
        }

        /** 卡片底部區域 **/
        .card-footer {
            padding: 4px 8px;
        }

        /** 隱藏卡片內原始 checkbox **/
        .topicCheck {
            display: none !important;
        }

        /** 自製勾選框 **/
        .check-box {
            width: 24px;
            height: 24px;
            border: 2px solid #6b4226;
            border-radius: 4px;
            margin-left: 70px;
            display: flex;
            justify-content: center;
            align-items: center;
            cursor: pointer;
            background-color: #fff;
            transition: background-color 0.2s ease, transform 0.2s ease;
        }

        /** 全選自製勾選框（單獨控制） **/
        .check-box-all {
            margin-left: 8px;
        }

        /** 自製勾選框勾選狀態 **/
        .check-box.checked {
            background-color: #6b4226;
            border-color: #6b4226;
            transform: scale(1.1);
            background-image: url("images/tick.svg");
            background-repeat: no-repeat;
            background-position: center;
            background-size: 25px 25px;
        }

        /** 題數顯示文字 **/
        .question-count {
            font-size: 13px;
            font-weight: bold;
            color: #6b4226;
            margin-left: 10px;
        }

        /** 修正 Bootstrap row 邊距 **/
        #topicContainer {
            margin-left: 0 !important;
            margin-right: 0 !important;
        }

        /** 自訂開始測驗按鈕 **/
        .btn-start-custom {
            background-color: #6b4226;
            border: none;
            color: #fff;
            font-size: 20px;
            font-weight: bold;
            padding: 12px 40px;
            border-radius: 12px;
            box-shadow: 0 6px 14px rgba(0, 0, 0, 0.25);
            transition: all 0.25s ease;
        }

            /** 自訂開始測驗按鈕 hover 效果 **/
            .btn-start-custom:hover {
                background-color: #8b5a2b;
                transform: scale(1.05);
                box-shadow: 0 8px 20px rgba(0, 0, 0, 0.35);
            }

        /** 🎨 魔法森林風格的提示框 **/
        .custom-warning-modal {
            background: #fdfaf6;
            border: 3px solid #6b4226;
            border-radius: 15px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.35);
            color: #3e2723;
            font-family: "Microsoft JhengHei", sans-serif;
            animation: slideDown 0.35s ease-out;
        }

            /** 提示框標頭 **/
            .custom-warning-modal .modal-header {
                background: linear-gradient(90deg, #ffcc80, #ffb74d);
                border-bottom: 2px solid #6b4226;
                border-radius: 12px 12px 0 0;
            }

            /** 提示框標題 **/
            .custom-warning-modal .modal-title {
                font-weight: bold;
                font-size: 20px;
                color: #4e342e;
            }

            /** 提示框內容 **/
            .custom-warning-modal .modal-body {
                font-size: 18px;
                text-align: center;
                padding: 20px;
                color: #5d4037;
            }

            /** 提示框底部 **/
            .custom-warning-modal .modal-footer {
                border-top: none;
                justify-content: center;
            }

        /** 自訂提示框按鈕 **/
        .custom-warning-btn {
            background-color: #6b4226 !important;
            border: none;
            font-size: 18px;
            font-weight: bold;
            padding: 8px 30px;
            border-radius: 10px;
            color: #fff;
            transition: all 0.3s ease-in-out;
        }

            /** 自訂提示框按鈕 hover 效果 **/
            .custom-warning-btn:hover {
                transform: scale(1.05);
                color: #fff !important;
                background-color: #8b5a2b;
            }

        /* ✨ 彈出動畫 */
        @keyframes slideDown {
            from {
                transform: translateY(-30px);
                opacity: 0;
            }

            to {
                transform: translateY(0);
                opacity: 1;
            }
        }
        /* 測驗 Panel 外框：高度自適應，盡量撐滿可用空間 */
        .test-panel {
            display: flex;
            flex-direction: column;
            justify-content: flex-start; /* 從上排到下 */
            background: #fff;
            padding: 15px;
            border-radius: 15px;
            max-width: 800px;
            width: 80%;
            height: 94vh; /* 🔹 高度佔螢幕 90% */
            margin-top: 10px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.25);
            border: 5px solid #6b4226;
            z-index: 5000;
        }

        /* 頂部工具列：叉叉 + 進度條 */
        .test-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .close-btn {
            width: 28px;
            height: 28px;
            cursor: pointer;
            transition: transform 0.2s ease;
        }

            .close-btn:hover {
                transform: scale(1.2);
            }
        /* 🚩 提示是否中斷測驗Modal 遮罩 */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.45);
            display: none; /* 初始隱藏 */
            justify-content: center; /* 水平置中 */
            align-items: center; /* 垂直置中 */
            z-index: 10000;
        }

        /* 🚩 提示是否中斷測驗 Modal 內容面板容器 */
        .modal-panel {
            background: #fff; /* 白色背景 */
            border-radius: 18px; /* 圓角 */
            padding: 30px 26px; /* 內距 */
            box-shadow: 0 4px 24px rgba(0,0,0,0.2); /* 陰影效果 */
            text-align: center; /* 內容文字置中 */
            min-width: 320px; /* 最小寬度 */
            max-width: 90vw; /* 最大寬度，避免超過視窗 */
            animation: fadeIn 0.2s; /* 淡入動畫 */
        }

        /* 🚩 Modal 標題文字 */
        .modal-title {
            font-size: 22px; /* 字體大小 */
            font-weight: 600; /* 半粗體 */
            margin-bottom: 10px; /* 與下方元素間距 */
            color: #222; /* 深灰色字體 */
        }

        /* 🚩 Modal 副標題文字 */
        .modal-subtitle {
            font-size: 15px; /* 字體大小 */
            color: #666; /* 淺灰色字體 */
            margin-bottom: 22px; /* 與下方元素間距 */
        }

        /* 🚩 Modal 按鈕容器 */
        .modal-actions {
            display: flex; /* 使用 flex 排版 */
            flex-direction: column; /* 垂直排列子元素 */
            gap: 12px; /* 按鈕間距 */
            align-items: center; /* 子元素（水平方向）置中 */
        }

        /* 🚩 Modal 內的兩個按鈕（共用樣式） */
        .exit-yes, .exit-no {
            width: 220px; /* 按鈕寬度 */
            padding: 12px 0; /* 上下內距 */
            border: none; /* 移除邊框 */
            border-radius: 14px; /* 圓角 */
            font-size: 17px; /* 字體大小 */
            font-weight: bold; /* 粗體 */
            cursor: pointer; /* 滑鼠移上去變手指 */
        }

        /* 🚩 YES 按鈕（離開測驗） */
        .exit-yes {
            background: #fa2e50; /* 紅色背景 */
            color: #fff; /* 白色字體 */
        }

            .exit-yes:hover {
                background: #d0203b; /* 深紅色背景 */
            }

        /* 🚩 NO 按鈕（繼續作答） */
        .exit-no {
            background: #f5f5f5; /* 淺灰背景 */
            color: #777; /* 中灰字體 */
        }

            .exit-no:hover {
                background: #e1e1e1; /* 更深一點的灰背景 */
            }

        /* 播放按鈕容器 */
        .play-btn {
            text-align: left; /* 改為靠左 */
        }

            /* 播放按鈕圖片 */
            .play-btn img {
                width: 28px; /* 從 40px 縮小 */
                height: 28px;
                cursor: pointer;
                transition: transform 0.2s ease;
            }

                /* 🚩 播放按鈕圖片：非禁用時 hover 有放大效果 */
                .play-btn img:not(.disabled):hover {
                    transform: scale(1.1); /* 放大 1.1 倍 */
                    transition: transform 0.2s ease; /* 柔和過渡 */
                }

                /* 🎵 播放按鈕禁用狀態 */
                .play-btn img.disabled {
                    opacity: 0.5; /* 半透明，表示無法操作 */
                    pointer-events: none; /* 禁止滑鼠點擊 */
                    cursor: not-allowed; /* 滑鼠指標變成禁止符號 */
                }
        /* 題目圖片 */
        .test-image {
            display: block;
            margin: 1px auto;
            max-height: 50vh; /*圖片最大高度佔螢幕一半*/
            width: auto;
            object-fit: contain;
            border-radius: 8px;
            border: 2px solid #ddd;
            flex-shrink: 0; /*圖片不要因空間壓縮*/
        }

        /* 父容器，每個選項一格：按鈕 + 文字 */
        .option-wrapper {
            display: flex;
            align-items: center;
            gap: 10px; /* 按鈕與文字的距離 */
        }

        /* 選項區塊：2x2 Grid */
        .options-grid {
            display: grid;
            grid-template-columns: 1fr 1fr; /* 兩欄 */
            grid-template-rows: auto auto; /* 兩列 */
            gap: 12px; /* 選項間距 */
            margin-top: 15px;
        }

        /* 選項按鈕：改為適合兩欄的樣式 */
        .option-btn {
            width: 100%; /* 讓每個格子自動填滿 */
            padding: 14px;
            font-size: 18px;
            font-weight: bold;
            border: 2px solid #6b4226;
            border-radius: 10px;
            background: #f5f5f5;
            transition: all 0.2s ease;
        }

            .option-btn:hover {
                transform: scale(1.02);
            }

            /* 選項按鈕被選中 */
            .option-btn.selected {
                background: #006000;
                border-color: #8b5a2b;
                color: #fff;
                transform: scale(1.02);
            }

        .transcript {
            font-size: 16px;
            color: #333;
            flex: 1; /* 靠近按鈕 */
            margin-left: 8px; /* 與按鈕間距縮小 */
            display: inline-block;
        }

        /* 送出按鈕 */
        .submit-btn {
            margin-top: 15px;
            width: 100%;
            padding: 14px;
            font-size: 20px;
            font-weight: bold;
            color: #fff;
            background: #6b4226;
            border: none;
            border-radius: 12px;
            transition: all 0.2s ease;
        }

            .submit-btn:hover {
                background: #8b5a2b;
            }

            /* 📤 送出按鈕禁用狀態 */
            .submit-btn:disabled {
                background-color: #ccc; /* 灰色背景 */
                border: none;
                color: #666; /* 文字也變淡 */
                cursor: not-allowed;
                transform: none !important; /* 移除 hover 效果 */
                box-shadow: none;
            }


        /* 詳解模式下：按鈕縮小成方塊 */
        .option-btn.explained {
            width: 16%; /* 父容器寬度的16 % */
            aspect-ratio: 1/1; /* 保持正方形 */
            padding: 0;
            font-size: 1rem; /* 用 rem/em 讓字體跟隨縮放 */
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            transition: all 0.3s ease;
        }

        /* 答錯選項 */
        .option-btn.wrong {
            background: #a00000 !important;
            color: #fff !important;
        }

        /* 答對選項 */
        .option-btn.correct {
            background: #006000 !important;
            color: #fff !important;
        }
        /* 題目進場（從右滑入） */
        .slide-in-right {
            animation: slideInRight 0.4s ease forwards;
        }

        /* 題目退場（往左滑出） */
        .slide-out-left {
            animation: slideOutLeft 0.4s ease forwards;
        }

        @keyframes slideInRight {
            from {
                transform: translateX(100%);
                opacity: 0;
            }

            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        @keyframes slideOutLeft {
            from {
                transform: translateX(0);
                opacity: 1;
            }

            to {
                transform: translateX(-100%);
                opacity: 0;
            }
        }

        .summary-panel {
            background: #fff;
            border-radius: 12px;
            padding: 30px;
            text-align: center;
            max-width: 500px;
            margin: 40px auto;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            animation: fadeIn 0.5s ease-in-out;
        }

            .summary-panel h2 {
                font-size: 24px;
                margin-bottom: 20px;
                color: #333;
            }

            .summary-panel p {
                font-size: 18px;
                margin: 8px 0;
            }

            .summary-panel .btn-finish {
                margin-top: 20px;
                padding: 10px 20px;
                font-size: 18px;
                border: none;
                border-radius: 8px;
                background: #007bff;
                color: #fff;
                cursor: pointer;
            }

                .summary-panel .btn-finish:hover {
                    background: #0056b3;
                }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- 🔹 導覽列 -->
        <div id="navbar">
            <span class="resource">
                <img src="images/diamond.svg" alt="魔法鑽石"
                    style="width: 24px; height: 24px; vertical-align: middle;" />
                <asp:Label ID="lblDiamonds" runat="server" Text="0"></asp:Label>
            </span>
        </div>

        <div class="overlay">
            <asp:Panel ID="pnlListeningMenu" runat="server" CssClass="panel-container">
                <!-- 標題 -->
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <asp:ImageButton ID="btnBack" runat="server" ImageUrl="~/images/back-arrow.svg"
                        CssClass="me-3 back-icon" OnClick="btnBack_Click" AlternateText="返回" />
                    <h3 class="flex-grow-1 text-center">🎧 請選擇聽力測驗主題</h3>
                    <button type="button" class="btn btn-light info-btn" data-bs-toggle="modal" data-bs-target="#infoModal">
                        <img src="images/info-icon.svg" alt="資訊" class="info-icon" />
                    </button>
                </div>

                <!-- 題數下拉 -->
                <div class="text-center mb-3">
                    <label for="ddlQuestionCount" class="form-label me-2">選擇題目數量：</label>
                    <asp:DropDownList ID="ddlQuestionCount" runat="server" CssClass="form-select d-inline-block" Width="150px">
                        <asp:ListItem Value="5">5 題</asp:ListItem>
                        <asp:ListItem Value="10" Selected="True">10 題</asp:ListItem>
                        <asp:ListItem Value="15">15 題</asp:ListItem>
                        <asp:ListItem Value="20">20 題</asp:ListItem>
                        <asp:ListItem Value="25">25 題</asp:ListItem>
                        <asp:ListItem Value="30">30 題</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <!-- 全選 -->
                <div class="text-center mb-3" onclick="toggleAll()">
                    <div class="form-check d-inline-flex align-items-center justify-content-center" style="cursor: pointer;">
                        <label for="chkAll" class="form-check-label mb-0 me-2">全選所有主題</label>
                        <div class="check-box check-box-all" id="chkAllBox"></div>
                        <!-- ✅ 加了 check-box-all -->
                        <input type="checkbox" id="chkAll" class="d-none" />
                    </div>
                </div>

                <!-- 主題卡片區 -->
                <div class="row" id="topicContainer">
                    <asp:Repeater ID="rptTopics" runat="server">
                        <ItemTemplate>
                            <div class="col-md-4 mb-4">
                                <div class="card topic-card" onclick="toggleCheckBox('<%# Eval("TopicID") %>')">
                                    <img src='<%# Eval("ImagePath") %>' alt='<%# Eval("TopicName") %>' />
                                    <div class="topic-card-body">
                                        <h5><%# Eval("TopicName") %></h5>
                                        <p><%# Eval("Description") %></p>

                                        <!-- ✅ 改成純 HTML input，確保 JS 可正確存取 -->
                                        <input type="checkbox"
                                            name="selectedTopics"
                                            class="d-none topicCheck"
                                            value='<%# Eval("TopicID") %>' />

                                        <!-- ✅ 勾選框 + 題數 -->
                                        <div class="card-footer d-flex align-items-center">
                                            <div class="check-box" data-topicid='<%# Eval("TopicID") %>'></div>
                                            <span class="question-count">
                                                <%# (Eval("TopicName").ToString() == "多益測驗") ? "題數：100 題" : "題數：10 題" %>
                                            </span>
                                        </div>

                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
            <!-- 開始測驗按鈕 -->
            <div class="text-center mt-4">
                <button type="button" id="btnStart" class="btn-start-custom">開始測驗</button>
            </div>

            <!-- 🔹 測驗 Panel（初始隱藏） -->
            <asp:Panel ID="pnlDoTest" runat="server" CssClass="test-panel" Style="display: none;">

                <!-- 頂部：叉叉 + 進度條 -->
                <div class="test-header">
                    <span>Part 1</span>
                    <div class="progress flex-grow-1 mx-3" style="height: 12px;">
                        <div id="progressBar" class="progress-bar bg-success" style="width: 20%;"></div>
                    </div>
                    <img src="<%= ResolveUrl("~/images/close.svg") %>" class="close-btn" alt="關閉" onclick="showExitModal()" />
                </div>

                <!-- 播放按鈕 + 音檔 -->
                <div class="play-btn">
                    <img id="btnPlay" src="<%= ResolveUrl("~/images/triangle-filled.svg") %>"
                        alt="播放" onclick="manualPlay()" />
                    <audio id="audioPlayer"
                        src="<%= ResolveUrl("~/ListeningTest_Audio/TOEIC_001.wav") %>">
                    </audio>
                </div>

                <!-- 題目圖片 -->
                <img src="<%= ResolveUrl("~/ListeningTest_Images/TOEIC_001.jpg") %>"
                    alt="題目圖片" class="test-image" />

                <!-- 選項 -->
                <div class="options-grid mt-3">
                    <div class="option-wrapper">
                        <button type="button" class="option-btn">A</button>
                        <span class="transcript"></span>
                        <!-- ✅ 預留逐字稿 -->
                    </div>
                    <div class="option-wrapper">
                        <button type="button" class="option-btn">B</button>
                        <span class="transcript"></span>
                    </div>
                    <div class="option-wrapper">
                        <button type="button" class="option-btn">C</button>
                        <span class="transcript"></span>
                    </div>
                    <div class="option-wrapper">
                        <button type="button" class="option-btn">D</button>
                        <span class="transcript"></span>
                    </div>
                </div>

                <!-- 送出按鈕 -->
                <button type="button" class="submit-btn" onclick="submitAnswer()">送出</button>
            </asp:Panel>

            <!-- 結算畫面 Panel -->
            <div id="pnlSummary" style="display: none;" class="summary-panel">
                <!-- 內容將由 JS 動態插入 -->
            </div>

            <!-- 🚩 離開確認 Modal -->
            <div id="exitTestModal" class="modal-overlay" style="display: none;">
                <div class="modal-panel">
                    <div class="modal-title">是否確定離開測驗？</div>
                    <div class="modal-subtitle">(本次作答將不會被記錄)</div>
                    <div class="modal-actions">
                        <button type="button" class="exit-yes" onclick="abortTest()">是，離開測驗</button>
                        <button type="button" class="exit-no" onclick="hideExitModal()">否，繼續作答</button>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <!-- Info Modal -->
    <div class="modal fade" id="infoModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">玩法說明</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    在這裡您可以選擇題數與主題，系統將依照選擇自動生成測驗。
                </div>
            </div>
        </div>
    </div>

    <!-- 題目不足提示 Modal -->
    <div class="modal fade" id="warningModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content custom-warning-modal">
                <div class="modal-header">
                    <h5 class="modal-title">⚠ 題目不足</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    您未勾選主題或所選主題的題目總數不足，<br />
                    請重新選擇題目數量或增加主題。
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-warning custom-warning-btn" data-bs-dismiss="modal">確定</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        //=====================================
        //====第零章:選取主題&驗證題數是否足夠
        //=====================================
        // 點擊卡片切換
        function toggleCheckBox(topicId) {
            let cb = document.querySelector(".topicCheck[value='" + topicId + "']"); // ✅ 現在能正確找到 input
            if (!cb) return;

            cb.checked = !cb.checked;

            let box = document.querySelector(".check-box[data-topicid='" + topicId + "']");
            if (box) box.classList.toggle("checked", cb.checked);
            // 🚩 檢查是否所有都勾選
            let allChecked = Array.from(document.querySelectorAll(".topicCheck"))
                .every(c => c.checked);

            document.getElementById("chkAll").checked = allChecked;
            document.getElementById("chkAllBox").classList.toggle("checked", allChecked);
        }

        // 全選/取消全選
        function toggleAll() {
            let cb = document.getElementById("chkAll");
            cb.checked = !cb.checked;

            // 切換外觀
            let box = document.getElementById("chkAllBox");
            box.classList.toggle("checked", cb.checked);

            // 同步所有卡片
            document.querySelectorAll(".topicCheck").forEach(c => {
                c.checked = cb.checked;
                let b = document.querySelector(".check-box[data-topicid='" + c.value + "']");
                if (b) b.classList.toggle("checked", cb.checked);
            });
        }

        document.getElementById("btnStart").addEventListener("click", function () {
            let ddl = document.getElementById("<%= ddlQuestionCount.ClientID %>");
            let selectedCount = parseInt(ddl.value);

            // 計算勾選題數
            let totalQuestions = 0;
            document.querySelectorAll(".topicCheck:checked").forEach(cb => {
                let topicName = cb.closest(".card").querySelector("h5").innerText;
                totalQuestions += (topicName === "多益測驗") ? 100 : 10;
            });

            if (totalQuestions < selectedCount) {
                let warningModal = new bootstrap.Modal(document.getElementById("warningModal"));
                warningModal.show();
            } else {
                // ✅ 切換顯示狀態
                document.getElementById("<%= pnlListeningMenu.ClientID %>").style.display = "none";
                document.getElementById("btnStart").style.display = "none";
                document.getElementById("<%= pnlDoTest.ClientID %>").style.display = "block";
                //開始輪播題目
                startTest(); // ✅ 正確呼叫
            }
        });
    </script>

    <script>
        //=====================================
        //==== 第一章：聽力測驗多題輪播版邏輯
        //=====================================

        // 模擬從資料庫撈出的題目
        const questions = [
            {
                QuestionID: 1,
                QuestionCode: "TOEIC_001",
                QuestionText: "Look at the picture.",
                OptionA: "The man is writing on a whiteboard.",
                OptionB: "The man is looking out the window.",
                OptionC: "The man is speaking on the phone.",
                OptionD: "The man is sitting at a desk.",
                CorrectAnswer: "B",
                AudioPath: "ListeningTest_Audio/TOEIC_001.wav",
                ImagePath: "ListeningTest_Images/TOEIC_001.jpg"
            },
            {
                QuestionID: 2,
                QuestionCode: "TOEIC_002",
                QuestionText: "Look at the picture.",
                OptionA: "The woman is talking on the phone.",
                OptionB: "The woman is cutting vegetables in the kitchen.",
                OptionC: "The woman is washing the floor.",
                OptionD: "The woman is sitting at a dining table.",
                CorrectAnswer: "B",
                AudioPath: "ListeningTest_Audio/TOEIC_002.wav",
                ImagePath: "ListeningTest_Images/TOEIC_002.jpg"
            },
            {
                QuestionID: 3,
                QuestionCode: "TOEIC_003",
                QuestionText: "Look at the picture.",
                OptionA: "A woman is holding a puppy in front of a colorful wall.",
                OptionB: "A dog is lying on a wooden floor.",
                OptionC: "A man is walking a dog in the park.",
                OptionD: "A cat is sitting on a couch.",
                CorrectAnswer: "A",
                AudioPath: "ListeningTest_Audio/TOEIC_003.wav",
                ImagePath: "ListeningTest_Images/TOEIC_003.jpg"
            },
            {
                QuestionID: 4,
                QuestionCode: "TOEIC_004",
                QuestionText: "Look at the picture.",
                OptionA: "A man is reading a book at a cafe.",
                OptionB: "A man is fixing a bicycle.",
                OptionC: "A man is jogging through a park.",
                OptionD: "A man is sleeping on a bench.",
                CorrectAnswer: "A",
                AudioPath: "ListeningTest_Audio/TOEIC_004.wav",
                ImagePath: "ListeningTest_Images/TOEIC_004.jpg"
            },
            {
                QuestionID: 5,
                QuestionCode: "TOEIC_005",
                QuestionText: "Look at the picture.",
                OptionA: "A woman is using a laptop at a desk.",
                OptionB: "A woman is cooking dinner.",
                OptionC: "A woman is walking her dog.",
                OptionD: "A woman is painting a wall.",
                CorrectAnswer: "A",
                AudioPath: "ListeningTest_Audio/TOEIC_005.wav",
                ImagePath: "ListeningTest_Images/TOEIC_005.jpg"
            }
        ];

        // 測驗狀態
        let currentIndex = 0;  // 目前題號 (0 起算)
        let correctCount = 0; // 記錄答對題數
        let selectedAnswer = null; // 暫存使用者選擇的答案

        //===============================
        // 啟動測驗（載入第 1 題）
        //===============================
        function startTest() {
            currentIndex = 0;
            loadQuestion(currentIndex);
        }

        //===============================
        // 載入題目（含動畫控制 & 自動播放）
        //===============================
        function loadQuestion(index) {
            if (index >= questions.length) {
                finishTest();
                return;
            }

            const panel = document.querySelector(".test-panel"); // 題目外層容器

            // 清除殘留動畫 class（避免干擾）
            panel.classList.remove("slide-in-right", "slide-out-left");

            // 如果不是第一次（index > 0），需要先做舊題「滑出」動畫
            if (index > 0) {
                panel.classList.add("slide-out-left");

                // 監聽舊題動畫結束
                panel.addEventListener("animationend", function handler(e) {
                    if (e.animationName === "slideOutLeft") {
                        // 換題目內容
                        updateQuestionContent(index);

                        // 新題目進場
                        panel.classList.remove("slide-out-left");
                        panel.classList.add("slide-in-right");

                        // 等待新題滑入完成後 → 才開始自動播放音檔
                        panel.addEventListener("animationend", function handler2(e2) {
                            if (e2.animationName === "slideInRight") {
                                setTimeout(() => {
                                    autoPlayAudio();
                                }, 600); // 🚩 延遲 300ms，避免音檔被吃掉
                                panel.removeEventListener("animationend", handler2);
                            }
                        });

                        // 移除舊的監聽器，避免累積
                        panel.removeEventListener("animationend", handler);
                    }
                });
            } else {
                // 第一次載入，不需要滑出動畫，直接進場
                updateQuestionContent(index);
                panel.classList.add("slide-in-right");

                // 等待第一次滑入動畫完成 → 再播放音檔
                panel.addEventListener("animationend", function handler(e) {
                    if (e.animationName === "slideInRight") {
                        setTimeout(() => {
                            autoPlayAudio();
                        }, 600);
                        panel.removeEventListener("animationend", handler);
                    }
                });
            }
        }

        //===============================
        // 更新題目內容（單純換資料）
        //===============================
        function updateQuestionContent(index) {
            selectedAnswer = null; // 清空使用者選擇

            const q = questions[index];
            const img = document.querySelector(".test-image");
            const audio = document.getElementById("audioPlayer");
            const playBtn = document.getElementById("btnPlay");
            const submitBtn = document.querySelector(".submit-btn");
            const optionWrappers = document.querySelectorAll(".option-wrapper");

            // 更新圖片與音檔
            img.src = q.ImagePath;
            audio.src = q.AudioPath;
            audio.load(); //強制重新載入，確保 oncanplaythrough 正確觸發

            // 初始化播放按鈕 → 先設為禁用，等自動播放結束後再啟用
            playBtn.classList.add("disabled");

            // 初始化送出按鈕
            submitBtn.textContent = "送出";
            submitBtn.disabled = true;
            submitBtn.onclick = submitAnswer;

            // 初始化選項按鈕
            const optionTexts = ["A", "B", "C", "D"];
            optionWrappers.forEach((wrap, i) => {
                const btn = wrap.querySelector(".option-btn");
                const transcript = wrap.querySelector(".transcript");

                // 重置狀態
                btn.innerText = optionTexts[i];
                btn.disabled = false;
                btn.className = "option-btn";
                transcript.textContent = "";

                // 綁定點擊事件（單選邏輯）
                btn.onclick = () => {
                    optionWrappers.forEach(w => w.querySelector(".option-btn").classList.remove("selected"));
                    btn.classList.add("selected");
                    selectedAnswer = btn.innerText.trim();
                    submitBtn.disabled = !selectedAnswer;
                };
            });
        }

        //===============================
        // 自動播放（含預熱機制，避免開頭被吃掉）
        //===============================
        function autoPlayAudio() {
            const audio = document.getElementById("audioPlayer");
            const playBtn = document.getElementById("btnPlay");

            playBtn.classList.add("disabled");

            // === 預熱：偷偷播 0.05 秒再停下 ===
            audio.currentTime = 0.09; // 避免 0s bug
            audio.play().then(() => {
                setTimeout(() => {
                    audio.pause();
                    audio.currentTime = 0; // 回到真正開頭

                    // === 正式開始播放 ===
                    setTimeout(() => {
                        audio.play().catch(() => playBtn.classList.remove("disabled"));
                    }, 50); // 預熱後稍等再播
                }, 50); // 播放 0.05 秒後立刻停掉
            }).catch(() => {
                // 如果瀏覽器阻擋自動播放，至少解除禁用按鈕
                playBtn.classList.remove("disabled");
            });

            // === 播放結束 → 解鎖按鈕 ===
            audio.onended = () => playBtn.classList.remove("disabled");
        }

        //===============================
        // 送出答案
        //===============================
        function submitAnswer() {
            if (!selectedAnswer) {
                alert("請先選擇一個答案！");
                return;
            }

            stopAudio();
            document.getElementById("btnPlay").classList.remove("disabled");

            const q = questions[currentIndex];
            const optionWrappers = document.querySelectorAll(".option-wrapper");

            optionWrappers.forEach(wrap => {
                const btn = wrap.querySelector(".option-btn");
                const transcript = wrap.querySelector(".transcript");
                const key = btn.innerText.trim();

                btn.disabled = true;
                btn.classList.add("explained");

                if (key === q.CorrectAnswer) {
                    btn.classList.add("correct");
                }
                if (key === selectedAnswer && selectedAnswer !== q.CorrectAnswer) {
                    btn.classList.add("wrong");
                }

                transcript.textContent = q["Option" + key]; // 顯示逐字稿
            });

            // 🚩 移到迴圈外：只要答對才 +1
            if (selectedAnswer === q.CorrectAnswer) {
                correctCount++;
            }

            updateProgress(currentIndex + 1, questions.length);

            const submitBtn = document.querySelector(".submit-btn");
            if (currentIndex + 1 < questions.length) {
                submitBtn.textContent = "下一題";
                submitBtn.onclick = nextQuestion;
            } else {
                submitBtn.textContent = "下一步"; // 🚩 改成下一步
                submitBtn.onclick = showSummaryPanel; // 🚩 連到結算畫面
            }
        }


        function showSummaryPanel() {
            // 隱藏測驗面板
            document.getElementById("<%= pnlDoTest.ClientID %>").style.display = "none";

            // 顯示結算面板
            const pnl = document.getElementById("pnlSummary");
            pnl.style.display = "block";

            // 清空舊內容
            pnl.innerHTML = "";

            // 計算數據
            const total = questions.length;
            const accuracy = ((correctCount / total) * 100).toFixed(0);
            const diamonds = correctCount; // 每題一顆

            // 動態生成結算內容
            pnl.innerHTML = `
        <h2>恭喜您結束測驗 🎉</h2>
        <p>答對率：${accuracy}%</p>
        <p>答對題數：${correctCount}/${total}</p>
        <p>獲得鑽石：${diamonds} 顆 💎</p>
        <button class="btn-finish" onclick="finishTest()">完成測驗</button>
    `;
        }


        //===============================
        // 下一題（會觸發動畫）
        //===============================
        function nextQuestion() {
            stopAudio();
            currentIndex++;
            loadQuestion(currentIndex);
        }

        //===============================
        // 使用者手動點播放
        //===============================
        function manualPlay() {
            const audio = document.getElementById("audioPlayer");
            const playBtn = document.getElementById("btnPlay");
            if (playBtn.classList.contains("disabled")) return;
            audio.currentTime = 0;
            audio.play();
        }

        //===============================
        // 停止語音播放
        //===============================
        function stopAudio() {
            const audio = document.getElementById("audioPlayer");
            if (audio) {
                audio.pause();
                audio.currentTime = 0;
            }
        }

        //===============================
        // 更新進度條
        //===============================
        function updateProgress(current, total) {
            const percent = (current / total) * 100;
            document.getElementById("progressBar").style.width = percent + "%";
        }

        //===============================
        // 重置測驗狀態
        //===============================
        function resetTest() {
            currentIndex = 0;
            selectedAnswer = null;
            correctCount = 0; // 🚩 在這裡清空，保證每次測驗都是乾淨的
            document.getElementById("progressBar").style.width = "0%";

            const submitBtn = document.querySelector(".submit-btn");
            if (submitBtn) {
                submitBtn.textContent = "送出";
                submitBtn.disabled = true;
                submitBtn.onclick = submitAnswer;
            }

            document.querySelectorAll(".option-wrapper").forEach(wrap => {
                const btn = wrap.querySelector(".option-btn");
                const transcript = wrap.querySelector(".transcript");
                if (btn) {
                    btn.disabled = false;
                    btn.className = "option-btn";
                }
                if (transcript) transcript.textContent = "";
            });
        }

        //===============================
        // 中途離開 → 彈出 Modal
        //===============================
        function showExitModal() {
            document.getElementById("exitTestModal").style.display = "flex";
        }
        function hideExitModal() {
            document.getElementById("exitTestModal").style.display = "none";
        }
        document.getElementById("exitTestModal").onclick = function (e) {
            if (e.target === this) hideExitModal();
        };

        //===============================
        // 中途離開 → abortTest()
        //===============================
        function abortTest() {
            hideExitModal();
            resetTest();
            closeTest();
        }

        //===============================
        // 測驗完成 → finishTest()
        //===============================
        function finishTest() {
            resetTest();
            document.getElementById("pnlSummary").style.display = "none"; // 隱藏結算
        }

        // 🚩 首題音檔預熱機制(此邏輯不屬於任何函數，首次在載入網頁會自己執行)
        window.addEventListener("load", () => {
            const audio = document.getElementById("audioPlayer");
            if (audio) {
                // 指定第一題音檔來源
                audio.src = questions[0].AudioPath;
                audio.load();

                // 稍微等一下再做預熱，避免還沒 ready
                setTimeout(() => {
                    audio.currentTime = 0.1; // 往後跳避免 0s bug
                    audio.play().then(() => {
                        setTimeout(() => {
                            audio.pause();
                            audio.currentTime = 0; // 回到真正開頭
                        }, 50); // 播放 0.05 秒後停掉
                    }).catch(() => {
                        // 瀏覽器若阻擋自動播放，忽略即可
                    });
                }, 300);
            }
        });

        //===============================
        // 關閉測驗 Panel（回主畫面）
        //===============================
        function closeTest() {
            stopAudio();
            document.getElementById("<%= pnlDoTest.ClientID %>").style.display = "none";
            document.getElementById("<%= pnlListeningMenu.ClientID %>").style.display = "block";
            document.getElementById("btnStart").style.display = "block";
            // 🚩 清除所有勾選
            document.querySelectorAll(".topicCheck").forEach(cb => cb.checked = false);
            document.querySelectorAll(".check-box").forEach(box => box.classList.remove("checked"));
            document.getElementById("chkAll").checked = false;
            document.getElementById("chkAllBox").classList.remove("checked");
        }
    </script>
</body>
</html>
