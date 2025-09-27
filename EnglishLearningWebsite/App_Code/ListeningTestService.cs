using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[ScriptService] // ✅ 允許 AJAX 呼叫
public class ListeningTestService : WebService
{
    private string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

    // ✅ 取得題目（依用戶選擇的主題 & 題數）
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public List<object> GetQuestions(List<int> topicIds, int questionCount)
    {
        var results = new List<object>();

        // 1️⃣ 檢查是否登入
        if (HttpContext.Current.Session["UserID"] == null)
        {
            results.Add(new { error = "NOT_LOGGED_IN" });
            return results;
        }

        if (topicIds == null || topicIds.Count == 0 || questionCount <= 0)
        {
            results.Add(new { error = "INVALID_PARAM" });
            return results;
        }

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // 2️⃣ 拼接 TopicID 條件
            string ids = string.Join(",", topicIds);

            // 3️⃣ SQL 抽題 (隨機題數)
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
ORDER BY NEWID();"; // ✅ NEWID() 保證隨機

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
}
