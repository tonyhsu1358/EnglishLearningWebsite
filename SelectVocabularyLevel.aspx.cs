using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class SelectVocabularyLevel : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 防止未登入用戶進入
        if (Session["UserEmail"] == null)
        {
            Response.Redirect("UserLogin.aspx?returnUrl=SelectVocabularyLevel.aspx");
        }
    }

    // 🔹 點擊 LEVEL 按鈕時，後端處理
    protected void btnLevel_Click(object sender, EventArgs e)
    {
        Button clickedButton = sender as Button;
        if (clickedButton != null)
        {
            string level = clickedButton.CommandArgument;
            Response.Redirect($"VocabularyGame.aspx?level={level}");
        }
    }

    // 🔹 回首頁按鈕
    protected void btnHome_Click(object sender, EventArgs e)
    {
        Response.Redirect("HomePage.aspx");
    }
}
