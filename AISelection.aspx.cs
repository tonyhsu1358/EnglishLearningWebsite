using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Net.Http;
using System.Text;
using Newtonsoft.Json;
using System.Threading.Tasks;
using System.Linq;
using System.Web.UI.WebControls;
using System.Web.UI;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.IO;
using System.Web;
using static AISelection;

public partial class AISelection : System.Web.UI.Page
{
    public class Question
    {
        public int QuestionID { get; set; }
        public string QuestionText { get; set; }
        public List<Option> Options { get; set; }
    }

    public class Option
    {
        public string Text { get; set; }
        public string Value { get; set; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            System.Diagnostics.Debug.WriteLine(" [DEBUG] 首次進入網頁，初始化測驗");

            // 檢查隱藏欄位，判斷使用者是否直接關閉網頁
            if (hfPageUnloaded.Value == "false" && Session["CurrentBatchID"] != null && ViewState["UserAnswers"] == null)
            {
                // 清除 Session
                Session["CurrentBatchID"] = null;
                System.Diagnostics.Debug.WriteLine("⚠ [WARNING] 使用者未提交答案就離開頁面，清除 `Session[CurrentBatchID]`");
            }

            // 重置隱藏欄位
            hfPageUnloaded.Value = "false";

            // 清除題目相關狀態
            pnlQuestions.Controls.Clear();
            ViewState["UserAnswers"] = null;
            ViewState["GeneratedQuestions"] = null;

            // 檢查 Session["CurrentBatchID"] 是否存在
            if (Session["CurrentBatchID"] == null)
            {
                System.Diagnostics.Debug.WriteLine("⚠ [WARNING] `Session[CurrentBatchID]` 為 NULL，請重新產生題目！");
                btnSubmit.Visible = false;
                return;
            }

            System.Diagnostics.Debug.WriteLine($" [INFO] 使用 `Session[CurrentBatchID]={Session["CurrentBatchID"]}` 來載入題目");

            // 從資料庫載入題目
            LoadQuestionsFromDatabase();

            // 根據題目數量顯示提交按鈕
            btnSubmit.Visible = pnlQuestions.Controls.Count > 0;
        }
        else
        {
            // 確保 Postback 時，動態控制項不會遺失
            if (Session["CurrentBatchID"] != null)
            {
                LoadQuestionsFromDatabase();
            }
        }
    }

    // 📌 **Page_Unload 事件：當使用者離開頁面但未提交答案時，清除 Session**
    protected void Page_Unload(object sender, EventArgs e)
    {
        if (Session["CurrentBatchID"] == null && ViewState["UserAnswers"] == null)
        {
            System.Diagnostics.Debug.WriteLine("⚠ [WARNING] 使用者未提交答案就離開頁面，清除 `Session[CurrentBatchID]`");
            Session["CurrentBatchID"] = null;
        }
    }
    protected async void btnAskAI_Click(object sender, EventArgs e)
    {
        // 在伺服器端禁用按鈕
        btnAskAI.Enabled = false;

        // 在客戶端禁用按鈕
        //ClientScript.RegisterStartupScript(this.GetType(), "disableButton", "document.getElementById('" + btnAskAI.ClientID + "').disabled = true;", true);

        try
        {
            // ✅ **確保 Session 裡的 BatchID 不會影響新題目**
            Session["CurrentBatchID"] = null;
            ViewState["CurrentBatchID"] = null;

            string apiKey = ConfigurationManager.AppSettings["GeminiAPIKey"];
            string questionCount = ddlQuestionCount.SelectedValue;
            string difficulty = ddlDifficulty.SelectedValue;
            string topic = hfSelectedTopics.Value.Trim();
            if (string.IsNullOrEmpty(topic)) topic = "any";

            // **產生新的 BatchID**
            Guid newBatchID = Guid.NewGuid();
            System.Diagnostics.Debug.WriteLine($"📌 [INFO] 產生新的 BatchID: {newBatchID}");
            System.Diagnostics.Debug.WriteLine($"🚀 [DEBUG] 按下 AI 產生按鈕！新的 BatchID: {newBatchID}");


            // ✅ **立即更新 Session & ViewState**
            Session["CurrentBatchID"] = newBatchID;
            ViewState["CurrentBatchID"] = newBatchID;

            System.Diagnostics.Debug.WriteLine($"📌 [INFO] `Session[CurrentBatchID]` 設定為 {Session["CurrentBatchID"]}");

            // 🔥 **確認 `Session["CurrentBatchID"]` 真的變更**
            if (Session["CurrentBatchID"] == null || (Guid)Session["CurrentBatchID"] != newBatchID)
            {
                System.Diagnostics.Debug.WriteLine($"❌ [ERROR] `Session[CurrentBatchID]` 沒有成功更新！");
                return;
            }

            // ✅ **完整保留你的 AI 提示詞**
            string aiPrompt = $@"
You are an expert TOEIC question-generating AI assistant. Please generate **EXACTLY {questionCount}** TOEIC multiple-choice questions.
The difficulty level is: {difficulty}, and the topic is: {topic}.

🔹 **⚠️ CRITICAL REQUIREMENTS (STRICTLY FOLLOW THESE RULES)**
1️⃣ **Generate EXACTLY {questionCount} questions.**
   - ✅ **If the number of questions is less than {questionCount}, retry until there are exactly {questionCount} questions.**
   - ✅ **Internally verify that the output contains exactly {questionCount} questions before responding.**
   - ❌ **DO NOT return fewer or more than {questionCount} questions.**
   - 🚨 **If AI fails to generate {questionCount} questions in one attempt, retry internally until success.**
   - 🛑 **Failure to generate {questionCount} questions is NOT ACCEPTABLE. Regenerate until it is correct.**

2️⃣ **The correct answer must be RANDOMLY placed in A, B, C, or D.**
   - 🔄 **Ensure that the correct answer is randomly assigned to A, B, C, or D for each question.**
   - ✅ **Clearly mark which option (A, B, C, or D) is the correct answer.**
   - ❌ **DO NOT generate a question where more than one option could be a correct answer.**
   - 🚨 **Before finalizing, VERIFY that ONLY one option is correct. If unsure, regenerate.**

3️⃣ **The incorrect options (B, C, D) must be meaningfully distinct and incorrect.**
   - 🚫 **They must NOT be synonyms or minor variations of the correct answer.**
   - 🚫 **They must NOT be valid in any interpretation of the sentence.**
   - 🛑 **If any incorrect option could be valid, REWRITE THE QUESTION.**

4️⃣ **Ensure that the questions adhere to the TOEIC format:**
   - 📌 **Use natural, professional, and unambiguous sentence structures.**
   - 📌 **Avoid vague wording or overly complex grammar.**
   - 📌 **Ensure each sentence has a clear and single correct answer.**

5️⃣ **Before outputting the JSON response, perform a strict validation:**
   - ✅ **CONFIRM that exactly {questionCount} questions are generated.**
   - ✅ **DO NOT return fewer or more than {questionCount} questions.**
   - 🚨 **If AI is uncertain whether the number of questions is correct, regenerate the response until it is exactly {questionCount}.**
   - ❌ **DO NOT output the question if the correct answer is ambiguous.**

6️⃣ **Output must strictly follow the given JSON format. DO NOT include explanations, annotations, or non-JSON content.**  

---  

🔹 **✅ JSON Format Example (STRICTLY FOLLOW THIS STRUCTURE)**:
```json
{{
    ""questions"": [
        {{
            ""question"": ""All clothing sold in Develyn’s Boutique is made from natural materials and contains no ___ dyes."",
            ""options"": {{
                ""A"": ""immediate"",  // ❌ Incorrect
                ""B"": ""synthetic"",  // ✅ Correct answer (randomized position)
                ""C"": ""reasonable"", // ❌ Incorrect
                ""D"": ""assumed""     // ❌ Incorrect
            }},
            ""correct"": ""B""        // ✅ Correct answer is randomly assigned
        }},
        {{
            ""question"": ""The manager was impressed by the applicant’s ___ experience in project management."",
            ""options"": {{
                ""A"": ""extensive"",  // ✅ Correct answer (randomized position)
                ""B"": ""temporary"",  // ❌ Incorrect
                ""C"": ""frequent"",   // ❌ Incorrect
                ""D"": ""moderate""    // ❌ Incorrect
            }},
            ""correct"": ""A""        // ✅ Correct answer is randomly assigned
        }}
    ]
}}";

            string aiResponse = await GetAIResponse(aiPrompt, apiKey);


            if (string.IsNullOrEmpty(aiResponse))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('AI 生成題目失敗，請稍後再試。');", true);
                btnAskAI.Enabled = true;
                return;
            }

            // ✅ **確保 `BatchID` 被更新後再存入題目**
            SaveQuestionsToDatabase(aiResponse, difficulty, topic, newBatchID);

            // 🚀 **確認 SQL 真的有新題目**
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString))
            {
                conn.Open();
                string checkQuery = "SELECT COUNT(*) FROM AI_GeneratedQuestions WHERE BatchID = @BatchID";
                using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@BatchID", newBatchID);
                    int count = Convert.ToInt32(cmd.ExecuteScalar());

                    if (count > 0)
                    {
                        System.Diagnostics.Debug.WriteLine($"✅ [INFO] 成功存入新題目，共 {count} 題！");

                        // **只有在確認存入後，才更新 Session 和 ViewState**
                        Session["CurrentBatchID"] = newBatchID;
                        ViewState["CurrentBatchID"] = newBatchID;
                        System.Diagnostics.Debug.WriteLine($"📌 [INFO] `Session[CurrentBatchID]` 更新為最新 BatchID: {Session["CurrentBatchID"]}");
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine($"❌ [ERROR] `BatchID={newBatchID}` 內沒有成功存入新題目！");
                        ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('AI 題目存入失敗，請稍後再試！');", true);
                        return;
                    }
                }
            }

            // ✅ **立即載入最新的題目**
            LoadQuestionsFromDatabase();
            btnSubmit.Visible = true;
            btnAskAI.Enabled = false; //成功產生題目後設定為disable
            //ClientScript.RegisterStartupScript(this.GetType(), "enableButton", "document.getElementById('" + btnAskAI.ClientID + "').disabled = false;", true);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"❌ [ERROR] 生成題目時發生錯誤: {ex.Message}");
            ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('發生錯誤，請稍後再試！');", true);
            //ClientScript.RegisterStartupScript(this.GetType(), "enableButton", "document.getElementById('" + btnAskAI.ClientID + "').disabled = false;", true);
        }
        finally
        {
            // 如果成功產生題目就不需要設定為enable
            if (btnSubmit.Visible == false)
            {
                btnAskAI.Enabled = true;
            }
        }
    }

    private async Task<string> GetAIResponse(string userInput, string apiKey)
    {
        string apiUrl = $"https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key={apiKey}";

        using (HttpClient client = new HttpClient())
        {
            try
            {
                // 🔍 **準備請求資料**
                var requestData = new
                {
                    contents = new[]
                    {
                    new { parts = new[] { new { text = userInput } } }
                }
                };

                string jsonRequest = JsonConvert.SerializeObject(requestData);
                HttpContent httpContent = new StringContent(jsonRequest, Encoding.UTF8, "application/json");

                System.Diagnostics.Debug.WriteLine($"📤 [DEBUG] 發送請求到 Gemini API...");

                // 🔥 **發送請求**
                HttpResponseMessage response = await client.PostAsync(apiUrl, httpContent);

                // 🚨 **確保 API 回應成功**
                if (!response.IsSuccessStatusCode)
                {
                    string errorMsg = await response.Content.ReadAsStringAsync();
                    System.Diagnostics.Debug.WriteLine($"❌ [ERROR] Gemini API 回應錯誤: {response.StatusCode} - {errorMsg}");
                    return null;
                }

                // ✅ **取得 AI 回應的 JSON**
                string jsonResponse = await response.Content.ReadAsStringAsync();

                // 📌 **存檔到本地 (網站根目錄 AI_Response.json)**
                //string filePath = HttpContext.Current.Server.MapPath("~/AI_Response.json");
                //File.WriteAllText(filePath, jsonResponse, Encoding.UTF8);
                //System.Diagnostics.Debug.WriteLine($"✅ [INFO] AI 生成的 JSON 存到 {filePath}");

                return jsonResponse;
            }
            catch (HttpRequestException httpEx)
            {
                System.Diagnostics.Debug.WriteLine($"❌ [ERROR] HTTP 請求失敗: {httpEx.Message}");
            }
            catch (IOException ioEx)
            {
                System.Diagnostics.Debug.WriteLine($"❌ [ERROR] 存檔失敗: {ioEx.Message}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ [ERROR] 未知錯誤: {ex.Message}");
            }

            return null;
        }
    }
    // 📌 **將 AI 生成的題目存入 SQL Server，並補充題目（若不足）**
    private void SaveQuestionsToDatabase(string jsonResponse, string difficulty, string topic, Guid batchID)
    {
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString))
        {
            conn.Open();
            System.Diagnostics.Debug.WriteLine($"📌 [INFO] 確保 `SaveQuestionsToDatabase()` 內部 BatchID = {batchID}");

            try
            {
                // 🔍 **解析 AI 回應的 JSON**
                JObject parsedJson = JObject.Parse(jsonResponse);

                if (parsedJson["candidates"] == null || !parsedJson["candidates"].Any())
                {
                    System.Diagnostics.Debug.WriteLine("❌ [ERROR] AI 回應格式錯誤，找不到 `candidates`！");
                    ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('AI 生成的題目格式錯誤，請稍後再試！');", true);
                    return;
                }

                // **擷取 AI 生成的 JSON 內容**
                string extractedJson = parsedJson["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]?.ToString()?.Trim();
                if (string.IsNullOrEmpty(extractedJson))
                {
                    System.Diagnostics.Debug.WriteLine("❌ [ERROR] AI 回應 JSON 內容為空！");
                    ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('AI 生成的題目格式錯誤，請稍後再試！');", true);
                    return;
                }

                // **移除可能的 Markdown JSON 標籤**
                if (extractedJson.StartsWith("```json"))
                {
                    extractedJson = extractedJson.Substring(7);
                }
                if (extractedJson.EndsWith("```"))
                {
                    extractedJson = extractedJson.Substring(0, extractedJson.Length - 3);
                }

                JObject finalJson = JObject.Parse(extractedJson);
                if (finalJson["questions"] == null || !finalJson["questions"].Any())
                {
                    System.Diagnostics.Debug.WriteLine("❌ [ERROR] AI JSON 沒有 `questions` 字段！");
                    ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('AI 生成的題目格式錯誤，請稍後再試！');", true);
                    return;
                }

                int expectedCount = Convert.ToInt32(ddlQuestionCount.SelectedValue);
                int questionCount = finalJson["questions"].Count();
                System.Diagnostics.Debug.WriteLine($"📌 [INFO] AI 生成的題數: {questionCount}，應該要 {expectedCount} 題");

                int insertedCount = 0;

                // ✅ **逐題寫入資料庫**
                foreach (var questionToken in finalJson["questions"])
                {
                    if (!(questionToken is JObject question))
                    {
                        System.Diagnostics.Debug.WriteLine("❌ [ERROR] `question` 不是有效的 JObject，跳過該題！");
                        continue;
                    }

                    string questionText = question["question"]?.ToString()?.Trim();
                    if (string.IsNullOrEmpty(questionText))
                    {
                        System.Diagnostics.Debug.WriteLine("❌ [ERROR] `questionText` 為空，跳過該題！");
                        continue;
                    }

                    // 🔍 **檢查 `options` 是否存在**
                    JToken optionsToken;
                    if (!question.TryGetValue("options", out optionsToken) || optionsToken == null)
                    {
                        System.Diagnostics.Debug.WriteLine($"❌ [ERROR] `options` 欄位不存在！跳過該題！");
                        continue;
                    }

                    JObject options = optionsToken as JObject;
                    if (options == null || !options.ContainsKey("A") || !options.ContainsKey("B") || !options.ContainsKey("C") || !options.ContainsKey("D"))
                    {
                        System.Diagnostics.Debug.WriteLine($"❌ [ERROR] `options` 缺少 A/B/C/D 選項！跳過該題！");
                        continue;
                    }

                    // **安全地取得選項，防止 `null`**
                    string optionA = options["A"]?.ToString() ?? "N/A";
                    string optionB = options["B"]?.ToString() ?? "N/A";
                    string optionC = options["C"]?.ToString() ?? "N/A";
                    string optionD = options["D"]?.ToString() ?? "N/A";

                    // **取得正確答案**
                    string correctAnswer = question["correct"]?.ToString()?.Trim();
                    if (string.IsNullOrEmpty(correctAnswer))
                    {
                        System.Diagnostics.Debug.WriteLine($"❌ [ERROR] `correct` 欄位不存在！跳過該題！");
                        continue;
                    }

                    // ✅ **直接存入資料庫**
                    string query = @"
                INSERT INTO AI_GeneratedQuestions (QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer, Difficulty, Topic, BatchID) 
                VALUES (@QuestionText, @OptionA, @OptionB, @OptionC, @OptionD, @CorrectAnswer, @Difficulty, @Topic, @BatchID)";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@QuestionText", questionText);
                        cmd.Parameters.AddWithValue("@OptionA", optionA);
                        cmd.Parameters.AddWithValue("@OptionB", optionB);
                        cmd.Parameters.AddWithValue("@OptionC", optionC);
                        cmd.Parameters.AddWithValue("@OptionD", optionD);
                        cmd.Parameters.AddWithValue("@CorrectAnswer", correctAnswer);
                        cmd.Parameters.AddWithValue("@Difficulty", difficulty);
                        cmd.Parameters.AddWithValue("@Topic", topic);
                        cmd.Parameters.AddWithValue("@BatchID", batchID);

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            insertedCount++;
                            System.Diagnostics.Debug.WriteLine($"✅ 成功插入題目: {questionText}");
                        }
                        else
                        {
                            System.Diagnostics.Debug.WriteLine($"❌ [ERROR] 題目插入失敗: {questionText}");
                        }
                    }
                }

                // 🚨 **檢查是否需要補充題目**
                int remaining = expectedCount - insertedCount;
                if (remaining > 0)
                {
                    System.Diagnostics.Debug.WriteLine($"⚠ [WARNING] AI 只生成了 {insertedCount} 題，將補充 {remaining} 題！");
                    List<int> addedQuestionIDs = new List<int>();
                    List<int> questionIDsToUpdate = new List<int>();

                    string selectQuery = @"
                SELECT TOP (@RemainingCount) QuestionID 
                 FROM AI_GeneratedQuestions 
                  WHERE BatchID != @BatchID 
                   ORDER BY NEWID()
                     "; // 隨機選擇

                    // 🚀 **先讀取要補充的 QuestionIDs**
                    using (SqlCommand selectCmd = new SqlCommand(selectQuery, conn))
                    {
                        selectCmd.Parameters.AddWithValue("@RemainingCount", remaining);
                        selectCmd.Parameters.AddWithValue("@Difficulty", difficulty);
                        selectCmd.Parameters.AddWithValue("@Topic", topic);
                        selectCmd.Parameters.AddWithValue("@BatchID", batchID);

                        using (SqlDataReader reader = selectCmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                questionIDsToUpdate.Add(Convert.ToInt32(reader["QuestionID"]));
                            }
                        }
                    }

                    // 🚀 **更新 BatchID 以匹配當前批次**
                    if (questionIDsToUpdate.Count > 0)
                    {
                        string updateQuery = "UPDATE AI_GeneratedQuestions SET BatchID = @NewBatchID WHERE QuestionID = @QuestionID";

                        foreach (int questionID in questionIDsToUpdate)
                        {
                            using (SqlCommand updateCmd = new SqlCommand(updateQuery, conn))
                            {
                                updateCmd.Parameters.AddWithValue("@NewBatchID", batchID);
                                updateCmd.Parameters.AddWithValue("@QuestionID", questionID);
                                int rowsAffected = updateCmd.ExecuteNonQuery();
                                if (rowsAffected > 0)
                                {
                                    addedQuestionIDs.Add(questionID);
                                }
                            }
                            System.Diagnostics.Debug.WriteLine($"✅ [INFO] 已更新補充題目的 BatchID = {batchID} (QuestionID = {questionID})");
                        }
                    }
                    System.Diagnostics.Debug.WriteLine($"✅ [INFO] 已補充 {addedQuestionIDs.Count} 題，確保總數為 {expectedCount} 題！");
                }

                System.Diagnostics.Debug.WriteLine($"📌 [INFO] 最終存入 {insertedCount} / {expectedCount} 題到資料庫！");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ [ERROR] 未知錯誤: {ex.Message}");
            }
        }
    }


    private void LoadQuestionsFromDatabase()
    {
        System.Diagnostics.Debug.WriteLine("🔍 [DEBUG] 讀取最新一批 AI 題目");
        ViewState["GeneratedQuestions"] = null;

        // ✅ **強制檢查 `Session["CurrentBatchID"]` 是否存在**
        if (Session["CurrentBatchID"] == null)
        {
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString))
            {
                conn.Open();
                string getLatestBatchQuery = "SELECT TOP 1 BatchID FROM AI_GeneratedQuestions ORDER BY QuestionID DESC";
                using (SqlCommand cmd = new SqlCommand(getLatestBatchQuery, conn))
                {
                    object latestBatchID = cmd.ExecuteScalar();
                    if (latestBatchID != null)
                    {
                        Session["CurrentBatchID"] = (Guid)latestBatchID;
                        System.Diagnostics.Debug.WriteLine($"📌 [INFO] `Session[CurrentBatchID]` 更新為最新 BatchID: {latestBatchID}");
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("⚠ [WARNING] 沒有找到可用的 BatchID，無法載入題目");
                        return;
                    }
                }
            }
        }

        Guid currentBatchID = (Guid)Session["CurrentBatchID"];
        System.Diagnostics.Debug.WriteLine($"📌 [INFO] 使用 `BatchID={currentBatchID}` 來載入題目");

        pnlQuestions.Controls.Clear();
        List<Question> questionList = new List<Question>();

        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString))
        {
            conn.Open();
            string query = "SELECT * FROM AI_GeneratedQuestions WHERE BatchID = @BatchID ORDER BY QuestionID DESC";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@BatchID", currentBatchID);
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int questionID = Convert.ToInt32(reader["QuestionID"]);
                        string questionText = reader["QuestionText"].ToString();
                        string optionA = reader["OptionA"].ToString();
                        string optionB = reader["OptionB"].ToString();
                        string optionC = reader["OptionC"].ToString();
                        string optionD = reader["OptionD"].ToString();
                        string correctAnswer = reader["CorrectAnswer"].ToString().Trim(); // 取得正確答案

                        System.Diagnostics.Debug.WriteLine($"📌 [INFO] 題目載入: QuestionID={questionID}, Text={questionText}");

                        List<Option> options = new List<Option>
                    {
                        new Option { Text = optionA, Value = "A" },
                        new Option { Text = optionB, Value = "B" },
                        new Option { Text = optionC, Value = "C" },
                        new Option { Text = optionD, Value = "D" }
                    };

                        // 洗牌選項
                        Random rng = new Random();
                        int n = options.Count;
                        while (n > 1)
                        {
                            n--;
                            int k = rng.Next(n + 1);
                            Option value = options[k];
                            options[k] = options[n];
                            options[n] = value;
                        }

                        // 確保正確答案的關聯
                        bool correctAnswerFound = false;
                        foreach (var option in options)
                        {
                            if (option.Value.Equals(correctAnswer, StringComparison.OrdinalIgnoreCase))
                            {
                                correctAnswerFound = true;
                                break;
                            }
                        }
                        if (!correctAnswerFound)
                        {
                            System.Diagnostics.Debug.WriteLine($"❌ [ERROR] QuestionID={questionID} 的正確答案驗證失敗！");
                        }

                        Question newQuestion = new Question
                        {
                            QuestionID = questionID,
                            QuestionText = questionText,
                            Options = options // 使用洗牌後的選項
                        };

                        questionList.Add(newQuestion);
                        DisplayQuestion(newQuestion);
                    }
                }
            }
        }

        System.Diagnostics.Debug.WriteLine($"📌 [INFO] 載入完成，共 {questionList.Count} 題");
        Session["GeneratedQuestions"] = JsonConvert.SerializeObject(questionList);
        btnSubmit.Visible = pnlQuestions.Controls.Count > 0;
    }


    private void DisplayQuestion(Question question)
    {
        Panel questionPanel = new Panel { CssClass = "question-style" };

        Label lblQuestion = new Label { Text = $"<strong>{question.QuestionText}</strong>" };
        questionPanel.Controls.Add(lblQuestion);

        RadioButtonList options = new RadioButtonList { ID = "q" + question.QuestionID, CssClass = "radio-options" };

        foreach (var option in question.Options)
        {
            options.Items.Add(new ListItem(option.Text, option.Value));
        }

        // **確認選項有被成功加入**
        if (options.Items.Count > 0)
        {
            questionPanel.Controls.Add(new Literal { Text = "<br>" });
            questionPanel.Controls.Add(options);
            pnlQuestions.Controls.Add(questionPanel);
            System.Diagnostics.Debug.WriteLine($"✅ [INFO] 題目載入成功 - ID: {options.ID}, Text: {question.QuestionText}");
        }
        else
        {
            System.Diagnostics.Debug.WriteLine($"⚠ [WARNING] `QuestionID={question.QuestionID}` 沒有可用的選項！");
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        System.Diagnostics.Debug.WriteLine("🔍 [DEBUG] 提交答案");
        System.Diagnostics.Debug.WriteLine($"📌 [INFO] `pnlQuestions.Controls.Count` = {pnlQuestions.Controls.Count}");

        if (Session["UserEmail"] == null)
        {
            System.Diagnostics.Debug.WriteLine("❌ [ERROR] 使用者未登入，跳轉 UserLogin.aspx");
            Response.Redirect("UserLogin.aspx");
            return;
        }
        // ✅ **取得使用者 Email**
        string userEmail = Session["UserEmail"].ToString();
        int correctCount = 0;
        int totalQuestions = 0;
        Dictionary<int, string> userAnswers = new Dictionary<int, string>(); // 存放作答紀錄

        System.Diagnostics.Debug.WriteLine("📌 [INFO] 開始遍歷題目...");

        foreach (Panel questionPanel in pnlQuestions.Controls.OfType<Panel>())
        {
            foreach (RadioButtonList rbl in questionPanel.Controls.OfType<RadioButtonList>())
            {
                string selectedAnswer = rbl.SelectedValue;
                if (string.IsNullOrEmpty(selectedAnswer))
                {
                    System.Diagnostics.Debug.WriteLine($"⚠ [WARNING] `RadioButtonList ID={rbl.ID}` 沒有被選擇，跳過");
                    continue;
                }

                if (!int.TryParse(rbl.ID.Replace("q", ""), out int questionId))
                {
                    System.Diagnostics.Debug.WriteLine($"❌ [ERROR] `RadioButtonList ID={rbl.ID}` 無法解析為 `QuestionID`，跳過");
                    continue;
                }

                bool isCorrect = CheckAnswer(questionId, selectedAnswer);
                if (isCorrect) correctCount++;
                totalQuestions++;

                userAnswers[questionId] = selectedAnswer;
                // 🚀 **加入 `SaveUserAnswer()` 存入資料庫**
                SaveUserAnswer(userEmail, questionId, selectedAnswer, isCorrect);
            }
        }

        System.Diagnostics.Debug.WriteLine($"📌 [INFO] 測驗結束 - 總題數: {totalQuestions}, 答對: {correctCount}");

        ViewState["UserAnswers"] = userAnswers;
        ViewState["GeneratedQuestions"] = null;

        pnlQuestions.Controls.Clear();
        btnSubmit.Visible = false;

        Session["CorrectCount"] = correctCount;
        Session["TotalQuestions"] = totalQuestions;

        System.Diagnostics.Debug.WriteLine($"📌 [INFO] 提交答案後不清除 `Session[CurrentBatchID]`，確保測驗結果可以讀取");

        System.Threading.Thread.Sleep(500); // 讓系統稍微等待 0.5 秒，確保 Session 變更生效
        Response.Redirect("AISelectionResult.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }


    private bool CheckAnswer(int questionId, string selectedAnswer)
    {
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString))
        {
            conn.Open();
            string query = "SELECT CorrectAnswer FROM AI_GeneratedQuestions WHERE QuestionID = @QuestionID";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@QuestionID", questionId);
                object correctAnswer = cmd.ExecuteScalar();

                if (correctAnswer == null)
                {
                    System.Diagnostics.Debug.WriteLine($"❌ [ERROR] `QuestionID={questionId}` 沒有找到正確答案！");
                    return false;
                }

                string correctAnswerStr = correctAnswer.ToString().Trim();
                System.Diagnostics.Debug.WriteLine($"✅ [INFO] `QuestionID={questionId}` 的正確答案: {correctAnswerStr}");

                return selectedAnswer.Trim().Equals(correctAnswerStr, StringComparison.OrdinalIgnoreCase);
            }
        }
    }


    private void SaveUserAnswer(string userEmail, int questionId, string selectedAnswer, bool isCorrect)
    {
        int userID = -1;
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString))
        {
            conn.Open();
            try
            {
                System.Diagnostics.Debug.WriteLine($"🔍 [DEBUG] 嘗試儲存作答記錄: UserEmail={userEmail}, QuestionID={questionId}, 選擇={selectedAnswer}, 是否正確={isCorrect}");

                // 🔍 **查詢 UserID**
                string getUserIdQuery = "SELECT user_id FROM Users WHERE id_email = @UserEmail";
                using (SqlCommand userCmd = new SqlCommand(getUserIdQuery, conn))
                {
                    userCmd.Parameters.AddWithValue("@UserEmail", userEmail);
                    object result = userCmd.ExecuteScalar();

                    if (result != null && result != DBNull.Value)
                    {
                        userID = Convert.ToInt32(result);
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine($"❌ [ERROR] 找不到 `UserEmail={userEmail}` 對應的 `UserID`");
                        return;
                    }
                }

                System.Diagnostics.Debug.WriteLine($"✅ [INFO] 查詢 `UserID` 成功，UserID={userID}");

                // 🔍 **確認 `QuestionID` 是否有效**
                string checkQuestionQuery = "SELECT COUNT(*) FROM AI_GeneratedQuestions WHERE QuestionID = @QuestionID";
                using (SqlCommand checkCmd = new SqlCommand(checkQuestionQuery, conn))
                {
                    checkCmd.Parameters.AddWithValue("@QuestionID", questionId);
                    int count = Convert.ToInt32(checkCmd.ExecuteScalar());

                    if (count == 0)
                    {
                        System.Diagnostics.Debug.WriteLine($"❌ [ERROR] `QuestionID={questionId}` 不存在！");
                        return;
                    }
                }

                System.Diagnostics.Debug.WriteLine($"✅ [INFO] `QuestionID` 存在，準備寫入 AI_UserAnswers");

                // 🔥 **SQL INSERT**
                string insertQuery = @"
            INSERT INTO AI_UserAnswers (user_id, QuestionID, SelectedAnswer, IsCorrect, AnsweredAt) 
            VALUES (@UserID, @QuestionID, @SelectedAnswer, @IsCorrect, @AnsweredAt)";

                using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userID);
                    cmd.Parameters.AddWithValue("@QuestionID", questionId);
                    cmd.Parameters.AddWithValue("@SelectedAnswer", selectedAnswer);
                    cmd.Parameters.AddWithValue("@IsCorrect", isCorrect);
                    cmd.Parameters.AddWithValue("@AnsweredAt", DateTime.Now);

                    int rowsAffected = cmd.ExecuteNonQuery();
                    if (rowsAffected > 0)
                    {
                        System.Diagnostics.Debug.WriteLine($"✅ [INFO] 作答記錄插入成功: UserID={userID}, QuestionID={questionId}, 選擇={selectedAnswer}, 是否正確={isCorrect}");
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine($"❌ [ERROR] 作答記錄插入失敗: UserID={userID}, QuestionID={questionId}");
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                System.Diagnostics.Debug.WriteLine($"❌ [ERROR] SQL 錯誤: {sqlEx.Message}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ [ERROR] 未知錯誤: {ex.Message}");
            }
        }
    }


}