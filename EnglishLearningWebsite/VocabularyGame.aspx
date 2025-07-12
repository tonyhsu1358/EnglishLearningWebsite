<%@ Page Language="C#" AutoEventWireup="true" CodeFile="VocabularyGame.aspx.cs" Inherits="VocabularyGame" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Vocabulary Game</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" />
    <link rel="stylesheet" type="text/css" href="vocabulary-game.css" />
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
                        <img id="volumeIcon" src="images/volume.svg" alt="背景音樂" data-toggle="tooltip" title="調整背景音樂(BGM)" style="width: 24px; height: 24px; vertical-align: middle;" />
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
                                                <button class="altar-button-action"
                                                    style="position: absolute; left: 130px; bottom: 0; width: 180px;"
                                                    onclick="startFirstLearning(window.currentAltarId); return false;">
                                                    攻略
                                                </button>
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

        <!-- ✅ 🔽 新增：單字詳細資訊儀表板（遮罩 + 單字卡） -->
        <div id="pnlWordDetail" class="scroll-overlay" style="display: none;">
            <!-- 小卡浮出中央 -->
            <div class="word-detail-panel">

                <!-- 上方叉叉與愛心收藏 -->
                <div class="scroll-header">
                    <span class="scroll-close" onclick="closeWordDetailPanel()">&times;</span>
                    <img id="favIcon" class="word-fav" src="images/heartwithnocolor.svg" title="加入收藏" />
                </div>

                <!-- 詳細內容 -->
                <div id="pnlWordDetailContent" class="scroll-words-container">
                    <!-- 動態插入 -->
                </div>

                <!-- 導覽列與地點 -->
                <div class="word-detail-footer" style="display: flex; flex-direction: column; justify-content: center; align-items: center; gap: 10px; margin-top: 15px;">

                    <!-- 🔁 上下切換 + 頁碼區（橫向排列 + 分開一點） -->
                    <div style="display: flex; justify-content: center; align-items: center; gap: 20px;">
                        <img id="btnPrevWord" src="images/arrow-pointing-Upward.svg"
                            class="scroll-arrow" title="上一個" />

                        <span id="wordPosition" class="word-position">1 / 1</span>

                        <img id="btnNextWord" src="images/arrow-pointing-Downward.svg"
                            class="scroll-arrow" title="下一個" />
                    </div>

                </div>

                <!-- 📍 顯示單字位置的說明 -->
                <div style="text-align: center; font-size: 14px; color: #555;">
                    <span id="wordLocation">位於：森林？ 祭壇？</span>
                </div>
            </div>

        </div>

        <!-- ✅ 首次學習單字詳細資訊儀表板（複用 scroll-overlay 與 word-detail-panel 風格） -->
        <div id="pnlFirstLearningDetail" class="scroll-overlay" style="display: none;">
            <div class="word-detail-panel">

                <!-- 首次學習 NEW ICON（左上角絕對定位） -->
                <img class="first-learn-new-icon" src="images/new-button.svg" alt="NEW" />

                <!--插入進度條-->
                <div id="firstLearningProgressBarContainer">
                    <div id="firstLearningProgressBarBg">
                        <div id="firstLearningProgressBarFill"></div>
                    </div>
                    <img id="firstLearningProgressTick" src="images/tick-circle.svg" alt="完成" />
                </div>

                <!-- 上方叉叉與愛心收藏 -->
                <div class="scroll-header">
                    <!-- 將 onclick 拿掉，交給 JS 綁定 -->
                    <span id="firstLearnClose" class="scroll-close">&times;</span>
                    <img id="firstLearnFavIcon" class="word-fav" src="images/heartwithnocolor.svg" title="加入收藏" />
                </div>

                <!-- 單字內容（動態插入，結構與舊詳細一致，ID有 firstlearn 前綴）-->
                <div id="pnlFirstLearningWordContent" class="scroll-words-container"></div>

                <!-- 📍 NEXT 長方形按鈕 -->
                <div class="first-learn-next-btn-wrapper">
                    <button id="firstLearnNextBtn" type="button">NEXT</button>
                </div>

            </div>
        </div>

        <!-- 🚩 確認離開提示框直接加 body 最底下即可 -->
        <div id="firstLearnExitModal" class="modal-overlay" style="display: none;">
            <div class="modal-panel">
                <div class="modal-title">你是否確定離開？</div>
                <div class="modal-subtitle">(下次需重新攻略/充能喔)</div>
                <div class="modal-actions">
                    <!-- 🚩 加上 type="button"！ -->
                    <button id="btnFirstLearnExitYes" class="exit-yes" type="button">是，離開課程</button>
                    <button id="btnFirstLearnExitNo" class="exit-no" type="button">否，繼續課程</button>
                </div>
            </div>
        </div>

    </form>
    <!-- 🚩 遊戲介紹提示框 -->
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
        //================================================
        //第一章:顯示100個祭壇且點選祭壇按鈕後會自動記錄
        //================================================
        function showAltarOptions(altarId) {
            window.currentAltarId = altarId;   // ✅ 放這裡才對！每次呼叫都記錄最新ID
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

    <script>
        //================================================
        //第二章:顯示森林儀錶板
        //================================================

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

        // ✅ 單字詳細資訊遮罩點擊關閉
        const detailOverlay = document.getElementById("pnlWordDetail");
        detailOverlay?.addEventListener("click", function (e) {
            if (e.target === detailOverlay) {
                closeWordDetailPanel();
            }
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
        //================================================
        //第三章:顯示轉軸儀表板
        //================================================
        // ✅ 全域單字陣列，供卷軸 & 詳細資訊共用（關鍵）
        let scrollWords = [];

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
                    scrollWords = result.d; // ✅ 存入全域變數，供詳細資訊共用
                    if (scrollWords.length === 0) {
                        container.innerHTML = "<p>⚠ 尚無單字資料。</p>";
                        return;
                    }

                    scrollWords.forEach((w, i) => {
                        const card = document.createElement("div");
                        card.className = "scroll-word-card";

                        const favImg = document.createElement("img");
                        favImg.className = "word-fav";
                        favImg.src = w.is_favorite ? "images/heartwithredcolor.svg" : "images/heartwithnocolor.svg";

                        favImg.onclick = () => {
                            const latest = scrollWords.find(item => item.scroll_id === w.scroll_id);
                            if (!latest) return;

                            const newFav = !latest.is_favorite;
                            latest.is_favorite = newFav;

                            favImg.src = newFav ? "images/heartwithredcolor.svg" : "images/heartwithnocolor.svg";
                            toggleFavorite(w.scroll_id, newFav);
                            if (newFav) showFlyingHeart(favImg);
                        };

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
                        infoIcon.onclick = () => {
                            const forestId = parseInt('<%= Request.QueryString["level"] %>'); // ✅ 從 URL 抓 forestId
                            loadFullScrollWords(forestId, w.scroll_id); // ✅ 改用查整個森林
                        };
                        icons.appendChild(infoIcon);

                        const volIcon = document.createElement("img");
                        volIcon.src = "images/volumewithnocolor.svg?v=" + new Date().getTime();
                        volIcon.title = "播放單字";
                        volIcon.onclick = () => {
                            volIcon.src = "images/volumewithlightcolor.svg";
                            const utter = new SpeechSynthesisUtterance(w.word);
                            utter.lang = "en-US";
                            utter.volume = soundEffectVolume;
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

        // ✅ 收藏切換邏輯（動畫 + 傳送後端 + 切換圖片）
        function toggleFavorite(scrollId, isNowFav) {
            fetch("ScrollService.asmx/UpdateFavorite", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    scrollId: scrollId,
                    isFavorite: isNowFav
                })
            })
                .then(response => response.json())
                .then(data => {
                    console.log("✅ 收藏更新成功：", data.d);
                })
                .catch(err => {
                    console.error("❌ 收藏更新失敗：", err);
                });
        }

        //飛心動畫功能
        function showFlyingHeart(targetIcon) {
            const heart = document.createElement("img");
            heart.src = "images/heartwithredcolor.svg";
            heart.className = "fly-heart";

            const rect = targetIcon.getBoundingClientRect();
            heart.style.left = `${window.scrollX + rect.left + rect.width / 2 - 12}px`;
            heart.style.top = `${window.scrollY + rect.top + rect.height / 2 - 12}px`;

            // 🔁 不是 document.body，而是專用區域！
            const zone = document.getElementById("flyingEffectsZone");
            zone.appendChild(heart);

            void heart.offsetWidth;
            heart.style.animation = "fly-heart 0.8s ease-out forwards";

            setTimeout(() => {
                heart.remove();
            }, 800);
        }
    </script>

    <script>
        //================================================
        //第四章:顯示單字詳細資訊儀錶板
        //================================================
        // ✅ 從整座森林中載入所有單字，並打開詳細資訊儀表板（可用上下箭頭切換 1000 字）
        function loadFullScrollWords(forestId, clickedScrollId) {
            // 🔁 發送 POST 請求給 ScrollService.asmx/GetAllScrollWordsByForest，取得該森林全部單字
            fetch("ScrollService.asmx/GetAllScrollWordsByForest", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ forestId: forestId }) // 傳入森林 ID 作為查詢條件
            })
                .then(res => res.json()) // 轉成 JSON 格式
                .then(result => {
                    speechSynthesis.cancel(); // 取消播放語音

                    // 🔥 把所有亮著的小喇叭 ICON 還原成灰色
                    document.querySelectorAll(".word-icons img[src*='volumewithlightcolor']").forEach(icon => {
                        icon.src = "images/volumewithnocolor.svg";
                    });

                    scrollWords = result.d;
                    const startIndex = scrollWords.findIndex(w => w.scroll_id === clickedScrollId);
                    if (startIndex !== -1) {
                        showWordDetailPanel(scrollWords, startIndex);
                    } else {
                        alert("❌ 找不到該單字位置");
                    }
                });

        }

        //此為顯示詳細單字資訊的方法
        function showWordDetailPanel(words, index) {
            const panel = document.getElementById("pnlWordDetail");
            const container = document.getElementById("pnlWordDetailContent");
            const posLabel = document.getElementById("wordPosition");
            const locLabel = document.getElementById("wordLocation");

            // ✅ 每次都清空容器（不只第一次）
            container.innerHTML = "";

            const card = document.createElement("div");
            card.className = "scroll-word-card";

            const left = document.createElement("div");
            left.className = "word-left";
            left.innerHTML = `
<div class="word-text-wrapper">
    <span id="wordText" class="word-text"></span>
</div>

<span id="pronunciationText" class="info"></span>
<span id="posMeaningText" class="info"></span>

<div id="tenseWrapper">
    <span id="tenseText" class="info"></span>
</div>

<div class="example-container">
    <span id="exampleText"></span>
</div>

<span id="translationText" class="info text-muted"></span>
`;

            card.appendChild(left);
            container.appendChild(card);

            // 插入單字發音 icon（右上角）
            const iconAudio = document.createElement("img");
            iconAudio.id = "iconWordAudio";
            iconAudio.className = "word-audio-icon";
            iconAudio.src = "images/volumewithnocolor.svg";
            card.appendChild(iconAudio);

            // 插入例句發音 icon（例句右側）
            const exampleContainer = left.querySelector(".example-container");
            const sentenceAudio = document.createElement("img");
            sentenceAudio.id = "iconSentenceAudio";
            sentenceAudio.className = "sentence-audio-icon";
            sentenceAudio.src = "images/volumewithnocolor.svg";
            exampleContainer.appendChild(sentenceAudio);

            let currentIndex = index;
            let lastScrollTime = 0; // 放這裡就好
            let isSpeaking = false;
            let hasWheelListener = false;

            // 💡 用來記住展開狀態的變數（true = 展開中，false = 收起）
            let isExpandedGlobally = false;

            // ✅ 更新單字卡片內容
            function updateCard(w) {
                currentIndex = words.findIndex(word => word.scroll_id === w.scroll_id);
                if (currentIndex === -1) return; // 萬一同步出問題就跳掉

                const wordAudio = document.getElementById("iconWordAudio");
                const sentenceAudio = document.getElementById("iconSentenceAudio");

                // 還原音效圖示狀態
                if (wordAudio) wordAudio.src = "images/volumewithnocolor.svg";
                if (sentenceAudio) sentenceAudio.src = "images/volumewithnocolor.svg";

                speechSynthesis.cancel(); // 取消先前語音播放

                fetch("ScrollService.asmx/GetWordDetail", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    credentials: "include",
                    body: JSON.stringify({ scrollId: w.scroll_id })
                })
                    .then(res => res.json())
                    .then(result => {
                        const items = result.d;
                        if (!Array.isArray(items) || items.length === 0) {
                            container.innerHTML = "<p>❌ 無法載入資料</p>";
                            return;
                        }

                        const verbEntry = items.find(i => i.part_of_speech.startsWith("v")) || {};
                        const base = items[0];

                        // 填入基本資訊
                        document.getElementById("wordText").innerText = base.word;
                        document.getElementById("pronunciationText").innerHTML = `<strong>${base.pronunciation}</strong>`;

                        const tenseElem = document.getElementById("tenseText");
                        const past1 = verbEntry.past_tense || "—";
                        const past2 = verbEntry.past_participle || "—";

                        if (past1 === "—" && past2 === "—") {
                            tenseElem.style.display = "none";
                        } else {
                            tenseElem.style.display = "block";
                            tenseElem.innerHTML = `過去式：${past1}<br/>過去分詞：${past2}`;
                        }

                        document.getElementById("exampleText").innerText = base.example_sentence;
                        document.getElementById("translationText").innerText = base.example_translation;
                        locLabel.textContent = base.location_text;
                        posLabel.textContent = `${currentIndex + 1} / ${words.length}`;

                        const meanings = items.map(item =>
                            `<span class="part-of-speech-badge">${item.part_of_speech}</span> ${item.meaning}`
                        ).join("<br/>");
                        document.getElementById("posMeaningText").innerHTML = meanings;

                        // 移除舊的展開區塊
                        const oldExpand = document.getElementById("expandWrapper");
                        if (oldExpand) oldExpand.remove();

                        // 建立展開區塊（同反衍）
                        const tenseWrapper = document.getElementById("tenseWrapper");
                        const expandWrapper = document.createElement("div");
                        expandWrapper.id = "expandWrapper";
                        expandWrapper.style.marginTop = "6px";

                        // 建立展開 icon 圖示
                        const toggleIcon = document.createElement("img");
                        toggleIcon.src = "images/more-svgrepo-com.svg";
                        toggleIcon.className = "expand-toggle";
                        toggleIcon.style.width = "24px";
                        toggleIcon.style.cursor = "pointer";

                        // 根據展開狀態加上 `.expanded` class（旋轉 90 度）
                        if (isExpandedGlobally) {
                            toggleIcon.classList.add("expanded");
                        } else {
                            toggleIcon.classList.remove("expanded");
                        }

                        // 建立展開內容區塊
                        const wordInfoDiv = document.createElement("div");
                        wordInfoDiv.style.marginTop = "8px";
                        wordInfoDiv.style.display = isExpandedGlobally ? "block" : "none";

                        // 建立單行項目（同/反/衍）
                        const createRow = (labelText, content) => {
                            const row = document.createElement("div");
                            const badge = document.createElement("span");
                            badge.className = "part-of-speech-badge";
                            badge.textContent = labelText;

                            const contentSpan = document.createElement("span");
                            contentSpan.textContent = content || "—";
                            contentSpan.style.marginLeft = "6px";

                            row.appendChild(badge);
                            row.appendChild(contentSpan);
                            return row;
                        };

                        // 加入內容區塊
                        wordInfoDiv.appendChild(createRow("同", base.synonym_words));
                        wordInfoDiv.appendChild(createRow("反", base.antonym_words));
                        wordInfoDiv.appendChild(createRow("衍", base.related_info));

                        // 點擊 toggle 展開 / 收合
                        toggleIcon.onclick = () => {
                            isExpandedGlobally = !isExpandedGlobally;
                            wordInfoDiv.style.display = isExpandedGlobally ? "block" : "none";
                            toggleIcon.classList.toggle("expanded", isExpandedGlobally);
                        };

                        // 最後插入 DOM
                        expandWrapper.appendChild(toggleIcon);
                        expandWrapper.appendChild(wordInfoDiv);
                        tenseWrapper.appendChild(expandWrapper);

                        // ❤️ 收藏圖示邏輯
                        const favIcon = document.getElementById("favIcon");
                        favIcon.src = w.is_favorite ? "images/heartwithredcolor.svg" : "images/heartwithnocolor.svg";
                        favIcon.onclick = () => {
                            const newFav = !w.is_favorite;
                            w.is_favorite = newFav;
                            words[currentIndex].is_favorite = newFav;

                            // ✅ 同步 scrollWords 陣列（已經有）
                            const target = scrollWords.find(item => item.scroll_id === w.scroll_id);
                            if (target) target.is_favorite = newFav;

                            // ✅ ✅ ✅ [新增] 同步更新卷軸卡片上的圖示
                            const scrollCards = document.querySelectorAll(".scroll-word-card");
                            scrollCards.forEach(card => {
                                const icon = card.querySelector(".word-fav");
                                const wordLabel = card.querySelector(".word-left .word");
                                if (wordLabel && wordLabel.textContent === w.word && icon) {
                                    icon.src = newFav ? "images/heartwithredcolor.svg" : "images/heartwithnocolor.svg";
                                }
                            });

                            // ✅ 換圖 + 傳後端
                            favIcon.src = newFav ? "images/heartwithredcolor.svg" : "images/heartwithnocolor.svg";
                            toggleFavorite(w.scroll_id, newFav);
                            if (newFav) showFlyingHeart(favIcon);
                        };

                        // 語音：單字
                        wordAudio.onclick = () => {
                            speechSynthesis.cancel();
                            wordAudio.src = "images/volumewithlightcolor.svg";

                            // ❗️補上這一行，修復例句語音亮著的殘留 BUG
                            sentenceAudio.src = "images/volumewithnocolor.svg";

                            const utter = new SpeechSynthesisUtterance(base.word);
                            utter.lang = "en-US";
                            utter.volume = soundEffectVolume;
                            speechSynthesis.speak(utter);
                            utter.onend = () => wordAudio.src = "images/volumewithnocolor.svg";
                        };

                        // 語音：例句
                        sentenceAudio.onclick = () => {
                            speechSynthesis.cancel();
                            sentenceAudio.src = "images/volumewithlightcolor.svg";

                            // ❗️補上這一行，修復單字語音亮著的殘留 BUG
                            wordAudio.src = "images/volumewithnocolor.svg";

                            const utter = new SpeechSynthesisUtterance(base.example_sentence);
                            utter.lang = "en-US";
                            utter.volume = soundEffectVolume;
                            speechSynthesis.speak(utter);
                            utter.onend = () => sentenceAudio.src = "images/volumewithnocolor.svg";
                        };


                        // ✅ 自動播放語音（進入卡片後延遲播放）
                        if (!isSpeaking) {
                            isSpeaking = true;
                            wordAudio.src = "images/volumewithlightcolor.svg";

                            setTimeout(() => {
                                const autoUtter = new SpeechSynthesisUtterance(base.word);
                                autoUtter.lang = "en-US";
                                autoUtter.volume = soundEffectVolume;
                                autoUtter.onend = () => {
                                    wordAudio.src = "images/volumewithnocolor.svg";
                                    isSpeaking = false;
                                };
                                autoUtter.onerror = () => { isSpeaking = false; };
                                speechSynthesis.speak(autoUtter);
                            }, 100);
                        }
                    });
            }

            // ✅ 確保滾輪事件只加一次
            function setupWheelScroll(panel, words, updateCardFunc) {
                if (panel.dataset.hasWheelListener === "true") return;

                panel.addEventListener("wheel", function (e) {
                    const now = Date.now();
                    if (now - lastScrollTime < 250) return;
                    lastScrollTime = now;
                    speechSynthesis.cancel();

                    if (e.deltaY > 0 && currentIndex < words.length - 1) {
                        currentIndex++;
                        updateCardFunc(words[currentIndex]);
                    } else if (e.deltaY < 0 && currentIndex > 0) {
                        currentIndex--;
                        updateCardFunc(words[currentIndex]);
                    }

                    e.preventDefault();
                }, { passive: false });

                panel.dataset.hasWheelListener = "true"; // 標記已加過滾輪事件
            }

            // 初始載入
            updateCard(words[currentIndex]);
            panel.style.display = "flex";
            setupWheelScroll(panel, words, updateCard);

            // 上下切換
            document.getElementById("btnPrevWord").onclick = () => {
                if (currentIndex > 0) {
                    currentIndex--;
                    updateCard(words[currentIndex]);
                }
            };
            document.getElementById("btnNextWord").onclick = () => {
                if (currentIndex < words.length - 1) {
                    currentIndex++;
                    updateCard(words[currentIndex]);
                }
            };
        }

        function closeWordDetailPanel() {
            document.getElementById("pnlWordDetail").style.display = "none";
        }
    </script>

    <script>
        //===========================================================
        // 第五章：首次學習 - 單字詳細資訊卡片渲染函式（含滑動特效）
        //===========================================================
        // ◆ 全域狀態變數
        let firstLearningWords = [];             // 儲存本次祭壇10個單字
        let firstLearningCurrentIndex = 0;       // 當前組的起始索引（0,2,4,...）
        let firstLearningStep = 0;               // 控制流程的步驟：0=展示1, 1=展示2, 2=quiz1, 3=quiz2
        let currentProgressPercent = 0;          // 進度條目前百分比
        let firstLearningIsExpandedGlobally = false; // 控制首次學習卡片的展開狀態

        // ================ 主控流程函式 ================
        function handleFirstLearningStep() {
            const n = firstLearningWords.length;
            const groupStart = firstLearningCurrentIndex;

            // 0: 展示本組第1個單字
            if (firstLearningStep === 0) {
                showFirstLearningPanel(groupStart, true);
                document.getElementById("firstLearnNextBtn").style.display = ""; // 出現 NEXT
                firstLearningStep = 1;
                return;
            }
            // 1: 展示本組第2個單字（如有）
            if (firstLearningStep === 1) {
                if ((groupStart + 1) < n) {
                    showFirstLearningPanel(groupStart + 1, true);
                }
                document.getElementById("firstLearnNextBtn").style.display = ""; // 出現 NEXT
                firstLearningStep = 2;
                return;
            }
            // 2: quiz 第1題
            if (firstLearningStep === 2) {
                renderQuizForWord(firstLearningWords[groupStart], function (isCorrect) {
                    // 答對直接進入 quiz2，答錯顯示 NEXT 按鈕，必須點下才繼續
                    if (isCorrect) {
                        firstLearningStep = 3;
                        handleFirstLearningStep();
                    } else {
                        // 答錯，顯示 NEXT 按鈕，按下再進入 quiz2
                        let btn = document.getElementById("firstLearnNextBtn");
                        btn.style.display = "";
                        btn.onclick = function () {
                            playSoundEffect('/sounds/click-sound.wav');
                            btn.style.display = "none";
                            btn.onclick = null;
                            firstLearningStep = 3;
                            handleFirstLearningStep();
                        };
                    }
                });
                document.getElementById("firstLearnNextBtn").style.display = "none";
                return;
            }
            // 3: quiz 第2題（如有）
            if (firstLearningStep === 3) {
                if ((groupStart + 1) < n) {
                    renderQuizForWord(firstLearningWords[groupStart + 1], function (isCorrect) {
                        // 完成 quiz2
                        if (isCorrect) {
                            nextLearningGroup();
                        } else {
                            let btn = document.getElementById("firstLearnNextBtn");
                            btn.style.display = "";
                            btn.onclick = function () {
                                playSoundEffect('/sounds/click-sound.wav');
                                btn.style.display = "none";
                                btn.onclick = null;
                                nextLearningGroup();
                            };
                        }
                    });
                } else {
                    // 無 quiz2，直接進入下一組
                    nextLearningGroup();
                }
                document.getElementById("firstLearnNextBtn").style.display = "none";
                return;
            }
        }

        // ================ 進入下一組單字學習 ================
        function nextLearningGroup() {
            const n = firstLearningWords.length;
            firstLearningCurrentIndex += 2; // 下一組
            updateProgressBar();
            if (firstLearningCurrentIndex < n) {
                firstLearningStep = 0;
                handleFirstLearningStep();
            } else {
                alert("恭喜完成所有單字學習！");
            }
        }

        // ================ 四選一 quiz 控制 ================
        function renderQuizForWord(wordObj, onFinish) {
            const container = document.getElementById("pnlFirstLearningWordContent");
            container.innerHTML = ""; // 清空內容

            // 產生三個不重複且不與正確答案重複的選項
            const correct = wordObj.meaning;
            let pool = firstLearningWords
                .map(w => w.meaning)
                .filter(m => m && m !== correct);

            let distractors = [];
            while (distractors.length < 3 && pool.length > 0) {
                const idx = Math.floor(Math.random() * pool.length);
                distractors.push(pool[idx]);
                pool.splice(idx, 1);
            }
            // 補足三個選項
            while (distractors.length < 3) {
                distractors.push("（無）");
            }

            // 洗牌
            const options = [correct, ...distractors].sort(() => Math.random() - 0.5);

            // HTML 結構
            let html = `<div class="quiz-panel">
        <div class="quiz-word">${wordObj.word}</div>
        <div class="quiz-options">`;
            options.forEach(opt => {
                html += `<button type="button" class="quiz-option">${opt}</button>`;
            });
            html += `</div></div>`;
            container.innerHTML = html;

            // 隱藏 NEXT 按鈕
            document.getElementById("firstLearnNextBtn").style.display = "none";

            // 綁定選項點擊
            const btns = container.querySelectorAll('.quiz-option');
            btns.forEach(btn => {
                btn.onclick = function () {
                    btns.forEach(b => b.disabled = true);
                    let isCorrect = false;
                    if (btn.innerText === correct) {
                        btn.classList.add('correct');
                        isCorrect = true;
                    } else {
                        btn.classList.add('wrong');
                    }
                    setTimeout(() => {
                        if (typeof onFinish === "function") onFinish(isCorrect);
                    }, 400);
                };
            });
        }

        // =================== 進入首次學習 ===================
        function startFirstLearning(altarId) {
            document.getElementById("pnlFirstLearningDetail").style.display = "flex";
            document.getElementById("pnlFirstLearningWordContent").innerHTML = "";

            fetch("FirstLearningService.asmx/GetFirstLearningWords", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ altarId: altarId })
            })
                .then(res => res.json())
                .then(result => {
                    if (result.d && result.d.length > 0 && result.d[0].error === "NOT_LOGGED_IN") {
                        alert("請先登入！");
                        document.getElementById("pnlFirstLearningDetail").style.display = "none";
                        return;
                    }

                    firstLearningWords = result.d || [];

                    // ======== ✅ 新增 DEBUG 區塊 ========
                    if (firstLearningWords.length > 0) {
                        const debugList = firstLearningWords
                            .map((w, idx) => `${idx + 1}. ${w.word}（${w.part_of_speech || "無詞性"}：${w.meaning || "無釋義"}）`)
                            .join('\n');
                        console.log(`【本次攻略亂數單字（共 ${firstLearningWords.length} 筆）】\n` + debugList);
                    }
                    // ======== ✅ DEBUG 區塊結束 ========

                    if (firstLearningWords.length === 0) {
                        document.getElementById("pnlFirstLearningDetail").style.display = "none";
                        alert("此祭壇沒有單字可學習！");
                        return;
                    }
                    firstLearningCurrentIndex = 0;
                    firstLearningStep = 0;
                    currentProgressPercent = 0;
                    updateProgressBar();
                    handleFirstLearningStep(); // 進入流程主控
                })
                .catch(() => {
                    alert("讀取單字發生錯誤！");
                    document.getElementById("pnlFirstLearningDetail").style.display = "none";
                });
        }

        // =================== 滑動切換動畫公用函式 ===================
        function slideCardSwitch(container, renderContent, isFirst = false) {
            // 1. 取得 NEXT 按鈕
            const nextBtn = document.getElementById("firstLearnNextBtn");
            if (nextBtn) nextBtn.style.visibility = "hidden"; // 切換動畫前先隱藏

            const oldCard = container.firstElementChild;
            if (isFirst || !oldCard) {
                renderContent();
                // 新卡片進場動畫
                const newCard = container.firstElementChild;
                if (newCard) {
                    newCard.classList.add('slide-in-right');
                    newCard.addEventListener('animationend', function handler() {
                        newCard.classList.remove('slide-in-right');
                        newCard.removeEventListener('animationend', handler);

                        // ✅ 動畫結束再顯示 NEXT
                        if (nextBtn) nextBtn.style.visibility = "visible";
                    });
                } else {
                    if (nextBtn) nextBtn.style.visibility = "visible";
                }
                return;
            }
            // 先滑出舊卡片
            oldCard.classList.add('slide-out-left');
            oldCard.addEventListener('animationend', function handler() {
                oldCard.removeEventListener('animationend', handler);
                container.innerHTML = '';
                renderContent();
                // 滑入新卡片
                const newCard = container.firstElementChild;
                if (newCard) {
                    newCard.classList.add('slide-in-right');
                    newCard.addEventListener('animationend', function animClear() {
                        newCard.classList.remove('slide-in-right');
                        newCard.removeEventListener('animationend', animClear);

                        // ✅ 動畫結束再顯示 NEXT
                        if (nextBtn) nextBtn.style.visibility = "visible";
                    });
                } else {
                    if (nextBtn) nextBtn.style.visibility = "visible";
                }
            });
        }

        // =================== 單字內容渲染（核心函式） ===================
        function showFirstLearningPanel(index, isFirst = false) {
            const container = document.getElementById("pnlFirstLearningWordContent");
            slideCardSwitch(container, () => {
                const words = firstLearningWords;
                const w = words[index];
                // 無需再設 firstLearningCurrentIndex，流程已於 handleFirstLearningStep 控管

                container.innerHTML = ""; // 保險

                // 主卡片
                const card = document.createElement("div");
                card.className = "scroll-word-card";

                // 左側內容
                const left = document.createElement("div");
                left.className = "word-left";
                left.innerHTML = `
<div class="word-text-wrapper">
    <span class="word-text">${w.word}</span>
</div>
<span class="info"><strong>${w.pronunciation || ""}</strong></span>
<span class="info">
    ${w.part_of_speech ? `<span class="part-of-speech-badge">${w.part_of_speech}</span> ${w.meaning}` : ""}
</span>
<div id="tenseWrapper">
    ${(w.past_tense || w.past_participle) ?
                        `<span class="info">過去式：${w.past_tense || "—"}<br/>過去分詞：${w.past_participle || "—"}</span>` : ""}
</div>
<div class="example-container">
    <span>${w.example_sentence || ""}</span>
</div>
<span class="info text-muted">${w.example_translation || ""}</span>
`;
                card.appendChild(left);
                container.appendChild(card);

                // 右上角語音 ICON
                const iconAudio = document.createElement("img");
                iconAudio.className = "word-audio-icon";
                iconAudio.src = "images/volumewithnocolor.svg";
                iconAudio.title = "播放單字";
                card.appendChild(iconAudio);

                // 例句語音 ICON
                const exampleContainer = left.querySelector(".example-container");
                const sentenceAudio = document.createElement("img");
                sentenceAudio.className = "sentence-audio-icon";
                sentenceAudio.src = "images/volumewithnocolor.svg";
                sentenceAudio.title = "播放例句";
                exampleContainer.appendChild(sentenceAudio);

                // ===== 展開（同/反/衍） =====
                const tenseWrapper = left.querySelector("#tenseWrapper");
                const expandWrapper = document.createElement("div");
                expandWrapper.style.marginTop = "6px";
                const toggleIcon = document.createElement("img");
                toggleIcon.src = "images/more-svgrepo-com.svg";
                toggleIcon.className = "expand-toggle";
                toggleIcon.width = 24;
                toggleIcon.height = 24;

                // 1. 先建立 wordInfoDiv（不可省略！）
                const wordInfoDiv = document.createElement("div");
                wordInfoDiv.style.marginTop = "8px";
                wordInfoDiv.style.display = firstLearningIsExpandedGlobally ? "block" : "none";
                if (firstLearningIsExpandedGlobally) {
                    toggleIcon.classList.add("expanded");
                } else {
                    toggleIcon.classList.remove("expanded");
                }

                // 2. 補上三個 row
                const createRow = (labelText, content) => {
                    const row = document.createElement("div");
                    const badge = document.createElement("span");
                    badge.className = "part-of-speech-badge";
                    badge.textContent = labelText;
                    const contentSpan = document.createElement("span");
                    contentSpan.textContent = content || "—";
                    contentSpan.style.marginLeft = "6px";
                    row.appendChild(badge);
                    row.appendChild(contentSpan);
                    return row;
                };
                wordInfoDiv.appendChild(createRow("同", w.synonym_words));
                wordInfoDiv.appendChild(createRow("反", w.antonym_words));
                wordInfoDiv.appendChild(createRow("衍", w.related_info));

                // 3. 切換展開狀態
                toggleIcon.onclick = () => {
                    firstLearningIsExpandedGlobally = !firstLearningIsExpandedGlobally;
                    wordInfoDiv.style.display = firstLearningIsExpandedGlobally ? "block" : "none";
                    toggleIcon.classList.toggle("expanded", firstLearningIsExpandedGlobally);
                };

                expandWrapper.appendChild(toggleIcon);
                expandWrapper.appendChild(wordInfoDiv);
                tenseWrapper.appendChild(expandWrapper);

                // ===== 收藏愛心邏輯 =====
                const favIcon = document.getElementById("firstLearnFavIcon");
                favIcon.src = w.is_favorite ? "images/heartwithredcolor.svg" : "images/heartwithnocolor.svg";
                favIcon.onclick = function () {
                    const newFav = !w.is_favorite;
                    w.is_favorite = newFav;
                    favIcon.src = newFav ? "images/heartwithredcolor.svg" : "images/heartwithnocolor.svg";
                    toggleFavorite(w.scroll_id, newFav);
                    if (newFav) showFlyingHeart(favIcon);
                };

                // ===== 語音播放邏輯 =====
                iconAudio.onclick = () => {
                    speechSynthesis.cancel();
                    iconAudio.src = "images/volumewithlightcolor.svg";
                    sentenceAudio.src = "images/volumewithnocolor.svg";
                    const utter = new SpeechSynthesisUtterance(w.word);
                    utter.lang = "en-US";
                    utter.volume = typeof soundEffectVolume === "number" ? soundEffectVolume : 1.0;
                    speechSynthesis.speak(utter);
                    utter.onend = () => iconAudio.src = "images/volumewithnocolor.svg";
                };
                sentenceAudio.onclick = () => {
                    speechSynthesis.cancel();
                    sentenceAudio.src = "images/volumewithlightcolor.svg";
                    iconAudio.src = "images/volumewithnocolor.svg";
                    const utter = new SpeechSynthesisUtterance(w.example_sentence);
                    utter.lang = "en-US";
                    utter.volume = typeof soundEffectVolume === "number" ? soundEffectVolume : 1.0;
                    speechSynthesis.speak(utter);
                    utter.onend = () => sentenceAudio.src = "images/volumewithnocolor.svg";
                };

                // ====== 上下頁箭頭（如有請補id） ======
                if (document.getElementById("btnPrevFirstWord")) {
                    document.getElementById("btnPrevFirstWord").onclick = function () {
                        if (firstLearningCurrentIndex > 0) showFirstLearningPanel(firstLearningCurrentIndex - 1);
                    };
                }
                if (document.getElementById("btnNextFirstWord")) {
                    document.getElementById("btnNextFirstWord").onclick = function () {
                        if (firstLearningCurrentIndex < words.length - 1) showFirstLearningPanel(firstLearningCurrentIndex + 1);
                    };
                }

                // ====== 新增：自動播放單字語音 ======
                setTimeout(() => {
                    iconAudio.src = "images/volumewithlightcolor.svg";
                    const utter = new SpeechSynthesisUtterance(w.word);
                    utter.lang = "en-US";
                    utter.volume = typeof soundEffectVolume === "number" ? soundEffectVolume : 1.0;
                    speechSynthesis.speak(utter);
                    utter.onend = () => iconAudio.src = "images/volumewithnocolor.svg";
                }, 100);
            }, isFirst);
        }

        // =================== 進度條更新（固定 +5%） ===================
        function updateProgressBar() {
            // 每次呼叫進度條就 +5%，但最大不得超過100%
            currentProgressPercent = Math.min(currentProgressPercent + 5, 100);
            document.getElementById("firstLearningProgressBarFill").style.width = currentProgressPercent + "%";
        }

        // ================ 綁定 NEXT 按鈕 ================
        document.addEventListener("DOMContentLoaded", function () {
            document.getElementById("firstLearnNextBtn").onclick = function () {
                playSoundEffect('/sounds/click-sound.wav');
                handleFirstLearningStep();
            };
        });

        //===================若重整或關閉網頁進度條強制歸0===================
        window.addEventListener('beforeunload', function () {
            // 歸零變數
            currentProgressPercent = 0;
            // 歸零畫面
            var bar = document.getElementById('firstLearningProgressBarFill');
            if (bar) bar.style.width = '0%';
        });
    </script>

    <script>
        // 🚩 專屬首次學習關閉 Modal 綁定（含 DEBUG 訊息）
        // 1. 叉叉按鈕點擊 → 開啟離開確認 Modal
        document.getElementById('firstLearnClose').onclick = function () {
            showFirstLearnExitModal();
        };

        // 2. Modal 遮罩點擊 → 關閉 Modal
        document.getElementById('firstLearnExitModal').onclick = function (e) {
            if (e.target === this) this.style.display = "none";
        };

        // 3. 否 → 關閉 Modal
        document.getElementById('btnFirstLearnExitNo').onclick = function () {
            document.getElementById('firstLearnExitModal').style.display = "none";
        };

        // 4. 是 → 關閉 Modal ＋ 關閉首次學習面板（回到主畫面）
        // 必須 type="button"，**永不觸發 form submit**
        document.getElementById('btnFirstLearnExitYes').onclick = function (e) {
            if (e) e.preventDefault();
            // 非同步閉合，保證不卡畫面、不刷新
            setTimeout(function () {
                // 關閉各面板與遮罩
                document.getElementById('firstLearnExitModal').style.display = "none";
                document.getElementById('pnlFirstLearningDetail').style.display = "none";
                document.getElementById('pnlAltarOptions').style.display = "none";
                document.getElementById('altarOptionsOverlay').style.display = "none";
                // 進度條歸零
                currentProgressPercent = 0;
                document.getElementById('firstLearningProgressBarFill').style.width = "0%";
            }, 0);
        };

        // 5. 專屬函式，呼叫即彈出 Modal
        function showFirstLearnExitModal() {
            document.getElementById('firstLearnExitModal').style.display = "flex";
        }
    </script>

    <div id="flyingEffectsZone" style="position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; pointer-events: none; z-index: 99999;"></div>
</body>
</html>
