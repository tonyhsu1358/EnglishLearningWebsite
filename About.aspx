<%@ Page Language="C#" AutoEventWireup="true" CodeFile="About.aspx.cs" Inherits="About" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>關於網站 | English Learning</title>

    <!-- Bootstrap 5 & FontAwesome -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" />

    <style>
        /* ✅ 調整頁面，確保內容不超出視窗 */
        body {
            font-family: 'Arial', sans-serif;
            background: url('images/macbookbackground.jpg') no-repeat center center fixed;
            background-size: cover;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }


        /* ✅ 限制容器最大高度，超出時允許滾動 */
        .container {
            max-width: 800px;
            max-height: 80vh; /* 🔹 限制最大高度，避免超出螢幕 */
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
            overflow-y: auto; /* ✅ 內容過多時允許內部滾動 */
        }

        h1 {
            color: #002B5B;
            font-weight: bold;
        }

        h2 {
            color: #004080;
            font-size: 22px;
            margin-top: 20px;
        }

        p {
            font-size: 16px;
            line-height: 1.6;
            color: #333;
        }

        .highlight-link {
            color: #FF6600; /* 鮮豔橘 */
            font-weight: bold;
            text-decoration: none; /* 移除底線 */
        }

            .highlight-link:hover {
                color: #CC4400; /* 滑鼠懸停時變深橘 */
                text-decoration: underline;
            }


        /* ✅ 美化回首頁按鈕 */
        .btn-home {
            display: block;
            width: 200px;
            margin: 20px auto 0;
            background: #B0A8B9; /* 莫蘭迪色系 */
            color: white;
            font-weight: bold;
            padding: 12px;
            border-radius: 25px;
            transition: all 0.3s ease-in-out;
            text-align: center;
            border: none;
            box-shadow: 0 3px 6px rgba(0, 0, 0, 0.2);
        }

            .btn-home:hover {
                background: #9E9B9B;
                transform: scale(1.05);
            }
    </style>

</head>

<body>
    <form id="form1" runat="server">
        <div class="container">
            <h1 class="text-center">
                <i class="fa-solid fa-book-open"></i>關於本網站
            </h1>

            <h2>📌 開發者的話</h2>
            <p>
                隨著 <a href="https://www.ey.gov.tw/Page/5A8A0CB5B41DA11E/45a00f6b-b3b2-4306-9fcd-9904f9ce0d77"
                    target="_blank" class="highlight-link">2030 雙語國家政策</a> 的推行，英語學習已成為台灣社會的重要趨勢。
    然而，許多學習者在傳統的學習方式中遇到了挑戰，例如記憶單字困難、缺乏口說與聽力練習的機會，或是找不到適合自己的學習節奏。
    因此，我決定開發這個網站，希望透過互動式學習與個人化內容，幫助更多人輕鬆提升英語能力。
            </p>


            <h2>🌟 我們的願景</h2>
            <p>
                本網站的設計理念是讓英語學習更有效率、更有趣，不論是學生、上班族，甚至是對英語感興趣的任何人，
                都能夠透過這個平台找到適合自己的學習方式。我們相信，只要擁有良好的學習工具，每個人都可以在英語學習上取得進步，並更自信地與世界接軌。
            </p>

            <h2>🔹 網站特色</h2>
            <ul>
                <li>📖 <strong>多元學習工具：</strong> 提供單字記憶、聽力測驗、互動遊戲等功能，讓學習不再枯燥。</li>
                <li>🎯 <strong>個人化學習：</strong> 根據使用者的學習進度與需求，推薦適合的課程內容。</li>
                <li>🏆 <strong>挑戰與獎勵：</strong> 透過體力與鑽石機制，鼓勵使用者每日學習並持續進步。</li>
                <li>📱 <strong>友善的使用介面：</strong> 簡潔直觀的設計，讓不同年齡層的學習者都能輕鬆上手。</li>
            </ul>

            <h2>🎯 結語</h2>
            <p>
                這不僅是一個英語學習平台，更是一個陪伴學習者成長的夥伴。我希望透過這個網站，讓大家在學習英語的路上感受到成就感，
                並享受學習的樂趣。讓我們一起迎向雙語時代，開啟更廣闊的未來！
            </p>

            <!-- 🔹 回首頁按鈕 -->
            <asp:Button ID="btnHome" runat="server" CssClass="btn-home" Text="🏠 回首頁" OnClick="btnHome_Click" />
        </div>
    </form>
</body>
</html>
