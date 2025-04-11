using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class About : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
    }

    protected void btnHome_Click(object sender, EventArgs e)
    {
        // ✅ 讓使用者導向首頁
        Response.Redirect("HomePage.aspx");
    }
}
