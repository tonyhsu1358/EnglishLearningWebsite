<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EliteChannels.aspx.cs" Inherits="EliteChannels" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="zh">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>英文教學優質頻道</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }

        .container {
            width: 80%;
            margin: 20px auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            text-align: center;
        }

        h1 {
            color: #333;
            margin-bottom: 30px;
        }

        .channel-list {
            list-style: none;
            padding: 0;
        }

        .channel-list li {
            background: #fff;
            padding: 20px;
            margin: 20px 0;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.15);
            text-align: center;
        }

        .channel-list img {
            width: 100%;
            max-width: 600px;
            height: auto;
            border-radius: 12px;
            margin-bottom: 15px;
        }

        .channel-title {
            font-size: 1.4em;
            font-weight: bold;
            color: #007BFF;
            text-decoration: none;
        }

        .channel-desc {
            margin-top: 10px;
            font-size: 1em;
            color: #555;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h1>📚 英文教學優質頻道</h1>
            <ul class="channel-list">
                <li>
                    <a href="https://www.youtube.com/user/bbclearningenglish" target="_blank">
                        <img src="images/bbc.png" alt="BBC Learning English" />
                    </a>
                    <a class="channel-title" href="https://www.youtube.com/user/bbclearningenglish" target="_blank">BBC Learning English</a>
                    <p class="channel-desc">由英國廣播公司推出，提供標準英語教學影片，包括新聞英語、會話技巧、文法等，是學習英式英語的絕佳資源。</p>
                </li>
                <li>
                    <a href="https://www.youtube.com/user/React" target="_blank">
                        <img src="images/peopleVSfood.png" alt="People Vs Food" />
                    </a>
                    <a class="channel-title" href="https://www.youtube.com/user/React" target="_blank">People Vs Food</a>
                    <p class="channel-desc">主要邀請各年齡階層的人觀看各式影片並給予反應，語言自然，適合學生活用語。</p>
                </li>
                <li>
                    <a href="https://www.youtube.com/channel/UCNhX3WQEkraW3VHPyup8jkQ" target="_blank">
                        <img src="images/LangFocus.png" alt="Langfocus" />
                    </a>
                    <a class="channel-title" href="https://www.youtube.com/channel/UCNhX3WQEkraW3VHPyup8jkQ" target="_blank">Langfocus</a>
                    <p class="channel-desc">Paul 解釋語言學概念非常清晰，適合提升聽力理解。</p>
                </li>
                <li>
                    <a href="https://www.youtube.com/channel/UCLNoXf8gq6vhwsrYp-l0J-Q" target="_blank">
                        <img src="images/xiaoman.png" alt="小馬在紐約" />
                    </a>
                    <a class="channel-title" href="https://www.youtube.com/channel/UCLNoXf8gq6vhwsrYp-l0J-Q" target="_blank">小馬在紐約</a>
                    <p class="channel-desc">美籍主持人分享生活與試吃內容，影片附中英字幕。</p>
                </li>
                <li>
                    <a href="https://www.youtube.com/channel/UCO8GewbsHFFmJn4kLLq1WXQ" target="_blank">
                        <img src="images/maaaxter.png" alt="Maaaxter English 麦琪英文" />
                    </a>
                    <a class="channel-title" href="https://www.youtube.com/channel/UCO8GewbsHFFmJn4kLLq1WXQ" target="_blank">Maaaxter English 麦琪英文</a>
                    <p class="channel-desc">美籍華人主講，分享美式英語與美國文化生活。</p>
                </li>
                <li>
                    <a href="https://www.youtube.com/user/GeographyNow" target="_blank">
                        <img src="images/Grography.png" alt="Geography Now" />
                    </a>
                    <a class="channel-title" href="https://www.youtube.com/user/GeographyNow" target="_blank">Geography Now</a>
                    <p class="channel-desc">介紹世界各國地理與文化，主持人風格幽默輕鬆。</p>
                </li>
                <li>
                    <a href="https://www.youtube.com/channel/UCKgpamMlm872zkGDcBJHYDg" target="_blank">
                        <img src="images/LearnEnglishWithTVSeries.png" alt="Learn English With TV Series" />
                    </a>
                    <a class="channel-title" href="https://www.youtube.com/channel/UCKgpamMlm872zkGDcBJHYDg" target="_blank">Learn English With TV Series</a>
                    <p class="channel-desc">以影集片段教英文，並附益智複習活動，非常實用。</p>
                </li>
                <li>
                    <a href="https://www.youtube.com/channel/UCz4tgANd4yy8Oe0iXCdSWfA" target="_blank">
                        <img src="images/English with Lucy.png" alt="English with Lucy" />
                    </a>
                    <a class="channel-title" href="https://www.youtube.com/channel/UCz4tgANd4yy8Oe0iXCdSWfA" target="_blank">English with Lucy</a>
                    <p class="channel-desc">來自英國的 Lucy 教授正統英式英文，口音標準、內容清晰。</p>
                </li>
                <li>
                    <a href="https://www.youtube.com/user/TEDtalksDirector" target="_blank">
                        <img src="images/TED.png" alt="TED" />
                    </a>
                    <a class="channel-title" href="https://www.youtube.com/user/TEDtalksDirector" target="_blank">TED</a>
                    <p class="channel-desc">世界知名演講平台，幫助提升聽力與專業英文詞彙。</p>
                </li>
                <li>
                    <a href="https://www.youtube.com/user/engvidenglish" target="_blank">
                        <img src="images/engvid.png" alt="EngVid" />
                    </a>
                    <a class="channel-title" href="https://www.youtube.com/user/engvidenglish" target="_blank">EngVid</a>
                    <p class="channel-desc">多位專業英文教師製作，涵蓋文法、會話與考試準備。</p>
                </li>
                <li>
                    <a href="https://www.youtube.com/user/LearnEnglishESL" target="_blank">
                        <img src="images/esl.png" alt="Learn English with Emma" />
                    </a>
                    <a class="channel-title" href="https://www.youtube.com/user/LearnEnglishESL" target="_blank">Learn English with Emma</a>
                    <p class="channel-desc">Emma 老師風格溫柔，教學清楚易懂，適合初中級學習者。</p>
                </li>
                <li>
                    <a href="https://www.youtube.com/@rayduenglish" target="_blank">
                        <img src="images/rayduenglish.png" alt="阿滴英文" />
                    </a>
                    <a class="channel-title" href="https://www.youtube.com/@rayduenglish" target="_blank">阿滴英文</a>
                    <p class="channel-desc">台灣熱門頻道，內容生活化、輕鬆有趣，是提升英文的好幫手。</p>
                </li>
            </ul>
        </div>
    </form>
</body>
</html>
