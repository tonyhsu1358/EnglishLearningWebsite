using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[System.Web.Script.Services.ScriptService] // ✅ 允許前端 AJAX 呼叫此 WebMethod
public class ScrollService : System.Web.Services.WebService
{
    public ScrollService() { }

    // ✅ 取得指定祭壇的單字列表（簡略版，適用捲軸列表 UI）
    [WebMethod(EnableSession = true)]
    public List<object> GetScrollWords(int altarId)
    {
        var results = new List<object>();

        // ⛔ 若未登入，直接回傳空陣列
        if (HttpContext.Current.Session["UserID"] == null)
            return results;

        int userId = (int)HttpContext.Current.Session["UserID"];
        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            string query = @"
    WITH FirstMeaning AS (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY word ORDER BY scroll_id) AS rn
        FROM ancient_scrolls
        WHERE altar_id = @AltarID
    )
    SELECT 
        fm.scroll_id,
        fm.word,
        fm.part_of_speech,
        fm.meaning,
        fm.word_audio_url,
        CASE 
            WHEN f.user_id IS NOT NULL THEN 1 ELSE 0 
        END AS is_favorite
    FROM FirstMeaning fm
    LEFT JOIN user_favorite_words f
        ON fm.scroll_id = f.scroll_id AND f.user_id = @UserID
    WHERE fm.rn = 1
    ORDER BY fm.word";

            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@UserID", userId);
            cmd.Parameters.AddWithValue("@AltarID", altarId);

            SqlDataReader reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                results.Add(new
                {
                    scroll_id = (int)reader["scroll_id"],
                    word = reader["word"].ToString(),
                    part_of_speech = reader["part_of_speech"].ToString(),
                    meaning = reader["meaning"].ToString(),
                    word_audio_url = reader["word_audio_url"]?.ToString(),
                    is_favorite = Convert.ToBoolean(reader["is_favorite"])
                });
            }
        }

        return results;
    }

    // ✅ 取得單字詳細資訊（點選單字後才查詢）
    [WebMethod(EnableSession = true)]
    public object GetWordDetail(int scrollId)
    {
        if (HttpContext.Current.Session["UserID"] == null)
            return new { error = "NOT_LOGGED_IN" };

        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            string query = @"
    SELECT 
        s.scroll_id,
        s.word,
        s.pronunciation,
        s.part_of_speech,
        s.meaning,
        s.example_sentence,
        s.example_translation,
        s.past_tense,
        s.past_participle,
        s.word_audio_url,
        mf.forest_name_zh + N' ' + N'地塊' + CAST(ma.altar_id AS NVARCHAR) AS location_text
    FROM ancient_scrolls s
    INNER JOIN magic_altar ma ON s.altar_id = ma.altar_id
    INNER JOIN magic_forest mf ON ma.forest_id = mf.forest_id
    WHERE s.scroll_id = @ScrollID";

            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@ScrollID", scrollId);
            SqlDataReader reader = cmd.ExecuteReader();

            if (reader.Read())
            {
                return new
                {
                    scroll_id = (int)reader["scroll_id"],
                    word = reader["word"].ToString(),
                    pronunciation = reader["pronunciation"].ToString(),
                    part_of_speech = reader["part_of_speech"].ToString(),
                    meaning = reader["meaning"].ToString(),
                    example_sentence = reader["example_sentence"].ToString(),
                    example_translation = reader["example_translation"].ToString(),
                    past_tense = string.IsNullOrEmpty(reader["past_tense"].ToString()) ? "—" : reader["past_tense"].ToString(),
                    past_participle = string.IsNullOrEmpty(reader["past_participle"].ToString()) ? "—" : reader["past_participle"].ToString(),
                    word_audio_url = reader["word_audio_url"]?.ToString(),
                    location_text = reader["location_text"].ToString()
                };
            }
            else
            {
                return new { error = "NOT_FOUND" };
            }
        }
    }

    // ✅ 新增或移除收藏
    [WebMethod(EnableSession = true)]
    public string UpdateFavorite(int scrollId, bool isFavorite)
    {
        string userIdStr = HttpContext.Current.Session["UserID"]?.ToString();
        if (string.IsNullOrEmpty(userIdStr)) return "未登入";

        int userId = int.Parse(userIdStr);
        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmd;

            if (isFavorite)
            {
                // 加入收藏（避免重複）
                cmd = new SqlCommand(@"
                    IF NOT EXISTS (
                        SELECT 1 FROM user_favorite_words WHERE user_id = @UserID AND scroll_id = @ScrollID
                    )
                    BEGIN
                        INSERT INTO user_favorite_words (user_id, scroll_id)
                        VALUES (@UserID, @ScrollID)
                    END
                ", conn);
            }
            else
            {
                // 移除收藏
                cmd = new SqlCommand(@"
                    DELETE FROM user_favorite_words
                    WHERE user_id = @UserID AND scroll_id = @ScrollID
                ", conn);
            }

            cmd.Parameters.AddWithValue("@UserID", userId);
            cmd.Parameters.AddWithValue("@ScrollID", scrollId);
            cmd.ExecuteNonQuery();

            return isFavorite ? "已加入收藏" : "已取消收藏";
        }
    }
}
