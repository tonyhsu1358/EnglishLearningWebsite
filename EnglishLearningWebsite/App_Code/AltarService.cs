using System;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Data.SqlClient;
using System.Configuration;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[ScriptService] // ✅ 支援 JavaScript AJAX 呼叫
public class AltarService : WebService
{
    [WebMethod(EnableSession = true)]
    public object GetAltarStatus(int altarId)
    {
        try
        {
            // ✅ 1. 檢查是否登入（未登入則直接回傳錯誤）
            if (HttpContext.Current.Session["UserID"] == null)
            {
                return new { error = "NOT_LOGGED_IN" };
            }

            int userId = (int)HttpContext.Current.Session["UserID"];
            int learningStatus = 0;
            DateTime? nextReviewTime = null;

            // ✅ 2. 連接資料庫
            string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // ✅ 3. 查詢使用者在該祭壇的學習狀態與下一次複習時間
                string query = @"
                    SELECT learning_status, next_review_time
                    FROM user_altar_progress
                    WHERE user_id = @UserID AND altar_id = @AltarID";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@AltarID", altarId);

                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    // ✅ 4. 讀取學習狀態，若為 NULL 則設為 0
                    learningStatus = reader["learning_status"] != DBNull.Value
                        ? Convert.ToInt32(reader["learning_status"])
                        : 0;

                    // ✅ 5. 讀取下一次複習時間（可為 NULL）
                    if (reader["next_review_time"] != DBNull.Value)
                    {
                        nextReviewTime = Convert.ToDateTime(reader["next_review_time"]);
                    }
                }
            }

            // ✅ 6. 回傳 JSON 物件給前端
            return new
            {
                learningStatus,
                nextReviewTime = nextReviewTime?.ToString("yyyy-MM-dd HH:mm:ss")
            };
        }
        catch (Exception ex)
        {
            // ✅ 7. 錯誤處理（避免 API Crash）
            return new { error = "INTERNAL_ERROR", message = ex.Message };
        }
    }
}
