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
        </div>
    </form>

    <!-- 新的測驗 Panel -->
    <asp:Panel ID="pnlDoTest" runat="server" CssClass="panel-container" Style="display: none;">
        <h3 class="text-center">📖 測驗開始</h3>
        <div id="testContent">
            <!-- 這裡之後依您需求生成題目、紫色元素等等 -->
            <p>這裡是測驗內容 (之後會用程式碼載入題目)</p>
        </div>
    </asp:Panel>

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
            // 取得 Dropdown 題數
            let ddl = document.getElementById("<%= ddlQuestionCount.ClientID %>");
            let selectedCount = parseInt(ddl.value);

            // 計算勾選題數總和
            let totalQuestions = 0;
            document.querySelectorAll(".topicCheck:checked").forEach(cb => {
                let topicName = cb.closest(".card").querySelector("h5").innerText;
                totalQuestions += (topicName === "多益測驗") ? 100 : 10;
            });

            // 驗證
            if (totalQuestions < selectedCount) {
                let warningModal = new bootstrap.Modal(document.getElementById("warningModal"));
                warningModal.show();
            } else {
                // ✅ 通過驗證 → 切換 Panel
                document.getElementById("<%= pnlListeningMenu.ClientID %>").style.display = "none";
                document.getElementById("pnlDoTest").style.display = "block";
            }
        });
    </script>
</body>
</html>
