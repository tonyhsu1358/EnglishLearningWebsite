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
WHERE tp.name IN ('Users','UserResources','AI_GeneratedQuestions', 'AI_UserAnswers','magic_forest','magic_altar','ancient_scrolls','user_altar_progress','user_favorite_words','user_word_errors');

USE EnglishLearningWebsite;
SELECT * FROM Users;
SELECT * FROM UserResources;
SELECT * FROM AI_GeneratedQuestions ORDER BY QuestionID DESC;
SELECT * FROM AI_UserAnswers ORDER BY QuestionID DESC ;
SELECT * FROM magic_forest;                         --3.1️ 魔法森林表（存放 7 個森林）
SELECT * FROM magic_altar;                          --3.2 祭壇表（每個魔法森林 100 個，共 700 個）
SELECT * FROM ancient_scrolls;                      --3.3 單字表：ancient_scrolls（每個祭壇 10 個單字，共 7,000 個）
SELECT * FROM user_altar_progress;                  --3.4 使用者祭壇進度表（學習 & 複習記錄）
SELECT * FROM user_favorite_words;                  --3.5 使用者收藏單字表：紀錄每個使用者收藏的單字（對應 ancient_scrolls）
SELECT * FROM user_word_errors;                     --3.6 使用者單字錯誤紀錄表，用於追蹤首次學習與複習階段中的答錯狀況與補救情形

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
SELECT*FROM UserResources;
--1.2 使用者資源表，用於紀錄用戶持有的魔法能量、魔法鑽石、獲得時間等等
CREATE TABLE UserResources (
    resource_id INT IDENTITY(1,1) PRIMARY KEY,          -- 資源紀錄唯一識別碼，自動遞增
    user_id INT NOT NULL,                               -- 對應使用者 ID
    energy INT NOT NULL DEFAULT 0,                      -- 使用者能量
    diamonds INT NOT NULL DEFAULT 0,                    -- 寶石數量
    last_claimed DATETIME NULL,                         -- 上次領取資源的時間
    diamonds_ai_test INT NOT NULL DEFAULT 0,            -- AI 測驗所獲得的寶石
    diamonds_vocabulary_game INT NOT NULL DEFAULT 0,    -- 單字遊戲所得寶石
    diamonds_listening_test INT NOT NULL DEFAULT 0,     -- 聽力測驗所得寶石
    diamonds_matching_game INT NOT NULL DEFAULT 0,      -- 配對遊戲所得寶石
    diamonds_total INT NOT NULL DEFAULT 0,              -- 總寶石數量
    last_awarded_batch_id NVARCHAR(64) NULL,            -- 上次獲獎題組的 Batch ID (帶字串前綴)
    last_energy_deduction_batch_id NVARCHAR(64) NULL,   -- 上次扣除能量的 Batch ID (帶字串前綴)
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
-- ==========✅ 你的標準插入邏輯（幫你整理成規則）：==========
-- 🧠 多詞性支援  
--    每個單字如果有多個詞性，要各自插入一筆資料（像 black 的例子）。
-- 🔢 priority_level  
--    按「常見程度」分級：主詞性 = 1，其他詞性為 2~5（依重要度排序）。
-- 📝 例句與翻譯  
--    只填在主詞性（priority_level = 1）那筆資料中，其他詞性留空。
-- 🔊 發音音標  
--    要處理特殊符號（例如 /ˈbjuː.ti/）不要被當成字串錯誤。
-- 🔁 動詞要補時態  
--    past_tense 與 past_participle 該補的要補，沒有就填 NULL。
-- 🔶 同義詞 (synonym_words)  
--    只在主詞性（priority_level = 1）填入；格式例如：dark (adj.) 黑暗的；inky (adj.) 墨水般的 
--    若沒有合適的同義詞，則填 NULL。
-- 🔷 反義詞 (antonym_words)  
--    同樣只在主詞性（priority_level = 1）填入；格式與同義詞相同。  
--    若沒有合適的反義詞，則填 NULL。
-- ✨ 衍伸補充 (related_info)  
--    只在主詞性（priority_level = 1）填入，且一定要填入；不限於片語，可以是其他相關延伸，例如：  
--    black out (phr.) 昏倒；blackboard (n.) 黑板。  
--    若沒有合適的補充，則填 NULL。

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
	synonym_words NVARCHAR(1000) NULL,      -- 同義詞（格式：dark (adj.) 黑暗的；inky (adj.) 墨水般的），只插入priority_level為1的單字，若沒有適當的同義詞則無需插入
    antonym_words NVARCHAR(1000) NULL,      -- 反義詞（格式：white (adj.) 白色的；bright(adj.) 明亮的），只插入priority_level為1的單字，若沒有適當的反義詞則無須插入
    related_info  NVARCHAR(1000) NULL,     -- 衍伸補充（格式：black out (phr.) 昏倒)，但不限於片語，可以是其他相關延伸，且只插入priority_level為1的單字，且一定要填入
    CONSTRAINT CK_priority_level_range CHECK (priority_level BETWEEN 1 AND 5), -- ✅ 加回 CHECK 約束
    FOREIGN KEY (altar_id) REFERENCES magic_altar(altar_id) -- FK 關聯
);
--=============================================
-- 🔍 精確查詢：確認是否已有完全相同的單字
SELECT 
    scroll_id AS 單字ID,
    altar_id AS 祭壇編號,
    word AS 單字,
    part_of_speech AS 詞性,
    meaning AS 單字意思,
    pronunciation AS 音標,
    priority_level AS 優先順序
FROM ancient_scrolls
WHERE word IN (
    N'her',
    N'count',
    N'pump',
    N'cousin',
    N'film',
    N'ice',
    N'broad',
    N'basket',
    N'opinion',
    N'range'
)
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
SELECT * FROM user_altar_progress;
--3.4 使用者祭壇進度表（學習 & 複習記錄）
CREATE TABLE user_altar_progress (
    progress_id INT PRIMARY KEY IDENTITY(1,1), -- 進度紀錄 ID
    user_id INT NOT NULL,                      -- 使用者 ID（關聯 users）
    altar_id INT NOT NULL,                     -- 祭壇 ID（關聯 magic_altar）
    learning_status INT DEFAULT 0 
        CHECK (learning_status BETWEEN 0 AND 7),  
        -- 學習狀態：
        -- 0 = 未解鎖
        -- 1 = 學習完成
        -- 2~6 = 複習次數
        -- 7 = 完全完成
    last_review_time DATETIME,                 -- 最近一次學習/複習時間
    next_review_time DATETIME,                 -- 下次需要複習的時間
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (altar_id) REFERENCES magic_altar(altar_id)
);
SELECT * FROM user_favorite_words
--3.5 使用者收藏單字表：紀錄每個使用者收藏的單字（對應 ancient_scrolls）
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
SELECT * FROM user_word_errors;
--3.6 使用者單字錯誤紀錄表，用於追蹤首次學習與複習階段中的答錯狀況與補救情形
CREATE TABLE user_word_errors (
    error_id INT PRIMARY KEY IDENTITY(1,1),      -- 錯誤紀錄主鍵，自動遞增
    user_id INT NOT NULL,                        -- 對應的使用者 ID（關聯 users 表）
    scroll_id INT NOT NULL,                      -- 對應的單字 ID（關聯 ancient_scrolls 表）
    error_stage VARCHAR(20) NOT NULL,            -- 錯誤發生的階段，如 'first_learning', 'review_1' ~ 'review_6'
    error_count INT DEFAULT 1,                   -- 錯誤次數，若再次答錯則更新累加
    last_wrong_time DATETIME DEFAULT GETDATE(),  -- 最近一次答錯的時間
    memo NVARCHAR(255) NULL,                     -- 備註欄，用於紀錄補救方式或異常說明
    CONSTRAINT UQ_user_scroll_stage UNIQUE(user_id, scroll_id, error_stage),  -- 限制每位使用者在相同階段與單字只能記錄一筆錯誤
    FOREIGN KEY (user_id) REFERENCES users(user_id),               -- 外鍵：使用者
    FOREIGN KEY (scroll_id) REFERENCES ancient_scrolls(scroll_id)  -- 外鍵：單字
);

INSERT INTO ancient_scrolls 
(altar_id, word, pronunciation, part_of_speech, meaning, past_tense, past_participle, example_sentence, example_translation, word_audio_url, example_audio_url, priority_level, synonym_words, antonym_words, related_info)
VALUES
-- guitar
(16, N'guitar', N'/ɡɪˈtɑːr/', 'n.', N'吉他', NULL, NULL, N'She plays the guitar beautifully.', N'她吉他彈得很美妙。', NULL, NULL, 1, N'instrument (n.) 樂器', NULL, N'electric guitar (n.) 電吉他'),

-- area
(16, N'area', N'/ˈer.i.ə/', 'n.', N'區域；範圍', NULL, NULL, N'This area is famous for its beautiful scenery.', N'這個地區以美麗的風景聞名。', NULL, NULL, 1, N'region (n.) 地區', N'point (n.) 點', N'parking area (n.) 停車區'),

-- plant
(16, N'plant', N'/plænt/', 'n.', N'植物；工廠', NULL, NULL, N'The plant needs water every day.', N'這株植物每天都需要澆水。', NULL, NULL, 1, N'factory (n.) 工廠；flora (n.) 植物群', NULL, N'power plant (n.) 發電廠'),
(16, N'plant', N'/plænt/', 'v.', N'種植；安置', N'planted', N'planted', NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL),

-- low
(16, N'low', N'/loʊ/', 'adj.', N'低的；不足的', NULL, NULL, N'The river is very low this summer.', N'今年夏天河水很淺。', NULL, NULL, 1, N'short (adj.) 矮的；shallow (adj.) 淺的', N'high (adj.) 高的', N'low-cost (adj.) 低成本的'),
(16, N'low', N'/loʊ/', 'adv.', N'低地；低聲地', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL),

-- keep
(16, N'keep', N'/kiːp/', 'v.', N'保持；保存；繼續', N'kept', N'kept', N'She tries to keep her room clean.', N'她努力保持房間乾淨。', NULL, NULL, 1, N'maintain (v.) 維持', NULL, N'keep up (phr.) 繼續'),
(16, N'keep', N'/kiːp/', 'n.', N'城堡主樓；生活費', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL),

-- rainy
(16, N'rainy', N'/ˈreɪ.ni/', 'adj.', N'多雨的；下雨的', NULL, NULL, N'We stayed indoors on the rainy day.', N'下雨天我們待在室內。', NULL, NULL, 1, N'wet (adj.) 潮濕的', N'dry (adj.) 乾燥的', N'rainy season (n.) 雨季'),

-- banker
(16, N'banker', N'/ˈbæŋ.kər/', 'n.', N'銀行家', NULL, NULL, N'The banker approved the loan quickly.', N'銀行家很快批准了貸款。', NULL, NULL, 1, N'financier (n.) 金融家', NULL, N'central banker (n.) 中央銀行官員'),

-- role
(16, N'role', N'/roʊl/', 'n.', N'角色；職責', NULL, NULL, N'She played an important role in the project.', N'她在這個專案中扮演重要角色。', NULL, NULL, 1, N'part (n.) 角色；duty (n.) 責任', NULL, N'lead role (n.) 主角'),

-- individual
(16, N'individual', N'/ˌɪn.dɪˈvɪdʒ.u.əl/', 'n.', N'個人；個體', NULL, NULL, N'Each individual has the right to freedom.', N'每個人都有自由的權利。', NULL, NULL, 1, N'person (n.) 人；being (n.) 存在', NULL, N'individual rights (n.) 個人權利'),
(16, N'individual', N'/ˌɪn.dɪˈvɪdʒ.u.əl/', 'adj.', N'個別的；獨特的', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL),

-- handle
(16, N'handle', N'/ˈhæn.dəl/', 'v.', N'處理；應付', N'handled', N'handled', N'She can handle the situation well.', N'她能很好地處理這個情況。', NULL, NULL, 1, N'manage (v.) 處理；cope (v.) 應付', NULL, N'handle with care (phr.) 小心處理'),
(16, N'handle', N'/ˈhæn.dəl/', 'n.', N'把手；柄', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL);

-- 🎯 精確查詢祭壇17要插入的單字是否已有重複
SELECT 
    scroll_id AS 單字ID,
    altar_id AS 祭壇編號,
    word AS 單字,
    part_of_speech AS 詞性,
    meaning AS 單字意思,
    pronunciation AS 音標,
    priority_level AS 優先順序
FROM ancient_scrolls
WHERE word IN (
    N'royal',
    N'pants',
    N'date',
    N'soup',
    N'Taiwanese',
    N'topic',
    N'language',
    N'wise',
    N'swallow',
    N'decrease'
)
ORDER BY scroll_id ASC;

INSERT INTO ancient_scrolls 
(altar_id, word, pronunciation, part_of_speech, meaning, past_tense, past_participle, example_sentence, example_translation, word_audio_url, example_audio_url, priority_level, synonym_words, antonym_words, related_info)
VALUES
-- royal
(17, 'royal', N'/ˈrɔɪ.əl/', 'adj.', N'皇家的；高貴的', NULL, NULL, 'The royal family lives in the palace.', N'皇室成員住在宮殿裡。', NULL, NULL, 1, 'regal (adj.) 帝王的', NULL, 'royal court (n.) 皇室宮廷'),

-- pants
(17, 'pants', N'/pænts/', 'n.', N'褲子', NULL, NULL, 'He bought a new pair of pants.', N'他買了一條新褲子。', NULL, NULL, 1, 'trousers (n.) 長褲', NULL, 'jeans (n.) 牛仔褲'),

-- date
(17, 'date', N'/deɪt/', 'n.', N'日期；約會', NULL, NULL, 'What is today’s date?', N'今天是幾號？', NULL, NULL, 1, NULL, NULL, 'go on a date (phr.) 約會'),
(17, 'date', N'/deɪt/', 'v.', N'與…約會；註明日期', 'dated', 'dated', NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL),

-- soup
(17, 'soup', N'/suːp/', 'n.', N'湯', NULL, NULL, 'She had chicken soup for lunch.', N'她午餐喝了雞湯。', NULL, NULL, 1, NULL, NULL, 'soup kitchen (n.) 施粥所'),

-- Taiwanese
(17, 'Taiwanese', N'/ˌtaɪ.wəˈniːz/', 'adj.', N'台灣的；台灣人的', NULL, NULL, 'He enjoys Taiwanese food.', N'他喜歡台灣食物。', NULL, NULL, 1, NULL, NULL, 'Taiwanese culture (n.) 台灣文化'),
(17, 'Taiwanese', N'/ˌtaɪ.wəˈniːz/', 'n.', N'台灣人；台灣語', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL),

-- topic
(17, 'topic', N'/ˈtɑː.pɪk/', 'n.', N'主題；話題', NULL, NULL, 'The teacher introduced a new topic today.', N'老師今天介紹了一個新主題。', NULL, NULL, 1, 'subject (n.) 主題', NULL, 'hot topic (n.) 熱門話題'),

-- language
(17, 'language', N'/ˈlæŋ.ɡwɪdʒ/', 'n.', N'語言', NULL, NULL, 'English is an international language.', N'英語是一種國際語言。', NULL, NULL, 1, 'tongue (n.) 語言', NULL, 'body language (n.) 肢體語言'),

-- wise
(17, 'wise', N'/waɪz/', 'adj.', N'有智慧的；明智的', NULL, NULL, 'It was wise of you to save money.', N'你存錢是明智的。', NULL, NULL, 1, 'sensible (adj.) 明智的', 'foolish (adj.) 愚蠢的', 'wise man (n.) 智者'),

-- swallow
(17, 'swallow', N'/ˈswɒl.oʊ/', 'v.', N'吞嚥', 'swallowed', 'swallowed', 'She swallowed the medicine with water.', N'她用水吞下了藥。', NULL, NULL, 1, NULL, NULL, 'swallow up (phr.) 吞沒'),
(17, 'swallow', N'/ˈswɒl.oʊ/', 'n.', N'燕子（鳥）', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL),

-- decrease
(17, 'decrease', N'/dɪˈkriːs/', 'v.', N'減少；下降', 'decreased', 'decreased', 'The population has decreased in recent years.', N'近年來人口減少了。', NULL, NULL, 1, 'reduce (v.) 減少', 'increase (v.) 增加', 'price decrease (n.) 價格下降'),
(17, 'decrease', N'/ˈdiː.kriːs/', 'n.', N'減少；下降', NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL);
