using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[ScriptService]
public class FirstLearningService : WebService
{
    [WebMethod(EnableSession = true)]
    public object GetFirstLearningWords(int altarId)
    {
        if (HttpContext.Current.Session["UserID"] == null)
            return new { error = "NOT_LOGGED_IN" };

        string connStr = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;
        var results = new List<object>();

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            // 抓出該祭壇下所有單字（不重複單字，詞性優先1最前）
            string wordListQuery = @"
            SELECT word
            FROM ancient_scrolls
            WHERE altar_id = @AltarID
            GROUP BY word
            ORDER BY MIN(priority_level) ASC, MIN(scroll_id) ASC";
            SqlCommand wordListCmd = new SqlCommand(wordListQuery, conn);
            wordListCmd.Parameters.AddWithValue("@AltarID", altarId);

            var wordList = new List<string>();
            using (var reader = wordListCmd.ExecuteReader())
                while (reader.Read()) wordList.Add(reader["word"].ToString());

            // 取出每個單字下所有詞性，依 priority_level ASC
            foreach (var word in wordList)
            {
                string detailQuery = @"
                SELECT 
                    s.scroll_id, s.pronunciation, s.part_of_speech, s.meaning,
                    s.example_sentence, s.example_translation, s.past_tense, s.past_participle,
                    s.word_audio_url, s.synonym_words, s.antonym_words, s.related_info,
                    s.priority_level,
                    CASE WHEN f.user_id IS NOT NULL THEN 1 ELSE 0 END AS is_favorite,
                    mf.forest_name_zh + N' 祭壇' + CAST(ma.altar_id AS NVARCHAR) AS location_text
                FROM ancient_scrolls s
                LEFT JOIN user_favorite_words f ON s.scroll_id = f.scroll_id AND f.user_id = @UserID
                JOIN magic_altar ma ON s.altar_id = ma.altar_id
                JOIN magic_forest mf ON ma.forest_id = mf.forest_id
                WHERE s.altar_id = @AltarID AND s.word = @Word
                ORDER BY s.priority_level ASC";
                SqlCommand detailCmd = new SqlCommand(detailQuery, conn);
                detailCmd.Parameters.AddWithValue("@UserID", (int)HttpContext.Current.Session["UserID"]);
                detailCmd.Parameters.AddWithValue("@AltarID", altarId);
                detailCmd.Parameters.AddWithValue("@Word", word);

                var posList = new List<object>();
                string locationText = "";
                using (var dr = detailCmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        posList.Add(new
                        {
                            scroll_id = (int)dr["scroll_id"],
                            pronunciation = dr["pronunciation"]?.ToString(),
                            part_of_speech = dr["part_of_speech"]?.ToString(),
                            meaning = dr["meaning"]?.ToString(),
                            example_sentence = dr["example_sentence"]?.ToString(),
                            example_translation = dr["example_translation"]?.ToString(),
                            past_tense = dr["past_tense"]?.ToString(),
                            past_participle = dr["past_participle"]?.ToString(),
                            word_audio_url = dr["word_audio_url"]?.ToString(),
                            synonym_words = dr["synonym_words"]?.ToString(),
                            antonym_words = dr["antonym_words"]?.ToString(),
                            related_info = dr["related_info"]?.ToString(),
                            priority_level = (int)dr["priority_level"],
                            is_favorite = Convert.ToBoolean(dr["is_favorite"])
                        });
                        locationText = dr["location_text"]?.ToString();
                    }
                }
                if (posList.Count > 0)
                    results.Add(new
                    {
                        word = word,
                        location_text = locationText,
                        positions = posList
                    });
            }
        }

        // Fisher-Yates 洗牌（如須亂序）
        var rng = new Random();
        int n = results.Count;
        while (n > 1)
        {
            n--;
            int k = rng.Next(n + 1);
            var value = results[k];
            results[k] = results[n];
            results[n] = value;
        }
        return results;
    }
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object ResetFirstLearningBatchID(int altar_id)
    {
        if (HttpContext.Current.Session["UserID"] == null)
            return new { status = "NOT_LOGGED_IN" };

        string newBatchId = Guid.NewGuid().ToString();
        HttpContext.Current.Session["FirstLearningBatchID"] = newBatchId;

        System.Diagnostics.Debug.WriteLine($"[DEBUG] ResetFirstLearningBatchID: UserID={HttpContext.Current.Session["UserID"]}, NewBatchID={newBatchId}, AltarID={altar_id}");

        return new { status = "OK", batch_id = newBatchId };
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object SaveFirstLearningResult(int altar_id, int correct_count, int wrong_count, double accuracy, int diamonds, int hours)
    {
        if (HttpContext.Current.Session["UserID"] == null)
            return new { status = "NOT_LOGGED_IN" };

        int userId = (int)HttpContext.Current.Session["UserID"];
        string batchID = HttpContext.Current.Session["FirstLearningBatchID"]?.ToString();

        System.Diagnostics.Debug.WriteLine($"[DEBUG] SaveFirstLearningResult: START - UserID={userId}, BatchID={batchID}, AltarID={altar_id}");

        if (string.IsNullOrEmpty(batchID))
        {
            batchID = Guid.NewGuid().ToString();
            HttpContext.Current.Session["FirstLearningBatchID"] = batchID;
            System.Diagnostics.Debug.WriteLine($"[DEBUG] SaveFirstLearningResult: BatchID 是 NULL，自動生成新 BatchID={batchID}");
        }

        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString))
        {
            conn.Open();

            // 讀取使用者資源
            string getUserResSql = @"
        SELECT COALESCE(diamonds, 0), 
               COALESCE(diamonds_vocabulary_game, 0), 
               COALESCE(diamonds_total, 0), 
               last_awarded_batch_id
        FROM UserResources
        WHERE user_id = @UserId";

            int curDiamonds = 0, curVocabDiamonds = 0, curTotalDiamonds = 0;
            string lastBatchId = null;

            using (SqlCommand cmd = new SqlCommand(getUserResSql, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        curDiamonds = dr.GetInt32(0);
                        curVocabDiamonds = dr.GetInt32(1);
                        curTotalDiamonds = dr.GetInt32(2);

                        // ★ 修正：用 GetString() 而不是 GetGuid()
                        lastBatchId = dr.IsDBNull(3) ? null : dr.GetString(3);
                    }
                }
            }

            System.Diagnostics.Debug.WriteLine($"[DEBUG] 當前鑽石={curDiamonds}, 上次 BatchID={lastBatchId}");

            // 檢查是否已領過
            if (lastBatchId == batchID)
            {
                System.Diagnostics.Debug.WriteLine("[DEBUG] ALREADY_CLAIMED - 批次相同，跳過更新");
                return new { status = "ALREADY_CLAIMED" };
            }

            // 計算新數值
            int newDiamonds = curDiamonds + diamonds;
            int newVocabDiamonds = curVocabDiamonds + diamonds;
            int newTotalDiamonds = curTotalDiamonds + diamonds;

            // 更新 UserResources
            string updateSql = @"
        UPDATE UserResources
        SET diamonds = @NewDiamonds,
            diamonds_vocabulary_game = @NewVocabDiamonds,
            diamonds_total = @NewTotalDiamonds,
            last_awarded_batch_id = @BatchId
        WHERE user_id = @UserId";

            using (SqlCommand cmd = new SqlCommand(updateSql, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@NewDiamonds", newDiamonds);
                cmd.Parameters.AddWithValue("@NewVocabDiamonds", newVocabDiamonds);
                cmd.Parameters.AddWithValue("@NewTotalDiamonds", newTotalDiamonds);

                // ★ 修正：直接傳字串，不用 Guid.Parse()
                cmd.Parameters.AddWithValue("@BatchId", batchID);

                int rows = cmd.ExecuteNonQuery();
                System.Diagnostics.Debug.WriteLine($"[DEBUG] UserResources 更新完成，影響 {rows} 筆資料");
            }
        }

        System.Diagnostics.Debug.WriteLine("[DEBUG] SaveFirstLearningResult: END ✅ 更新完成");
        return new { status = "OK" };
    }

}
