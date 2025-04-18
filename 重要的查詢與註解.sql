USE EnglishLearningWebsite; -- 確保使用正確的資料庫
SELECT 
    fk.name AS 外來鍵名稱,
    tp.name AS 來源資料表,
    cp.name AS 來源欄位,
    tr.name AS 參照資料表,
    cr.name AS 參照欄位
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.tables AS tp ON fkc.parent_object_id = tp.object_id
INNER JOIN sys.columns AS cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN sys.tables AS tr ON fkc.referenced_object_id = tr.object_id
INNER JOIN sys.columns AS cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
WHERE tp.name IN ('Users','UserResources','AI_GeneratedQuestions', 'AI_UserAnswers','magic_forest','magic_altar','ancient_scrolls','user_favorite_words');



USE EnglishLearningWebsite;
SELECT * FROM Users;
SELECT * FROM UserResources;
SELECT * FROM AI_GeneratedQuestions ORDER BY QuestionID DESC;
SELECT * FROM AI_UserAnswers ORDER BY QuestionID DESC ;
SELECT * FROM Users;
SELECT * FROM magic_forest;
SELECT * FROM magic_altar;
SELECT * FROM ancient_scrolls WHERE priority_level = 1
SELECT * FROM user_altar_progress;
SELECT * FROM trial_records;
SELECT * FROM user_favorite_words;  

USE EnglishLearningWebsite;
--================================
--========1.使用者資料邏輯========
--================================
--1.1 使用者基本資料表，在註冊頁面建立完帳號後儲存用戶的個資於此
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,              -- 使用者唯一識別碼，自動遞增
    username NVARCHAR(50),                              -- 使用者帳號
    name NVARCHAR(50),                                  -- 使用者姓名
    id_email NVARCHAR(100),                             -- 使用者電子郵件
    password NVARCHAR(MAX),                             -- 使用者加密後的密碼
    phoneNumber NVARCHAR(20),                           -- 使用者電話號碼
    gender NVARCHAR(10),                                -- 性別
    nationality NVARCHAR(50),                           -- 國籍
    birthday DATE,                                      -- 出生日期
    created_at DATETIME                                 -- 註冊時間
);
--1.2 使用者資源表，用於紀錄用戶持有的魔法能量、魔法鑽石、獲得時間等等
CREATE TABLE UserResources (
    resource_id INT IDENTITY(1,1) PRIMARY KEY,          -- 資源紀錄唯一識別碼，自動遞增
    user_id INT,                                        -- 對應使用者 ID
    energy INT,                                         -- 使用者能量
    diamonds INT,                                       -- 寶石數量
    last_claimed DATETIME,                              -- 上次領取資源的時間
    diamonds_ai_test INT,                               -- AI 測驗所獲得的寶石
    diamonds_vocabulary_game INT,                       -- 單字遊戲所得寶石
    diamonds_listening_test INT,                        -- 聽力測驗所得寶石
    diamonds_matching_game INT,                         -- 配對遊戲所得寶石
    diamonds_total INT,                                 -- 總寶石數量
    last_awarded_batch_id UNIQUEIDENTIFIER,             -- 上次獲獎題組的 Batch ID
    FOREIGN KEY (user_id) REFERENCES Users(user_id)     -- 關聯到 Users 表
);
--================================
--========2.AI測驗關邏輯==========
--================================
--2.1 題目紀錄表，用於紀錄Gemini API生成的題目資料
CREATE TABLE AI_GeneratedQuestions (
    QuestionID INT IDENTITY(1,1) PRIMARY KEY,           -- 題目唯一識別碼，自動遞增
    QuestionText NVARCHAR(MAX),                         -- 題目內容文字
    OptionA NVARCHAR(255),                              -- 選項 A
    OptionB NVARCHAR(255),                              -- 選項 B
    OptionC NVARCHAR(255),                              -- 選項 C
    OptionD NVARCHAR(255),                              -- 選項 D
    CorrectAnswer CHAR(1),                              -- 正確答案（A/B/C/D）
    Difficulty NVARCHAR(50),                            -- 題目難度（如 expert）
    Topic NVARCHAR(100),                                -- 題目主題（如 company）
    CreatedAt DATETIME,                                 -- 題目建立時間
    BatchID UNIQUEIDENTIFIER                            -- 題組批次 ID（對應領獎）
);
--2.2 使用者AI測驗作答紀錄表
CREATE TABLE AI_UserAnswers (
    AnswerID INT IDENTITY(1,1) PRIMARY KEY,             -- 作答紀錄唯一識別碼，自動遞增
    user_id INT,                                        -- 作答的使用者 ID
    QuestionID INT,                                     -- 題目 ID（外鍵）
    SelectedAnswer CHAR(1),                             -- 使用者所選答案（A/B/C/D）
    IsCorrect BIT,                                      -- 是否答對（1=正確，0=錯誤）
    AnsweredAt DATETIME,                                -- 作答時間
    FOREIGN KEY (user_id) REFERENCES Users(user_id),    -- 關聯到使用者
    FOREIGN KEY (QuestionID) REFERENCES AI_GeneratedQuestions(QuestionID) -- 關聯到題目
);
--================================
--========3.背單字遊戲相關邏輯====
--================================
--3.1️ 魔法森林表（存放 7 個森林）
CREATE TABLE magic_forest (
    forest_id INT PRIMARY KEY,         -- 魔法森林 ID（1~7）
    forest_name NVARCHAR(100) NOT NULL -- 魔法森林名稱（例如「火焰之森」、「冰霜之森」）
	forest_name_zh NVARCHAR(100) NOT NULL DEFAULT '';
);
--3.2 祭壇表（每個魔法森林 100 個，共 700 個）
CREATE TABLE magic_altar (
    altar_id INT PRIMARY KEY IDENTITY(1,1), -- 祭壇 ID（1~700）
    forest_id INT NOT NULL,                  -- 所屬魔法森林（關聯 magic_forest）
    FOREIGN KEY (forest_id) REFERENCES magic_forest(forest_id) -- 關聯到 magic_forest
);
--✅ 你的標準插入邏輯（幫你整理成規則）：
--🧠 多詞性支援	每個單字如果有多個詞性，要各自插入一筆資料（像 black 的例子）
--🔢 priority_level	按「常見程度」分級：主詞性 = 1，其他詞性為 2~5(依樣需要依照重要度排序)
--📝 例句與翻譯	只填在主詞性（priority_level = 1）那筆資料中，其他詞性留空
--🔊 發音音標	要處理特殊符號（例如 /ˈbjuː.ti/）不要被當成字串錯誤
--🔁 動詞要補時態	past_tense 與 past_participle 該補的要補，沒有就 NULL
--3.3 單字表：ancient_scrolls（每個祭壇 10 個單字，共 7,000 個）
CREATE TABLE ancient_scrolls (
    scroll_id INT PRIMARY KEY IDENTITY(1,1), -- 單字 ID，自動編號
    altar_id INT NOT NULL,                   -- 所屬祭壇（關聯 magic_altar）
    word NVARCHAR(100) NOT NULL,             -- 單字內容
    pronunciation NVARCHAR(100),             -- 發音（KK 音標 / IPA）
    part_of_speech NVARCHAR(50) NOT NULL,    -- 詞性（noun, verb, adj, adv）
    meaning NVARCHAR(255) NOT NULL,          -- 單字意思
    past_tense NVARCHAR(50),                 -- 過去式（可為 NULL）
    past_participle NVARCHAR(50),            -- 過去分詞（可為 NULL）
    example_sentence NVARCHAR(500),          -- 例句（只在首筆紀錄中填入）
    example_translation NVARCHAR(500),       -- 例句翻譯（只在首筆紀錄中填入）
    word_audio_url NVARCHAR(255),            -- 單字發音音檔 URL
    example_audio_url NVARCHAR(255),         -- 例句發音音檔 URL
    priority_level INT NOT NULL,             -- 每個單字詞性優先等級，依照該單字常用之詞性到冷門之詞性分級，高頻1低頻5（1～5）
	synonym_words NVARCHAR(1000) NULL,      -- 同義詞（格式：dark (adj.) 黑暗的；inky (adj.) 墨水般的）
    antonym_words NVARCHAR(1000) NULL,      -- 反義詞（格式：white (adj.) 白色的；bright(adj.) 明亮的）
    related_info  NVARCHAR(1000) NULL,     -- 衍伸補充（格式：black out (adj.) 昏倒）
    CONSTRAINT CK_priority_level_range CHECK (priority_level BETWEEN 1 AND 5), -- ✅ 加回 CHECK 約束
    FOREIGN KEY (altar_id) REFERENCES magic_altar(altar_id) -- FK 關聯
);
--=============================================
-- 🔍 模糊查詢：一次查詢多個關鍵字的單字資料，用以確認是否有無插入到重覆單字
SELECT 
    scroll_id AS 單字ID,
    altar_id AS 祭壇編號,
    word AS 單字,
    part_of_speech AS 詞性,
    meaning AS 單字意思,
    pronunciation AS 音標,
    priority_level AS 優先順序
FROM ancient_scrolls
WHERE word LIKE N'%wha%'
   --OR word LIKE N'%play%'
   --OR word LIKE N'%look%'
ORDER BY scroll_id ASC;
--=============================================

--=============================================
-- 🔍 相容舊版 SQL Server：找出重複單字 + 出現祭壇
SELECT 
    word AS 單字,
    COUNT(DISTINCT altar_id) AS 出現祭壇數,
    STUFF((
        SELECT ', ' + CAST(s2.altar_id AS NVARCHAR)
        FROM ancient_scrolls s2
        WHERE s2.word = s1.word
        GROUP BY s2.altar_id
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS 出現在哪些祭壇
FROM ancient_scrolls s1
GROUP BY word
HAVING COUNT(DISTINCT altar_id) > 1
ORDER BY 出現祭壇數 DESC, word ASC;
--=============================================


--3.4 使用者祭壇進度表（學習 & 複習記錄）
CREATE TABLE user_altar_progress (
    progress_id INT PRIMARY KEY IDENTITY(1,1), -- 進度紀錄 ID
    user_id INT NOT NULL,                      -- 使用者 ID（關聯 users）
    altar_id INT NOT NULL,                     -- 祭壇 ID（關聯 magic_altar）
    learning_status INT DEFAULT 0 CHECK (learning_status BETWEEN 0 AND 7),  
    -- 0 = 未解鎖, 1 = 學習完成, 2~6 = 複習次數, 7 = 完全完成
    last_review_time DATETIME,                  -- 最近一次學習/複習時間
    next_review_time DATETIME,                  -- 下次需要複習的時間
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (altar_id) REFERENCES magic_altar(altar_id)
);
--3.5 測驗記錄表（存放使用者測驗結果）
CREATE TABLE trial_records (
    trial_id INT PRIMARY KEY IDENTITY(1,1),  -- 試煉紀錄 ID
    user_id INT NOT NULL,                    -- 測驗者 ID（對應 users 表）
    altar_id INT NOT NULL,                    -- 測驗所屬祭壇（關聯 `magic_altar`）
    score INT NOT NULL,                      -- 測驗得分
    completion_time DATETIME DEFAULT GETDATE(), -- 測驗完成時間
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (altar_id) REFERENCES magic_altar(altar_id)
);

--3.6 使用者收藏單字表：紀錄每個使用者收藏的單字（對應 ancient_scrolls）
CREATE TABLE user_favorite_words (
    favorite_id INT PRIMARY KEY IDENTITY(1,1), -- 主鍵，自動遞增的收藏紀錄 ID
    user_id INT NOT NULL,                      -- 使用者 ID（對應 users 表）
    scroll_id INT NOT NULL,                    -- 單字 ID（對應 ancient_scrolls 表）
    added_time DATETIME DEFAULT GETDATE(),     -- 收藏時間，預設為當下時間
    -- 🔗 外鍵：user_id 對應到 users 表的主鍵 user_id
    CONSTRAINT FK_user_favorite_words_users
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    -- 🔗 外鍵：scroll_id 對應到 ancient_scrolls 表的主鍵 scroll_id
    CONSTRAINT FK_user_favorite_words_scrolls
        FOREIGN KEY (scroll_id) REFERENCES ancient_scrolls(scroll_id)
);

INSERT INTO ancient_scrolls 
(altar_id, word, pronunciation, part_of_speech, meaning, past_tense, past_participle, example_sentence, example_translation, word_audio_url, example_audio_url, priority_level)
VALUES
-- thumb
(5, 'thumb', N'/θʌm/', 'n.', '拇指', NULL, NULL, 'She gave a thumbs up.', '她比了個讚。', NULL, NULL, 1),
(5, 'thumb', N'/θʌm/', 'v.', '用拇指翻動；翹起拇指', 'thumbed', 'thumbed', NULL, NULL, NULL, NULL, 2),

-- toe
(5, 'toe', N'/toʊ/', 'n.', '腳趾', NULL, NULL, 'He injured his big toe.', '他的大腳趾受傷了。', NULL, NULL, 1),
(5, 'toe', N'/toʊ/', 'v.', '用腳尖觸碰；踮著腳走', 'toed', 'toed', NULL, NULL, NULL, NULL, 2),

-- treat
(5, 'treat', N'/triːt/', 'v.', '對待；治療；款待', 'treated', 'treated', 'They treated us to dinner.', '他們請我們吃晚餐。', NULL, NULL, 1),
(5, 'treat', N'/triːt/', 'n.', '款待；樂事', NULL, NULL, NULL, NULL, NULL, NULL, 2),

-- weekend
(5, 'weekend', N'/ˈwiːk.end/', 'n.', '週末', NULL, NULL, 'They went hiking over the weekend.', '他們週末去爬山了。', NULL, NULL, 1),

-- welcome
(5, 'welcome', N'/ˈwel.kəm/', 'v.', '歡迎；迎接', 'welcomed', 'welcomed', 'We welcomed the new student.', '我們歡迎新同學。', NULL, NULL, 1),
(5, 'welcome', N'/ˈwel.kəm/', 'adj.', '受歡迎的；令人高興的', NULL, NULL, NULL, NULL, NULL, NULL, 2),

-- what
(5, 'what', N'/wʌt/', 'pron.', '什麼', NULL, NULL, 'What is your name?', '你叫什麼名字？', NULL, NULL, 1),
(5, 'what', N'/wʌt/', 'det.', '什麼樣的', NULL, NULL, NULL, NULL, NULL, NULL, 2),

-- fifty
(5, 'fifty', N'/ˈfɪf.ti/', 'num.', '五十', NULL, NULL, 'There are fifty students in the class.', '班上有五十個學生。', NULL, NULL, 1),

-- hit
(5, 'hit', N'/hɪt/', 'v.', '打；撞擊；達到', 'hit', 'hit', 'He accidentally hit the wall.', '他不小心撞到了牆。', NULL, NULL, 1),
(5, 'hit', N'/hɪt/', 'n.', '打擊；熱門作品', NULL, NULL, NULL, NULL, NULL, NULL, 2),

-- joke
(5, 'joke', N'/dʒoʊk/', 'n.', '笑話；玩笑', NULL, NULL, 'He told a funny joke.', '他講了一個有趣的笑話。', NULL, NULL, 1),
(5, 'joke', N'/dʒoʊk/', 'v.', '開玩笑；戲弄', 'joked', 'joked', NULL, NULL, NULL, NULL, 2),

-- look
(5, 'look', N'/lʊk/', 'v.', '看；看起來', 'looked', 'looked', 'Look at the sky!', '看那天空！', NULL, NULL, 1),
(5, 'look', N'/lʊk/', 'n.', '表情；樣子', NULL, NULL, NULL, NULL, NULL, NULL, 2);

INSERT INTO ancient_scrolls (altar_id, word, pronunciation, part_of_speech, meaning, past_tense, past_participle, example_sentence, example_translation, word_audio_url, example_audio_url, priority_level)
VALUES
-- social
(6, 'social', N'/ˈsəʊ.ʃəl/', 'adj.', '社交的；社會的', NULL, NULL, 'He has strong social skills.', '他的社交能力很強。', NULL, NULL, 1),

-- spider
(6, 'spider', N'/ˈspaɪ.dər/', 'n.', '蜘蛛', NULL, NULL, 'A spider is building a web.', '一隻蜘蛛正在結網。', NULL, NULL, 1),

-- spirit
(6, 'spirit', N'/ˈspɪr.ɪt/', 'n.', '精神；心靈；鬼魂', NULL, NULL, 'She has a free spirit.', '她有著自由的心靈。', NULL, NULL, 1),

-- straw
(6, 'straw', N'/strɔː/', 'n.', '吸管；稻草', NULL, NULL, 'He drank juice with a straw.', '他用吸管喝果汁。', NULL, NULL, 1),

-- tear
(6, 'tear', N'/tɪər/', 'n.', '眼淚', NULL, NULL, 'A tear rolled down her cheek.', '一滴眼淚滑過她的臉頰。', NULL, NULL, 1),
(6, 'tear', N'/teər/', 'v.', '撕裂；撕開', 'tore', 'torn', NULL, NULL, NULL, NULL, 2),

-- teenager
(6, 'teenager', N'/ˈtiːnˌeɪ.dʒər/', 'n.', '青少年', NULL, NULL, 'The teenager loves music.', '這位青少年喜歡音樂。', NULL, NULL, 1),

-- theater
(6, 'theater', N'/ˈθɪə.tər/', 'n.', '劇院；戲劇', NULL, NULL, 'They went to the theater last night.', '他們昨晚去了劇院。', NULL, NULL, 1),

-- title
(6, 'title', N'/ˈtaɪ.təl/', 'n.', '標題；稱號', NULL, NULL, 'What’s the title of this book?', '這本書的標題是什麼？', NULL, NULL, 1),
(6, 'title', N'/ˈtaɪ.təl/', 'v.', '給…命名；授予頭銜', 'titled', 'titled', NULL, NULL, NULL, NULL, 2),

-- travel
(6, 'travel', N'/ˈtræv.əl/', 'v.', '旅行；行進', 'traveled', 'traveled', 'They love to travel abroad.', '他們喜歡出國旅行。', NULL, NULL, 1),
(6, 'travel', N'/ˈtræv.əl/', 'n.', '旅行；旅程', NULL, NULL, NULL, NULL, NULL, NULL, 2),

-- trick
(6, 'trick', N'/trɪk/', 'n.', '把戲；詭計', NULL, NULL, 'That was just a magic trick.', '那只是個魔術把戲。', NULL, NULL, 1),
(6, 'trick', N'/trɪk/', 'v.', '欺騙；戲弄', 'tricked', 'tricked', NULL, NULL, NULL, NULL, 2);

INSERT INTO ancient_scrolls 
(altar_id, word, pronunciation, part_of_speech, meaning, past_tense, past_participle, example_sentence, example_translation, word_audio_url, example_audio_url, priority_level)
VALUES
-- screen
(7, 'screen', N'/skriːn/', 'n.', '螢幕；屏幕', NULL, NULL, 'He looked at the computer screen.', '他看著電腦螢幕。', NULL, NULL, 1),
(7, 'screen', N'/skriːn/', 'v.', '篩選；播放', 'screened', 'screened', NULL, NULL, NULL, NULL, 2),

-- cartoon
(7, 'cartoon', N'/kɑːˈtuːn/', 'n.', '卡通；漫畫', NULL, NULL, 'Children enjoy watching cartoons.', '小朋友喜歡看卡通。', NULL, NULL, 1),

-- excuse
(7, 'excuse', N'/ɪkˈskjuːz/', 'n.', '藉口；理由', NULL, NULL, 'He made an excuse for being late.', '他為遲到找了一個藉口。', NULL, NULL, 1),
(7, 'excuse', N'/ɪkˈskjuːz/', 'v.', '原諒；辯解', 'excused', 'excused', NULL, NULL, NULL, NULL, 2),

-- closet
(7, 'closet', N'/ˈklɒz.ɪt/', 'n.', '衣櫥；壁櫥', NULL, NULL, 'She put her clothes in the closet.', '她把衣服放進衣櫥裡。', NULL, NULL, 1),

-- hip
(7, 'hip', N'/hɪp/', 'n.', '臀部；髖部', NULL, NULL, 'She placed her hands on her hips.', '她把手放在臀部上。', NULL, NULL, 1),

-- practice
(7, 'practice', N'/ˈpræk.tɪs/', 'n.', '練習；實踐', NULL, NULL, 'Daily practice helps you improve.', '每天練習能幫助你進步。', NULL, NULL, 1),
(7, 'practice', N'/ˈpræk.tɪs/', 'v.', '練習；實行', 'practiced', 'practiced', NULL, NULL, NULL, NULL, 2),

-- volleyball
(7, 'volleyball', N'/ˈvɒl.i.bɔːl/', 'n.', '排球', NULL, NULL, 'They play volleyball on the beach.', '他們在海灘上打排球。', NULL, NULL, 1),

-- rude
(7, 'rude', N'/ruːd/', 'adj.', '粗魯的；無禮的', NULL, NULL, 'It is rude to interrupt people.', '打斷別人說話是很沒禮貌的。', NULL, NULL, 1),

-- papaya
(7, 'papaya', N'/pəˈpaɪ.ə/', 'n.', '木瓜', NULL, NULL, 'Papaya is rich in vitamins.', '木瓜富含維生素。', NULL, NULL, 1),

-- eye
(7, 'eye', N'/aɪ/', 'n.', '眼睛', NULL, NULL, 'She has beautiful eyes.', '她有一雙漂亮的眼睛。', NULL, NULL, 1),
(7, 'eye', N'/aɪ/', 'v.', '注視；打量', 'eyed', 'eyed', NULL, NULL, NULL, NULL, 2);

INSERT INTO ancient_scrolls (altar_id, word, pronunciation, part_of_speech, meaning, past_tense, past_participle, example_sentence, example_translation, word_audio_url, example_audio_url, priority_level)
VALUES
-- court
(8, 'court', N'/kɔːrt/', 'n.', '法院；球場；庭院', NULL, NULL, 'The court is full of players.', '球場上擠滿了球員。', NULL, NULL, 1),
(8, 'court', N'/kɔːrt/', 'v.', '追求；討好；求愛', 'courted', 'courted', NULL, NULL, NULL, NULL, 2),

-- swan
(8, 'swan', N'/swɒn/', 'n.', '天鵝', NULL, NULL, 'The swan swam across the lake.', '天鵝游過湖面。', NULL, NULL, 1),

-- bottle
(8, 'bottle', N'/ˈbɒt.əl/', 'n.', '瓶子', NULL, NULL, 'She drank a bottle of water.', '她喝了一瓶水。', NULL, NULL, 1),
(8, 'bottle', N'/ˈbɒt.əl/', 'v.', '把…裝入瓶中', 'bottled', 'bottled', NULL, NULL, NULL, NULL, 2),

-- twelve
(8, 'twelve', N'/twelv/', 'num.', '十二', NULL, NULL, 'There are twelve cookies on the plate.', '盤子上有十二塊餅乾。', NULL, NULL, 1),

-- paris
(8, 'paris', N'/ˈpær.ɪs/', 'n.', '巴黎（地名）', NULL, NULL, 'She traveled to Paris last year.', '她去年去了巴黎旅行。', NULL, NULL, 1),

-- anybody
(8, 'anybody', N'/ˈen.iˌbɒd.i/', 'pron.', '任何人', NULL, NULL, 'Did anybody call me?', '有人打電話找我嗎？', NULL, NULL, 1),

-- half
(8, 'half', N'/hæf/', 'n.', '一半', NULL, NULL, 'He ate half of the cake.', '他吃了一半的蛋糕。', NULL, NULL, 1),
(8, 'half', N'/hæf/', 'adj.', '一半的；部分的', NULL, NULL, NULL, NULL, NULL, NULL, 2),

-- record
(8, 'record', N'/ˈrek.ɔːrd/', 'n.', '紀錄；唱片', NULL, NULL, 'He broke the world record.', '他打破了世界紀錄。', NULL, NULL, 1),
(8, 'record', N'/rɪˈkɔːrd/', 'v.', '錄音；記錄', 'recorded', 'recorded', NULL, NULL, NULL, NULL, 2),

-- throat
(8, 'throat', N'/θrəʊt/', 'n.', '喉嚨', NULL, NULL, 'Her throat hurts.', '她喉嚨痛。', NULL, NULL, 1),

-- cure
(8, 'cure', N'/kjʊər/', 'v.', '治癒；矯正', 'cured', 'cured', 'The doctor cured her illness.', '醫生治好了她的病。', NULL, NULL, 1),
(8, 'cure', N'/kjʊər/', 'n.', '療法；治療', NULL, NULL, NULL, NULL, NULL, NULL, 2);

INSERT INTO ancient_scrolls (
    altar_id, word, pronunciation, part_of_speech, meaning,
    past_tense, past_participle, example_sentence, example_translation,
    word_audio_url, example_audio_url, priority_level
)
VALUES
-- couple
(9, 'couple', N'/ˈkʌp.əl/', 'n.', '一對；夫妻；幾個', NULL, NULL, 'The couple walked hand in hand.', '那對夫妻手牽著手走著。', NULL, NULL, 1),
(9, 'couple', N'/ˈkʌp.əl/', 'v.', '連接；結合', 'coupled', 'coupled', NULL, NULL, NULL, NULL, 2),

-- underwear
(9, 'underwear', N'/ˈʌn.də.weər/', 'n.', '內衣褲', NULL, NULL, 'He forgot to pack his underwear.', '他忘了帶內衣褲。', NULL, NULL, 1),

-- healthy
(9, 'healthy', N'/ˈhel.θi/', 'adj.', '健康的；有益健康的', NULL, NULL, 'She has a healthy lifestyle.', '她過著健康的生活方式。', NULL, NULL, 1),

-- weekday
(9, 'weekday', N'/ˈwiːk.deɪ/', 'n.', '平日（週一至週五）', NULL, NULL, 'He works from home on weekdays.', '他平日都在家工作。', NULL, NULL, 1),

-- invitation
(9, 'invitation', N'/ˌɪn.vɪˈteɪ.ʃən/', 'n.', '邀請；請帖', NULL, NULL, 'I got an invitation to the wedding.', '我收到一張婚禮邀請函。', NULL, NULL, 1),

-- scared
(9, 'scared', N'/skeəd/', 'adj.', '害怕的', NULL, NULL, 'The child looked scared of the dog.', '那個小孩看起來很怕那隻狗。', NULL, NULL, 1),

-- struggle
(9, 'struggle', N'/ˈstrʌɡ.əl/', 'v.', '掙扎；奮鬥', 'struggled', 'struggled', 'He struggled to finish his homework.', '他掙扎著完成作業。', NULL, NULL, 1),
(9, 'struggle', N'/ˈstrʌɡ.əl/', 'n.', '努力；奮鬥', NULL, NULL, NULL, NULL, NULL, NULL, 2),

-- mass
(9, 'mass', N'/mæs/', 'n.', '大量；群眾；彌撒', NULL, NULL, 'A mass of people gathered in the square.', '一大群人聚集在廣場上。', NULL, NULL, 1),
(9, 'mass', N'/mæs/', 'adj.', '大規模的；集體的', NULL, NULL, NULL, NULL, NULL, NULL, 2),

-- appear
(9, 'appear', N'/əˈpɪər/', 'v.', '出現；似乎', 'appeared', 'appeared', 'She appeared suddenly at the door.', '她突然出現在門口。', NULL, NULL, 1),

(9, 'angel', N'/ˈeɪn.dʒəl/', 'n.', '天使', NULL, NULL, 
'She looked like an angel in her white dress.', '她穿著白色洋裝看起來像天使。', 
NULL, NULL, 1);

INSERT INTO ancient_scrolls (altar_id, word, pronunciation, part_of_speech, meaning, past_tense, past_participle, example_sentence, example_translation, word_audio_url, example_audio_url, priority_level)
VALUES
-- line
(10, 'line', N'/laɪn/', 'n.', '線條；行列；台詞', NULL, NULL, 'She drew a straight line on the paper.', '她在紙上畫了一條直線。', NULL, NULL, 1),
(10, 'line', N'/laɪn/', 'v.', '排隊；排列', 'lined', 'lined', NULL, NULL, NULL, NULL, 2),

-- slim
(10, 'slim', N'/slɪm/', 'adj.', '苗條的；微小的', NULL, NULL, 'She has a slim figure.', '她身材苗條。', NULL, NULL, 1),
(10, 'slim', N'/slɪm/', 'v.', '減肥；變瘦', 'slimmed', 'slimmed', NULL, NULL, NULL, NULL, 2),

-- seek
(10, 'seek', N'/siːk/', 'v.', '尋找；追求', 'sought', 'sought', 'They seek advice from experts.', '他們向專家尋求建議。', NULL, NULL, 1),

-- basic
(10, 'basic', N'/ˈbeɪ.sɪk/', 'adj.', '基本的；基礎的', NULL, NULL, 'We need to cover the basic concepts first.', '我們需要先講解基本概念。', NULL, NULL, 1),
(10, 'basic', N'/ˈbeɪ.sɪk/', 'n.', '基本要素', NULL, NULL, NULL, NULL, NULL, NULL, 2),

-- create
(10, 'create', N'/kriˈeɪt/', 'v.', '創造；建立', 'created', 'created', 'She created a beautiful painting.', '她創作了一幅美麗的畫。', NULL, NULL, 1),

-- these
(10, 'these', N'/ðiːz/', 'pron.', '這些', NULL, NULL, 'These are my favorite books.', '這些是我最喜歡的書。', NULL, NULL, 1),

-- bark
(10, 'bark', N'/bɑːrk/', 'v.', '吠叫', 'barked', 'barked', 'The dog barked loudly at the stranger.', '那隻狗對陌生人大聲吠叫。', NULL, NULL, 1),
(10, 'bark', N'/bɑːrk/', 'n.', '樹皮；吠聲', NULL, NULL, NULL, NULL, NULL, NULL, 2),

-- hen
(10, 'hen', N'/hen/', 'n.', '母雞', NULL, NULL, 'The hen laid three eggs.', '那隻母雞下了三顆蛋。', NULL, NULL, 1),

-- view
(10, 'view', N'/vjuː/', 'n.', '視野；景色；觀點', NULL, NULL, 'The view from the mountain was amazing.', '從山上看出去的景色令人驚嘆。', NULL, NULL, 1),
(10, 'view', N'/vjuː/', 'v.', '觀看；考慮', 'viewed', 'viewed', NULL, NULL, NULL, NULL, 2),

-- inside
(10, 'inside', N'/ˌɪnˈsaɪd/', 'prep.', '在…裡面', NULL, NULL, 'The keys are inside the drawer.', '鑰匙在抽屜裡面。', NULL, NULL, 1),
(10, 'inside', N'/ˌɪnˈsaɪd/', 'n.', '內部', NULL, NULL, NULL, NULL, NULL, NULL, 2),
(10, 'inside', N'/ˌɪnˈsaɪd/', 'adj.', '內部的', NULL, NULL, NULL, NULL, NULL, NULL, 3),
(10, 'inside', N'/ˌɪnˈsaɪd/', 'adv.', '在裡面', NULL, NULL, NULL, NULL, NULL, NULL, 4);

UPDATE ancient_scrolls
SET synonym_words = N'dark (adj.) 黑暗的；inky (adj.) 墨水般的',
    antonym_words = N'white (adj.) 白色的；bright (adj.) 明亮的',
    related_info  = N'black out (phr.) 昏倒'
WHERE scroll_id = 36;

UPDATE ancient_scrolls
SET synonym_words = N'base (n.) 底部；foundation (n.) 基礎',
    antonym_words = N'top (n.) 頂部；summit (n.) 山頂',
    related_info  = N'bottom line (n.) 底線；hit bottom (phr.) 跌落谷底'
WHERE scroll_id = 39;

UPDATE ancient_scrolls SET
    synonym_words = 'hairstyle (n.) 髮型',
    antonym_words = 'messy hair (n.) 凌亂的頭髮',
    related_info = 'get a haircut (phr.) 去剪頭髮'
WHERE scroll_id = 41;

UPDATE ancient_scrolls SET
    synonym_words = 'journal (n.) 報刊；gazette (n.) 公報',
    antonym_words = 'rumor (n.) 謠言',
    related_info = 'read the newspaper (phr.) 讀報紙'
WHERE scroll_id = 42;

UPDATE ancient_scrolls SET
    synonym_words = NULL,
    antonym_words = NULL,
    related_info = 'November rain (phr.) 十一月的雨'
WHERE scroll_id = 43;

UPDATE ancient_scrolls SET
    synonym_words = 'mechanical pencil (n.) 自動鉛筆；graphite (n.) 石墨',
    antonym_words = 'pen (n.) 原子筆；crayon (n.) 蠟筆',
    related_info = 'pencil case (n.) 鉛筆盒'
WHERE scroll_id = 44;

UPDATE ancient_scrolls SET
    synonym_words = 'trip (n.) 短程旅行；journey (n.) 旅程',
    antonym_words = NULL,
    related_info = 'go for a ride (phr.) 去兜風'
WHERE scroll_id = 46;

UPDATE ancient_scrolls SET
    synonym_words = 'cycle (v.) 騎腳踏車；drive (v.) 開車',
    antonym_words = 'walk (v.) 走路',
    related_info = 'ride a bike (phr.) 騎腳踏車'
WHERE scroll_id = 47;

UPDATE ancient_scrolls SET
    synonym_words = 'range (n.) 範圍；extension (n.) 延伸',
    antonym_words = 'limit (n.) 限制；reduction (n.) 減少',
    related_info = 'spread quickly (phr.) 快速擴散'
WHERE scroll_id = 48;

UPDATE ancient_scrolls SET
    synonym_words = 'extend (v.) 擴展；broadcast (v.) 散播',
    antonym_words = NULL,
    related_info = 'spread rumors (phr.) 散播謠言'
WHERE scroll_id = 49;

UPDATE ancient_scrolls SET
    synonym_words = 'belly (n.) 肚子；abdomen (n.) 腹部',
    antonym_words = NULL,
    related_info = 'stomach ache (n.) 胃痛'
WHERE scroll_id = 50;

UPDATE ancient_scrolls SET
    synonym_words = 'tolerate (v.) 忍受；endure (v.) 忍耐',
    antonym_words = 'reject (v.) 拒絕；refuse (v.) 拒絕接受',
    related_info = 'can’t stomach (phr.) 無法忍受'
WHERE scroll_id = 51;

UPDATE ancient_scrolls SET
    synonym_words = 'group (n.) 組；squad (n.) 小隊',
    antonym_words = 'individual (n.) 個人；opponent (n.) 對手',
    related_info = 'team spirit (n.) 團隊精神'
WHERE scroll_id = 52;
