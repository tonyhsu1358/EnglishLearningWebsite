using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class AISelectionResult : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        System.Diagnostics.Debug.WriteLine($"➡ [INFO] 進入 AISelectionResult.aspx - Session ID: {Session.SessionID}");

        if (!IsPostBack)
        {
            if (Session["UserEmail"] == null)
            {
                System.Diagnostics.Debug.WriteLine("❌ [ERROR] 使用者未登入，跳轉至登入頁面");
                Response.Redirect("UserLogin.aspx");
                return;
            }

            // ✅ 記錄 Session 內的值
            string userEmail = Session["UserEmail"].ToString();
            System.Diagnostics.Debug.WriteLine($"✅ [INFO] 目前登入用戶: {userEmail}");

            // ✅ 獲取用戶選擇的難度
            string difficulty = Session["SelectedDifficulty"]?.ToString() ?? "beginner";
            System.Diagnostics.Debug.WriteLine($"🎯 [INFO] 用戶選擇的難度: {difficulty}");

            LoadUserResults(difficulty);
            RewardUserWithDiamonds();

            // **確保 ViewState["DiamondsEarned"] 一定有值**
            if (ViewState["DiamondsEarned"] == null)
                ViewState["DiamondsEarned"] = 0;

            int diamondsEarned = (int)ViewState["DiamondsEarned"];
            string script = $"<script>var diamondsEarned = {diamondsEarned}; console.log('💎 獲得鑽石:', diamondsEarned);</script>";
            ClientScript.RegisterStartupScript(this.GetType(), "DiamondsScript", script);
        }
    }

    private void LoadUserResults(string difficulty)
    {
        string userEmail = Session["UserEmail"]?.ToString();
        string batchID = Session["CurrentBatchID"]?.ToString();

        string query = @"
        SELECT q.QuestionText, 
               a.SelectedAnswer, 
               q.CorrectAnswer, 
               a.IsCorrect,
               CASE a.SelectedAnswer
                    WHEN 'A' THEN q.OptionA
                    WHEN 'B' THEN q.OptionB
                    WHEN 'C' THEN q.OptionC
                    WHEN 'D' THEN q.OptionD
               END AS SelectedAnswerFull,
               CASE q.CorrectAnswer
                    WHEN 'A' THEN q.OptionA
                    WHEN 'B' THEN q.OptionB
                    WHEN 'C' THEN q.OptionC
                    WHEN 'D' THEN q.OptionD
               END AS CorrectAnswerFull
        FROM AI_UserAnswers a
        JOIN AI_GeneratedQuestions q ON a.QuestionID = q.QuestionID
        JOIN Users u ON a.user_id = u.user_id
        WHERE u.id_email = @UserEmail AND q.BatchID = @BatchID";

        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString))
        {
            conn.Open();
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserEmail", userEmail);
                cmd.Parameters.AddWithValue("@BatchID", batchID);
                SqlDataReader reader = cmd.ExecuteReader();
                gvUserResults.DataSource = reader;
                gvUserResults.DataBind();
            }
        }

        int correctCount = 0, totalQuestions = gvUserResults.Rows.Count;
        foreach (GridViewRow row in gvUserResults.Rows)
        {
            if (((Label)row.FindControl("lblResult")).Text.Contains("✔")) correctCount++;
        }

        double accuracy = totalQuestions > 0 ? Math.Round((double)correctCount / totalQuestions * 100, 2) : 0;
        lblScoreSummary.Text = $"答對題數: {correctCount} / {totalQuestions}，正確率: {accuracy}%";

        int level = GetUserLevel(accuracy, difficulty);

        /* ✅ 直接使用 Dictionary 搭配迴圈來設定按鈕樣式 */
        Dictionary<int, string> levelTextMap = new Dictionary<int, string>()
    {
        { 1, "CEFR A1 (TOEIC 120-225)" },
        { 2, "CEFR A2 (TOEIC 225-550)" },
        { 3, "CEFR B1 (TOEIC 550-785)" },
        { 4, "CEFR B2 (TOEIC 785-945)" },
        { 5, "CEFR C1 (TOEIC 945-990)" },
        { 6, "CEFR C2 (母語級)" }
    };

        Dictionary<int, string> levelClassMap = new Dictionary<int, string>()
    {
        { 1, "level-1" },
        { 2, "level-2" },
        { 3, "level-3" },
        { 4, "level-4" },
        { 5, "level-5" },
        { 6, "level-6" }
    };

        Dictionary<int, string> levelTooltipMap = new Dictionary<int, string>()
    {
    { 1, "🔰 挑戰 A1，從基礎開始！" },
    { 2, "💪 挑戰 A2，提升你的能力！" },
    { 3, "🚀 B1 挑戰來了！向更高層次邁進！" },
    { 4, "🔥 B2 高級挑戰！挑戰你的極限！" },
    { 5, "🌟 C1，接近母語者的程度！" },
    { 6, "🏆 C2 母語級！你行的！💯" }
    };

        string levelText = levelTextMap.ContainsKey(level) ? levelTextMap[level] : "CEFR A1 (TOEIC 120-225)";
        string levelClass = levelClassMap.ContainsKey(level) ? levelClassMap[level] : "level-1";
        string tooltipText = levelTooltipMap.ContainsKey(level) ? levelTooltipMap[level] : "🚀 立即挑戰此 LEVEL！";

        /* ✅ 設定按鈕樣式，確保一定會套用 */
        hlVocabularyGame.Text = levelText;
        hlVocabularyGame.CssClass = $"btn btn-level {levelClass}";
        hlVocabularyGame.NavigateUrl = $"VocabularyGame.aspx?level={level}";

        /* ✅ 設定 Tooltip */
        hlVocabularyGame.Attributes["title"] = tooltipText;
        hlVocabularyGame.Attributes["data-bs-toggle"] = "tooltip";
        hlVocabularyGame.Attributes["data-bs-placement"] = "top";
    }

    protected void RewardUserWithDiamonds()
    {
        string userEmail = Session["UserEmail"]?.ToString();
        string batchID = Session["CurrentBatchID"]?.ToString();

        if (string.IsNullOrEmpty(userEmail) || string.IsNullOrEmpty(batchID))
        {
            System.Diagnostics.Debug.WriteLine("❌ [ERROR] 缺少 UserEmail 或 BatchID，無法發放鑽石");
            return;
        }

        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString))
        {
            conn.Open();

            // 1️⃣ **獲取用戶 ID、最近一次領獎的 BatchID，以及目前的鑽石數**
            string getUserQuery = @"
        SELECT user_id, last_awarded_batch_id, 
               COALESCE(diamonds, 0), 
               COALESCE(diamonds_ai_test, 0), 
               COALESCE(diamonds_total, 0)
        FROM UserResources 
        WHERE user_id = (SELECT user_id FROM Users WHERE id_email = @UserEmail)";

            int userId = -1, currentDiamonds = 0, currentAiDiamonds = 0, currentTotalDiamonds = 0;
            string lastAwardedBatch = null;

            using (SqlCommand cmd = new SqlCommand(getUserQuery, conn))
            {
                cmd.Parameters.AddWithValue("@UserEmail", userEmail);
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        userId = reader.GetInt32(0);
                        lastAwardedBatch = reader.IsDBNull(1) ? null : reader.GetString(1);
                        currentDiamonds = reader.GetInt32(2);
                        currentAiDiamonds = reader.GetInt32(3);
                        currentTotalDiamonds = reader.GetInt32(4);
                    }
                }
            }

            if (userId == -1)
            {
                System.Diagnostics.Debug.WriteLine("❌ [ERROR] 無法找到用戶 ID，發放鑽石失敗");
                return;
            }

            // 2️⃣ **檢查是否已經領取過該測驗的鑽石**
            if (lastAwardedBatch == batchID)
            {
                System.Diagnostics.Debug.WriteLine($"⚠ [WARN] 用戶 {userEmail} 已經領取過 Batch {batchID} 的鑽石，拒絕發放");
                lblDiamonds.Text = "⚠ 已領取過獎勵，無法重複領取！";
                lblDiamonds.CssClass = "diamond-label warning";
                return;
            }

            // 3️⃣ **計算可獲得的鑽石**
            int correctCount = 0, totalQuestions = gvUserResults.Rows.Count;
            foreach (GridViewRow row in gvUserResults.Rows)
            {
                if (((Label)row.FindControl("lblResult")).Text.Contains("✔")) correctCount++;
            }

            if (totalQuestions == 0) return;
            int diamondsToAdd = (int)Math.Ceiling(totalQuestions * ((double)correctCount / totalQuestions)); // **無條件進位**

            // **新鑽石計算**
            int newDiamonds = currentDiamonds + diamondsToAdd;
            int newAiDiamonds = currentAiDiamonds + diamondsToAdd;
            int newTotalDiamonds = currentTotalDiamonds + diamondsToAdd;

            // 4️⃣ **更新 `diamonds`、`diamonds_ai_test`、`diamonds_total`，並更新 `last_awarded_batch_id`**
            string updateDiamondsQuery = @"
        UPDATE UserResources 
        SET diamonds = @NewDiamonds, 
            diamonds_ai_test = @NewAiDiamonds,
            diamonds_total = @NewTotalDiamonds,
            last_awarded_batch_id = @BatchID 
        WHERE user_id = @UserId";

            using (SqlCommand cmd = new SqlCommand(updateDiamondsQuery, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@NewDiamonds", newDiamonds);
                cmd.Parameters.AddWithValue("@NewAiDiamonds", newAiDiamonds);
                cmd.Parameters.AddWithValue("@NewTotalDiamonds", newTotalDiamonds);
                cmd.Parameters.AddWithValue("@BatchID", batchID);
                int rowsAffected = cmd.ExecuteNonQuery();

                if (rowsAffected > 0)
                {
                    System.Diagnostics.Debug.WriteLine($"✅ [SUCCESS] 用戶 {userEmail} 獲得 {diamondsToAdd} 顆鑽石！(Batch: {batchID})");
                    System.Diagnostics.Debug.WriteLine($"💎 [INFO] 新總鑽石數: {newDiamonds}，AI 測驗總數: {newAiDiamonds}，鑽石總計: {newTotalDiamonds}");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("❌ [ERROR] SQL 執行成功，但沒有更新任何資料");
                }
            }

            // ✅ **更新 UI 顯示獎勵**
            lblDiamonds.Text = $"🎉 恭喜！你獲得了 <span style='font-weight: bold;'>{diamondsToAdd}</span> 顆鑽石！";
            lblDiamonds.CssClass = "diamond-label success";
        }
    }


    private int GetUserLevel(double accuracy, string difficulty)
    {
        int level = 1; // 預設 A1

        if (accuracy >= 95) level = 6; // C2
        else if (accuracy >= 85) level = 5; // C1
        else if (accuracy >= 70) level = 4; // B2
        else if (accuracy >= 55) level = 3; // B1
        else if (accuracy >= 40) level = 2; // A2

        // **根據難度限制最高等級**
        switch (difficulty.ToLower())
        {
            case "beginner": // 普通模式
                level = Math.Min(level, 2); // 最高 A2
                break;
            case "intermediate": // 中等模式
                level = Math.Min(level, 3); // 最高 B1
                break;
            case "advanced": // 高級模式
                level = Math.Min(level, 4); // 最高 B2
                break;
            case "expert": // 進階模式
                level = Math.Min(level, 6); // 最高 C2 (不限制)
                break;
        }

        return level;
    }
}
