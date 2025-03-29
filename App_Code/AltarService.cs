using System;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Data.SqlClient;
using System.Configuration;

/// <summary>
/// AltarService 的摘要描述
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[ScriptService] // ✅ 表示這個 WebService 支援 JavaScript AJAX 呼叫（可被前端呼叫）
public class AltarService : WebService
{
    [WebMethod(EnableSession = true)] // ✅ 開啟 Session 功能，讓我們能透過 Session["UserID"] 取登入狀態
    public object GetAltarStatus(int altarId) // ✅ 接收祭壇 ID，查詢對應的學習狀態與下次複習時間
    {
        try
        {
            // ✅ 1. 檢查是否登入，沒登入就回傳錯誤訊息（避免有人未登入直接呼叫此 API）
            if (HttpContext.Current.Session["UserID"] == null)
            {
                return new { error = "NOT_LOGGED_IN" };
            }

            // ✅ 2. 取得目前登入使用者的 ID
            int userId = (int)HttpContext.Current.Session["UserID"];

            // ✅ 3. 宣告要回傳的欄位：學習狀態與下次複習時間
            int learningStatus = 0;
            DateTime? nextReviewTime = null;

            // ✅ 4. 取得連線字串（來自 Web.config 中的 <connectionStrings> 設定）
            string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

            // ✅ 5. 建立與資料庫的連線並執行 SQL 查詢
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // ✅ 查詢使用者在某個祭壇的進度記錄
                string query = @"
                SELECT learning_status, next_review_time
                FROM user_altar_progress
                WHERE user_id = @UserID AND altar_id = @AltarID";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@AltarID", altarId);

                // ✅ 6. 讀取結果資料
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    // ✅ 有資料的話，抓出 learning_status
                    learningStatus = reader["learning_status"] != DBNull.Value
                        ? Convert.ToInt32(reader["learning_status"])
                        : 0;

                    // ✅ 抓出 next_review_time（可能為 NULL，要先檢查）
                    if (reader["next_review_time"] != DBNull.Value)
                    {
                        nextReviewTime = Convert.ToDateTime(reader["next_review_time"]);
                    }
                }
            }

            // ✅ 7. 成功查詢 → 回傳物件（會自動序列化成 JSON 回給 JS 前端）
            return new
            {
                learningStatus,
                nextReviewTime = nextReviewTime?.ToString("yyyy-MM-dd HH:mm:ss") // ⚠ 注意轉成字串格式，JS 比較好解析
            };
        }
        catch (Exception ex)
        {
            // ✅ 8. 發生例外時回傳錯誤（方便前端偵錯用）
            return new { error = "INTERNAL_ERROR", message = ex.Message };
        }
    }
}
