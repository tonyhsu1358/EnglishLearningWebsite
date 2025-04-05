using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
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
SELECT 
    s.scroll_id,
    s.word,
    s.part_of_speech,
    s.meaning,
    s.word_audio_url,
    CASE 
        WHEN f.user_id IS NOT NULL THEN 1 ELSE 0 
    END AS is_favorite
FROM ancient_scrolls s
LEFT JOIN user_favorite_words f
    ON s.scroll_id = f.scroll_id AND f.user_id = @UserID
WHERE s.altar_id = @AltarID AND s.priority_level = 1
ORDER BY s.word ASC"; 


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
    public List<object> GetWordDetail(int scrollId)
    {
        if (HttpContext.Current.Session["UserID"] == null)
            return new List<object> { new { error = "NOT_LOGGED_IN" } };

        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;
        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();

            // 先取得該 scrollId 的 word 與 altar_id
            string baseQuery = "SELECT word, altar_id FROM ancient_scrolls WHERE scroll_id = @ScrollID";
            SqlCommand baseCmd = new SqlCommand(baseQuery, conn);
            baseCmd.Parameters.AddWithValue("@ScrollID", scrollId);
            SqlDataReader baseReader = baseCmd.ExecuteReader();

            if (!baseReader.Read())
                return new List<object> { new { error = "NOT_FOUND" } };

            string word = baseReader["word"].ToString();
            int altarId = (int)baseReader["altar_id"];
            baseReader.Close();

            // 查詢該單字在同個祭壇下的所有詞性資料，依 priority_level 升冪排序
            string detailQuery = @"
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
    s.synonym_words,
    s.antonym_words,
    s.related_info,
    mf.forest_name_zh + N' 祭壇' + CAST(ma.altar_id AS NVARCHAR) AS location_text
FROM ancient_scrolls s
JOIN magic_altar ma ON s.altar_id = ma.altar_id
JOIN magic_forest mf ON ma.forest_id = mf.forest_id
WHERE s.word = @Word AND s.altar_id = @AltarID
ORDER BY s.priority_level ASC";

            SqlCommand cmd = new SqlCommand(detailQuery, conn);
            cmd.Parameters.AddWithValue("@Word", word);
            cmd.Parameters.AddWithValue("@AltarID", altarId);

            var results = new List<object>();
            SqlDataReader reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                results.Add(new
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
                    synonym_words = reader["synonym_words"]?.ToString(),
                    antonym_words = reader["antonym_words"]?.ToString(),
                    related_info = reader["related_info"]?.ToString(),
                    location_text = reader["location_text"].ToString()
                });
            }

            return results;
        }
    }

    [WebMethod(EnableSession = true)]
    public List<object> GetAllScrollWordsByForest(int forestId)
    {
        var results = new List<object>();

        if (HttpContext.Current.Session["UserID"] == null)
            return results;

        int userId = (int)HttpContext.Current.Session["UserID"];
        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            string query = @"
SELECT 
    s.scroll_id,
    s.word,
    s.part_of_speech,
    s.meaning,
    s.word_audio_url,
    CASE 
        WHEN f.user_id IS NOT NULL THEN 1 ELSE 0 
    END AS is_favorite,
    mf.forest_name_zh + N' 祭壇' + CAST(ma.altar_id AS NVARCHAR) AS location_text
FROM ancient_scrolls s
JOIN magic_altar ma ON s.altar_id = ma.altar_id
JOIN magic_forest mf ON ma.forest_id = mf.forest_id
LEFT JOIN user_favorite_words f
    ON s.scroll_id = f.scroll_id AND f.user_id = @UserID
WHERE mf.forest_id = @ForestID AND s.priority_level = 1
ORDER BY ma.altar_id, s.word ASC";  // ✅ 按照祭壇與單字順序排列

            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@UserID", userId);
            cmd.Parameters.AddWithValue("@ForestID", forestId);

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
                    is_favorite = Convert.ToBoolean(reader["is_favorite"]),
                    location_text = reader["location_text"].ToString()
                });
            }
        }

        return results;
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
