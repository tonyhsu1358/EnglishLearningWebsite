using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.Script.Services;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[ScriptService] // ✅ 允許 AJAX 呼叫
public class DiamondStoreService : WebService
{
    private readonly string connectionString = ConfigurationManager.ConnectionStrings["EnglishLearningDB"].ConnectionString;

    // ✅ 實際 Session 驗證
    private bool IsUserLoggedIn()
    {
        return HttpContext.Current != null &&
               HttpContext.Current.Session != null &&
               HttpContext.Current.Session["UserID"] != null;
    }

    // ✅ 撈出所有上架商品與規格
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string GetActiveProducts()
    {
        var serializer = new JavaScriptSerializer();

        if (!IsUserLoggedIn())
        {
            return serializer.Serialize(new { success = false, message = "使用者尚未登入。" });
        }

        int userId = (int)HttpContext.Current.Session["UserID"]; // ✅ 實際取得使用者 ID
        var productList = new List<object>();

        try
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                string query = @"
                    SELECT 
                        p.product_id,
                        p.product_name,
                        p.product_description,
                        p.main_image,
                        v.variant_id,
                        v.spec_name,
                        v.price,
                        v.spec_image,
                        v.stock
                    FROM ShopProducts AS p
                    INNER JOIN ShopProductVariants AS v
                        ON p.product_id = v.product_id
                    WHERE p.is_active = 1 AND v.is_active = 1
                    ORDER BY p.product_id, v.variant_id;";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        productList.Add(new
                        {
                            product_id = Convert.ToInt32(r["product_id"]),
                            name = r["product_name"].ToString(),
                            description = r["product_description"].ToString(),
                            main_image = r["main_image"].ToString(),
                            variant_id = Convert.ToInt32(r["variant_id"]),
                            spec_name = r["spec_name"].ToString(),
                            price = Convert.ToInt32(r["price"]),
                            spec_image = r["spec_image"].ToString(),
                            stock = Convert.ToInt32(r["stock"])
                        });
                    }
                }
            }

            return serializer.Serialize(new { success = true, userId = userId, data = productList });
        }
        catch (Exception ex)
        {
            return serializer.Serialize(new { success = false, message = "伺服器發生錯誤：" + ex.Message });
        }
    }
}
