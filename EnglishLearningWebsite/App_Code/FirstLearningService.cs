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

        // 生成新的 BatchID（鑽石 + 體力）
        string diamondBatchId = "FIRSTLEARN-" + Guid.NewGuid().ToString();
        string energyBatchId = "ENERGY-" + Guid.NewGuid().ToString();

        // 存到 Session（方便後端 debug）
        HttpContext.Current.Session["FirstLearningDiamondBatchID"] = diamondBatchId;
        HttpContext.Current.Session["FirstLearningEnergyBatchID"] = energyBatchId;

        System.Diagnostics.Debug.WriteLine($"[DEBUG] ResetFirstLearningBatchID: UserID={HttpContext.Current.Session["UserID"]}, DiamondBatchID={diamondBatchId}, EnergyBatchID={energyBatchId}, AltarID={altar_id}");

        return new { status = "OK", diamond_batch_id = diamondBatchId, energy_batch_id = energyBatchId };
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public object SaveFirstLearningResult(
   int altar_id,
   int correct_count,
   int wrong_count,
   double accuracy,
   int diamonds,
   int hours,
   string diamond_batch_id,
   string energy_batch_id)
    {
        if (HttpContext.Current.Session["UserID"] == null)
            return new { status = "NOT_LOGGED_IN" };

        int userId = (int)HttpContext.Current.Session["UserID"];

        // 🔹 宣告暫存變數（最後要回傳的值）
        int finalEnergy = 0;
        int finalDiamonds = 0;

        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString))
        {
            conn.Open();
            using (SqlTransaction tran = conn.BeginTransaction())
            {
                try
                {
                    // 1️.讀取現有資源
                    string getUserResSql = @"
                SELECT diamonds, diamonds_vocabulary_game, diamonds_total, 
                       last_awarded_batch_id, energy, last_energy_deduction_batch_id
                FROM UserResources
                WHERE user_id = @UserId";

                    int curDiamonds = 0, curVocabDiamonds = 0, curTotalDiamonds = 0, curEnergy = 0;
                    string lastDiamondBatch = null, lastEnergyBatch = null;

                    using (SqlCommand cmd = new SqlCommand(getUserResSql, conn, tran))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                curDiamonds = dr.GetInt32(0);
                                curVocabDiamonds = dr.GetInt32(1);
                                curTotalDiamonds = dr.GetInt32(2);
                                lastDiamondBatch = dr.IsDBNull(3) ? null : dr.GetString(3);
                                curEnergy = dr.GetInt32(4);
                                lastEnergyBatch = dr.IsDBNull(5) ? null : dr.GetString(5);
                            }
                        }
                    }

                    // 2️.發鑽石（避免重複發放，需檢查 batch_id）
                    if (lastDiamondBatch != diamond_batch_id)
                    {
                        finalDiamonds = curDiamonds + diamonds;   // ✅ 更新最終變數
                        int newVocabDiamonds = curVocabDiamonds + diamonds;
                        int newTotalDiamonds = curTotalDiamonds + diamonds;

                        string updateDiamondSql = @"
                    UPDATE UserResources
                    SET diamonds = @NewDiamonds,
                        diamonds_vocabulary_game = @NewVocabDiamonds,
                        diamonds_total = @NewTotalDiamonds,
                        last_awarded_batch_id = @BatchId
                    WHERE user_id = @UserId";
                        using (SqlCommand cmd = new SqlCommand(updateDiamondSql, conn, tran))
                        {
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            cmd.Parameters.AddWithValue("@NewDiamonds", finalDiamonds);
                            cmd.Parameters.AddWithValue("@NewVocabDiamonds", newVocabDiamonds);
                            cmd.Parameters.AddWithValue("@NewTotalDiamonds", newTotalDiamonds);
                            cmd.Parameters.AddWithValue("@BatchId", diamond_batch_id);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        // ❗ 若沒有發新鑽石，就維持原值
                        finalDiamonds = curDiamonds;
                    }

                    // 3️.扣體力（避免重複扣除，需檢查 batch_id）
                    if (lastEnergyBatch != energy_batch_id)
                    {
                        finalEnergy = curEnergy - 10;
                        if (finalEnergy < 0) finalEnergy = 0;

                        string updateEnergySql = @"
                    UPDATE UserResources
                    SET energy = @NewEnergy,
                        last_energy_deduction_batch_id = @BatchId
                    WHERE user_id = @UserId";
                        using (SqlCommand cmd = new SqlCommand(updateEnergySql, conn, tran))
                        {
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            cmd.Parameters.AddWithValue("@NewEnergy", finalEnergy);
                            cmd.Parameters.AddWithValue("@BatchId", energy_batch_id);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        // ❗ 若沒有扣能量，就維持原值
                        finalEnergy = curEnergy;
                    }

                    // 4️.更新使用者祭壇進度（首次學習 → learning_status=1，並設定複習時間）
                    string updateProgressSql = @"
                IF EXISTS (SELECT 1 FROM user_altar_progress WHERE user_id = @UserId AND altar_id = @AltarId)
                BEGIN
                    UPDATE user_altar_progress
                    SET learning_status = CASE 
                                             WHEN learning_status = 0 THEN 1 
                                             ELSE learning_status 
                                         END,
                        last_review_time = GETDATE(),
                        next_review_time = DATEADD(HOUR, @Hours, GETDATE())
                    WHERE user_id = @UserId AND altar_id = @AltarId;
                END
                ELSE
                BEGIN
                    INSERT INTO user_altar_progress (user_id, altar_id, learning_status, last_review_time, next_review_time)
                    VALUES (@UserId, @AltarId, 1, GETDATE(), DATEADD(HOUR, @Hours, GETDATE()));
                END";

                    using (SqlCommand cmd = new SqlCommand(updateProgressSql, conn, tran))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.Parameters.AddWithValue("@AltarId", altar_id);
                        cmd.Parameters.AddWithValue("@Hours", hours);
                        cmd.ExecuteNonQuery();
                    }

                    // ✅ 所有 SQL 都成功，最後才 Commit 一次
                    tran.Commit();
                }
                catch (Exception ex)
                {
                    // ❌ 發生錯誤 → Rollback
                    tran.Rollback();
                    System.Diagnostics.Debug.WriteLine("❌ [ERROR] SaveFirstLearningResult 發生錯誤: " + ex.Message);
                    return new { status = "ERROR", message = ex.Message };
                }
            }
        }

        // 🔥 回傳最新能量、鑽石，以及該祭壇的最新狀態
        return new
        {
            status = "OK",
            newEnergy = finalEnergy,
            newDiamonds = finalDiamonds,
            altarId = altar_id,
            newStatus = 1 // 首次學習完成 → 狀態至少會是 1
        };
    }

}
