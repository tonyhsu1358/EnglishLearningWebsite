<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeFile="AISelection.aspx.cs" Inherits="AISelection" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>AI 智慧英文實力診斷</title>

    <!-- Bootstrap 5 & FontAwesome -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" />

    <style>

        /* ✅ 背景與主要內容設定 */
        body {
            font-family: 'Arial', sans-serif;
            background: url('images/woodbackground.jpg') no-repeat center center fixed;
            background-size: cover;
            display: flex;
            justify-content: center;
            align-items: flex-start; /* 讓內容從上開始對齊 */
            overflow-y: auto; /* 確保可滾動 */
        }

            body::before {
                content: "";
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100vh; /* ✅ 這裡改成 100%，確保隨內容變長 */
                background: rgba(255, 255, 255, 0.4); /* ✅ 透明度維持 40% */
                z-index: 0;
            }

        /* ✅ 修正 .container 只保留一個設定，確保寬度一致 */
        .container {
            position: relative;
            z-index: 1050; /* 確保 `.container` 在 `custom-backdrop` 之上 */
            max-width: 1100px !important; /* 🔥 強制覆蓋 Bootstrap 預設寬度 */
            width: 90% !important; /* 🔥 讓它自適應不同螢幕 */
            padding: 40px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
        }

        /* ✅ 標題與 Info Icon */
        .title-container {
            display: flex;
            align-items: center; /* ✅ 確保圖標與標題垂直對齊 */
            align-items: center;
            justify-content: center;
            gap: 8px; /* ✅ 增加標題與 Info 圖標間距 */
        }

        /* ✅ 確保 h2 沒有不必要的 margin，並讓它與 Info 圖標對齊 */
        h2 {
            font-weight: bold;
            color: #333;
            margin: 0; /* ✅ 取消 margin，避免影響對齊 */
            display: flex;
            align-items: center; /* ✅ 確保 h2 內的內容垂直居中 */
        }

        /* ✅ Info 圖標 */
        .info-icon {
            font-size: 27px;
            cursor: pointer;
            color: #6D5F57;
            transition: 0.3s ease-in-out;
        }

            .info-icon:hover {
                color: #8D7E77;
                transform: scale(1.2);
            }

        /* ✅ 美化 Modal */
        .custom-modal {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            padding: 20px;
        }

            /* ✅ Modal 標題樣式 */
            .custom-modal .modal-header {
                border-bottom: 2px solid #ddd;
                padding-bottom: 10px;
            }

            /* ✅ 美化 Modal 內容 */
            .custom-modal .modal-body {
                font-size: 18px;
                color: #444;
                line-height: 1.8;
            }

        /* ✅ 美化列表 */
        .custom-list {
            list-style: none;
            padding-left: 0;
        }

            .custom-list li {
                font-size: 18px;
                margin-bottom: 8px;
                display: flex;
                align-items: center;
            }

                .custom-list li i {
                    margin-right: 10px;
                }

        /* ✅ 美化警告框 */
        .alert-danger {
            font-size: 18px;
            font-weight: bold;
            padding: 12px;
            border-radius: 8px;
        }


        /* ✅ 隱藏 Bootstrap 預設的 `modal-backdrop` */
        .modal-backdrop {
            display: none !important;
        }

        /* ✅ 讓 `.container` 外的部分變灰 */
        .custom-backdrop {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100%;
            background: rgba(0, 0, 0, 0.5); /* 半透明灰色 */
            z-index: 1040; /* 讓它在 `.container` 之下 */
            display: none; /* 預設隱藏 */
        }

            /* ✅ 顯示 `custom-backdrop` */
            .custom-backdrop.show {
                display: block;
            }

        label {
            font-weight: bold;
            color: #555;
            margin-top: 12px;
            display: block;
            text-align: left;
        }

        /* ✅ 下拉選單樣式 */
        select {
            width: 100%;
            padding: 12px;
            border-radius: 8px;
            border: 1px solid #ccc;
            background-color: #F5F5F5;
            font-size: 16px;
            transition: all 0.3s;
        }

            select:hover, select:focus {
                border-color: #8D7E77;
                background: #EAE7DC;
                outline: none;
            }

        /* ✅ 核取方塊（Checkbox）區塊 */
        .checkbox-container {
            display: grid;
            grid-template-columns: repeat(3, 1fr); /* ✅ 設定為 3 欄 */
            gap: 10px 15px; /* ✅ 增加間距 */
            text-align: left;
            margin-top: 10px;
        }

        .checkbox-item {
            display: flex;
            align-items: center;
            font-size: 16px; /* ✅ 讓文字大小統一 */
        }

            .checkbox-item input[type="checkbox"] {
                width: 18px;
                height: 18px;
                margin-right: 8px; /* ✅ 讓 Checkbox 與文字有間距 */
            }

        /* ✅ 送出按鈕 */
        .btn-primary {
            background: #8D7E77;
            border: none;
            padding: 12px 20px;
            border-radius: 25px;
            font-size: 18px;
            font-weight: bold;
            color: white;
            transition: all 0.3s ease-in-out;
            width: 100%;
            margin-top: 20px; /* ✅ 讓按鈕與選項區分開 */
        }


            .btn-primary:hover {
                background: #6D5F57;
                transform: translateY(-2px);
                box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
            }

        /* ✅ 送出按鈕 */
        .btn-primary, .btn-success {
            width: 100%;
            margin-top: 20px;
        }

        /* ✅ 自訂「禁用狀態」的按鈕顏色 */
        .custom-disabled-btn:disabled {
            background-color: #B0AFAF !important; /* 莫蘭迪灰色 */
            border-color: #A5A5A5 !important;
            color: #E3E3E3 !important;
            cursor: not-allowed;
            opacity: 0.7;
        }

        /* ✅ 確保問題區塊不會過於擠在一起 */
        .question-container {
            width: 100%;
            text-align: left;
        }

        /* ✅ 讓每個題目區塊有更好的佈局 */
        .question-style {
            background: #f8f9fa;
            padding: 15px;
            margin-bottom: 10px;
            border-radius: 8px;
            border: 1px solid #ddd;
            width: 100%;
        }

        /* ✅ 讓選項垂直排列 */
        .radio-options {
            display: flex;
            flex-direction: column;
            gap: 10px; /* 讓選項之間的間距適中 */
        }

            .radio-options label {
                display: inline-flex !important; /* ✅ 保持 input & text 在同一行 */
                align-items: center !important; /* ✅ 讓按鈕與文字對齊 */
                gap: 6px !important; /* ✅ 設定按鈕與文字之間的距離 */
                width: fit-content !important; /* ✅ 避免 label 撐開 */
                white-space: nowrap; /* ✅ 防止 label 內容自動換行 */
            }

            .radio-options input[type="radio"] {
                width: 18px !important;
                height: 18px !important;
                flex-shrink: 0;
                margin: 0 !important;
                padding: 0 !important;
                vertical-align: middle !important; /* ✅ 確保與文字對齊 */
            }

        /* ✅ 提交答案按鈕 */
        .btn-success {
            background-color: #A5A5A5; /* 莫蘭迪灰色背景 */
            border: 1px solid #999; /* 淺灰色邊框 */
            color: #F0F0F0; /* 淺灰色文字 */
            padding: 12px 20px;
            border-radius: 25px;
            font-size: 18px;
            font-weight: bold;
            transition: all 0.3s ease-in-out;
            width: 100%;
            margin-top: 20px;
        }

            .btn-success:hover {
                background-color: #999; /* 懸停時顏色略深 */
                transform: translateY(-2px);
                box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
            }


        /* 🔥 強制覆蓋 Bootstrap `.container`，確保它真的變寬 */
        .container, .container-fluid {
            position: relative;
            z-index: 1050;
            max-width: 1100px !important; /* ✅ 讓 `.container` 真的變寬 */
            width: 90vw !important; /* ✅ 讓它根據視窗大小變化 */
            padding: 40px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
        }
    </style>

</head>

<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfPageUnloaded" runat="server" Value="false" />
        <div class="container">
            <!-- ✅ 標題與 Info Icon 放在同一行 -->
            <div class="title-container">
                <h2><i class="fa-solid fa-robot"></i>AI 英文測驗</h2>
                <i class="fa-solid fa-circle-info info-icon" data-bs-toggle="modal" data-bs-target="#infoModal"></i>
            </div>
            <!-- ✅ Info Modal (正中央彈出) -->
            <!-- ✅ 美化後的 Info Modal -->
            <div class="modal fade" id="infoModal" tabindex="-1" aria-labelledby="infoModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered modal-lg">
                    <!-- ✅ 修改成較大的寬度 -->
                    <div class="modal-content custom-modal">
                        <!-- ✅ 加上 class 以便美化 -->
                        <div class="modal-header">
                            <h3 class="modal-title" id="infoModalLabel">
                                <i class="fa-solid fa-circle-info text-primary"></i>測驗說明
                            </h3>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <p><strong>本測驗會根據你的選擇，由AI助手自動生成適合你的多益測驗題目，協助您分析英文實力！</strong></p>
                            <ul class="custom-list">
                                <li><i class="fa-solid fa-check-circle text-success"></i>📌 <strong>題目數量</strong>：可選擇 5-30 題。</li>
                                <li><i class="fa-solid fa-brain text-warning"></i>📌 <strong>難度選擇</strong>：包含 普通、中等、高級、進階。</li>
                                <li><i class="fa-solid fa-list-ul text-info"></i>📌 <strong>主題分類</strong>：可多選，例如 美食、科技、運動等。</li>
                            </ul>
                            <div class="alert alert-danger text-center mt-3">
                                <i class="fa-solid fa-triangle-exclamation"></i><strong>⚠️ 選擇「任何」時，系統會隨機出題！</strong>
                            </div>
                        </div>
                    </div>
                </div>
            </div>


            <!-- 選擇題目數量 -->
            <label>選擇題目數量：</label>
            <asp:DropDownList ID="ddlQuestionCount" runat="server" CssClass="form-select">
                <asp:ListItem Text="5 題" Value="5"></asp:ListItem>
                <asp:ListItem Text="10 題" Value="10" Selected="True"></asp:ListItem>
                <asp:ListItem Text="15 題" Value="15"></asp:ListItem>
                <asp:ListItem Text="20 題" Value="20"></asp:ListItem>
                <asp:ListItem Text="25 題" Value="25"></asp:ListItem>
                <asp:ListItem Text="30 題" Value="30"></asp:ListItem>
            </asp:DropDownList>

            <!-- 選擇難度 -->
            <label>選擇難度：</label>
            <asp:DropDownList ID="ddlDifficulty" runat="server" CssClass="form-select">
                <asp:ListItem Text="普通" Value="beginner"></asp:ListItem>
                <asp:ListItem Text="中等" Value="intermediate"></asp:ListItem>
                <asp:ListItem Text="高級" Value="advanced"></asp:ListItem>
                <asp:ListItem Text="進階" Value="expert"></asp:ListItem>
            </asp:DropDownList>

            <!-- ✅ 選擇主題 -->
            <label>選擇主題：</label>
            <div class="checkbox-container">
                <div class="checkbox-item">
                    <input type="checkbox" name="topics" value="any" onclick="updateSelectedTopics()" />
                    任何
                </div>
                <div class="checkbox-item">
                    <input type="checkbox" name="topics" value="aviation" onclick="updateSelectedTopics()" />
                    航空
                </div>
                <div class="checkbox-item">
                    <input type="checkbox" name="topics" value="environment" onclick="updateSelectedTopics()" />
                    環境
                </div>
                <div class="checkbox-item">
                    <input type="checkbox" name="topics" value="food" onclick="updateSelectedTopics()" />
                    美食
                </div>
                <div class="checkbox-item">
                    <input type="checkbox" name="topics" value="business" onclick="updateSelectedTopics()" />
                    商業
                </div>
                <div class="checkbox-item">
                    <input type="checkbox" name="topics" value="technology" onclick="updateSelectedTopics()" />
                    科技
                </div>
                <div class="checkbox-item">
                    <input type="checkbox" name="topics" value="science" onclick="updateSelectedTopics()" />
                    科學
                </div>
                <div class="checkbox-item">
                    <input type="checkbox" name="topics" value="sports" onclick="updateSelectedTopics()" />
                    運動
                </div>
                <div class="checkbox-item">
                    <input type="checkbox" name="topics" value="history" onclick="updateSelectedTopics()" />
                    歷史
                </div>
                <div class="checkbox-item">
                    <input type="checkbox" name="topics" value="health" onclick="updateSelectedTopics()" />
                    健康
                </div>
                <div class="checkbox-item">
                    <input type="checkbox" name="topics" value="fashion" onclick="updateSelectedTopics()" />
                    時尚
                </div>
                <div class="checkbox-item">
                    <input type="checkbox" name="topics" value="politics" onclick="updateSelectedTopics()" />
                    政治
                </div>
            </div>

            <!-- ✅ 隱藏欄位，用來存放勾選的主題 -->
            <asp:HiddenField ID="hfSelectedTopics" runat="server" />

            <!-- 開始測驗按鈕，增加 Tooltip -->
            <asp:Button ID="btnAskAI" runat="server" CssClass="btn btn-primary custom-disabled-btn"
                Text="開始測驗" OnClick="btnAskAI_Click"
                data-bs-toggle="tooltip" data-bs-placement="top"
                title="按下後請勿重複點選，稍等AI生成題目，以免影響作答結果" />

            <!-- ✅ 顯示 AI 生成的題目 -->
            <div id="questionList" class="question-container">
                <asp:Panel ID="pnlQuestions" runat="server" CssClass="question-style">
                    <asp:RadioButtonList ID="RadioButtonList" runat="server" CssClass="radio-options"
                        RepeatLayout="Table" RepeatDirection="Vertical">
                    </asp:RadioButtonList>
                </asp:Panel>
            </div>

            <!-- 提交答案 -->
            <asp:Button ID="btnSubmit" runat="server" CssClass="btn btn-success"
                Text="提交答案" OnClick="btnSubmit_Click" Visible="false" />
        </div>
    </form>
    <!-- ✅ Bootstrap 5 JS (支援 Modal 功能) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var infoModal = document.getElementById('infoModal');
            var backdrop = document.createElement('div'); // 自訂 backdrop
            backdrop.classList.add('custom-backdrop');
            document.body.appendChild(backdrop); // 加到 body

            // ✅ 顯示 `custom-backdrop`
            infoModal.addEventListener('show.bs.modal', function () {
                backdrop.classList.add('show');
            });

            // ✅ 隱藏 `custom-backdrop`
            infoModal.addEventListener('hidden.bs.modal', function () {
                backdrop.classList.remove('show');
            });

            // ✅ 監聽 `X` 按鈕點擊，關閉 `Modal`
            document.querySelector(".btn-close").addEventListener("click", function () {
                var modal = bootstrap.Modal.getInstance(infoModal);
                modal.hide();
            });

            // ✅ 點擊 `backdrop` 也關閉 `Modal`
            backdrop.addEventListener("click", function () {
                var modal = bootstrap.Modal.getInstance(infoModal);
                modal.hide();
            });

            document.addEventListener("DOMContentLoaded", function () {
                var btnAskAI = document.getElementById('<%= btnAskAI.ClientID %>');

                if (btnAskAI) {
                    var observer = new MutationObserver(function () {
                        if (btnAskAI.disabled) {
                            btnAskAI.classList.add("custom-disabled-btn");
                        } else {
                            btnAskAI.classList.remove("custom-disabled-btn");
                        }
                    });

                    observer.observe(btnAskAI, { attributes: true, attributeFilter: ["disabled"] });
                }
            });

            // ✅ 處理開始測驗按鈕，確保畫面不會滾動到底部
            var btnAskAI = document.getElementById('<%= btnAskAI.ClientID %>'); // 取得開始測驗按鈕
            var questionList = document.getElementById('questionList'); // 取得題目區塊

            if (btnAskAI) {
                btnAskAI.addEventListener("click", function () {
                    var currentScroll = window.scrollY; // ✅ 記錄滾動位置

                    setTimeout(function () {
                        window.scrollTo({
                            top: currentScroll, // ✅ 回到原本的位置
                            behavior: 'instant' // ✅ 立即回復，避免畫面跳動
                        });
                    }, 100); // ✅ 延遲 100 毫秒確保 UI 更新
                });
            }

            // ✅ 確保畫面在題目載入後不會滾動到底部
            var observer = new MutationObserver(function () {
                var currentScroll = window.scrollY; // 記錄當前滾動位置
                setTimeout(function () {
                    window.scrollTo({
                        top: currentScroll, // ✅ 強制回到原來的位置
                        behavior: 'instant' // ✅ 立即回復
                    });
                }, 50); // ✅ 當內容變動時，短暫延遲後滾回原位
            });

            // ✅ 監聽 `questionList` 區塊的變化
            if (questionList) {
                observer.observe(questionList, { childList: true, subtree: true });
            }
        });

        // ✅ 更新選擇的主題
        function updateSelectedTopics() {
            var selectedTopics = [];
            var checkboxes = document.querySelectorAll("input[name='topics']:checked");
            checkboxes.forEach(function (checkbox) {
                selectedTopics.push(checkbox.value);
            });

            // ✅ 更新 HiddenField 的值
            document.getElementById('<%= hfSelectedTopics.ClientID %>').value = selectedTopics.join(",");
        }

        document.addEventListener("DOMContentLoaded", function () {
            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        });
    </script>
    <script type="text/javascript">
        window.onbeforeunload = function () {
            document.getElementById('<%= hfPageUnloaded.ClientID %>').value = 'true';
        };
    </script>
</body>
</html>
