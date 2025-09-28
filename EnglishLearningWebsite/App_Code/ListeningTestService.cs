using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[ScriptService] // ✅ 允許 AJAX 呼叫（才能被前端 fetch 使用）
public class ListeningTestService : WebService
{
    // 連線字串，從 Web.config 讀取
    private string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

    // =======================================================
    // ✅ 方法一：取得題目（依用戶選擇的主題 & 題數）
    // =======================================================
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public List<object> GetQuestions(List<int> topicIds, int questionCount)
    {
        var results = new List<object>();

        // 1️⃣ 確認使用者是否登入
        if (HttpContext.Current.Session["UserID"] == null)
        {
            results.Add(new { error = "NOT_LOGGED_IN" });
            return results;
        }

        // 2️⃣ 參數檢查
        if (topicIds == null || topicIds.Count == 0 || questionCount <= 0)
        {
            results.Add(new { error = "INVALID_PARAM" });
            return results;
        }

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // 3️⃣ 把選到的 TopicID 串成字串 (e.g. "1,2,3")
            string ids = string.Join(",", topicIds);

            // 4️⃣ SQL 語法：從 Listening_Questions 隨機取題
            string query = $@"
SELECT TOP (@Count) 
    q.QuestionID, q.QuestionCode, q.QuestionText,
    q.OptionA, q.OptionB, q.OptionC, q.OptionD, q.CorrectAnswer,
    q.AudioPath, q.ImagePath,
    q.OptionA_Chinese, q.OptionB_Chinese, q.OptionC_Chinese, q.OptionD_Chinese,
    t.TopicID, t.TopicName
FROM Listening_Questions q
INNER JOIN Listening_Topics t ON q.TopicID = t.TopicID
WHERE q.TopicID IN ({ids})
ORDER BY NEWID();"; // ✅ NEWID() 保證隨機抽題

            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@Count", questionCount);

            SqlDataReader reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                results.Add(new
                {
                    QuestionID = (int)reader["QuestionID"],
                    QuestionCode = reader["QuestionCode"].ToString(),
                    QuestionText = reader["QuestionText"].ToString(),
                    OptionA = reader["OptionA"].ToString(),
                    OptionB = reader["OptionB"].ToString(),
                    OptionC = reader["OptionC"].ToString(),
                    OptionD = reader["OptionD"].ToString(),
                    CorrectAnswer = reader["CorrectAnswer"].ToString(),
                    AudioPath = reader["AudioPath"].ToString(),
                    ImagePath = reader["ImagePath"].ToString(),
                    OptionA_Chinese = reader["OptionA_Chinese"].ToString(),
                    OptionB_Chinese = reader["OptionB_Chinese"].ToString(),
                    OptionC_Chinese = reader["OptionC_Chinese"].ToString(),
                    OptionD_Chinese = reader["OptionD_Chinese"].ToString(),
                    TopicID = (int)reader["TopicID"],
                    TopicName = reader["TopicName"].ToString()
                });
            }
        }

        return results;
    }

    // =======================================================
    // ✅ 方法二：儲存錯題紀錄
    // =======================================================

    // 🚩 DTO（前端傳過來的 JSON 結構）
    public class WrongAnswerDTO
    {
        public int QuestionID { get; set; }       // 題目ID
        public string SelectedAnswer { get; set; } // 使用者選的答案
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object SaveWrongAnswers(List<WrongAnswerDTO> wrongList)
    {
        // 1️⃣ 確認是否登入
        if (HttpContext.Current.Session["UserID"] == null)
            return new { status = "NOT_LOGGED_IN" };

        // 2️⃣ 檢查是否有錯題
        if (wrongList == null || wrongList.Count == 0)
            return new { status = "NO_DATA" };

        int userId = Convert.ToInt32(HttpContext.Current.Session["UserID"]);

        // 🚩 產生一個 batchId，把同一次測驗的錯題分組
        string batchId = "BATCH_" + DateTime.Now.Ticks;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            foreach (var wrong in wrongList)
            {
                // 3️⃣ 把錯題存入 UserListeningMistakes
                // 🚩 同時 SELECT 出正解與 TopicID
                string query = @"
INSERT INTO UserListeningMistakes
(user_id, question_id, topic_id, selected_answer, correct_answer, created_at, batch_id)
SELECT @UserID, q.QuestionID, q.TopicID, @SelectedAnswer, q.CorrectAnswer, GETDATE(), @BatchID
FROM Listening_Questions q
WHERE q.QuestionID = @QuestionID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@QuestionID", wrong.QuestionID);
                    cmd.Parameters.AddWithValue("@SelectedAnswer", (object)wrong.SelectedAnswer ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@BatchID", batchId);

                    cmd.ExecuteNonQuery();
                }
            }
        }

        // 4️⃣ 回傳結果給前端
        return new { status = "OK", saved = wrongList.Count, batchId = batchId };
    }

    // =======================================================
    // ✅ 方法三：驗證以及比對後發放鑽石
    // =======================================================
    // 🚩 DTO：前端只送答對題數與總題數
    public class ListeningResultDTO
    {
        public int CorrectCount { get; set; }
        public int TotalCount { get; set; }
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object SaveListeningResult(ListeningResultDTO result)
    {
        if (HttpContext.Current.Session["UserID"] == null)
            return new { status = "NOT_LOGGED_IN" };

        int userId = (int)HttpContext.Current.Session["UserID"];

        // 🔒 後端決定：1 題 = 1 鑽石
        int diamondsToAward = result.CorrectCount;
        double accuracy = (result.TotalCount > 0)
            ? (result.CorrectCount * 100.0 / result.TotalCount)
            : 0;

        int finalDiamonds = 0, finalListeningDiamonds = 0, finalTotalDiamonds = 0;

        using (SqlConnection conn = new SqlConnection(
            ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString))
        {
            conn.Open();

            // 產生一個唯一 batchId，避免重複發獎
            string batchId = "LISTENING-" + Guid.NewGuid().ToString();

            using (SqlTransaction tran = conn.BeginTransaction())
            {
                try
                {
                    // 1️⃣ 查詢目前資源
                    string getSql = @"
                    SELECT diamonds, diamonds_listening_test, diamonds_total, last_awarded_batch_id
                    FROM UserResources
                    WHERE user_id = @UserId";

                    int curDiamonds = 0, curListening = 0, curTotal = 0;
                    string lastBatch = null;

                    using (SqlCommand cmd = new SqlCommand(getSql, conn, tran))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                curDiamonds = dr.GetInt32(0);
                                curListening = dr.GetInt32(1);
                                curTotal = dr.GetInt32(2);
                                lastBatch = dr.IsDBNull(3) ? null : dr.GetString(3);
                            }
                        }
                    }

                    // 2️⃣ 發獎：檢查是否已經處理過相同批次（防重複）
                    if (lastBatch != batchId)
                    {
                        finalDiamonds = curDiamonds + diamondsToAward;
                        finalListeningDiamonds = curListening + diamondsToAward;
                        finalTotalDiamonds = curTotal + diamondsToAward;

                        string updateSql = @"
                        UPDATE UserResources
                        SET diamonds = @Diamonds,
                            diamonds_listening_test = @ListeningDiamonds,
                            diamonds_total = @TotalDiamonds,
                            last_awarded_batch_id = @BatchId
                        WHERE user_id = @UserId";

                        using (SqlCommand cmd = new SqlCommand(updateSql, conn, tran))
                        {
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            cmd.Parameters.AddWithValue("@Diamonds", finalDiamonds);
                            cmd.Parameters.AddWithValue("@ListeningDiamonds", finalListeningDiamonds);
                            cmd.Parameters.AddWithValue("@TotalDiamonds", finalTotalDiamonds);
                            cmd.Parameters.AddWithValue("@BatchId", batchId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        // ❗ 如果 batchId 重複，不重發
                        finalDiamonds = curDiamonds;
                        finalListeningDiamonds = curListening;
                        finalTotalDiamonds = curTotal;
                    }

                    tran.Commit();
                }
                catch (Exception ex)
                {
                    tran.Rollback();
                    return new { status = "ERROR", message = ex.Message };
                }
            }
        }

        return new
        {
            status = "OK",
            correct = result.CorrectCount,
            total = result.TotalCount,
            accuracy = accuracy,
            diamondsAwarded = diamondsToAward,
            newDiamonds = finalDiamonds,
            newListeningDiamonds = finalListeningDiamonds,
            newTotalDiamonds = finalTotalDiamonds
        };
    }

}
